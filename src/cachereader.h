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

#ifndef CACHEREADER_H
#define CACHEREADER_H

#include <QObject>
#include <QUrl>

class CacheReaderPrivate;

class CacheReader : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString cacheFolder READ cacheFolder NOTIFY cacheFolderChanged)
    Q_PROPERTY(QString homeFolder READ homeFolder NOTIFY homeFolderChanged)
public:
    virtual ~CacheReader();
    static CacheReader *instance();

    const QString &cacheFolder() const;
    const QString &homeFolder() const;

    void writeCache(const QString &fileName, const QString &data);
    QString readCache(const QString &fileName);

Q_SIGNALS:
    void cacheFolderChanged();
    void homeFolderChanged();

private:
    explicit CacheReader(QObject *parent = 0);

private:
    Q_DISABLE_COPY(CacheReader)
    Q_DECLARE_PRIVATE(CacheReader)
    CacheReaderPrivate *d_ptr;
};

#endif // CACHEREADER_H
