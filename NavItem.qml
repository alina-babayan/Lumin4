import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: navItem
    property string iconText: ""
    property string labelText: ""
    property bool isActive: false

    Layout.fillWidth: true
    height: 40
    radius: 8
    color: isActive ? "#F3F4F6" : (navMA.containsMouse ? "#F9FAFB" : "transparent")

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Text {
            text: navItem.iconText
            font.pixelSize: 16
            font.family: "Segoe UI Emoji"
        }

        Text {
            text: navItem.labelText
            color: navItem.isActive ? "#18181B" : "#6B7280"
            font.pixelSize: 13
            font.weight: navItem.isActive ? Font.Medium : Font.Normal
        }

        Item { Layout.fillWidth: true }
    }

    MouseArea {
        id: navMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
