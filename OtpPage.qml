import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#f8f9fa"

    signal navigateBack()

    property var otpFields: []

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 700
            Layout.fillHeight: true
            color: "white"

            Column {
                anchors.centerIn: parent
                width: 440
                spacing: 32

                Rectangle {
                    width: 56; height: 56; radius: 12; color: "#1a1a1a"
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text { text: "L"; color: "white"; font.pixelSize: 32; font.bold: true; anchors.centerIn: parent }
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Text {
                        text: "Verify Your Login"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#1a1a1a"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Enter the OTP(one time password) to verify your login.\nA code has been sent to " + (authController ? authController.maskedEmail : "")
                        color: "#6b7280"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 8
                    color: "#FEE2E2"
                    visible: authController && authController.errorMessage !== ""
                    anchors.horizontalCenter: parent.horizontalCenter
                    Text {
                        text: authController ? authController.errorMessage : ""
                        color: "#DC2626"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                        width: parent.width - 32
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Row {
                    spacing: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                    Repeater {
                        model: 6
                        delegate: Rectangle {
                            width: 60
                            height: 64
                            radius: 8
                            color: "#ffffff"
                            border.color: otpInput.activeFocus ? "#1a1a1a" : "#e5e7eb"
                            border.width: otpInput.activeFocus ? 2 : 1

                            TextField {
                                id: otpInput
                                anchors.centerIn: parent
                                width: parent.width - 8
                                height: parent.height - 8
                                font.pixelSize: 28
                                font.bold: true
                                maximumLength: 1
                                horizontalAlignment: TextInput.AlignHCenter
                                verticalAlignment: TextInput.AlignVCenter
                                color: "#1a1a1a"
                                enabled: !authController || !authController.isLoading
                                validator: RegularExpressionValidator { regularExpression: /[0-9]/ }

                                background: Rectangle {
                                    color: "transparent"
                                }

                                Component.onCompleted: {
                                    root.otpFields.push(otpInput)
                                    if (index === 0) {
                                        Qt.callLater(function() {
                                            otpInput.forceActiveFocus()
                                        })
                                    }
                                }

                                onTextChanged: {
                                    if (text.length === 1) {
                                        if (index < 5) {
                                            root.otpFields[index + 1].forceActiveFocus()
                                        } else {
                                            let code = root.otpFields.map(function(input) {
                                                return input.text
                                            }).join("")
                                            if (code.length === 6) {
                                                authController.verifyOtp(code)
                                            }
                                        }
                                    }
                                    else if (text.length > 1) {
                                        handlePaste(text)
                                    }
                                }

                                Keys.onPressed: function(event) {
                                    if ((event.key === Qt.Key_Backspace || event.key === Qt.Key_Delete)) {
                                        if (text.length === 0 && index > 0) {
                                            root.otpFields[index - 1].text = ""
                                            root.otpFields[index - 1].forceActiveFocus()
                                            event.accepted = true
                                        }
                                    }
                                }

                                function handlePaste(pastedText) {
                                    let digits = pastedText.replace(/\D/g, '')

                                    if (digits.length === 0) return

                                    for (let i = 0; i < 6; i++) {
                                        root.otpFields[i].text = ""
                                    }

                                    for (let i = 0; i < Math.min(digits.length, 6); i++) {
                                        root.otpFields[i].text = digits.charAt(i)
                                    }

                                    if (digits.length >= 6) {
                                        root.otpFields[5].forceActiveFocus()
                                        Qt.callLater(function() {
                                            authController.verifyOtp(digits.substring(0, 6))
                                        })
                                    } else {
                                        let nextIndex = Math.min(digits.length, 5)
                                        root.otpFields[nextIndex].forceActiveFocus()
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.IBeamCursor
                                    acceptedButtons: Qt.LeftButton
                                    onPressed: function(mouse) {
                                        otpInput.forceActiveFocus()
                                        mouse.accepted = false
                                    }
                                }
                            }
                        }
                    }
                }

                Button {
                    text: (authController && authController.isLoading) ? "Verifying..." : "Verify"
                    width: parent.width
                    height: 52
                    enabled: !authController || !authController.isLoading
                    background: Rectangle {
                        radius: 8
                        color: parent.enabled ? (parent.pressed ? "#0f0f0f" : (parent.hovered ? "#2a2a2a" : "#1a1a1a")) : "#e5e7eb"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "white" : "#9ca3af"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        let code = root.otpFields.map(b => b.text).join("")
                        if (code.length === 6) {
                            authController.verifyOtp(code)
                        }
                    }
                }

                Text {
                    id: resendText
                    text: resendTimer.running ? ("Resend code (" + resendSeconds + "s)") : "Resend code"
                    color: resendTimer.running ? "#9ca3af" : "#3b82f6"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int resendSeconds: 60

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: resendTimer.running ? Qt.ArrowCursor : Qt.PointingHandCursor
                        enabled: !resendTimer.running && (!authController || !authController.isLoading)
                        onClicked: {
                            authController.resendOtp()
                            resendText.resendSeconds = 60
                            resendTimer.start()
                        }
                    }

                    Timer {
                        id: resendTimer
                        interval: 1000
                        repeat: true
                        running: true
                        onTriggered: {
                            resendText.resendSeconds--
                            if (resendText.resendSeconds <= 0) {
                                resendTimer.stop()
                            }
                        }
                    }
                }

                Text {
                    text: "← Back to login"
                    color: "#3b82f6"
                    font.pixelSize: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            authController.clearError()
                            root.navigateBack()
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f8f9fa"
            clip: true

            Image {
                source: "qrc:new/prefix1/first"
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                anchors.centerIn: parent
            }
        }
    }

    Component.onCompleted: {
        if (root.otpFields.length > 0) root.otpFields[0].forceActiveFocus()
    }

    Connections {
        target: authController
        function onErrorMessageChanged() {
            if (authController.errorMessage !== "") {
                for (var i = 0; i < root.otpFields.length; i++) {
                    root.otpFields[i].text = ""
                }
                if (root.otpFields.length > 0) {
                    root.otpFields[0].forceActiveFocus()
                }
            }
        }
    }
}
