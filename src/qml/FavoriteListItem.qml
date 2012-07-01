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

Item {
    property alias title : titleLabel.text;
    property alias status : statusLabel.text;

    property bool active: false;
    property bool busy : false;

    signal clicked();
    signal contextMenu();

    id: stationListItem;
    height: 80;

    BorderImage {
        id: background;
        source: UI.LIST_ITEM_BACKGROUND;
        anchors.fill: parent;
        visible: mouseArea.pressed;
    }

    Image {
        id: iconImage;
        source: UI.ICON_PLAYLIST;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.left: parent.left;
        anchors.leftMargin: 8;
    }

    Item {
        anchors {
            top: parent.top;
            left: iconImage.right;
            bottom: parent.bottom;
            right: busyIndicator.left;
        }

        Label {
            id: titleLabel;
            anchors.left: parent.left;
            anchors.leftMargin: 4;
            anchors.top: parent.top;
            anchors.topMargin: statusLabel.visible ? 16 : 27;
            anchors.right: parent.right
            font.pixelSize: 26;
            font.weight: Font.Bold;
            elide: Text.ElideRight;
        }

        Label {
            id: statusLabel;
            anchors.topMargin: 4;
            anchors.top: titleLabel.bottom;
            anchors.leftMargin: 4;
            anchors.left: parent.left;
            anchors.right: parent.right;
            font.family: UI.FONT_LIGHT;
            font.pixelSize: 18;
            color: UI.FONT_SECONDARY_COLOR;
            visible: text != "";
            elide: Text.ElideRight;
        }
    }

    BusyIndicator {
        id: busyIndicator;
        visible: stationListItem.busy;
        anchors.right: parent.right;
        anchors.rightMargin: 12;
        anchors.verticalCenter: parent.verticalCenter;
        running: stationListItem.busy;
    }

    Image {
        source: UI.SEPARATOR_BACKGROUND;
        anchors.leftMargin: 12;
        anchors.rightMargin: 12;
        anchors.left: parent.left;
        anchors.bottom: parent.bottom;
        anchors.right: parent.right;
    }

    Rectangle {
        id: overlayRectangle;
        anchors.fill: parent;
        color: "#000000";
        opacity: 0.0;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: stationListItem.clicked();
        onPressAndHold: stationListItem.contextMenu();
        onPressedChanged: {
            if (pressed)
                overlayFadeAnimation.start();
            else
                overlayFadeAnimation.stop();
        }
    }

    PropertyAnimation {
        id: overlayFadeAnimation;
        target: overlayRectangle;
        property: "opacity";
        to: 0.95;
        duration: 900;
        onRunningChanged: {
            overlayRectangle.opacity = 0.0;
        }
    }
}
