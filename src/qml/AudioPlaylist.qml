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
import com.ionascu.meeradio 1.0;
import "../js/UI.js" as UI;
import "../js/DB.js" as DB;

Item {
    property int origin: -1;
    property alias playing: stream.playing;
    property string track: "";
    property bool busy: false;

    signal play();
    signal stop();
    signal error(string errorString);
    signal metaDataChanged(variant metaData);

    id: root;

    Playlist {
        id: playlist;

        onError: {
            console.log("Playlist error...");
            root.error(errorString);
        }

        onLoaded: {
            console.log("Playlist loaded...");
        }

        onUrlChanged: {
            track = qsTr("Loading ") + url;
        }
    }

    Audio {
        property int errorCount: 0;

        id: stream;
        autoLoad: true;
        source: playlist.mediaUrl;
        volume: 1.0;

        onStarted: {
            console.log("Playback started...");
        }

        onStopped: {
            console.log("Playback stopped...");
            track = "Paused.";
        }

        onStatusChanged: {
            if (status == Audio.Buffering) {
                console.log("Buffering...");
            } else if (status == Audio.Loading) {
                console.log("Loading...");
                track = qsTr("Buffering...");
                busy = true;
            } else if (status == Audio.Buffered) {
                console.log("Buffered...");
                busy = false;
                DB.printMetaData(metaData);
                var meta = "";
                if (metaData.publisher !== undefined)
                    meta = metaData.publisher;
                if (metaData.genre !== undefined)
                    meta += " - " + metaData.genre;
                if (metaData.title !== undefined)
                    meta = metaData.title;
                track = meta;
            } else if (status == Audio.Loaded) {
                console.log("Loaded...")
                busy = false;
            }
        }

        onError: {
            if ((error == Audio.NetworkError || error == Audio.FormatError || error == Audio.ResourceError) &&
                    (errorCount < UI.MAX_ERROR_COUNT * playlist.mediaUrlCount)) {
                console.log(error + ": Network error... Trying next...");
                playlist.next();
                play();
                errorCount ++;
            } else {
                errorCount = 0;
                root.error(errorString);
                busy = false;
            }
        }

        onSourceChanged: {
            errorCount = 0;
            console.log("Trying... " + source);
            play();
        }
    }

    Timer {
        running: stream.playing;
        repeat: true;
        interval: 10000;

        onTriggered: {
            DB.requestMetadata(stream.source, root.metaDataChanged);
        }
    }

    onPlay: stream.play();
    onStop: stream.stop();

    onMetaDataChanged: {
        if (metaData !== null && metaData !== undefined) {
            if (metaData.track != "")
                track = metaData.track;
        }
    }

    function playUrl(cacheId, origin, url) {
        stream.stop();
        this.origin = origin;
        playlist.cacheId = cacheId;
        if (playlist.url == url) {
            stream.play();
        } else {
            playlist.url = url;
        }
    }

    function removeCache(cacheId) {
        playlist.removeCache(cacheId);
    }
}
