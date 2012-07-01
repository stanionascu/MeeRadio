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
import com.nokia.meego 1.0;
import "../js/UI.js" as UI;
import "../js/DB.js" as DB;

Page {
    id: searchPage;
    orientationLock: PageOrientation.LockPortrait;

    SHOUTcastSearchModel {
        id: searchModel;
    }

    Item {
        id: searchFieldContainer;
        height: searchQueryField.height;
        z: 100;
        anchors {
            top: parent.top;
            left: parent.left;
            right: parent.right;
        }

        Rectangle {
            color: "#000000";
            anchors.fill: parent;
        }

        TextField {
            anchors.fill: parent;

            id: searchQueryField;
            placeholderText: qsTr("Type the search term, more than 2 characters...");
            inputMethodHints: Qt.ImhNoPredictiveText;

            onActiveFocusChanged: {
                if (!activeFocus)
                    searchModel.searchTerm = searchQueryField.text;
            }
        }

        ToolIcon {
            anchors {
                right: searchQueryField.right;
                verticalCenter: searchQueryField.verticalCenter;
            }
            iconSource: "image://theme/icon-m-input-clear";
            onClicked: {
                searchQueryField.text = "";
                searchModel.searchTerm = "";
            }
        }
    }

    Flickable {
        id: search;
        anchors.top: searchFieldContainer.bottom;
        anchors.bottom: parent.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        ListView {
            id: searchList;
            model: searchModel;
            anchors.fill: parent;
            currentIndex: -1;
            delegate: MediaListItem {
                width: searchList.width;
                title: model.name;
                playing: model.id === servicesTab.stationId && playlist.origin == DB.ORIGIN_SERVICES && playlist.playing;
                selected: searchList.currentIndex === -1 ? playing : model.index === searchList.currentIndex;
                iconSource: UI.ICON_PLAYLIST;
                onClicked: {
                    searchList.currentIndex = model.index;
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
