/*************************************************************************
 * This file is part of MeeRadio for Nokia N9.
 * Copyright (C) 2012 Stanislav Ionascu <stanislav.ionascu@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 ***************************************************************************/

#include "playlistreader.h"
#include "playlistreader_p.h"

#include "cachereader.h"

#include <QFile>
#include <QDir>
#include <QXmlStreamReader>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDebug>

namespace {
    typedef QHash<PlaylistReader::Format, QStringList> FormatContentTypes;
    Q_GLOBAL_STATIC(FormatContentTypes, SupportedContentTypes)
}

PlaylistReaderPrivate::PlaylistReaderPrivate() :
    networkAccessManager(new QNetworkAccessManager),
    pendingRequests(0),
    cached(false)
{
    if (SupportedContentTypes()->count() == 0) {
        // Fill
        // PLS Content Types
        QStringList pls;
        pls << "pls+xml" << "x-scpls";
        SupportedContentTypes()->insert(PlaylistReader::PLS, pls);

        // M3U Content Types
        QStringList m3u;
        m3u << "x-mpegurl";
        SupportedContentTypes()->insert(PlaylistReader::M3U, m3u);

        // ASX Content Types
        QStringList asx;
        asx << "x-ms-asf";
        SupportedContentTypes()->insert(PlaylistReader::ASX, asx);
    }
}

PlaylistReaderPrivate::~PlaylistReaderPrivate()
{
    delete networkAccessManager;
}

void PlaylistReaderPrivate::init()
{
    Q_Q(PlaylistReader);

    networkAccessManager->disconnect(q);

    networkAccessManager->connect(networkAccessManager, SIGNAL(finished(QNetworkReply*)), q, SLOT(_q_networkReplyReady(QNetworkReply*)));
}

bool PlaylistReaderPrivate::isFormat(const QString &contentType, PlaylistReader::Format format)
{
    foreach (QString type, SupportedContentTypes()->value(format)) {
        if (contentType.endsWith(type, Qt::CaseInsensitive))
            return true;
    }
    return false;
}

bool PlaylistReaderPrivate::loadFromLocal(const QUrl &url)
{
    QFile file(url.toLocalFile());
    file.open(QFile::ReadOnly);
    if (url.path().toLower().endsWith(".m3u"))
        urls = parseM3U(&file);
    else if (url.path().toLower().endsWith(".pls"))
        urls = parsePLS(&file);
    else if (url.path().toLower().endsWith(".asx"))
        urls = parseASX(&file);
    else
        return false;

    return true;
}

void PlaylistReaderPrivate::loadFromRemote(const QUrl &url)
{
    Q_Q(PlaylistReader);
    qDebug() << "Load from Remote:" << url;
    if (url.scheme().compare("mms", Qt::CaseInsensitive) == 0) {
        urls << url.toString();
        qDebug() << "MMS Stream detected...";
        emit q->loaded();
    } else {
        //this fix allows listening direct streaming (not using playlist)
        //ex. http://mp3.streampower.be/radio1-low.mp3
        //first do head to check content type
        queuedReply = networkAccessManager->head(QNetworkRequest(url));
    }
}

QStringList PlaylistReaderPrivate::parseASX(QIODevice *device)
{
    QStringList result;
    QXmlStreamReader xml(device);
    while (!xml.atEnd()) {
        xml.readNext();
        if (xml.name().compare("ref", Qt::CaseInsensitive) == 0 && xml.tokenType() == QXmlStreamReader::StartElement) {
            foreach (QXmlStreamAttribute attribute, xml.attributes()) {
                if (attribute.name().compare("href", Qt::CaseInsensitive) == 0) {
                    result << attribute.value().toString();
                }
            }
        }
    }
    return result;
}

QStringList PlaylistReaderPrivate::parseM3U(QIODevice *device)
{
    QStringList result;
    QList<QByteArray> data = device->readAll().split('\n');
    foreach (QByteArray line, data) {
        line = line.trimmed();
        if (!line.startsWith('#') && !line.isEmpty())
            result << line;
    }
    return result;
}

QStringList PlaylistReaderPrivate::parsePLS(QIODevice *device)
{
    QStringList result;
    QList<QByteArray> data = device->readAll().split('\n');
    foreach (QByteArray line, data) {
        if (line.contains('=')) {
            QList<QByteArray> entry = line.split('=');
            if (entry[0].toLower().trimmed().startsWith("file") && entry.count() == 2 && !entry[1].trimmed().isEmpty())
                result << entry[1].trimmed();
        }
    }
    return result;
}

