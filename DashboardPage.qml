import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    color: "#f8f9fa"

    Column {
        anchors.centerIn: parent
        spacing: 32

        Rectangle {
            width: 80
            height: 80
            radius: 40
            color: "#10b981"
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "✓"
                color: "white"
                font.pixelSize: 48
                font.bold: true
                anchors.centerIn: parent
            }
        }

        Text {
            text: "Login Successful!"
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 32
            color: "#1a1a1a"
            font.bold: true
        }

        Text {
            text: "Welcome back, " + (authController ? authController.userName : "")
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 16
            color: "#6b7280"
        }

        Button {
            text: "Logout"
            width: 200
            height: 52
            anchors.horizontalCenter: parent.horizontalCenter
            background: Rectangle {
                radius: 8
                color: parent.pressed ? "#dc2626" : (parent.hovered ? "#ef4444" : "#f87171")
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: authController.logout()
        }
    }
}
