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

.pragma library

var ORIGIN_FAVORITES = 1;
var ORIGIN_SERVICES = 2;
var ORIGIN_LOCALS = 3;

function openDB() {
    return openDatabaseSync("MeeRadioDB", "1.0", "MeeRadio internet radio station application database.", 1000000);
}

function readAllStations() {
    var stations = new Array();
    var db = openDB();
    db.transaction(
                function(tx) {
                    // Create database if it does not exist yet.
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Stations(id INTEGER, name TEXT, url TEXT, genre TEXT, rating INTEGER)');
                    var rs = tx.executeSql('SELECT * FROM Stations ORDER BY name');
                    for (var i = 0; i < rs.rows.length; i ++) {
                        stations.push({"name": rs.rows.item(i).name,
                                      "url": rs.rows.item(i).url,
                                      "id": Number(rs.rows.item(i).id)});
                    }
                }
     );
    return stations;
}

function insertStation(name, url) {
    var db = openDB();
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql('SELECT MAX(id) as "maxId" FROM Stations');
                    var id = rs.rows.item(0).maxId;
                    if (id <= 0)
                        id = 1;
                    else
                        id++;
                    var genre = "Unspecified";
                    tx.executeSql('INSERT INTO Stations(id, name, url, genre, rating) VALUES(?,?,?,?,?)',
                                  [id, name, url, genre, 0]);
                }
    );
}

function removeStation(id) {
    var db = openDB();
    db.transaction(
                function(tx) {
                    tx.executeSql('DELETE FROM Stations WHERE id=?', [id]);
                }
    );
}

function updateStation(id, name, url) {
    var db = openDB();
    db.transaction(
                function(tx) {
                    tx.executeSql('UPDATE Stations SET name=?, url=? WHERE id=?', [name, url, id]);
                }
    );
}

function fetchStation(id) {
    var db = openDB();
    var result = new Object();
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql('SELECT * FROM Stations WHERE id=?', [id]);
                    if (rs.rows.length > 0)
                        result = {"name": rs.rows.item(0).name,
                                "url": rs.rows.item(0).url,
                                "id": Number(rs.rows.item(0).id)};
                    else
                        result = {"name": "",
                                "url": "",
                                "id": Number(-1)};
                }
    );
    return result;
}

function resetDB() {
    var db = openDB();
    db.transaction(
                function(tx) {
                    tx.executeSql('DELETE FROM Stations');
                }
    );
}

function printMetaData(metaData) {
    if (metaData.albumArtist !== undefined)
        console.log("albumArtist:" + metaData.albumArtist);

    if (metaData.albumTitle !== undefined)
        console.log("albumTitle:" + metaData.albumTitle);

    if (metaData.audioBitRate !== undefined)
        console.log("audioBitRate:" + metaData.audioBitRate);

    if (metaData.audioCodec !== undefined)
        console.log("audioCodec:" + metaData.audioCodec);

    if (metaData.author !== undefined)
        console.log("author:" + metaData.author);

    if (metaData.averageLevel !== undefined)
        console.log("averageLevel:" + metaData.averageLevel);

    if (metaData.category !== undefined)
        console.log("category:" + metaData.category);

    if (metaData.channelCount !== undefined)
        console.log("channelCount:" + metaData.channelCount);

    if (metaData.chapterNumber !== undefined)
        console.log("chapterNumber:" + metaData.chapterNumber);

    if (metaData.comment !== undefined)
        console.log("comment:" + metaData.comment);

    if (metaData.composer !== undefined)
        console.log("composer:" + metaData.composer);

    if (metaData.conductor !== undefined)
        console.log("conductor:" + metaData.conductor);

    if (metaData.contributingArtist !== undefined)
        console.log("contributingArtist:" + metaData.contributingArtist);

    if (metaData.copyright !== undefined)
        console.log("copyright:" + metaData.copyright);

    if (metaData.coverArtUrlLarge !== undefined)
        console.log("coverArtUrlLarge:" + metaData.coverArtUrlLarge);

    if (metaData.coverArtUrlSmall !== undefined)
        console.log("coverArtUrlSmall:" + metaData.coverArtUrlSmall);

    if (metaData.date !== undefined)
        console.log("date:" + metaData.date);

    if (metaData.description !== undefined)
        console.log("description:" + metaData.description);

    if (metaData.director !== undefined)
        console.log("director:" + metaData.director);

    if (metaData.genre !== undefined)
        console.log("genre:" + metaData.genre);

    if (metaData.keywords !== undefined)
        console.log("keywords:" + metaData.keywords);

    if (metaData.language !== undefined)
        console.log("language:" + metaData.language);

    if (metaData.leadPerformer !== undefined)
        console.log("leadPerformer:" + metaData.leadPerformer);

    if (metaData.lyrics !== undefined)
        console.log("lyrics:" + metaData.lyrics);

    if (metaData.mediaType !== undefined)
        console.log("mediaType:" + metaData.mediaType);

    if (metaData.mood !== undefined)
        console.log("mood:" + metaData.mood);

    if (metaData.parentalRating !== undefined)
        console.log("parentalRating:" + metaData.parentalRating);

    if (metaData.peakValue !== undefined)
        console.log("peakValue:" + metaData.peakValue);

    if (metaData.posterUrl !== undefined)
        console.log("posterUrl:" + metaData.posterUrl);

    if (metaData.publisher !== undefined)
        console.log("publisher:" + metaData.publisher);

    if (metaData.ratingOrganisation !== undefined)
        console.log("ratingOrganisation:" + metaData.ratingOrganisation);

    if (metaData.sampleRate !== undefined)
        console.log("sampleRate:" + metaData.sampleRate);

    if (metaData.size !== undefined)
        console.log("size:" + metaData.size);

    if (metaData.subTitle !== undefined)
        console.log("subTitle:" + metaData.subTitle);

    if (metaData.title !== undefined)
        console.log("title:" + metaData.title);

    if (metaData.trackCount !== undefined)
        console.log("trackCount:" + metaData.trackCount);

    if (metaData.trackNumber !== undefined)
        console.log("trackNumber:" + metaData.trackNumber);

    if (metaData.userRating !== undefined)
        console.log("userRating:" + metaData.userRating);

    if (metaData.writer !== undefined)
        console.log("writer:" + metaData.writer);

    if (metaData.year !== undefined)
        console.log("year:" + metaData.year);
}

function requestMetadata(url, callback) {
    console.log("Requesting metadata...");
    var doc = new XMLHttpRequest();
    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var response = String(doc.responseText);
            response = response.replace(/(<([^>]+)>)/ig, "");
            if (response.length > 6) {
                var data = response.split(',');
                var metadata = new Object();
                metadata = { "listenersCount": Number(data[0]),
                             "streaming": Boolean(data[1]),
                             "listenersPeak": Number(data[2]),
                             "listenersMax": Number(data[3]),
                             "listenersUnique": Number(data[4]),
                             "bitrate": Number(data[5]),
                             "track": String(data[6])};
                var i = 7;
                while (i < data.length) {
                    metadata.track += data[i];
                    i++;
                }
                callback(metadata);
            } else {
                callback(undefined);
            }
        }
    }
    doc.open("GET", url + "/7.html");
    doc.send();
}
