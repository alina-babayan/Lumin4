import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var student

    signal viewDetailsClicked()

    height: 80
    color: hoverHandler.hovered ? Material.color(Material.Grey, Material.Shade100) : "transparent"

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Material.dividerColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        spacing: 16

        // Student Info (Profile Image + Name + Email)
        RowLayout {
            Layout.preferredWidth: 300
            spacing: 12

            // Profile Image
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: Material.color(Material.Blue, Material.Shade100)

                Label {
                    anchors.centerIn: parent
                    text: student.firstName ? student.firstName.charAt(0).toUpperCase() : "S"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    color: Material.color(Material.Blue)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    text: student.fullName || "Unknown"
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Material.foreground
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Label {
                    text: student.email || ""
                    font.pixelSize: 13
                    color: Material.hintTextColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        // Status Badge
        Rectangle {
            Layout.preferredWidth: 120
            height: 28
            radius: 14
            color: student.isActive ?
                   Material.color(Material.Green, Material.Shade100) :
                   Material.color(Material.Grey, Material.Shade200)

            Label {
                anchors.centerIn: parent
                text: student.statusText || "Inactive"
                font.pixelSize: 13
                font.weight: Font.Medium
                color: student.isActive ?
                       Material.color(Material.Green, Material.Shade900) :
                       Material.color(Material.Grey, Material.Shade700)
            }
        }

        // Joined Date
        Label {
            Layout.preferredWidth: 150
            text: student.relativeDate || "Unknown"
            font.pixelSize: 14
            color: Material.hintTextColor
        }

        // Actions
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Button {
                text: "View Details"
                flat: true
                highlighted: true
                onClicked: root.viewDetailsClicked()
            }

            Item { Layout.fillWidth: true }
        }
    }
}
