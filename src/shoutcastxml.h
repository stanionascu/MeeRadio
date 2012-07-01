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

#ifndef SHOUTCASTXML_H
#define SHOUTCASTXML_H

#include <QObject>
#include <QMap>

class SHOUTcastXMLPrivate;

class SHOUTcastXML : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString genres READ genres NOTIFY genresChanged)
    Q_PROPERTY(QMap stations READ stations NOTIFY stationsChanged)
    Q_PROPERTY(QString tuneInUrl READ tuneInUrl NOTIFY tuneInUrlChanged)
    Q_PROPERTY(QString searchResults READ searchResults NOTIFY searchResultsChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
public:
    SHOUTcastXML(QObject *parent = 0);
    virtual ~SHOUTcastXML();

    const QString &genres() const;
    QMap<QString, QVariant> stations() const;
    const QString &tuneInUrl() const;
    const QString &searchResults() const;
    bool busy() const;

    Q_INVOKABLE void search(const QString &terms);
    Q_INVOKABLE void loadStationsCache(const QString &genre);
    Q_INVOKABLE QString url(int id);

Q_SIGNALS:
    void genresChanged();
    void stationsChanged();
    void tuneInUrlChanged();
    void searchResultsChanged();
    void busyChanged();

private:
    Q_DECLARE_PRIVATE(SHOUTcastXML)
    SHOUTcastXMLPrivate *d_ptr;

    Q_PRIVATE_SLOT(d_func(), void _q_refreshGenresXML())
    Q_PRIVATE_SLOT(d_func(), void _q_refreshGenreStationsXML())
    Q_PRIVATE_SLOT(d_func(), void _q_refreshSearchResultsXML())
};

#endif // SHOUTCASTXML_H
