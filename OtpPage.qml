import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#f8f9fa"
    signal navigateBack()

    // ─── Internal state ───────────────────────────────────────────────────────
    property var otpFields: []
    property bool handlingPaste: false   // guard to prevent re-entrant onTextChanged

    // ─── Helpers ──────────────────────────────────────────────────────────────
    function fullCode() {
        return otpFields.map(function(f){ return f.text }).join("")
    }

    function distributePaste(digits) {
        handlingPaste = true
        for (var i = 0; i < 6; i++) {
            otpFields[i].text = (i < digits.length) ? digits.charAt(i) : ""
        }
        handlingPaste = false

        var focusIdx = Math.min(digits.length, 5)
        otpFields[focusIdx].forceActiveFocus()

        if (digits.length >= 6) {
            Qt.callLater(function() { authController.verifyOtp(digits.substring(0, 6)) })
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // ─── Left panel ───────────────────────────────────────────────────────
        Rectangle {
            Layout.preferredWidth: 700
            Layout.fillHeight: true
            color: "white"

            Column {
                anchors.centerIn: parent
                width: 440
                spacing: 32

                // Logo
                Rectangle {
                    width: 56; height: 56; radius: 12; color: "#1a1a1a"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text { text: "L"; color: "white"; font.pixelSize: 32; font.bold: true; anchors.centerIn: parent }
                }

                // Title
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Text {
                        text: "Verify Your Login"
                        font.pixelSize: 32; font.bold: true; color: "#1a1a1a"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Enter the OTP to verify your login.\nA code has been sent to " +
                              (authController ? authController.maskedEmail : "")
                        color: "#6b7280"; font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                // Error banner
                Rectangle {
                    width: parent.width; height: 52; radius: 8; color: "#FEE2E2"
                    visible: authController && authController.errorMessage !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text {
                        text: authController ? authController.errorMessage : ""
                        color: "#DC2626"; font.pixelSize: 14
                        anchors.centerIn: parent; width: parent.width - 32
                        wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter
                    }
                }

                // OTP boxes
                Row {
                    spacing: 12
                    anchors.horizontalCenter: parent.horizontalCenter

                    Repeater {
                        model: 6
                        delegate: Rectangle {
                            width: 60; height: 64; radius: 8; color: "#ffffff"
                            border.color: otpInput.activeFocus ? "#1a1a1a" : "#e5e7eb"
                            border.width: otpInput.activeFocus ? 2 : 1

                            TextField {
                                id: otpInput
                                anchors.centerIn: parent
                                width: parent.width - 8; height: parent.height - 8
                                font.pixelSize: 28; font.bold: true
                                maximumLength: 6   // allow 6 chars so paste works
                                horizontalAlignment: TextInput.AlignHCenter
                                verticalAlignment: TextInput.AlignVCenter
                                color: "#1a1a1a"
                                enabled: !authController || !authController.isLoading
                                validator: RegularExpressionValidator { regularExpression: /[0-9]*/ }
                                background: Rectangle { color: "transparent" }

                                Component.onCompleted: {
                                    root.otpFields.push(otpInput)
                                    if (index === 0) Qt.callLater(function(){ otpInput.forceActiveFocus() })
                                }

                                onTextChanged: {
                                    if (root.handlingPaste) return   // ← avoid re-entry

                                    if (text.length === 0) return

                                    if (text.length === 1) {
                                        // Normal single digit typed
                                        if (index < 5) {
                                            root.otpFields[index + 1].forceActiveFocus()
                                        } else {
                                            var code = root.fullCode()
                                            if (code.length === 6) authController.verifyOtp(code)
                                        }
                                    } else {
                                        // Paste: multiple chars landed in this field
                                        var digits = text.replace(/\D/g, '').substring(0, 6)
                                        root.distributePaste(digits)
                                        // Clear this field last (guard prevents re-entry)
                                        root.handlingPaste = true
                                        text = (index < digits.length) ? digits.charAt(index) : ""
                                        root.handlingPaste = false
                                    }
                                }

                                Keys.onPressed: function(event) {
                                    if (event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete) {
                                        if (text.length === 0 && index > 0) {
                                            root.otpFields[index - 1].text = ""
                                            root.otpFields[index - 1].forceActiveFocus()
                                            event.accepted = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Verify button
                Button {
                    text: (authController && authController.isLoading) ? "Verifying..." : "Verify"
                    width: parent.width; height: 52
                    enabled: !authController || !authController.isLoading
                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ? (parent.pressed ? "#0f0f0f" : (parent.hovered ? "#2a2a2a" : "#1a1a1a")) : "#e5e7eb"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : "#9ca3af"
                        font.pixelSize: 16; font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var code = root.fullCode()
                        if (code.length === 6) authController.verifyOtp(code)
                    }
                }

                // Loading spinner (Issue 3)
                BusyIndicator {
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: authController && authController.isLoading
                    visible: running
                    width: 40; height: 40
                }

                // Resend
                Text {
                    id: resendText
                    property int resendSeconds: 60
                    text: resendTimer.running ? ("Resend code (" + resendSeconds + "s)") : "Resend code"
                    color: resendTimer.running ? "#9ca3af" : "#3b82f6"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: resendTimer.running ? Qt.ArrowCursor : Qt.PointingHandCursor
                        enabled: !resendTimer.running && (!authController || !authController.isLoading)
                        onClicked: { authController.resendOtp(); resendText.resendSeconds = 60; resendTimer.start() }
                    }
                    Timer {
                        id: resendTimer
                        interval: 1000; repeat: true; running: true
                        onTriggered: { resendText.resendSeconds--; if (resendText.resendSeconds <= 0) resendTimer.stop() }
                    }
                }

                // Back
                Text {
                    text: "← Back to login"
                    color: "#3b82f6"; font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: { authController.clearError(); root.navigateBack() }
                    }
                }
            }
        }

        // ─── Right panel ──────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: "#f8f9fa"; clip: true
            Image {
                source: "qrc:new/prefix1/first"
                anchors.fill: parent; anchors.centerIn: parent
                fillMode: Image.PreserveAspectCrop
            }
        }
    }

    Component.onCompleted: {
        if (root.otpFields.length > 0) root.otpFields[0].forceActiveFocus()
    }

    // Clear all fields and refocus on any error
    Connections {
        target: authController
        function onErrorMessageChanged() {
            if (authController.errorMessage !== "") {
                root.handlingPaste = true
                for (var i = 0; i < root.otpFields.length; i++) root.otpFields[i].text = ""
                root.handlingPaste = false
                if (root.otpFields.length > 0) root.otpFields[0].forceActiveFocus()
            }
        }
    }
}
