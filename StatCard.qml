import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: statCard
    property string cardIcon: "📊"
    property string cardTitle: "Stat Title"
    property string cardValue: "0"
    property string cardSubtitle: ""

    color: "white"
    radius: 12
    border.color: "#E5E7EB"
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: statCard.cardIcon
                font.pixelSize: 20
                font.family: "Segoe UI Emoji"
            }
        }

        Text {
            text: statCard.cardTitle
            font.pixelSize: 13
            color: "#6B7280"
            Layout.fillWidth: true
        }

        Text {
            text: statCard.cardValue
            font.pixelSize: 24
            font.bold: true
            color: "#18181B"
            Layout.fillWidth: true
        }

        Text {
            text: statCard.cardSubtitle
            font.pixelSize: 12
            color: "#9CA3AF"
            Layout.fillWidth: true
            visible: statCard.cardSubtitle !== ""
        }

        Item { Layout.fillHeight: true }
    }
}
