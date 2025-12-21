import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#f8f9fa"

    signal navigateBack()

    property bool emailSent: false

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "white"

            Column {
                anchors.centerIn: parent
                width: Math.min(440, parent.width - 64)
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
                        text: "Forgot Password"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#1a1a1a"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Enter your email address to reset your password"
                        color: "#6b7280"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 8
                    color: "#FEE2E2"
                    visible: authController && authController.errorMessage !== ""
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

                Rectangle {
                    width: parent.width
                    height: 52
                    radius: 8
                    color: "#D1FAE5"
                    visible: root.emailSent
                    Text {
                        text: "✓ Reset link sent successfully! Check your email."
                        color: "#065F46"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                        width: parent.width - 32
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Column {
                    width: parent.width
                    spacing: 20

                    Column {
                        width: parent.width
                        spacing: 8
                        Text {
                            text: "Email"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#333"
                        }
                        TextField {
                            id: forgotEmailField
                            placeholderText: "Enter your email"
                            font.pixelSize: 15
                            width: parent.width
                            height: 52
                            leftPadding: 16
                            rightPadding: 16
                            enabled: !authController || !authController.isLoading
                            background: Rectangle {
                                radius: 8
                                color: "#ffffff"
                                border.color: forgotEmailField.activeFocus ? "#1a1a1a" : "#e5e7eb"
                                border.width: 1
                            }
                            onAccepted: {
                                if (forgotEmailField.text.includes("@")) {
                                    authController.forgotPassword(forgotEmailField.text.trim())
                                }
                            }
                        }
                    }

                    Button {
                        text: (authController && authController.isLoading) ? "Sending..." : "Send Reset Link"
                        width: parent.width
                        height: 52
                        enabled: (!authController || !authController.isLoading) && forgotEmailField.text.includes("@")
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
                            authController.clearError()
                            authController.forgotPassword(forgotEmailField.text.trim())
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
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f8f9fa"
            clip: true

            Image {
                source: "qrc:new/prefix1/first"
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
            }
        }
    }

    Connections {
        target: authController
        function onPasswordResetSent() {
            root.emailSent = true
            successTimer.start()
        }
    }

    Timer {
        id: successTimer
        interval: 3000
        onTriggered: {
            root.emailSent = false
            root.navigateBack()
        }
    }
}
