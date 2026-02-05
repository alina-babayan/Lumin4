import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root

    property var student: ({})

    modal: true
    width: 500
    height: 600
    anchors.centerIn: parent
    title: "Student Details"

    ColumnLayout {
        anchors.fill: parent
        spacing: 24

        // Profile Image
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 120
            height: 120
            radius: 60
            color: Material.color(Material.Blue, Material.Shade100)

            Label {
                anchors.centerIn: parent
                text: student.firstName ? student.firstName.charAt(0).toUpperCase() : "S"
                font.pixelSize: 48
                font.weight: Font.Medium
                color: Material.color(Material.Blue)
            }
        }

        // Student Information
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 16
            rowSpacing: 16

            // Full Name
            Label {
                text: "Full Name:"
                font.weight: Font.Medium
                color: Material.hintTextColor
            }
            Label {
                text: student.fullName || "Unknown"
                Layout.fillWidth: true
            }

            // Email
            Label {
                text: "Email:"
                font.weight: Font.Medium
                color: Material.hintTextColor
            }
            Label {
                text: student.email || "N/A"
                Layout.fillWidth: true
            }

            // Student ID
            Label {
                text: "Student ID:"
                font.weight: Font.Medium
                color: Material.hintTextColor
            }
            Label {
                text: student.id || "N/A"
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // Account Status
            Label {
                text: "Account Status:"
                font.weight: Font.Medium
                color: Material.hintTextColor
            }
            Rectangle {
                Layout.preferredWidth: 100
                height: 28
                radius: 14
                color: student.isActive ?
                       Material.color(Material.Green, Material.Shade100) :
                       Material.color(Material.Grey, Material.Shade200)

                Label {
                    anchors.centerIn: parent
                    text: student.statusText || "Inactive"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: student.isActive ?
                           Material.color(Material.Green, Material.Shade900) :
                           Material.color(Material.Grey, Material.Shade700)
                }
            }

            // Join Date
            Label {
                text: "Join Date:"
                font.weight: Font.Medium
                color: Material.hintTextColor
            }
            Label {
                text: {
                    if (student.createdAt) {
                        var date = new Date(student.createdAt)
                        return Qt.formatDateTime(date, "MMMM dd, yyyy")
                    }
                    return "Unknown"
                }
                Layout.fillWidth: true
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }

    standardButtons: Dialog.Close
}
