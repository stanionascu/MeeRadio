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

#ifndef PLAYLIST_P_H
#define PLAYLIST_P_H

#include <QtGlobal>
#include <QUrl>

class Playlist;
class PlaylistReader;

class PlaylistPrivate
{
public:
    PlaylistPrivate();
    virtual ~PlaylistPrivate();

    void init();
    void _q_loaded();
    void _q_error(const QString &errorString);

private:
    Q_DECLARE_PUBLIC(Playlist)

    Playlist *q_ptr;
    PlaylistReader *playlistReader;
    mutable int mediaUrlIndex;

    QUrl playlistUrl;
    mutable QString errorString;
    int cacheId;
};

#endif // PLAYLIST_P_H
