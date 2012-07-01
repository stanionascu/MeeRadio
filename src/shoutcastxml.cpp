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

#include "shoutcastxml.h"
#include "shoutcastxml_p.h"

#include "cachereader.h"

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QDateTime>
#include <QDesktopServices>
#include <QDir>
#include <QXmlStreamReader>
#include <QDebug>

#define SHOUTCAST_SERVER "http://yp.shoutcast.com"
#define SHOUTCAST_API_SERVER "http://yp.shoutcast.com/sbin/newxml.phtml"

SHOUTcastXMLPrivate::SHOUTcastXMLPrivate()
    : q_ptr(0),
      networkManager(0),
      queuedReply(0)
{
    genreStationsXMLHash.insert("", "");
}

SHOUTcastXMLPrivate::~SHOUTcastXMLPrivate()
{
}

void SHOUTcastXMLPrivate::init()
{
    networkManager = new QNetworkAccessManager;
}

void SHOUTcastXMLPrivate::clearCache()
{
    qDebug() << "Clearing cache.";
    QDir dir(CacheReader::instance()->cacheFolder());
    QStringList entryFilters;
    entryFilters << "SHOUTCAST_*.xml";
    QStringList cacheFilesList = dir.entryList(entryFilters);
    foreach (QString cacheFile, cacheFilesList)
        dir.remove(cacheFile);
}

int SHOUTcastXMLPrivate::parseXML(const QString &stringXMLData)
{
    int result = 0;
    if (stringXMLData.isEmpty())
        return -1;
    QXmlStreamReader xmlDoc(stringXMLData);
    while (!xmlDoc.hasError() && !xmlDoc.atEnd()) {
        QXmlStreamReader::TokenType token = xmlDoc.readNext();
        if (token == QXmlStreamReader::StartDocument)
            continue;
        if (token == QXmlStreamReader::StartElement) {
            if (xmlDoc.name().compare("tunein", Qt::CaseInsensitive) == 0)
                setTuneInURL(QString(SHOUTCAST_SERVER) + xmlDoc.attributes().value("base").toString());
            else if (xmlDoc.name().compare("statusCode", Qt::CaseInsensitive) == 0)
                result = QString(xmlDoc.readElementText()).toInt();
        }
    }
    return result;
}

QString SHOUTcastXMLPrivate::genresCacheFile()
{
    return "SHOUTCAST_Genres" + QDateTime::currentDateTime().toString("yyyyMMdd") + ".xml";
}

QString SHOUTcastXMLPrivate::stationsCacheFile(const QString &genre)
{
    QString sanitizedGenre = genre;
    sanitizedGenre = sanitizedGenre.replace(' ', '_').replace('.','_').replace('/', '_').replace('\\', '_').toLatin1();
    return  "SHOUTCAST_Stations_" + sanitizedGenre + QDateTime::currentDateTime().toString("yyyyMMdd") + ".xml";
}

bool SHOUTcastXMLPrivate::loadGenresFromCache()
{
    QString xml = CacheReader::instance()->readCache(genresCacheFile());
    if (parseXML(xml) == 0) {
        genresXML = xml;
        return true;
    }
    return false;
}

void SHOUTcastXMLPrivate::saveGenresToCache()
{
    CacheReader::instance()->writeCache(genresCacheFile(), genresXML);
}

bool SHOUTcastXMLPrivate::loadStationsByGenreFromCache(const QString &genre)
{
    QString xml = CacheReader::instance()->readCache(stationsCacheFile(genre));
    if (parseXML(xml) == 0) {
        genreStationsXMLHash.insert(genre, xml);
        return true;
    }
    return false;
}

void SHOUTcastXMLPrivate::saveStationsByGenreToCache(const QString &genre)
{
    CacheReader::instance()->writeCache(stationsCacheFile(genre), genreStationsXMLHash.value(genre).toString());
}

void SHOUTcastXMLPrivate::reloadGenres()
{
    Q_Q(SHOUTcastXML);
    if (!loadGenresFromCache()) {
        clearCache();
        QNetworkRequest request(QUrl(SHOUTCAST_API_SERVER));
        request.setRawHeader("User-Agent", "Chrome");
        queuedReply = networkManager->get(request);
        queuedReply->connect(queuedReply, SIGNAL(finished()), q, SLOT(_q_refreshGenresXML()));
        emit q->busyChanged();
    }
}

