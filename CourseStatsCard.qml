import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string title: ""
    property int value: 0
    property string status: "total"
    property color cardColor: Material.backgroundColor
    property color accentColor: Material.accent

    color: "white"
    radius: 12
    border.color: Material.dividerColor
    border.width: 1

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
        anchors.margins: 20
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: 24
            color: root.cardColor

            Label {
                anchors.centerIn: parent
                text: root.getIcon()
                font.pixelSize: 24
            }
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
            font.pixelSize: 32
            font.weight: Font.Bold
            color: root.accentColor
        }

        Item { Layout.fillHeight: true }
    }

    function getIcon() {
        switch(status) {
            case "total": return "📚"
            case "draft": return "📝"
            case "pending_review": return "⏳"
            case "published": return "✅"
            case "rejected": return "❌"
            default: return "📚"
        }
    }

    function getColors() {
        switch(status) {
            case "total":
                cardColor = Material.color(Material.Blue, Material.Shade50)
                accentColor = Material.color(Material.Blue)
                break
            case "draft":
                cardColor = Material.color(Material.Grey, Material.Shade100)
                accentColor = Material.color(Material.Grey, Material.Shade700)
                break
            case "pending_review":
                cardColor = Material.color(Material.Orange, Material.Shade50)
                accentColor = Material.color(Material.Orange)
                break
            case "published":
                cardColor = Material.color(Material.Green, Material.Shade50)
                accentColor = Material.color(Material.Green)
                break
            case "rejected":
                cardColor = Material.color(Material.Red, Material.Shade50)
                accentColor = Material.color(Material.Red)
                break
        }
    }

    Component.onCompleted: getColors()
}
