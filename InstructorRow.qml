import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var instructor: ({})

    signal approveClicked()
    signal rejectClicked()
    signal revokeClicked()

    height: 80
    color: mouseArea.containsMouse ? Material.color(Material.Grey, Material.Shade50) : "transparent"

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
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

        // Instructor Info Column
        RowLayout {
            Layout.preferredWidth: 300
            spacing: 12

            // Profile Image
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: Material.color(Material.Grey, Material.Shade200)
                clip: true

                Image {
                    anchors.fill: parent
                    anchors.margins: 0
                    source: instructor.image || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: instructor.image && instructor.image.length > 0
                }

                Label {
                    anchors.centerIn: parent
                    text: root.getInitials()
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: Material.color(Material.Grey, Material.Shade700)
                    visible: !instructor.image || instructor.image.length === 0
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    text: instructor.fullName || ""
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: Material.foreground
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Label {
                    text: instructor.email || ""
                    font.pixelSize: 13
                    color: Material.hintTextColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        // Status Column
        Item {
            Layout.preferredWidth: 120

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: statusLabel.implicitWidth + 16
                height: 28
                radius: 14
                color: root.getStatusColor()

                Label {
                    id: statusLabel
                    anchors.centerIn: parent
                    text: root.getStatusText()
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: root.getStatusTextColor()
                }
            }
        }

        // Registered Column
        Label {
            Layout.preferredWidth: 150
            text: instructor.relativeDate || ""
            font.pixelSize: 14
            color: Material.hintTextColor
        }

        // Actions Column
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Pending status - show Approve and Reject buttons
            Button {
                visible: instructor.instructorStatus === "pending"
                text: "Approve"
                flat: false
                Material.background: Material.color(Material.Green)
                Material.foreground: "white"
                onClicked: root.approveClicked()
            }

            Button {
                visible: instructor.instructorStatus === "pending"
                text: "Reject"
                flat: false
                Material.background: Material.color(Material.Red)
                Material.foreground: "white"
                onClicked: root.rejectClicked()
            }

            // Verified status - show Revoke button
            Button {
                visible: instructor.instructorStatus === "verified"
                text: "Revoke"
                flat: false
                Material.background: Material.color(Material.Orange)
                Material.foreground: "white"
                onClicked: root.revokeClicked()
            }

            // Rejected status - show Approve button
            Button {
                visible: instructor.instructorStatus === "rejected"
                text: "Approve"
                flat: false
                Material.background: Material.color(Material.Green)
                Material.foreground: "white"
                onClicked: root.approveClicked()
            }

            Item { Layout.fillWidth: true }
        }
    }

    function getInitials() {
        if (!instructor.firstName && !instructor.lastName) return "?"

        var initials = ""
        if (instructor.firstName) initials += instructor.firstName.charAt(0).toUpperCase()
        if (instructor.lastName) initials += instructor.lastName.charAt(0).toUpperCase()
        return initials
    }

    function getStatusText() {
        var status = instructor.instructorStatus || ""
        return status.charAt(0).toUpperCase() + status.slice(1)
    }

    function getStatusColor() {
        var status = instructor.instructorStatus || ""
        if (status === "pending") return Material.color(Material.Orange, Material.Shade100)
        if (status === "verified") return Material.color(Material.Green, Material.Shade100)
        if (status === "rejected") return Material.color(Material.Red, Material.Shade100)
        return Material.color(Material.Grey, Material.Shade100)
    }

    function getStatusTextColor() {
        var status = instructor.instructorStatus || ""
        if (status === "pending") return Material.color(Material.Orange, Material.Shade900)
        if (status === "verified") return Material.color(Material.Green, Material.Shade900)
        if (status === "rejected") return Material.color(Material.Red, Material.Shade900)
        return Material.color(Material.Grey, Material.Shade900)
    }
}
