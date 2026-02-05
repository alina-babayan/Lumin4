import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // Local state for form fields
    property string firstName: authController ? (authController.userName || "").split(" ")[0] : ""
    property string lastName: authController ? ((authController.userName || "").split(" ").length > 1 ? (authController.userName || "").split(" ")[1] : "") : ""
    property string email: authController ? (authController.userEmail || "") : ""

    property string currentPassword: ""
    property string newPassword: ""
    property string confirmPassword: ""

    property bool savingProfile: false
    property bool savingPassword: false
    property string successMessage: ""
    property string errorMessage: ""

    // Auto-dismiss messages
    Timer {
        id: msgTimer
        interval: 3000
        onTriggered: { successMessage = ""; errorMessage = "" }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        // Header
        Text {
            text: "Settings"
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: "#18181B"
        }
        Text {
            text: "Manage your account settings and preferences"
            font.pixelSize: 13
            color: "#6B7280"
        }

        // Toast messages
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 8
            color: "#DCFCE7"
            border.color: "#86EFAC"
            border.width: 1
            visible: successMessage.length > 0
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10
                Text { text: "✓"; font.pixelSize: 16; color: "#16A34A" }
                Text { text: successMessage; font.pixelSize: 13; color: "#15803D"; Layout.fillWidth: true }
            }
        }
        Rectangle {
            Layout.fillWidth: true
            height: 44
            radius: 8
            color: "#FEE2E2"
            border.color: "#FCA5A5"
            border.width: 1
            visible: errorMessage.length > 0
            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10
                Text { text: "✕"; font.pixelSize: 16; color: "#DC2626" }
                Text { text: errorMessage; font.pixelSize: 13; color: "#DC2626"; Layout.fillWidth: true }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 24

                // ===== PROFILE SETTINGS =====
                Rectangle {
                    Layout.fillWidth: true
                    radius: 10
                    color: "white"
                    border.color: "#E5E7EB"
                    border.width: 1
                    height: profileCol.implicitHeight + 48

                    ColumnLayout {
                        id: profileCol
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20

                        // Section title
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Profile Settings"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#18181B" }
                            Text { text: "Update your profile information"; font.pixelSize: 13; color: "#9CA3AF" }
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }

                        // Avatar
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20

                            Rectangle {
                                width: 80; height: 80; radius: 40
                                color: "#EEF2FF"
                                Text {
                                    anchors.centerIn: parent
                                    text: root.firstName ? root.firstName.charAt(0).toUpperCase() : "U"
                                    font.pixelSize: 32; font.weight: Font.Medium; color: "#4F46E5"
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Text { text: root.firstName + " " + root.lastName; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#18181B" }
                                RowLayout {
                                    spacing: 12
                                    Rectangle {
                                        height: 32; width: chPhotoTxt.implicitWidth + 24; radius: 6
                                        color: chPhotoMA.containsMouse ? "#F3F4F6" : "white"
                                        border.color: "#E5E7EB"; border.width: 1
                                        Text { id: chPhotoTxt; anchors.centerIn: parent; text: "Change Photo"; font.pixelSize: 12; color: "#4F46E5"; font.weight: Font.Medium }
                                        MouseArea { id: chPhotoMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                                    }
                                    Rectangle {
                                        height: 32; width: rmPhotoTxt.implicitWidth + 24; radius: 6
                                        color: rmPhotoMA.containsMouse ? "#FEF2F2" : "white"
                                        border.color: "#E5E7EB"; border.width: 1
                                        Text { id: rmPhotoTxt; anchors.centerIn: parent; text: "Remove Photo"; font.pixelSize: 12; color: "#9CA3AF" }
                                        MouseArea { id: rmPhotoMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                                    }
                                }
                            }
                        }

                        // Name fields
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 16

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Text { text: "First Name"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                TextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    text: root.firstName
                                    selectByMouse: true
                                    leftPadding: 12; rightPadding: 12
                                    background: Rectangle {
                                        radius: 6; color: "white"
                                        border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                        border.width: parent.activeFocus ? 2 : 1
                                    }
                                    onTextEdited: root.firstName = text
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Text { text: "Last Name"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                TextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    text: root.lastName
                                    selectByMouse: true
                                    leftPadding: 12; rightPadding: 12
                                    background: Rectangle {
                                        radius: 6; color: "white"
                                        border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                        border.width: parent.activeFocus ? 2 : 1
                                    }
                                    onTextEdited: root.lastName = text
                                }
                            }
                        }

                        // Email field
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text { text: "Email"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                text: root.email
                                selectByMouse: true
                                leftPadding: 12; rightPadding: 12
                                background: Rectangle {
                                    radius: 6; color: "white"
                                    border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                                onTextEdited: root.email = text
                            }
                        }

                        // Save Changes button
                        Rectangle {
                            height: 40; width: saveTxt.implicitWidth + 40; radius: 6
                            color: saveMA.containsMouse ? "#4338CA" : "#4F46E5"
                            Text { id: saveTxt; anchors.centerIn: parent; text: "Save Changes"; font.pixelSize: 14; font.weight: Font.Medium; color: "white" }
                            MouseArea {
                                id: saveMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.savingProfile = true
                                    // Simulate save (no actual API yet)
                                    saveTimer.restart()
                                }
                            }
                            Timer {
                                id: saveTimer
                                interval: 800
                                onTriggered: {
                                    root.savingProfile = false
                                    root.successMessage = "Profile updated successfully!"
                                    msgTimer.restart()
                                }
                            }
                        }
                    }
                }

                // ===== CHANGE PASSWORD =====
                Rectangle {
                    Layout.fillWidth: true
                    radius: 10
                    color: "white"
                    border.color: "#E5E7EB"
                    border.width: 1
                    height: passwordCol.implicitHeight + 48

                    ColumnLayout {
                        id: passwordCol
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 20

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Text { text: "Change Password"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#18181B" }
                            Text { text: "Update your password to keep your account secure"; font.pixelSize: 13; color: "#9CA3AF" }
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }

                        // Current password
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text { text: "Current Password"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                echoMode: TextField.Password
                                selectByMouse: true
                                leftPadding: 12; rightPadding: 12
                                placeholderText: "Enter current password"
                                background: Rectangle {
                                    radius: 6; color: "white"
                                    border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                                onTextEdited: root.currentPassword = text
                            }
                        }

                        // New password
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text { text: "New Password"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                echoMode: TextField.Password
                                selectByMouse: true
                                leftPadding: 12; rightPadding: 12
                                placeholderText: "Enter new password"
                                background: Rectangle {
                                    radius: 6; color: "white"
                                    border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                                onTextEdited: root.newPassword = text
                            }
                        }

                        // Confirm password
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Text { text: "Confirm New Password"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                echoMode: TextField.Password
                                selectByMouse: true
                                leftPadding: 12; rightPadding: 12
                                placeholderText: "Confirm new password"
                                background: Rectangle {
                                    radius: 6; color: "white"
                                    border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                    border.width: parent.activeFocus ? 2 : 1
                                }
                                onTextEdited: root.confirmPassword = text
                            }
                        }

                        // Update Password button
                        Rectangle {
                            height: 40; width: upTxt.implicitWidth + 40; radius: 6
                            color: upMA.containsMouse ? "#4338CA" : "#4F46E5"
                            Text { id: upTxt; anchors.centerIn: parent; text: "Update Password"; font.pixelSize: 14; font.weight: Font.Medium; color: "white" }
                            MouseArea {
                                id: upMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.currentPassword.length === 0) {
                                        root.errorMessage = "Please enter your current password"
                                        msgTimer.restart()
                                        return
                                    }
                                    if (root.newPassword.length < 6) {
                                        root.errorMessage = "New password must be at least 6 characters"
                                        msgTimer.restart()
                                        return
                                    }
                                    if (root.newPassword !== root.confirmPassword) {
                                        root.errorMessage = "Passwords do not match"
                                        msgTimer.restart()
                                        return
                                    }
                                    root.savingPassword = true
                                    pwTimer.restart()
                                }
                            }
                            Timer {
                                id: pwTimer
                                interval: 800
                                onTriggered: {
                                    root.savingPassword = false
                                    root.successMessage = "Password updated successfully!"
                                    root.currentPassword = ""
                                    root.newPassword = ""
                                    root.confirmPassword = ""
                                    msgTimer.restart()
                                }
                            }
                        }
                    }
                }

                Item { height: 24 }
            }
        }
    }
}

