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
    id: mainPage;
    orientationLock: PageOrientation.LockPortrait;

    tools: ToolBarLayout {
        id: commonTools;
        visible: true;

        ToolIcon {
            platformIconId: "toolbar-add";
            onClicked: favoriteEditorSheet.openNew();
            visible: favoritesTabButton.checked;
        }

        ToolIcon {
            platformIconId: "toolbar-back";
            visible: !favoritesTabButton.checked;
            enabled: meeRadioTabGroup.currentTab.depth > 1 ? true : false;
            opacity: enabled ? 1.0 : 0.5;
            onClicked: meeRadioTabGroup.currentTab.pop();
        }

        ButtonRow {
            TabButton {
                id: favoritesTabButton;
                tab: favoritesTab;
                iconSource: "image://theme/icon-m-toolbar-frequent-used-white";
            }
            TabButton {
                id: servicesTabButton;
                tab: servicesTab;
                iconSource: "image://theme/icon-m-toolbar-content-audio-white";
            }
            TabButton {
                id: localsTabButton;
                tab: localsTab;
                iconSource: "image://theme/icon-m-toolbar-list-white";
            }
            TabButton {
                id: searchTabButton;
                tab: searchTab;
                iconSource: "image://theme/icon-m-toolbar-search-white";
            }
        }
    }

    BorderImage {
        id: background;
        source: UI.PAGE_BACKGROUND;
        anchors.fill: parent;
        border.left: 0; border.top: 0
        border.right: 0; border.bottom: 0
        z: 0;
    }

    ViewHeader {
        id: viewHeader;
        title: qsTr("MeeRadio");
        anchors.top: parent.top;
        anchors.left: parent.left;
        anchors.right: parent.right;
        height: meeRadioWindow.inPortrait ? 72 : 64;
        z: 2;
    }

    TabGroup {
        id: meeRadioTabGroup;
        currentTab: favoritesTab;

        FavoritesPage {
            id: favoritesTab;
            anchors.topMargin: viewHeader.height;
        }

        PageStack {
            property int stationId: -1;
            id: servicesTab;
        }

        PageStack {
            property url stationPath: "";
            id: localsTab;
        }

        SearchPage {
            id: searchTab;
            anchors.topMargin: viewHeader.height;
        }
    }

    ServicesPage {
        id: servicesPage;
        anchors.topMargin: viewHeader.height;
    }

    LocalsPage {
        id: localsPage;
        anchors.topMargin: viewHeader.height;
    }

    AddEditStationSheet {
        id: favoriteEditorSheet;

        onAccepted: {
            favoritesTab.readAllStations();
        }
    }

    AudioPlaylist {
        id: playlist;
        onError: {
            errorDialog.titleText = "Stream error";
            errorDialog.message = errorString;
            errorDialog.open();
        }
    }

    Item {
        id: busyPageIndicator;
        anchors.fill: parent;
        visible: SHOUTcastXML.busy;

        Rectangle {
            anchors.fill: parent;
            color: "#000000";
            opacity: 0.80;
        }

        BusyIndicator {
            id: indicator;
            anchors.centerIn: parent;
            running: true;
            platformStyle: BusyIndicatorStyle {
                size: "large";
            }
        }

        PropertyAnimation {
            id: fadeAnimation;
            target: busyPageIndicator;
            property: "opacity";
            from: 0.0;
            to: 1.0;
            duration: 200;
            loops: 1;
        }

        onVisibleChanged: {
            if (visible) {
                fadeAnimation.from = 0.0;
                fadeAnimation.to = 1.0;
                fadeAnimation.start();
            } else {
                fadeAnimation.from = 1.0;
                fadeAnimation.to = 0.0;
                fadeAnimation.start();
            }
        }
    }

    PlaybackButton {
        id: playbackButton;
        playing: playlist.playing;
        width: 64;
        height: 64;
        visible: favoritesTab.stationId !== -1 || servicesTab.stationId !== -1 || localsTab.stationPath != "";
        anchors {
            right: parent.right;
            bottom: parent.bottom;
        }

        onClicked: {
            if (playing)
                playlist.stop();
            else {
                if (playlist.origin == DB.ORIGIN_LOCALS)
                    playlist.playUrl(-1, DB.ORIGIN_LOCALS, localsTab.stationPath);
                else if (playlist.origin == DB.ORIGIN_SERVICES)
                    playlist.playUrl(-1, DB.ORIGIN_SERVICES, SHOUTcastXML.url(servicesTab.stationId));
                else if (playlist.origin == DB.ORIGIN_FAVORITES)
                    playlist.playUrl(favoritesTab.stationId, DB.ORIGIN_FAVORITES, favoritesTab.stationUrl);
            }
        }
    }

    QueryDialog {
        id: errorDialog;
        icon: UI.ICON_ERROR;

        acceptButtonText: qsTr("OK");
    }

    Component.onCompleted: {
        servicesTab.push(servicesPage);
        localsTab.push(localsPage);
    }
}
