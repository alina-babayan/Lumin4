import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var notification
    signal clicked()

    height: 80
    color: {
        if (mouseArea.pressed) return Material.color(Material.Grey, Material.Shade200)
        if (mouseArea.containsMouse) return Material.color(Material.Grey, Material.Shade100)
        if (!notification.isRead) return Material.color(Material.Blue, Material.Shade50)
        return "transparent"
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Material.dividerColor
    }

    // Unread indicator
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 6
        height: 40
        radius: 3
        color: Material.accent
        visible: !notification.isRead
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: notification.isRead ? 16 : 24
        anchors.rightMargin: 16
        spacing: 12

        // Icon
        Rectangle {
            width: 40
            height: 40
            radius: 20
            color: Material.color(Material.Blue, Material.Shade100)

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: notification.icon || "qrc:/icons/bell.svg"
                sourceSize: Qt.size(20, 20)
            }
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: notification.title || ""
                font.pixelSize: 14
                font.weight: notification.isRead ? Font.Normal : Font.Bold
                color: Material.foreground
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 1
                elide: Text.ElideRight
            }

            Label {
                text: notification.message || ""
                font.pixelSize: 12
                color: Material.hintTextColor
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Label {
                text: notification.relativeTime || ""
                font.pixelSize: 11
                color: Material.hintTextColor
            }
        }
    }
}

