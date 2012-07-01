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

import QtQuick 1.1;
import QtMultimediaKit 1.1;
import com.nokia.meego 1.0;
import com.ionascu.meeradio 1.0;
import "../js/UI.js" as UI;
import "../js/DB.js" as DB;

Page {
    property int selectedIndex: -1;
    property string iconSource: UI.ICON_FOLDER;
    property string genre: "";

    id: servicesPage;
    orientationLock: PageOrientation.LockPortrait;

    SHOUTcastGenresModel {
        id: shoutcastGenres;
    }

    FlickableListView {
        id: genres;
        model: shoutcastGenres;
        iconSource: servicesPage.iconSource;
        visible: genre === "";
        onItemClicked: {
            pageStack.push(Qt.resolvedUrl("ServicesPage.qml"),
                           { iconSource: UI.ICON_PLAYLIST, "anchors.topMargin": servicesPage.anchors.topMargin,
                           genre: model.name} );
        }
    }

    SHOUTcastTunesModel {
        id: shoutcastTunes;
        genre: servicesPage.genre;
    }


    Flickable {
        id: tunes;
        anchors.fill: parent;
        visible: !genres.visible;
        ListView {
            id: tunesList;
            model: shoutcastTunes;
            anchors.fill: parent;
            currentIndex: -1;
            delegate: MediaListItem {
                width: tunesList.width;
                title: model.name;
                playing: model.id === servicesTab.stationId && playlist.origin == DB.ORIGIN_SERVICES && playlist.playing;
                selected: tunesList.currentIndex === -1 ? playing : model.index === tunesList.currentIndex;
                iconSource: UI.ICON_PLAYLIST;
                onClicked: {
                    tunesList.currentIndex = model.index;
                }
                onImportClicked: {
                    favoriteEditorSheet.openByNameAndUrl(model.name, SHOUTcastXML.url(model.id));
                }
                onPlayClicked: {
                    if (!playing) {
                        playlist.playUrl(-1, DB.ORIGIN_SERVICES, SHOUTcastXML.url(model.id));
                        servicesTab.stationId = model.id;
                    } else {
                        playlist.stop();
                        servicesTab.stationId = -1;
                    }
                }
            }
        }
    }
}
