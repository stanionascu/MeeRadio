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

Sheet {
    property int stationId : -1;
    property alias name : nameEdit.text;
    property alias url : urlEdit.text;

    signal saved();

    id: sheet;

    acceptButtonText: qsTr("Save");
    rejectButtonText: qsTr("Cancel");

    content: Item {
        anchors.fill: parent;
        Label {
            id: nameLabel;
            anchors.topMargin: 20;
            anchors.top: parent.top;
            anchors.left: parent.left;
            text: qsTr("Name");
        }
        TextField {
            id: nameEdit;
            anchors.topMargin: 10;
            anchors.top: nameLabel.bottom;
            anchors.left: parent.left;
            anchors.right: parent.right;

            inputMethodHints: Qt.ImhNoPredictiveText;
            onTextChanged: validateInput();
            placeholderText: qsTr("Type the name of the station here...");
        }
        Label {
            id: urlLabel;
            anchors.topMargin: 20;
            anchors.top: nameEdit.bottom;
            anchors.left: parent.left;
            text: qsTr("URL");
        }
        TextField {
            id: urlEdit;
            anchors.topMargin: 10;
            anchors.top: urlLabel.bottom;
            anchors.left: parent.left;
            anchors.right: parent.right;

            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase;
            onTextChanged: validateInput();
            validator: urlValidator;
            placeholderText: qsTr("Type or paste the url to the stream here...");
        }
        Label {
            id: urlEditInfo;
            anchors.topMargin: 10;
            anchors.top: urlEdit.bottom;
            anchors.left: parent.left;
            anchors.right: parent.right;
            font.pixelSize: 24;
            color: UI.FONT_DARKER_COLOR;
            font.family: UI.FONT_LIGHT;
            text: qsTr("Supported protocols for urls are http(s)://, mms:// and file:// for local downloaded playlists.");
        }
    }

    RegExpValidator {
        id: urlValidator;
        regExp: /(file|http|https|mms):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/;
    }

    onAccepted: {
        if (stationId == -1)
            DB.insertStation(name, url);
        else
            DB.updateStation(stationId, name, url);
    }

    function validateInput() {
        getButton("acceptButton").enabled = urlEdit.text.length > 0 && nameEdit.text.length > 0 && urlEdit.acceptableInput;
    }

    function openById(stationId) {
        if (status != DialogStatus.Closed)
            return;

        reset();
        var data = DB.fetchStation(stationId);
        this.stationId = stationId;
        name = data.name;
        url = data.url;
        validateInput();
        open();
    }

    function openByUrl(newUrl) {
        if (status != DialogStatus.Closed)
            return;

        reset();
        url = newUrl;
        validateInput();
        open();
    }

    function openByNameAndUrl(newName, newUrl) {
        if (status != DialogStatus.Closed)
            return;

        reset();
        name = newName;
        url = newUrl;
        validateInput();
        open();
    }

    function openNew() {
        if (status != DialogStatus.Closed)
            return;
        reset();
        validateInput();
        open();
    }

    function reset() {
        stationId = -1;
        name = "";
        url = "";
    }
}
