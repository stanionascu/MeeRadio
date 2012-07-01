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

#include "playlist.h"
#include "playlist_p.h"

#include "playlistreader.h"

#include <QDebug>
#include <QStringList>

PlaylistPrivate::PlaylistPrivate() :
    q_ptr(0),
    playlistReader(0),
    mediaUrlIndex(0),
    cacheId(-1)
{
}

PlaylistPrivate::~PlaylistPrivate()
{
}

void PlaylistPrivate::init()
{
    Q_Q(Playlist);
    playlistReader = new PlaylistReader(q);
    q->connect(playlistReader, SIGNAL(loaded()), q, SLOT(_q_loaded()));
    q->connect(playlistReader, SIGNAL(error(QString)), q, SLOT(_q_error(QString)));
}

void PlaylistPrivate::_q_loaded()
{
    Q_Q(Playlist);
    qDebug() << "Loaded:" << playlistUrl.toString();
    if (playlistReader->entries().count() <= 0) {
        errorString = qtTrId("The playlist is empty.");
        qDebug() << errorString;
        emit q->errorStringChanged();
        emit q->error();
        return;
    }
    foreach (QString entry, playlistReader->entries()) {
        qDebug() << entry;
    }
    emit q->loaded();
    emit q->mediaUrlChanged();
    playlistReader->saveToCache(cacheId);
}

void PlaylistPrivate::_q_error(const QString &errorString)
{
    Q_Q(Playlist);
    this->errorString = errorString;
    emit q->errorStringChanged();
    emit q->error();
}

Playlist::Playlist(QObject *parent) :
    QObject(parent),
    d_ptr(new PlaylistPrivate)
{
    d_ptr->q_ptr = this;
    d_ptr->init();
}

Playlist::~Playlist()
{
    delete d_ptr;
}

void Playlist::setUrl(const QUrl &url)
{
    Q_D(Playlist);
    d->playlistUrl = url;
    if (!d->playlistReader->loadFromCache(d->cacheId))
        d->playlistReader->load(url);
    emit urlChanged();
}

QUrl Playlist::url() const
{
    Q_D(const Playlist);
    return d->playlistUrl;
}

QUrl Playlist::mediaUrl() const
{
    Q_D(const Playlist);
    if (d->mediaUrlIndex >= d->playlistReader->entries().count())
        d->mediaUrlIndex = 0;

    if (d->playlistReader->entries().count() > d->mediaUrlIndex) {
        return d->playlistReader->entries().at(d->mediaUrlIndex);
    }
    else
        return QUrl();
}

int Playlist::mediaUrlCount() const
{
    Q_D(const Playlist);
    return d->playlistReader->entries().count();
}

QString Playlist::errorString() const
{
    Q_D(const Playlist);
    QString result = d->errorString;
    d->errorString.clear();
    return result;
}

void Playlist::setCacheId(int id)
{
    Q_D(Playlist);
    d->cacheId = id;
    emit cacheIdChanged();
}

int Playlist::cacheId() const
{
    Q_D(const Playlist);
    return d->cacheId;
}

void Playlist::removeCache(int cacheId)
{
    Q_D(Playlist);
    d->playlistReader->removeCache(cacheId);
}

void Playlist::next()
{
    Q_D(Playlist);
    d->mediaUrlIndex ++;
    if (d->mediaUrlIndex >= d->playlistReader->entries().count())
        d->mediaUrlIndex = 0;
    emit mediaUrlChanged();
}

#include "moc_playlist.cpp"
