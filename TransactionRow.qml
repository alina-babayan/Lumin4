import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var transaction

    height: 90
    color: hoverHandler.hovered ? Material.color(Material.Grey, Material.Shade100) : "transparent"

    HoverHandler {
        id: hoverHandler
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Material.dividerColor
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        spacing: 16

        // Order Number + Payment Method
        ColumnLayout {
            Layout.preferredWidth: 150
            spacing: 2

            Label {
                text: transaction.orderNumber || "N/A"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Material.foreground
            }

            Label {
                text: transaction.paymentMethodDisplay || ""
                font.pixelSize: 12
                color: Material.hintTextColor
            }
        }

        // Student Info
        RowLayout {
            Layout.preferredWidth: 200
            spacing: 12

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: Material.color(Material.Blue, Material.Shade100)

                Label {
                    anchors.centerIn: parent
                    text: transaction.studentName ? transaction.studentName.charAt(0).toUpperCase() : "S"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    color: Material.color(Material.Blue)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    text: transaction.studentName || "Unknown"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: Material.foreground
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Label {
                    text: transaction.studentEmail || ""
                    font.pixelSize: 11
                    color: Material.hintTextColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }

        // Courses
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: transaction.courses || []

                RowLayout {
                    spacing: 8

                    Label {
                        text: "•"
                        color: Material.accent
                    }

                    Label {
                        text: modelData.title || ""
                        font.pixelSize: 13
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Label {
                        text: modelData.formattedPrice || ""
                        font.pixelSize: 12
                        color: Material.hintTextColor
                    }
                }
            }
        }

        // Amount
        Label {
            Layout.preferredWidth: 100
            text: transaction.formattedAmount || "$0.00"
            font.pixelSize: 16
            font.weight: Font.Bold
            color: Material.color(Material.Green)
            horizontalAlignment: Text.AlignRight
        }

        // Status Badge
        Rectangle {
            Layout.preferredWidth: 100
            height: 28
            radius: 14
            color: {
                if (transaction.status === "completed")
                    return Material.color(Material.Green, Material.Shade100)
                else if (transaction.status === "failed")
                    return Material.color(Material.Red, Material.Shade100)
                else if (transaction.status === "refunded")
                    return Material.color(Material.Grey, Material.Shade200)
                return Material.color(Material.Grey, Material.Shade200)
            }

            Label {
                anchors.centerIn: parent
                text: transaction.statusText || "Unknown"
                font.pixelSize: 12
                font.weight: Font.Medium
                color: {
                    if (transaction.status === "completed")
                        return Material.color(Material.Green, Material.Shade900)
                    else if (transaction.status === "failed")
                        return Material.color(Material.Red, Material.Shade900)
                    else if (transaction.status === "refunded")
                        return Material.color(Material.Grey, Material.Shade700)
                    return Material.color(Material.Grey, Material.Shade700)
                }
            }
        }

        // Date
        ColumnLayout {
            Layout.preferredWidth: 150
            spacing: 2

            Label {
                text: transaction.formattedDate || "Unknown"
                font.pixelSize: 13
                color: Material.foreground
            }

            Label {
                text: transaction.relativeTime || ""
                font.pixelSize: 11
                color: Material.hintTextColor
            }
        }
    }
}

