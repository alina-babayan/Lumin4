import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // Local form state — synced from authController on load
    property string firstName: ""
    property string lastName: ""
    property string email: ""
    property string currentPassword: ""
    property string newPassword: ""
    property string confirmPassword: ""
    property string successMessage: ""
    property string errorMessage: ""

    // Sync fields whenever the user object changes
    function syncFromController() {
        var parts = (authController ? authController.userName || "" : "").split(" ")
        firstName = parts[0] || ""
        lastName  = parts.length > 1 ? parts.slice(1).join(" ") : ""
        email     = authController ? authController.userEmail || "" : ""
        firstNameField.text = firstName
        lastNameField.text  = lastName
        emailField.text     = email
    }

    Component.onCompleted: syncFromController()

    Connections {
        target: authController
        function onUserNameChanged()  { root.syncFromController() }
        function onUserEmailChanged() { root.syncFromController() }
        // Profile saved successfully
        function onProfileUpdated() {
            root.successMessage = "Profile updated successfully!"
            msgTimer.restart()
        }
        // Password changed successfully
        function onPasswordChanged() {
            root.successMessage = "Password updated successfully!"
            root.currentPassword = ""; root.newPassword = ""; root.confirmPassword = ""
            currentPwField.text = ""; newPwField.text = ""; confirmPwField.text = ""
            msgTimer.restart()
        }
        // Any error from authController
        function onErrorMessageChanged() {
            if (authController.errorMessage !== "") {
                root.errorMessage = authController.errorMessage
                msgTimer.restart()
            }
        }
    }

    Timer { id: msgTimer; interval: 4000; onTriggered: { root.successMessage = ""; root.errorMessage = "" } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        // Header
        Text { text: "Settings"; font.pixelSize: 24; font.weight: Font.DemiBold; color: "#18181B" }
        Text { text: "Manage your account settings and preferences"; font.pixelSize: 13; color: "#6B7280" }

        // Toast success
        Rectangle {
            Layout.fillWidth: true; height: 44; radius: 8
            color: "#DCFCE7"; border.color: "#86EFAC"; border.width: 1
            visible: root.successMessage.length > 0
            RowLayout { anchors.fill: parent; anchors.margins: 12; spacing: 10
                Text { text: "✓"; font.pixelSize: 16; color: "#16A34A" }
                Text { text: root.successMessage; font.pixelSize: 13; color: "#15803D"; Layout.fillWidth: true }
            }
        }

        // Toast error
        Rectangle {
            Layout.fillWidth: true; height: 44; radius: 8
            color: "#FEE2E2"; border.color: "#FCA5A5"; border.width: 1
            visible: root.errorMessage.length > 0
            RowLayout { anchors.fill: parent; anchors.margins: 12; spacing: 10
                Text { text: "✕"; font.pixelSize: 16; color: "#DC2626" }
                Text { text: root.errorMessage; font.pixelSize: 13; color: "#DC2626"; Layout.fillWidth: true }
            }
        }

        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true

            ColumnLayout {
                width: parent.width
                spacing: 24

                // ── Profile Settings ────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true; radius: 10; color: "white"
                    border.color: "#E5E7EB"; border.width: 1
                    height: profileCol.implicitHeight + 48

                    ColumnLayout {
                        id: profileCol
                        anchors.fill: parent; anchors.margins: 24; spacing: 20

                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Profile Settings"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#18181B" }
                            Text { text: "Update your profile information"; font.pixelSize: 13; color: "#9CA3AF" }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }

                        // Avatar row
                        RowLayout { Layout.fillWidth: true; spacing: 20
                            Rectangle {
                                width: 80; height: 80; radius: 40; color: "#EEF2FF"
                                Text {
                                    anchors.centerIn: parent
                                    text: root.firstName ? root.firstName.charAt(0).toUpperCase() : "U"
                                    font.pixelSize: 32; font.weight: Font.Medium; color: "#4F46E5"
                                }
                            }
                            ColumnLayout { Layout.fillWidth: true; spacing: 4
                                Text { text: root.firstName + " " + root.lastName; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#18181B" }
                                Text { text: root.email; font.pixelSize: 13; color: "#6B7280" }
                            }
                        }

                        // Name fields
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            ColumnLayout { Layout.fillWidth: true; spacing: 6
                                Text { text: "First Name"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                TextField {
                                    id: firstNameField
                                    Layout.fillWidth: true; Layout.preferredHeight: 40
                                    text: root.firstName; selectByMouse: true
                                    leftPadding: 12; rightPadding: 12
                                    enabled: !authController || !authController.isLoading
                                    background: Rectangle { radius: 6; color: "white"
                                        border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                        border.width: parent.activeFocus ? 2 : 1 }
                                    onTextEdited: root.firstName = text
                                }
                            }
                            ColumnLayout { Layout.fillWidth: true; spacing: 6
                                Text { text: "Last Name"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                TextField {
                                    id: lastNameField
                                    Layout.fillWidth: true; Layout.preferredHeight: 40
                                    text: root.lastName; selectByMouse: true
                                    leftPadding: 12; rightPadding: 12
                                    enabled: !authController || !authController.isLoading
                                    background: Rectangle { radius: 6; color: "white"
                                        border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                        border.width: parent.activeFocus ? 2 : 1 }
                                    onTextEdited: root.lastName = text
                                }
                            }
                        }

                        // Email (read-only)
                        ColumnLayout { Layout.fillWidth: true; spacing: 6
                            Text { text: "Email"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                id: emailField
                                Layout.fillWidth: true; Layout.preferredHeight: 40
                                text: root.email; selectByMouse: true; readOnly: true
                                leftPadding: 12; rightPadding: 12
                                background: Rectangle { radius: 6; color: "#F9FAFB"
                                    border.color: "#E5E7EB"; border.width: 1 }
                            }
                            Text { text: "Email cannot be changed"; font.pixelSize: 11; color: "#9CA3AF" }
                        }

                        // Save + spinner
                        RowLayout { spacing: 12
                            Rectangle {
                                height: 40; width: saveTxt.implicitWidth + 40; radius: 6
                                color: saveMA.containsMouse ? "#4338CA" : "#4F46E5"
                                enabled: !authController || !authController.isLoading
                                opacity: enabled ? 1.0 : 0.6
                                Text { id: saveTxt; anchors.centerIn: parent; text: "Save Changes"; font.pixelSize: 14; font.weight: Font.Medium; color: "white" }
                                MouseArea {
                                    id: saveMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    enabled: !authController || !authController.isLoading
                                    onClicked: {
                                        root.successMessage = ""; root.errorMessage = ""
                                        authController.updateProfile(root.firstName, root.lastName)
                                    }
                                }
                            }
                            BusyIndicator {
                                running: authController && authController.isLoading
                                visible: running; width: 28; height: 28
                            }
                        }
                    }
                }

                // ── Change Password ─────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true; radius: 10; color: "white"
                    border.color: "#E5E7EB"; border.width: 1
                    height: passwordCol.implicitHeight + 48

                    ColumnLayout {
                        id: passwordCol
                        anchors.fill: parent; anchors.margins: 24; spacing: 20

                        ColumnLayout { Layout.fillWidth: true; spacing: 4
                            Text { text: "Change Password"; font.pixelSize: 18; font.weight: Font.DemiBold; color: "#18181B" }
                            Text { text: "Update your password to keep your account secure"; font.pixelSize: 13; color: "#9CA3AF" }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }

                        ColumnLayout { Layout.fillWidth: true; spacing: 6
                            Text { text: "Current Password"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                id: currentPwField
                                Layout.fillWidth: true; Layout.preferredHeight: 40
                                echoMode: TextField.Password; selectByMouse: true
                                leftPadding: 12; rightPadding: 12; placeholderText: "Enter current password"
                                enabled: !authController || !authController.isLoading
                                background: Rectangle { radius: 6; color: "white"
                                    border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                    border.width: parent.activeFocus ? 2 : 1 }
                                onTextEdited: root.currentPassword = text
                            }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 6
                            Text { text: "New Password"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                id: newPwField
                                Layout.fillWidth: true; Layout.preferredHeight: 40
                                echoMode: TextField.Password; selectByMouse: true
                                leftPadding: 12; rightPadding: 12; placeholderText: "Enter new password (min 8 chars)"
                                enabled: !authController || !authController.isLoading
                                background: Rectangle { radius: 6; color: "white"
                                    border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                    border.width: parent.activeFocus ? 2 : 1 }
                                onTextEdited: root.newPassword = text
                            }
                        }
                        ColumnLayout { Layout.fillWidth: true; spacing: 6
                            Text { text: "Confirm New Password"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                            TextField {
                                id: confirmPwField
                                Layout.fillWidth: true; Layout.preferredHeight: 40
                                echoMode: TextField.Password; selectByMouse: true
                                leftPadding: 12; rightPadding: 12; placeholderText: "Confirm new password"
                                enabled: !authController || !authController.isLoading
                                background: Rectangle { radius: 6; color: "white"
                                    border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"
                                    border.width: parent.activeFocus ? 2 : 1 }
                                onTextEdited: root.confirmPassword = text
                            }
                        }

                        // Update password + spinner
                        RowLayout { spacing: 12
                            Rectangle {
                                height: 40; width: upTxt.implicitWidth + 40; radius: 6
                                color: upMA.containsMouse ? "#4338CA" : "#4F46E5"
                                enabled: !authController || !authController.isLoading
                                opacity: enabled ? 1.0 : 0.6
                                Text { id: upTxt; anchors.centerIn: parent; text: "Update Password"; font.pixelSize: 14; font.weight: Font.Medium; color: "white" }
                                MouseArea {
                                    id: upMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    enabled: !authController || !authController.isLoading
                                    onClicked: {
                                        root.successMessage = ""; root.errorMessage = ""
                                        if (root.currentPassword.length === 0) {
                                            root.errorMessage = "Please enter your current password"; msgTimer.restart(); return
                                        }
                                        if (root.newPassword.length < 8) {
                                            root.errorMessage = "New password must be at least 8 characters"; msgTimer.restart(); return
                                        }
                                        if (root.newPassword !== root.confirmPassword) {
                                            root.errorMessage = "Passwords do not match"; msgTimer.restart(); return
                                        }
                                        authController.changePassword(root.currentPassword, root.newPassword)
                                    }
                                }
                            }
                            BusyIndicator {
                                running: authController && authController.isLoading
                                visible: running; width: 28; height: 28
                            }
                        }
                    }
                }

                Item { height: 24 }
            }
        }
    }
}
