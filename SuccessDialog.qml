import QtQuick 2.15
import QtQuick.Controls 2.15

Popup {
    id: root
    modal: true
    focus: true
    anchors.centerIn: parent
    width: 400
    height: successContent.height + 64
    padding: 32
    closePolicy: Popup.NoAutoClose

    signal accepted()

    background: Rectangle {
        radius: 16
        color: "white"
        border.color: "#e5e7eb"
        border.width: 1
    }

    Column {
        id: successContent
        width: parent.width
        spacing: 24

        Rectangle {
            width: 64
            height: 64
            radius: 32
            color: "#D1FAE5"
            anchors.horizontalCenter: parent.horizontalCenter
            Text {
                text: "✓"
                color: "#10b981"
                font.pixelSize: 36
                font.bold: true
                anchors.centerIn: parent
            }
        }

        Column {
            width: parent.width
            spacing: 8
            Text {
                text: "Registration Successful!"
                font.pixelSize: 24
                font.bold: true
                color: "#1a1a1a"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "Your account has been created.\nPlease wait for admin approval before logging in."
                font.pixelSize: 14
                color: "#6b7280"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
        }

        Button {
            text: "Back to Login"
            width: parent.width
            height: 52
            background: Rectangle {
                radius: 8
                color: parent.pressed ? "#0f0f0f" : (parent.hovered ? "#2a2a2a" : "#1a1a1a")
            }
            contentItem: Text {
                text: parent.text
                color: "white"
                font.pixelSize: 16
                font.weight: Font.Medium
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                root.close()
                root.accepted()
            }
        }
    }
}
