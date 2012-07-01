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

#ifndef PLAYLIST_H
#define PLAYLIST_H

#include <QObject>
#include <QUrl>

class PlaylistPrivate;
class QMediaPlaylist;

class Playlist : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QUrl mediaUrl READ mediaUrl NOTIFY mediaUrlChanged)
    Q_PROPERTY(int mediaUrlCount READ mediaUrlCount NOTIFY mediaUrlCountChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)
    Q_PROPERTY(int cacheId READ cacheId WRITE setCacheId NOTIFY cacheIdChanged)
public:
    explicit Playlist(QObject *parent = 0);
    virtual ~Playlist();

    void setUrl(const QUrl &url);
    QUrl url() const;

    QUrl mediaUrl() const;

    int mediaUrlCount() const;

    QString errorString() const;

    void setCacheId(int id);
    int cacheId() const;

    Q_INVOKABLE void removeCache(int cacheId);

Q_SIGNALS:
    void urlChanged();
    void error();
    void loaded();
    void mediaUrlChanged();
    void mediaUrlCountChanged();
    void errorStringChanged();
    void cacheIdChanged();

public Q_SLOTS:
    void next();

private:
    Q_PRIVATE_SLOT(d_func(), void _q_loaded())
    Q_PRIVATE_SLOT(d_func(), void _q_error(QString))

    Q_DECLARE_PRIVATE(Playlist)
    PlaylistPrivate *d_ptr;
};

#endif // PLAYLIST_H
