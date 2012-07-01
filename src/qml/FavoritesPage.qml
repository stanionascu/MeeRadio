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
import "../js/DB.js" as DB;
import "../js/UI.js" as UI;

Page {
    property int stationId: -1;
    property url stationUrl: "";

    id: favoritesPage;
    orientationLock: PageOrientation.LockPortrait;

    BorderImage {
        id: background;
        source: UI.PAGE_EMPTY_BACKGROUND;
        anchors.fill: parent;
        anchors.topMargin: -parent.anchors.topMargin;
        border.left: 0; border.top: 0
        border.right: 0; border.bottom: 0
        z: 0;
        visible: stationsList.count === 0;
    }

    ListModel {
        id: stationsModel;
    }

    Flickable {
        id: stationsFlickable;
        anchors.top: parent.top;
        anchors.bottom: parent.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        visible: stationsModel.count > 0;
        z: 1;
        ListView {
            anchors.fill: parent;
            id: stationsList;
            model: stationsModel;
            currentIndex: -1;
            delegate: FavoriteListItem {
                width: parent === null ? 480 : parent.width;
                title: model.name;
                active: stationId == model.id && playlist.origin == DB.ORIGIN_FAVORITES;
                status: active ? playlist.track : "";
                busy: active ? playlist.busy : false;
                onClicked: {
                    if (!active) {
                        stationId = model.id;
                        playlist.playUrl(model.id, DB.ORIGIN_FAVORITES, model.url);
                    }
                }

                onContextMenu: {
                    favoriteContextMenu.openById(model.id);
                }
            }
        }
    }

    Label {
        anchors.centerIn: parent;
        id: emptyDataLabel;
        text: qsTr("No stations yet");
        color: "#505050";
        font.family: UI.FONT_LIGHT;
        font.pixelSize: 64;
        verticalAlignment: Qt.AlignVCenter;
        horizontalAlignment: Qt.AlignHCenter;
        visible: stationsModel.count === 0;
    }

    ContextMenu {
        property int stationId: -1;

        id: favoriteContextMenu;
        MenuLayout {
            MenuItem {
                text: qsTr("Edit");
                onClicked: {
                    favoriteEditorSheet.openById(favoriteContextMenu.stationId);
                }
            }
            MenuItem {
                text: qsTr("Remove");
                onClicked: {
                    playlist.removeCache(favoriteContextMenu.stationId);
                    DB.removeStation(favoriteContextMenu.stationId);
                    readAllStations();
                }
            }
        }

        function openById(stationId) {
            if (status != DialogStatus.Closed)
                return;

            this.stationId = stationId;
            open();
        }
    }

    Component.onCompleted: {
        readAllStations();
    }

    onStationIdChanged: {
        stationUrl = "";
        console.log("Favorite station ID: " + stationId);
        if (stationId != -1) {
            var data = DB.fetchStation(stationId);
            stationUrl = data.url;
        }
    }

    function readAllStations() {
        stationId = -1;
        playlist.stop();
        stationsModel.clear();
        var stations = DB.readAllStations();
        for (var i = 0; i < stations.length; i ++) {
            stationsModel.append(stations[i]);
        }
    }
}
