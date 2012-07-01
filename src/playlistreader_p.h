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

#ifndef PLAYLISTREADER_P_H
#define PLAYLISTREADER_P_H

#include <QtGlobal>
#include <QIODevice>
#include <QStringList>
#include <QUrl>
#include <QWeakPointer>

class PlaylistReader;
class QNetworkAccessManager;
class QNetworkReply;

class PlaylistReaderPrivate
{
public:
    PlaylistReaderPrivate();
    virtual ~PlaylistReaderPrivate();

    void init();
    bool isFormat(const QString &contentType, PlaylistReader::Format format);

    bool loadFromLocal(const QUrl &url);
    void loadFromRemote(const QUrl &url);

    QStringList parseASX(QIODevice *device);
    QStringList parseM3U(QIODevice *device);
    QStringList parsePLS(QIODevice *device);

    void _q_networkReplyReady(QNetworkReply *reply);

    QString cacheFileName(int cacheId);
    QString cacheFilePath(int cacheId);

    void abortPendingRequest();

private:
    Q_DECLARE_PUBLIC(PlaylistReader)
    PlaylistReader *q_ptr;

    QStringList urls;
    QNetworkAccessManager *networkAccessManager;
    int pendingRequests;
    bool cached;
    QWeakPointer<QNetworkReply> queuedReply;
};

#endif // PLAYLISTREADER_P_H