void PlaylistReaderPrivate::_q_networkReplyReady(QNetworkReply *reply)
{
    Q_Q(PlaylistReader);
    if (reply != queuedReply.data()) {
        qWarning() << "Got unqueued reply! Discading!";
        return;
    }

    QString contentType = reply->header(QNetworkRequest::ContentTypeHeader).toString();
    bool isASX = reply->url().path().endsWith(".asx", Qt::CaseInsensitive);
    bool isM3U = reply->url().path().endsWith(".m3u", Qt::CaseInsensitive);
    bool isPLS = reply->url().path().endsWith(".pls", Qt::CaseInsensitive);
    qDebug() << "Content-Type:" << contentType;

    if (reply->operation() == QNetworkAccessManager::HeadOperation) {
        qWarning() << "Processing head!";
        //trying to figure is content type a play list
        if (isFormat(contentType, PlaylistReader::ASX) || isASX ||
            isFormat(contentType, PlaylistReader::PLS) || isPLS ||
            isFormat(contentType, PlaylistReader::M3U) || isM3U) {
            //this is playlist, do get
            queuedReply = networkAccessManager->get(QNetworkRequest(reply->url()));
            ++pendingRequests;
            reply->deleteLater();
            qDebug() << "Play List detected...";
            return;
        } else {
            //it's not playlist, assume direct streaming
            urls << reply->url().toString();
            qDebug() << "Assuming Direct Stream detected...";
            emit q->loaded();
            reply->deleteLater();
            return;
        }
    }

    if (reply->error() == QNetworkReply::NoError) {
        if (isFormat(contentType, PlaylistReader::ASX) || isASX) {
            if (isASX) {
                QStringList streams = parseASX(reply);
                foreach (QUrl url, streams) {
                    bool isRemote = (url.scheme().compare("http", Qt::CaseInsensitive) || url.scheme().compare("https", Qt::CaseInsensitive));
                    if (isRemote && url.path().endsWith(".asx", Qt::CaseInsensitive))
                        loadFromRemote(url);
                    else {
                        urls << url.toString();
                    }
                }
            } else {
                urls << reply->url().toString();
            }
        }

        if (isFormat(contentType, PlaylistReader::M3U) || isM3U) {
            QStringList streams = parseM3U(reply);
            foreach (QUrl url, streams) {
                bool isRemote = (url.scheme().compare("http", Qt::CaseInsensitive) || url.scheme().compare("https", Qt::CaseInsensitive));
                if (isRemote && url.path().endsWith(".m3u", Qt::CaseInsensitive))
                    loadFromRemote(url);
                else {
                    urls << url.toString();
                }
            }
        }

        if (isFormat(contentType, PlaylistReader::PLS) || isPLS) {
            QStringList streams = parsePLS(reply);
            foreach (QUrl url, streams) {
                bool isRemote = (url.scheme().compare("http", Qt::CaseInsensitive) || url.scheme().compare("https", Qt::CaseInsensitive));
                if (isRemote && url.path().endsWith(".pls", Qt::CaseInsensitive))
                    loadFromRemote(url);
                else {
                    urls << url.toString();
                }
            }
        }

        if (urls.isEmpty() && contentType.startsWith("audio", Qt::CaseInsensitive)) {
            urls << reply->url().toString();
        }
    } else {
        emit q->error(reply->errorString());
    }
    reply->deleteLater();
    --pendingRequests;

    if (pendingRequests == 0)
        emit q->loaded();
}

QString PlaylistReaderPrivate::cacheFileName(int cacheId)
{
    return "playlist_" + QString::number(cacheId) + ".m3u";
}

QString PlaylistReaderPrivate::cacheFilePath(int cacheId)
{
    return CacheReader::instance()->cacheFolder() + QDir::separator() + cacheFileName(cacheId);
}

void PlaylistReaderPrivate::abortPendingRequest()
{
    if (!queuedReply.isNull()) {
        qDebug() << "Aborting pending request to " << queuedReply.data()->url();
        queuedReply.data()->abort();
        queuedReply.data()->deleteLater();
    }
}

PlaylistReader::PlaylistReader(QObject *parent) :
    QObject(parent),
    d_ptr(new PlaylistReaderPrivate)
{
    d_ptr->q_ptr = this;
    d_ptr->init();
}

PlaylistReader::~PlaylistReader()
{
    delete d_ptr;
}

void PlaylistReader::load(const QUrl &url)
{
    Q_D(PlaylistReader);
    d->cached = false;
    d->urls.clear();
    d->abortPendingRequest();
    if (url.isEmpty())
        return;

    if (url.scheme().compare("file", Qt::CaseInsensitive) == 0) {
        if (d->loadFromLocal(url))
            emit loaded();
        else
            emit error(qtTrId("Unsupported playlist format."));
    } else {
        d->loadFromRemote(url);
    }
}

bool PlaylistReader::loadFromCache(int cacheId)
{
    Q_D(PlaylistReader);
    d->cached = false;
    d->urls.clear();
    d->abortPendingRequest();
    if (cacheId <= 0)
        return false;

    QString fileName = d->cacheFilePath(cacheId);
    qDebug() << "Loading playlist from cache: " << fileName;
    if (QFile::exists(fileName) && d->loadFromLocal(QUrl::fromLocalFile(fileName))) {
        d->cached = true;
        emit loaded();
        return true;
    }
    return false;
}

void PlaylistReader::saveToCache(int cacheId)
{
    Q_D(PlaylistReader);
    if (cacheId <= 0 || d->cached)
        return;

    QString cacheData = QString();
    foreach (QString url, d->urls) {
        cacheData += url + "\n";
    }

    QString fileName = d->cacheFileName(cacheId);
    CacheReader::instance()->writeCache(fileName, cacheData);
}

void PlaylistReader::removeCache(int cacheId)
{
    Q_D(PlaylistReader);
    QString fileName = d->cacheFilePath(cacheId);
    if (QFile::exists(fileName))
        QFile::remove(fileName);
}

const QStringList &PlaylistReader::entries() const {
    Q_D(const PlaylistReader);
    return d->urls;
}

#include "moc_playlistreader.cpp"
