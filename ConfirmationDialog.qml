import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root

    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property color confirmColor: Material.accent
    property bool isLoading: false

    signal confirmed()
    signal cancelled()

    modal: true
    focus: true
    anchors.centerIn: parent
    width: Math.min(parent ? parent.width * 0.9 : 500, 500)

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Material.elevation: 8

    // Custom background
    background: Rectangle {
        color: Material.backgroundColor
        radius: 12
        border.color: Material.dividerColor
        border.width: 1
    }

    header: ToolBar {
        Material.elevation: 0
        background: Rectangle {
            color: "transparent"
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16

            Label {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: Material.foreground
                elide: Text.ElideRight
            }

            ToolButton {
                text: "✕"
                onClicked: root.close()
                enabled: !root.isLoading
            }
        }
    }

    contentItem: ColumnLayout {
        spacing: 24

        Label {
            Layout.fillWidth: true
            text: root.message
            wrapMode: Text.WordWrap
            font.pixelSize: 15
            color: Material.foreground
            textFormat: Text.StyledText
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Material.dividerColor
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item { Layout.fillWidth: true }

            Button {
                text: root.cancelText
                flat: true
                onClicked: {
                    root.cancelled()
                    root.close()
                }
                enabled: !root.isLoading
                Material.foreground: Material.hintTextColor
            }

            Button {
                id: confirmButton
                text: root.confirmText
                highlighted: true
                enabled: !root.isLoading
                Material.background: root.confirmColor

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    BusyIndicator {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        running: root.isLoading
                        visible: root.isLoading
                        Material.accent: "white"
                    }

                    Label {
                        text: confirmButton.text
                        color: "white"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        visible: !root.isLoading
                    }
                }

                onClicked: {
                    root.confirmed()
                    root.close()
                }
            }
        }
    }

    // Animation on open/close
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutQuad }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 150; easing.type: Easing.InQuad }
    }
}