void SHOUTcastXMLPrivate::reloadStationsForGenre(const QString &genre)
{
    Q_Q(SHOUTcastXML);
    if (!loadStationsByGenreFromCache(genre)) {
        QUrl requestUrl(SHOUTCAST_API_SERVER);
        requestUrl.addQueryItem("genre", genre);
        QNetworkRequest request(requestUrl);
        request.setRawHeader("User-Agent", "Chrome");
        queuedReply = networkManager->get(request);
        queuedReply->connect(queuedReply, SIGNAL(finished()), q, SLOT(_q_refreshGenreStationsXML()));
        emit q->busyChanged();
    }
}

void SHOUTcastXMLPrivate::reloadSearchResults(const QString &terms)
{
    Q_Q(SHOUTcastXML);
    if (!terms.isEmpty()) {
        QUrl requestUrl(SHOUTCAST_API_SERVER);
        requestUrl.addQueryItem("search", terms);
        QNetworkRequest request(requestUrl);
        request.setRawHeader("User-Agent", "Chrome");
        queuedReply = networkManager->get(request);
        queuedReply->connect(queuedReply, SIGNAL(finished()), q, SLOT(_q_refreshSearchResultsXML()));
        emit q->busyChanged();
    } else {
        searchResults = QString();
        emit q->searchResultsChanged();
    }
}

void SHOUTcastXMLPrivate::setTuneInURL(const QString &newTuneInUrl)
{
    Q_Q(SHOUTcastXML);
    if (tuneInUrl != newTuneInUrl) {
        tuneInUrl = newTuneInUrl;
        qDebug() << "Tune in url:" << tuneInUrl;
        emit q->tuneInUrlChanged();
    }
}

void SHOUTcastXMLPrivate::_q_refreshGenresXML()
{
    Q_Q(SHOUTcastXML);
    genresXML = queuedReply->readAll();
    saveGenresToCache();
    queuedReply->deleteLater();
    queuedReply = 0;
    emit q->busyChanged();
    emit q->genresChanged();
}

void SHOUTcastXMLPrivate::_q_refreshGenreStationsXML()
{
    Q_Q(SHOUTcastXML);
    QString stationsXML = queuedReply->readAll();
    QUrl requestUrl = queuedReply->request().url();
    QString genre = requestUrl.queryItemValue("genre");
    if (parseXML(stationsXML) == 0) {
        genreStationsXMLHash.insert(genre, stationsXML);
        saveStationsByGenreToCache(genre);
    }
    queuedReply->deleteLater();
    queuedReply = 0;
    emit q->busyChanged();
    emit q->stationsChanged();
}

void SHOUTcastXMLPrivate::_q_refreshSearchResultsXML()
{
    Q_Q(SHOUTcastXML);
    searchResults = queuedReply->readAll();
    if (parseXML(searchResults) != 0) {
        searchResults = QString();
    }
    queuedReply->deleteLater();
    queuedReply = 0;
    emit q->busyChanged();
    emit q->searchResultsChanged();
}

SHOUTcastXML::SHOUTcastXML(QObject *parent)
    : QObject(parent),
      d_ptr(new SHOUTcastXMLPrivate)
{
    d_ptr->q_ptr = this;
    d_ptr->init();
    d_ptr->reloadGenres();
}

SHOUTcastXML::~SHOUTcastXML()
{
    delete d_ptr;
}

const QString &SHOUTcastXML::genres() const
{
    Q_D(const SHOUTcastXML);
    return d->genresXML;
}

QMap<QString, QVariant> SHOUTcastXML::stations() const
{
    Q_D(const SHOUTcastXML);
    return d->genreStationsXMLHash;
}

const QString &SHOUTcastXML::tuneInUrl() const
{
    Q_D(const SHOUTcastXML);
    return d->tuneInUrl;
}

const QString &SHOUTcastXML::searchResults() const
{
    Q_D(const SHOUTcastXML);
    return d->searchResults;
}

bool SHOUTcastXML::busy() const
{
    Q_D(const SHOUTcastXML);
    return d->queuedReply != 0;
}

void SHOUTcastXML::loadStationsCache(const QString &genre)
{
    Q_D(SHOUTcastXML);
    if (genre.isEmpty())
        return;

    if (!d->genreStationsXMLHash.value(genre, QVariant()).isNull()) {
        emit stationsChanged();
        return;
    }

    d->reloadStationsForGenre(genre);
}

QString SHOUTcastXML::url(int id)
{
    Q_D(SHOUTcastXML);
    return d->tuneInUrl + "?id=" + QString::number(id);
}

void SHOUTcastXML::search(const QString &terms)
{
    Q_D(SHOUTcastXML);
    d->reloadSearchResults(terms);
}

#include "moc_shoutcastxml.cpp"
