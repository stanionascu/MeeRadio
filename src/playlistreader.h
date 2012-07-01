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

#ifndef PLAYLISTREADER_H
#define PLAYLISTREADER_H

#include <QObject>
#include <QUrl>

class PlaylistReaderPrivate;
class QNetworkReply;

class PlaylistReader : public QObject
{
    Q_OBJECT

public:
    enum Format {
        M3U,
        PLS,
        ASX
    };

public:
    PlaylistReader(QObject *parent = 0);
    virtual ~PlaylistReader();

    void load(const QUrl &url);
    const QStringList &entries() const;

    bool loadFromCache(int cacheId);
    void saveToCache(int cacheId);
    void removeCache(int cacheId);

Q_SIGNALS:
    void loaded();
    void error(const QString &error);

private:
    Q_DECLARE_PRIVATE(PlaylistReader)
    PlaylistReaderPrivate *d_ptr;

    Q_PRIVATE_SLOT(d_func(), void _q_networkReplyReady(QNetworkReply*))
};

#endif // PLAYLISTREADER_H
