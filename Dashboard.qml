import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    anchors.fill: parent
    color: "#F3F4F6"

    signal logout()

    Component.onCompleted: {
        dashboardController.loadStats()
    }

    // Main Layout
    RowLayout {
        anchors.fill: parent
        spacing: 0

        // LEFT SIDEBAR
        Rectangle {
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: "#1F2937"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Logo Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "transparent"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 12

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 8
                            color: "#3B82F6"

                            Text {
                                text: "L"
                                color: "white"
                                font.pixelSize: 20
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        Text {
                            text: "Lumin Admin Panel"
                            color: "white"
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                        }
                    }
                }

                // Navigation Items
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 20
                    spacing: 4

                    NavItem { icon: "📊"; label: "Dashboard"; isActive: true }
                    NavItem { icon: "👥"; label: "Instructors" }
                    NavItem { icon: "📚"; label: "Courses" }
                    NavItem { icon: "👤"; label: "Users" }
                    NavItem { icon: "💳"; label: "Transactions" }
                    NavItem { icon: "⚙️"; label: "Settings" }
                }

                Item { Layout.fillHeight: true }

                // User Profile Section
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    color: "#111827"

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 12

                        Rectangle {
                            width: 40
                            height: 40
                            radius: 20
                            color: "#4B5563"

                            Text {
                                text: authController.userName ? authController.userName.charAt(0).toUpperCase() : "U"
                                color: "white"
                                font.pixelSize: 16
                                font.bold: true
                                anchors.centerIn: parent
                            }
                        }

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: authController.userName || "User"
                                color: "white"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }

                            Text {
                                text: authController.userEmail || "user@example.com"
                                color: "#9CA3AF"
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }

        // RIGHT CONTENT AREA
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Top Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "white"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 32
                    anchors.rightMargin: 32
                    spacing: 20

                    ColumnLayout {
                        spacing: 4

                        Text {
                            text: "Admin Dashboard"
                            font.pixelSize: 22
                            font.bold: true
                            color: "#111827"
                        }

                        Text {
                            text: "Welcome back! Here's an overview of your platform."
                            font.pixelSize: 13
                            color: "#6B7280"
                        }
                    }

                    Item { Layout.fillWidth: true }

                    TextField {
                        Layout.preferredWidth: 250
                        Layout.preferredHeight: 40
                        placeholderText: "Search anything..."
                        leftPadding: 12

                        background: Rectangle {
                            radius: 8
                            color: "#F9FAFB"
                            border.color: "#E5E7EB"
                            border.width: 1
                        }
                    }

                    Button {
                        text: "Logout"
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 80

                        background: Rectangle {
                            radius: 6
                            color: parent.pressed ? "#DC2626" : (parent.hovered ? "#EF4444" : "#F87171")
                        }

                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            authController.logout()
                            root.logout()
                        }
                    }
                }
            }

            // Main Content Area
            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentHeight: mainContent.height
                clip: true

                ColumnLayout {
                    id: mainContent
                    width: parent.width
                    spacing: 24

                    Item { height: 8 }

                    // Loading State
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        Layout.leftMargin: 32
                        Layout.rightMargin: 32
                        color: "transparent"
                        visible: dashboardController.isLoading

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16

                            BusyIndicator {
                                Layout.alignment: Qt.AlignHCenter
                                running: parent.parent.visible
                            }

                            Text {
                                text: "Loading dashboard statistics..."
                                color: "#6B7280"
                                font.pixelSize: 14
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }

                    // Error State
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: contentHeight + 40
                        Layout.leftMargin: 32
                        Layout.rightMargin: 32
                        radius: 8
                        color: "#FEE2E2"
                        border.color: "#FCA5A5"
                        border.width: 1
                        visible: !dashboardController.isLoading && dashboardController.errorMessage !== ""

                        property int contentHeight: errorContent.height

                        ColumnLayout {
                            id: errorContent
                            anchors.centerIn: parent
                            width: parent.width - 40
                            spacing: 16

                            Text {
                                text: "⚠️ " + dashboardController.errorMessage
                                color: "#DC2626"
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Button {
                                text: "Retry"
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredHeight: 36

                                background: Rectangle {
                                    radius: 6
                                    color: parent.pressed ? "#B91C1C" : (parent.hovered ? "#DC2626" : "#EF4444")
                                }

                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 13
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                onClicked: {
                                    dashboardController.clearError()
                                    dashboardController.loadStats()
                                }
                            }
                        }
                    }

                    // Stats Cards Grid
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 32
                        Layout.rightMargin: 32
                        columns: 4
                        rowSpacing: 20
                        columnSpacing: 20
                        visible: !dashboardController.isLoading && dashboardController.errorMessage === ""

                        StatCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140
                            iconText: "👥"
                            iconBg: "#EEF2FF"
                            iconColor: "#3B82F6"
                            title: "Total Instructors"
                            value: dashboardController.totalInstructors
                            subtitle: dashboardController.pendingInstructors + " pending verification"
                        }

                        StatCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140
                            iconText: "📚"
                            iconBg: "#ECFDF5"
                            iconColor: "#10B981"
                            title: "Total Courses"
                            value: dashboardController.totalCourses
                            subtitle: dashboardController.activeCourses + " active courses"
                        }

                        StatCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140
                            iconText: "🎓"
                            iconBg: "#FEF3C7"
                            iconColor: "#F59E0B"
                            title: "Total Students"
                            value: dashboardController.totalStudents
                            subtitle: dashboardController.activeStudents + " active students"
                        }

                        StatCard {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140
                            iconText: "💰"
                            iconBg: "#F5F3FF"
                            iconColor: "#8B5CF6"
                            title: "Total Revenue"
                            value: dashboardController.formattedTotalRevenue
                            subtitle: dashboardController.formattedMonthlyRevenue + " this month"
                            isRevenue: true
                        }
                    }

                    Item { height: 16 }
                }
            }
        }
    }
}

// Navigation Item Component
Component {
    id: navItemComponent

    Rectangle {
        property string icon: ""
        property string label: ""
        property bool isActive: false

        width: parent.width - 16
        height: 44
        radius: 8
        color: isActive ? "#374151" : (ma.containsMouse ? "#374151" : "transparent")

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            spacing: 12

            Text {
                text: parent.parent.icon
                font.pixelSize: 18
                font.family: "Segoe UI Emoji"
            }

            Text {
                text: parent.parent.label
                color: parent.parent.isActive ? "white" : "#D1D5DB"
                font.pixelSize: 14
                font.weight: parent.parent.isActive ? Font.Medium : Font.Normal
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }
}
