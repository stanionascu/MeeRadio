import QtQuick 1.0
import QtMultimediaKit 1.1
import com.meego 1.0

Page {
    property alias streamTitle : titleLabel.text;
    property alias streamUrl : audioPlayer.source;
    property bool buffered : false;

    id: stationPlaybackPage;
    tools: ToolBarLayout {
        id: playBackTools;
        visible: true;
        ToolIcon {
            platformIconId: "toolbar-back";
            anchors.left: parent===undefined ? undefined : parent.left;
            onClicked: pageStack.pop();
        }
    }

    Label {
        id: titleLabel;
        width: parent.width;
        height: 90;
        anchors.top: parent.top;
        anchors.left: parent.left;
        font.pixelSize: 90;

        wrapMode: Text.NoWrap;
    }
    Label {
        id: statusLabel;
        width: parent.width;
        anchors.topMargin: 20;
        anchors.top: titleLabel.bottom;
        anchors.left: parent.left;
    }
    Label {
        id: artistLabel;
        width: parent.width;
        anchors.topMargin: 20;
        anchors.top: statusLabel.bottom;
        anchors.left: parent.left;
    }

    Audio {
        id: audioPlayer;
        autoLoad: true;

        onError: {
            errorDialog.titleText = qsTr("Error occured") + ": " + error;
            errorDialog.message = errorString;
            errorDialog.open();

            statusLabel.text = qsTr("Error occured") + ": " + errorString;
        }

        onStopped: {
            statusLabel.text = qsTr("Stopped") + "...";
        }

        onStatusChanged: {
            if (status == Audio.Buffering) {
                statusLabel.text = qsTr("Buffering") + "...";
            }
            else if (status == Audio.Buffered) {
                statusLabel.text = qsTr("Playing") + "...";
                artistLabel.text = metaData.publisher + " - " + metaData.genre;
                buffered = true;
            }
        }

        onBufferProgressChanged: {
            if (!buffered) {
                statusLabel.text = qsTr("Buffering") + "...";
            }
        }
    }

    QueryDialog {
        id: errorDialog;
        icon: "image://theme/icon-l-error";

        acceptButtonText: qsTr("OK");
    }

    function play() {
        statusLabel.text = qsTr("Connecting") + "..."
        artistLabel.text = streamUrl;
        audioPlayer.play();
    }

    function printMetaData() {
        console.log("albumArtist:" + audioPlayer.metaData.albumArtist);
        console.log("albumTitle:" + audioPlayer.metaData.albumTitle);
        console.log("audioBitRate:" + audioPlayer.metaData.audioBitRate);
        console.log("audioCodec:" + audioPlayer.metaData.audioCodec);
        console.log("author:" + audioPlayer.metaData.author);
        console.log("averageLevel:" + audioPlayer.metaData.averageLevel);
        console.log("category:" + audioPlayer.metaData.category);
        console.log("channelCount:" + audioPlayer.metaData.channelCount);
        console.log("chapterNumber:" + audioPlayer.metaData.chapterNumber);
        console.log("comment:" + audioPlayer.metaData.comment);
        console.log("composer:" + audioPlayer.metaData.composer);
        console.log("conductor:" + audioPlayer.metaData.conductor);
        console.log("contributingArtist:" + audioPlayer.metaData.contributingArtist);
        console.log("copyright:" + audioPlayer.metaData.copyright);
        console.log("coverArtUrlLarge:" + audioPlayer.metaData.coverArtUrlLarge);
        console.log("coverArtUrlSmall:" + audioPlayer.metaData.coverArtUrlSmall);
        console.log("date:" + audioPlayer.metaData.date);
        console.log("description:" + audioPlayer.metaData.description);
        console.log("director:" + audioPlayer.metaData.director);
        console.log("genre:" + audioPlayer.metaData.genre);
        console.log("keywords:" + audioPlayer.metaData.keywords);
        console.log("language:" + audioPlayer.metaData.language);
        console.log("leadPerformer:" + audioPlayer.metaData.leadPerformer);
        console.log("lyrics:" + audioPlayer.metaData.lyrics);
        console.log("mediaType:" + audioPlayer.metaData.mediaType);
        console.log("mood:" + audioPlayer.metaData.mood);
        console.log("parentalRating:" + audioPlayer.metaData.parentalRating);
        console.log("peakValue:" + audioPlayer.metaData.peakValue);
        console.log("pixelAspectRatio:" + audioPlayer.metaData.pixelAspectRatio);
        console.log("posterUrl:" + audioPlayer.metaData.posterUrl);
        console.log("publisher:" + audioPlayer.metaData.publisher);
        console.log("ratingOrganisation:" + audioPlayer.metaData.ratingOrganisation);
        console.log("resolution:" + audioPlayer.metaData.resolution);
        console.log("sampleRate:" + audioPlayer.metaData.sampleRate);
        console.log("size:" + audioPlayer.metaData.size);
        console.log("subTitle:" + audioPlayer.metaData.subTitle);
        console.log("title:" + audioPlayer.metaData.title);
        console.log("trackCount:" + audioPlayer.metaData.trackCount);
        console.log("trackNumber:" + audioPlayer.metaData.trackNumber);
        console.log("userRating:" + audioPlayer.metaData.userRating);
        console.log("videoBitRate:" + audioPlayer.metaData.videoBitRate);
        console.log("videoCodec:" + audioPlayer.metaData.videoCodec);
        console.log("videoFrameRate:" + audioPlayer.metaData.videoFrameRate);
        console.log("writer:" + audioPlayer.metaData.writer);
        console.log("year:" + audioPlayer.metaData.year);
    }
}
