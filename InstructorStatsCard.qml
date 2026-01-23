import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string title: ""
    property int value: 0
    property color iconColor: Material.accent
    property color backgroundColor: Material.color(Material.Blue, Material.Shade50)
    property bool showBadge: false

    color: "white"
    radius: 12
    border.color: Material.dividerColor
    border.width: 1

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

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Icon Container
        Rectangle {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56
            Layout.alignment: Qt.AlignVCenter
            color: root.backgroundColor
            radius: 12

            Label {
                anchors.centerIn: parent
                text: root.getIcon()
                font.pixelSize: 28
                color: root.iconColor
            }

            // Badge for pending count
            Rectangle {
                visible: root.showBadge
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: -6
                width: 20
                height: 20
                radius: 10
                color: Material.color(Material.Red)

                Label {
                    anchors.centerIn: parent
                    text: "!"
                    color: "white"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            Label {
                text: root.title
                font.pixelSize: 14
                color: Material.hintTextColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Label {
                text: root.value
                font.pixelSize: 32
                font.weight: Font.Bold
                color: Material.foreground
            }
        }
    }

    function getIcon() {
        if (title.indexOf("Total") >= 0) return "👥"
        if (title.indexOf("Pending") >= 0) return "⏳"
        if (title.indexOf("Verified") >= 0) return "✓"
        if (title.indexOf("Rejected") >= 0) return "✕"
        return "📊"
    }
}
