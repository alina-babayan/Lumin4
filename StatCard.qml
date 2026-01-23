import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string title: ""
    property int value: 0
    property string icon: ""
    property color color: Material.accent

    radius: 12
    color: "white"
    border.width: 1
    border.color: Material.dividerColor

    // Hover effect
    scale: mouseArea.containsMouse ? 1.02 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: Qt.lighter(root.color, 1.8)

                Label {
                    anchors.centerIn: parent
                    text: root.icon
                    font.pixelSize: 24
                }
            }

            Item { Layout.fillWidth: true }
        }

        Label {
            text: root.title
            font.pixelSize: 14
            color: Material.hintTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Label {
            text: root.value
            font.pixelSize: 36
            font.weight: Font.Bold
            color: root.color
        }

        Item { Layout.fillHeight: true }
    }
}
