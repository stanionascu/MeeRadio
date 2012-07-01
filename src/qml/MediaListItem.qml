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

FileListItem {
    property bool playing: false;

    signal playClicked();

    id: root;
    iconVisible: !selected && !playing;

    ToolIcon {
        id: playbackButton;
        platformIconId: playing ? UI.ICON_PAUSE : UI.ICON_PLAY;
        anchors.left: parent.left;
        anchors.verticalCenter: parent.verticalCenter;
        visible: selected || playing;
        onClicked: {
            root.playClicked();
        }
    }
}
