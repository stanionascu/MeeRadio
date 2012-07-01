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

Flickable {
    property alias model : list.model;
    property url iconSource : "";
    property alias currentIndex : list.currentIndex;
    property int playingIndex : -1;

    signal itemClicked(variant model);
    signal importItemClicked(variant model);
    signal playItemClicked(variant model, variant playing);

    id: flickable;
    anchors.fill: parent;
    ListView {
        anchors.fill: parent;
        id: list;
        currentIndex: -1;
        delegate: MediaListItem {
            width: list.width;
            title: model.name;
            iconSource: flickable.iconSource;
            selected: model.index === currentIndex;
            playing: model.index === playingIndex;
            onClicked: {
                flickable.itemClicked(model);
            }
            onImportClicked: {
                flickable.importItemClicked(model);
            }
            onPlayClicked: {
                flickable.playItemClicked(model, playing);
            }
        }
    }
}
