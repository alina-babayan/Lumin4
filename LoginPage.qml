import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#f8f9fa"

    signal navigateToOtp()
    signal navigateToForgotPassword()
    signal navigateToRegister()

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
                    Text {
                        text: "L"; color: "white"; font.pixelSize: 32
                        font.bold: true; anchors.centerIn: parent
                    }
                }

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    Text {
                        text: "Login"
                        font.pixelSize: 32
                        font.bold: true
                        color: "#1a1a1a"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        text: "Login with your email and password to continue"
                        color: "#666"
                        font.pixelSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
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
                            id: emailField
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
                                border.color: emailField.activeFocus ? "#1a1a1a" : "#e5e7eb"
                                border.width: 1
                            }
                            onAccepted: passwordField.forceActiveFocus()
                        }
                    }

                    Column {
                        id: passwordColumn
                        width: parent.width
                        spacing: 8
                        property bool passwordHidden: true

                        Text {
                            text: "Password"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#333"
                        }

                        Rectangle {
                            width: parent.width
                            height: 52
                            radius: 8
                            color: "#ffffff"
                            border.color: passwordField.activeFocus ? "#1a1a1a" : "#e5e7eb"
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 12
                                spacing: 8

                                TextField {
                                    id: passwordField
                                    placeholderText: "Enter your password"
                                    font.pixelSize: 15
                                    echoMode: passwordColumn.passwordHidden ? TextInput.Password : TextInput.Normal
                                    width: parent.width - 44
                                    anchors.verticalCenter: parent.verticalCenter
                                    background: Rectangle { color: "transparent" }
                                    leftPadding: 0
                                    rightPadding: 0
                                    enabled: !authController || !authController.isLoading
                                    onAccepted: {
                                        if (emailField.text.length > 0 && passwordField.text.length > 0) {
                                            authController.login(emailField.text.trim(), passwordField.text)
                                        }
                                    }
                                }

                                Rectangle {
                                    width: 32
                                    height: 32
                                    radius: 6
                                    color: eyeMouseArea.containsMouse ? "#f3f4f6" : "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Image {
                                        source: passwordColumn.passwordHidden
                                                ? "qrc:/new/prefix1/eye-off.png"
                                                : "qrc:/new/prefix1/eye.png"
                                        width: 18
                                        height: 18
                                        anchors.centerIn: parent
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    MouseArea {
                                        id: eyeMouseArea
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: passwordColumn.passwordHidden = !passwordColumn.passwordHidden
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        width: parent.width
                        spacing: 0
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Forgot Password?"
                            color: "#3b82f6"
                            font.pixelSize: 14
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    authController.clearError()
                                    root.navigateToForgotPassword()
                                }
                            }
                        }
                    }

                    Button {
                        text: (authController && authController.isLoading) ? "Logging in..." : "Login"
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
                            if (emailField.text.length > 0 && passwordField.text.length > 0) {
                                authController.login(emailField.text.trim(), passwordField.text)
                            }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4
                        Text {
                            text: "Don't have an account?"
                            color: "#6b7280"
                            font.pixelSize: 14
                        }
                        Text {
                            text: "Register as an instructor"
                            color: "#3b82f6"
                            font.pixelSize: 14
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    authController.clearError()
                                    root.navigateToRegister()
                                }
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
                fillMode: Image.PreserveAspectCrop
                anchors.centerIn: parent
            }
        }
    }
}
