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
import Qt.labs.folderlistmodel 1.0;
import com.nokia.meego 1.0;
import "../js/UI.js" as UI;
import "../js/DB.js" as DB;

Page {
    property url path: CacheReader.homeFolder;

    id: localsPage;
    orientationLock: PageOrientation.LockPortrait;

    FolderListModel {
        id: fileListModel;
        nameFilters: ["*.m3u", "*.pls"];
        folder: localsPage.path;
        showDotAndDotDot: false;
    }

    Flickable {
        id: localsFlickable;
        anchors.fill: parent;
        ListView {
            anchors.fill: parent;
            currentIndex: -1;
            id: fileList;
            model: fileListModel;
            delegate: MediaListItem {
                width: fileList.width;
                title: model.fileName;
                playing: localsTab.stationPath == model.filePath && playlist.origin == DB.ORIGIN_LOCALS && playlist.playing;
                selected: fileList.currentIndex === -1 ? playing : fileList.currentIndex === model.index;
                iconSource: fileListModel.isFolder(model.index) ? UI.ICON_FOLDER : UI.ICON_PLAYLIST;
                onClicked: {
                    if (fileListModel.isFolder(model.index)) {
                        pageStack.push(Qt.resolvedUrl("LocalsPage.qml"),
                                       { path: model.filePath,
                                         "anchors.topMargin": localsPage.anchors.topMargin });
                    } else {
                        fileList.currentIndex = model.index;
                    }
                }
                onPlayClicked: {
                    if (!playing) {
                        playlist.playUrl(-1, DB.ORIGIN_LOCALS, model.filePath);
                        localsTab.stationPath = model.filePath;
                    } else {
                        playlist.stop();
                        localsTab.stationPath = "";
                    }
                }
                onImportClicked: {
                    favoriteEditorSheet.openByUrl(model.filePath);
                }
            }
        }
    }
}
