import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#f8f9fa"

    signal navigateBack()
    signal showSuccessDialog()

    Flickable {
        anchors.fill: parent
        contentHeight: regContent.height
        clip: true

        RowLayout {
            id: regContent
            width: parent.width
            height: Math.max(800, leftColumn.height + 100)
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 700
                Layout.fillHeight: true
                color: "white"

                Column {
                    id: leftColumn
                    anchors.centerIn: parent
                    width: 440
                    spacing: 24

                    Rectangle {
                        width: 56; height: 56; radius: 12; color: "#1a1a1a"
                        anchors.horizontalCenter: parent.horizontalCenter
                        Text { text: "L"; color: "white"; font.pixelSize: 32; font.bold: true; anchors.centerIn: parent }
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        Text {
                            text: "Create Account"
                            font.pixelSize: 32
                            font.bold: true
                            color: "#1a1a1a"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: "Register as an instructor to get started"
                            color: "#6b7280"
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
                        spacing: 16

                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: "First Name"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#333"
                            }
                            TextField {
                                id: regFirstName
                                placeholderText: "John"
                                font.pixelSize: 15
                                width: parent.width
                                height: 52
                                leftPadding: 16
                                enabled: !authController || !authController.isLoading
                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: regFirstName.activeFocus ? "#1a1a1a" : "#e5e7eb"
                                    border.width: 1
                                }
                                onAccepted: regLastName.forceActiveFocus()
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: "Last Name"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#333"
                            }
                            TextField {
                                id: regLastName
                                placeholderText: "Doe"
                                font.pixelSize: 15
                                width: parent.width
                                height: 52
                                leftPadding: 16
                                enabled: !authController || !authController.isLoading
                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: regLastName.activeFocus ? "#1a1a1a" : "#e5e7eb"
                                    border.width: 1
                                }
                                onAccepted: regEmail.forceActiveFocus()
                            }
                        }

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
                                id: regEmail
                                placeholderText: "email@example.com"
                                font.pixelSize: 15
                                width: parent.width
                                height: 52
                                leftPadding: 16
                                enabled: !authController || !authController.isLoading
                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: regEmail.activeFocus ? "#1a1a1a" : "#e5e7eb"
                                    border.width: 1
                                }
                                onAccepted: regPassword.forceActiveFocus()
                            }
                        }

                        Column {
                            width: parent.width
                            spacing: 8
                            Text {
                                text: "Password"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: "#333"
                            }
                            TextField {
                                id: regPassword
                                placeholderText: "Min. 8 characters"
                                font.pixelSize: 15
                                width: parent.width
                                height: 52
                                leftPadding: 16
                                echoMode: TextInput.Password
                                enabled: !authController || !authController.isLoading
                                background: Rectangle {
                                    radius: 8
                                    color: "#ffffff"
                                    border.color: regPassword.activeFocus ? "#1a1a1a" : "#e5e7eb"
                                    border.width: 1
                                }
                                onAccepted: {
                                    if (regFirstName.text.trim().length >= 2 &&
                                        regLastName.text.trim().length >= 2 &&
                                        regEmail.text.includes("@") &&
                                        regPassword.text.length >= 8) {
                                        authController.registerUser(
                                            regFirstName.text.trim(),
                                            regLastName.text.trim(),
                                            regEmail.text.trim(),
                                            regPassword.text
                                        )
                                    }
                                }
                            }
                        }

                        Button {
                            text: (authController && authController.isLoading) ? "Creating Account..." : "Create Account"
                            width: parent.width
                            height: 52
                            enabled: (!authController || !authController.isLoading) &&
                                     regFirstName.text.trim().length >= 2 &&
                                     regLastName.text.trim().length >= 2 &&
                                     regEmail.text.includes("@") &&
                                     regPassword.text.length >= 8
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
                                authController.registerUser(
                                    regFirstName.text.trim(),
                                    regLastName.text.trim(),
                                    regEmail.text.trim(),
                                    regPassword.text
                                )
                            }
                        }

                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 4
                            Text {
                                text: "Already have an account?"
                                color: "#6b7280"
                                font.pixelSize: 14
                            }
                            Text {
                                text: "Sign in"
                                color: "#3b82f6"
                                font.pixelSize: 14
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
}
