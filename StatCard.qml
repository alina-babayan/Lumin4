import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string title: ""
    property string value: "0"
    property string icon: ""
    property color iconColor: Material.accent
    property color backgroundColor: Material.color(Material.Blue, Material.Shade50)

    radius: 8
    color: "white"
    border.color: Material.dividerColor
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Rectangle {
            width: 48
            height: 48
            radius: 8
            color: backgroundColor

            Label {
                anchors.centerIn: parent
                text: icon
                font.pixelSize: 24
                color: iconColor
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Label {
                text: title
                font.pixelSize: 13
                color: Material.hintTextColor
            }

            Label {
                text: value
                font.pixelSize: 28
                font.weight: Font.Bold
                color: Material.foreground
            }
        }
    }
}
