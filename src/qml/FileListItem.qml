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
    property bool selected : false;
    property url iconSource : "";
    property alias iconVisible : iconImage.visible;

    signal clicked();
    signal contextMenu();
    signal importClicked();

    BorderImage {
        id: background;
        anchors.fill: parent;
        visible: mouseArea.pressed || selected;
        source: selected ? UI.LIST_ITEM_ACTIVE_BACKGROUND : UI.LIST_ITEM_BACKGROUND;
    }

    id: fileListItem;
    height: 80;

    Image {
        id: iconImage;
        source: iconSource;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.left: parent.left;
        anchors.leftMargin: 8;
    }

    Label {
        id: titleLabel;
        anchors.leftMargin: 4;
        anchors.left: iconImage.right;
        anchors.rightMargin: 4;
        anchors.right: addButton.left;
        anchors.top: parent.top;
        anchors.topMargin: 27;
        font.pixelSize: 26;
        font.weight: Font.Bold;
        elide: Text.ElideRight;
    }

    MouseArea {
        id: mouseArea;
        anchors.fill: parent;
        onClicked: fileListItem.clicked();
        onPressAndHold: fileListItem.contextMenu();
    }

    ToolIcon {
        id: addButton;
        platformIconId: UI.TOOL_ICON_FAVORITE;
        anchors.right: parent.right;
        anchors.verticalCenter: parent.verticalCenter;
        visible: selected;
        onClicked: fileListItem.importClicked();
    }

    Image {
        source: UI.SEPARATOR_BACKGROUND;
        anchors.leftMargin: 12;
        anchors.rightMargin: 12;
        anchors.left: parent.left;
        anchors.bottom: parent.bottom;
        anchors.right: parent.right;
    }
}
