import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    Component.onCompleted: {
        userController.loadStudents()
    }

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 24

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "User Management"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    color: "#18181B"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 36
                    width: refreshText.implicitWidth + 24
                    radius: 6
                    color: refreshMA.containsMouse ? "#F3F4F6" : "white"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Text {
                        id: refreshText
                        anchors.centerIn: parent
                        text: "↻ Refresh"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }

                    MouseArea {
                        id: refreshMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: userController.refresh()
                    }
                }
            }

            // Stats Cards
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Repeater {
                    model: [
                        { title: "Total Students", icon: "👥", bg: "#EEF2FF", val: userController.totalStudents },
                        { title: "Active Students", icon: "✓", bg: "#DCFCE7", val: userController.activeStudents },
                        { title: "Inactive Students", icon: "○", bg: "#F3F4F6", val: userController.inactiveStudents }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        height: 120
                        radius: 10
                        color: "white"
                        border.color: "#E5E7EB"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 8
                                    color: modelData.bg

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.icon
                                        font.pixelSize: 18
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            Text {
                                text: modelData.title
                                font.pixelSize: 12
                                color: "#6B7280"
                            }

                            Text {
                                text: modelData.val.toString()
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#18181B"
                            }
                        }
                    }
                }
            }

            // Filter Section
            Rectangle {
                Layout.fillWidth: true
                height: filterCol.implicitHeight + 24
                radius: 10
                color: "white"
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    id: filterCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Status Tabs
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Repeater {
                            model: [
                                { label: "All", value: "all" },
                                { label: "Active", value: "active" },
                                { label: "Inactive", value: "inactive" }
                            ]

                            Rectangle {
                                height: 34
                                width: tabLabel.implicitWidth + 24
                                radius: 6
                                color: {
                                    var isActive = userController.currentStatus === modelData.value
                                    if (isActive) return "#6366F1"
                                    if (tabMA.containsMouse) return "#F3F4F6"
                                    return "transparent"
                                }

                                Text {
                                    id: tabLabel
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.pixelSize: 13
                                    color: userController.currentStatus === modelData.value ? "white" : "#6B7280"
                                }

                                MouseArea {
                                    id: tabMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: userController.setStatusFilter(modelData.value)
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // Search Bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: 6
                            color: "white"
                            border.color: "#E5E7EB"
                            border.width: 1

                            TextInput {
                                id: searchInput
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                verticalAlignment: TextInput.AlignVCenter
                                font.pixelSize: 13
                                color: "#18181B"

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "🔍 Search by name or email..."
                                    font.pixelSize: 13
                                    color: "#9CA3AF"
                                    visible: searchInput.text.length === 0
                                }

                                onTextChanged: searchTimer.restart()

                                Timer {
                                    id: searchTimer
                                    interval: 500
                                    onTriggered: userController.setSearchQuery(searchInput.text)
                                }
                            }
                        }

                        Rectangle {
                            height: 40
                            width: clearText.implicitWidth + 24
                            radius: 6
                            color: clearMA.containsMouse ? "#F3F4F6" : "white"
                            border.color: "#E5E7EB"
                            border.width: 1
                            visible: searchInput.text.length > 0

                            Text {
                                id: clearText
                                anchors.centerIn: parent
                                text: "Clear"
                                font.pixelSize: 13
                                color: "#6B7280"
                            }

                            MouseArea {
                                id: clearMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    searchInput.text = ""
                                    userController.setSearchQuery("")
                                }
                            }
                        }
                    }
                }
            }

            // Students Table
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "white"
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Table Header
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: "#F9FAFB"

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: "#E5E7EB"
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            spacing: 16

                            Text {
                                Layout.preferredWidth: 312
                                text: "Student"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.preferredWidth: 120
                                text: "Status"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.preferredWidth: 150
                                text: "Joined"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Actions"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }
                        }
                    }

                    // Table Content
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Loading State
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16
                            visible: userController.isLoading

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "⏳"
                                font.pixelSize: 48
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Loading students..."
                                font.pixelSize: 13
                                color: "#9CA3AF"
                            }
                        }

                        // Empty State
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12
                            visible: !userController.isLoading && userController.students.length === 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "👥"
                                font.pixelSize: 48
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No students found"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "#18181B"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Try adjusting your filters or search query"
                                font.pixelSize: 13
                                color: "#9CA3AF"
                            }
                        }

                        // Students List
                        ScrollView {
                            anchors.fill: parent
                            visible: !userController.isLoading && userController.students.length > 0
                            clip: true

                            ColumnLayout {
                                width: parent.parent.width
                                spacing: 0

                                Repeater {
                                    model: userController.students

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 72
                                        color: rowMA.containsMouse ? "#F9FAFB" : "transparent"

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: 1
                                            color: "#F3F4F6"
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 24
                                            anchors.rightMargin: 24
                                            spacing: 16

                                            // Student Info
                                            RowLayout {
                                                Layout.preferredWidth: 312
                                                spacing: 12

                                                Rectangle {
                                                    width: 40
                                                    height: 40
                                                    radius: 20
                                                    color: "#EEF2FF"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.firstName ? modelData.firstName.charAt(0).toUpperCase() : "S"
                                                        font.pixelSize: 16
                                                        font.weight: Font.Medium
                                                        color: "#6366F1"
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.fullName || "Unknown"
                                                        font.pixelSize: 13
                                                        font.weight: Font.Medium
                                                        color: "#18181B"
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: modelData.email || ""
                                                        font.pixelSize: 12
                                                        color: "#6B7280"
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }
                                                }
                                            }

                                            // Status Badge
                                            Rectangle {
                                                Layout.preferredWidth: 120
                                                height: 24
                                                radius: 12
                                                color: modelData.isActive ? "#DCFCE7" : "#F3F4F6"

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.statusText || "Inactive"
                                                    font.pixelSize: 12
                                                    font.weight: Font.Medium
                                                    color: modelData.isActive ? "#16A34A" : "#6B7280"
                                                }
                                            }

                                            // Joined Date
                                            Text {
                                                Layout.preferredWidth: 150
                                                text: modelData.relativeDate || "Unknown"
                                                font.pixelSize: 13
                                                color: "#6B7280"
                                            }

                                            // Actions
                                            RowLayout {
                                                Layout.fillWidth: true

                                                Rectangle {
                                                    height: 32
                                                    width: viewText.implicitWidth + 20
                                                    radius: 6
                                                    color: viewMA.containsMouse ? "#EEF2FF" : "transparent"
                                                    border.color: "#E5E7EB"
                                                    border.width: 1

                                                    Text {
                                                        id: viewText
                                                        anchors.centerIn: parent
                                                        text: "View Details"
                                                        font.pixelSize: 12
                                                        color: "#6366F1"
                                                    }

                                                    MouseArea {
                                                        id: viewMA
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        onClicked: {
                                                            userDetailsDialog.student = modelData
                                                            userDetailsDialog.open()
                                                        }
                                                    }
                                                }

                                                Item { Layout.fillWidth: true }
                                            }
                                        }

                                        MouseArea {
                                            id: rowMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            propagateComposedEvents: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // User Details Dialog
    Dialog {
        id: userDetailsDialog

        property var student: ({})

        modal: true
        width: 480
        height: 560
        anchors.centerIn: parent

        background: Rectangle {
            color: "white"
            radius: 12
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 24

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Student Details"
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                    color: "#18181B"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: closeMA.containsMouse ? "#F3F4F6" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.pixelSize: 16
                        color: "#6B7280"
                    }

                    MouseArea {
                        id: closeMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: userDetailsDialog.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E5E7EB"
            }

            // Profile Image
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 96
                height: 96
                radius: 48
                color: "#EEF2FF"

                Text {
                    anchors.centerIn: parent
                    text: userDetailsDialog.student.firstName ?
                          userDetailsDialog.student.firstName.charAt(0).toUpperCase() : "S"
                    font.pixelSize: 40
                    font.weight: Font.Medium
                    color: "#6366F1"
                }
            }

            // Student Info
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 16
                rowSpacing: 16

                Text {
                    text: "Full Name:"
                    font.pixelSize: 13
                    color: "#6B7280"
                }
                Text {
                    text: userDetailsDialog.student.fullName || "Unknown"
                    font.pixelSize: 13
                    color: "#18181B"
                    Layout.fillWidth: true
                }

                Text {
                    text: "Email:"
                    font.pixelSize: 13
                    color: "#6B7280"
                }
                Text {
                    text: userDetailsDialog.student.email || "N/A"
                    font.pixelSize: 13
                    color: "#18181B"
                    Layout.fillWidth: true
                }

                Text {
                    text: "Student ID:"
                    font.pixelSize: 13
                    color: "#6B7280"
                }
                Text {
                    text: userDetailsDialog.student.id || "N/A"
                    font.pixelSize: 13
                    color: "#18181B"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: "Status:"
                    font.pixelSize: 13
                    color: "#6B7280"
                }
                Rectangle {
                    width: 80
                    height: 24
                    radius: 12
                    color: userDetailsDialog.student.isActive ? "#DCFCE7" : "#F3F4F6"

                    Text {
                        anchors.centerIn: parent
                        text: userDetailsDialog.student.statusText || "Inactive"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: userDetailsDialog.student.isActive ? "#16A34A" : "#6B7280"
                    }
                }

                Text {
                    text: "Join Date:"
                    font.pixelSize: 13
                    color: "#6B7280"
                }
                Text {
                    text: {
                        if (userDetailsDialog.student.createdAt) {
                            var date = new Date(userDetailsDialog.student.createdAt)
                            return Qt.formatDateTime(date, "MMMM dd, yyyy")
                        }
                        return "Unknown"
                    }
                    font.pixelSize: 13
                    color: "#18181B"
                    Layout.fillWidth: true
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#E5E7EB"
            }

            // Close Button
            Rectangle {
                Layout.fillWidth: true
                height: 40
                radius: 6
                color: closeBtnMA.containsMouse ? "#4F46E5" : "#6366F1"

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "white"
                }

                MouseArea {
                    id: closeBtnMA
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: userDetailsDialog.close()
                }
            }
        }
    }
}


