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

XmlListModel {
    property string genre: "";
    id: tunesModel;

    xml: SHOUTcastXML.stations[tunesModel.genre];
    query: "/stationlist/station";

    XmlRole {
        name: "id";
        query: "@id/number()";
    }
    XmlRole {
        name: "name";
        query: "@name/string()";
    }
    XmlRole {
        name: "bitRate";
        query: "@bt/number()";
    }
    XmlRole {
        name: "genre";
        query: "@genre/string()";
    }

    onGenreChanged: {
        SHOUTcastXML.loadStationsCache(genre);
    }
}
