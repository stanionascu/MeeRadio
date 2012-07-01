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

#include "cachereader.h"
#include "cachereader_p.h"

#include <QDesktopServices>
#include <QDir>
#include <QTextStream>
#include <QDebug>

namespace {
    static CacheReader *g_CacheRaderInstance = 0;
}

CacheReaderPrivate::CacheReaderPrivate()
    : q_ptr(0)
{
}

CacheReaderPrivate::~CacheReaderPrivate()
{
}

const QString &CacheReaderPrivate::findCacheFolder()
{
    Q_Q(CacheReader);
    if (cacheFolderPath.isEmpty()) {
        cacheFolderPath= QDesktopServices::storageLocation(QDesktopServices::CacheLocation) + QDir::separator() + "ionascu" + QDir::separator() + "meeradio";
        qDebug() << "Cache folder: " << cacheFolderPath;
        emit q->cacheFolderChanged();
    }

    return cacheFolderPath;
}

const QString &CacheReaderPrivate::findHomeFolder()
{
    Q_Q(CacheReader);
    if (homeFolderPath.isEmpty()) {
        homeFolderPath = QDesktopServices::storageLocation(QDesktopServices::HomeLocation);
        qDebug() << "Home folder: " << homeFolderPath;
        emit q->homeFolderChanged();
    }

    return homeFolderPath;
}

CacheReader::CacheReader(QObject *parent)
    : QObject(parent),
      d_ptr(new CacheReaderPrivate)
{
    d_ptr->q_ptr = this;
}

CacheReader::~CacheReader()
{
    delete d_ptr;
}

CacheReader *CacheReader::instance()
{
    if (g_CacheRaderInstance == 0)
        g_CacheRaderInstance = new CacheReader;

    return g_CacheRaderInstance;
}

const QString &CacheReader::cacheFolder() const
{
    Q_D(const CacheReader);
    return const_cast<CacheReaderPrivate*>(d)->findCacheFolder();
}

const QString &CacheReader::homeFolder() const
{
    Q_D(const CacheReader);
    return const_cast<CacheReaderPrivate*>(d)->findHomeFolder();
}

void CacheReader::writeCache(const QString &fileName, const QString &data)
{
    Q_D(CacheReader);
    QString cacheFilePath = d->findCacheFolder() + QDir::separator() + fileName;
    qDebug() << "Writing cache: " << cacheFilePath;

    QFile cacheFile(cacheFilePath);
    QTextStream textStream(&cacheFile);
    cacheFile.open(QFile::Truncate | QFile::WriteOnly);
    textStream << data;
    cacheFile.flush();
    cacheFile.close();
}

QString CacheReader::readCache(const QString &fileName)
{
    Q_D(CacheReader);
    QString cacheFilePath = d->findCacheFolder() + QDir::separator() + fileName;
    QString data = QString();
    if (QFile::exists(cacheFilePath)) {
        QFile cacheFile(cacheFilePath);
        cacheFile.open(QFile::ReadOnly);
        data = cacheFile.readAll();
        cacheFile.close();
    }
    return data;
}
