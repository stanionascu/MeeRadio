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

#include <QtGui/QApplication>
#include <QtDeclarative>
#ifdef HARMATTAN_BOOSTER
#include <applauncherd/MDeclarativeCache>
#endif

#include "playlist.h"
#include "shoutcastxml.h"
#include "cachereader.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifdef HARMATTAN_BOOSTER
    QApplication *app = MDeclarativeCache::qApplication(argc, argv);
    QDeclarativeView *view = MDeclarativeCache::qDeclarativeView();
#else
    QApplication *app = new QApplication(argc, argv);
    QDeclarativeView *view = new QDeclarativeView;
#endif

    qmlRegisterType<Playlist>("com.ionascu.meeradio", 1, 0, "Playlist");

    view->rootContext()->setContextProperty("SHOUTcastXML", new SHOUTcastXML(view));
    view->rootContext()->setContextProperty("CacheReader", CacheReader::instance());
    view->setSource(QUrl("qrc:/qml/main.qml"));
#ifdef __arm__
    view->showFullScreen();
#else
    view->show();
#endif

#ifdef HARMATTAN_BOOSTER
    //see http://harmattan-dev.nokia.com/docs/library/html/guide/html/limitations.html?tab=3&q=booster&sp=all
    //also no need to call 'delete', since we didn't call 'new' in case of using booster.
    _exit(app->exec());
#else
    int result = app->exec();
    delete view;
    delete app;
    return result;
#endif
}
