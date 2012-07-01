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

BorderImage {
    property alias title: titleLabel.text;

    id: viewHeader;
    source: UI.VIEW_HEADER_BACKGROUND;
    border { left: 8; top: 8; right: 8; bottom: 8 }
    height: 72 ;

    Label {
        id: titleLabel;
        font.pixelSize: 32;
        font.family: UI.FONT_LIGHT;
        anchors.topMargin: 20;
        anchors.bottomMargin: 20;
        anchors.rightMargin: 16;
        anchors.leftMargin: 16;
        anchors.fill: parent;
        verticalAlignment: Qt.AlignVCenter;
        horizontalAlignment: Qt.AlignLeft;
    }
}
