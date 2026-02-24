import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    Component.onCompleted: {
        instructorController.reloadTokens()
        instructorController.loadInstructors()
    }

    // Toast notification
    property string toastMessage: ""
    property bool toastSuccess: true

    Timer {
        id: toastTimer
        interval: 3500
        onTriggered: toastMessage = ""
    }

    function showToast(msg, success) {
        toastMessage = msg
        toastSuccess = success !== false
        toastTimer.restart()
    }

    Connections {
        target: instructorController
        function onInstructorUpdated(message) {
            showToast(message, true)
        }
        function onActionFailed(error) {
            showToast(error, false)
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        // Toast Banner
        Rectangle {
            id: toastBar
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: toastText.implicitWidth + 48
            height: 44
            radius: 22
            color: root.toastSuccess ? "#DCFCE7" : "#FEE2E2"
            border.color: root.toastSuccess ? "#86EFAC" : "#FCA5A5"
            border.width: 1
            visible: root.toastMessage.length > 0
            z: 10
            anchors.topMargin: 16

            RowLayout {
                anchors.centerIn: parent
                spacing: 8
                Text {
                    text: root.toastSuccess ? "✓" : "✕"
                    font.pixelSize: 14
                    color: root.toastSuccess ? "#16A34A" : "#DC2626"
                }
                Text {
                    id: toastText
                    text: root.toastMessage
                    font.pixelSize: 13
                    color: root.toastSuccess ? "#15803D" : "#DC2626"
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 24

            // Header
            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    spacing: 4
                    Text {
                        text: "Instructors Management"
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        color: "#18181B"
                    }
                    Text {
                        text: "Manage instructor accounts and applications"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    height: 36
                    width: refreshBtnText.implicitWidth + 24
                    radius: 6
                    color: refreshBtnMA.containsMouse ? "#F3F4F6" : "white"
                    border.color: "#E5E7EB"
                    border.width: 1
                    Text {
                        id: refreshBtnText
                        anchors.centerIn: parent
                        text: "↻ Refresh"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                    MouseArea {
                        id: refreshBtnMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            instructorController.reloadTokens()
                            instructorController.refresh()
                        }
                    }
                }
            }

            // Stats Cards
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Repeater {
                    model: [
                        { title: "Total Instructors", icon: "👥", bg: "#EEF2FF", val: instructorController.totalInstructors },
                        { title: "Pending Requests",  icon: "⏳", bg: "#FEF3C7", val: instructorController.pendingInstructors },
                        { title: "Verified",          icon: "✓",  bg: "#DCFCE7", val: instructorController.verifiedInstructors },
                        { title: "Rejected",          icon: "✕",  bg: "#FEE2E2", val: instructorController.rejectedInstructors }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        height: 110
                        radius: 10
                        color: "white"
                        border.color: "#E5E7EB"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 14

                            Rectangle {
                                width: 44; height: 44; radius: 10
                                color: modelData.bg
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.icon
                                    font.pixelSize: 20
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4
                                Text {
                                    text: modelData.title
                                    font.pixelSize: 12
                                    color: "#6B7280"
                                }
                                Text {
                                    text: modelData.val.toString()
                                    font.pixelSize: 30
                                    font.weight: Font.Bold
                                    color: "#18181B"
                                }
                            }
                        }
                    }
                }
            }

            // Filter Tabs + Search
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

                    // Status tabs
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                { label: "All",     value: "all" },
                                { label: "Pending (" + instructorController.pendingInstructors + ")", value: "pending" },
                                { label: "Verified", value: "verified" },
                                { label: "Rejected", value: "rejected" }
                            ]

                            Rectangle {
                                height: 34
                                width: tabLbl.implicitWidth + 24
                                radius: 17
                                color: {
                                    var active = instructorController.currentStatus === modelData.value
                                    if (active) return "#E91E8C"
                                    if (tabMA.containsMouse) return "#F3F4F6"
                                    return "transparent"
                                }
                                Text {
                                    id: tabLbl
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.pixelSize: 13
                                    color: instructorController.currentStatus === modelData.value ? "white" : "#6B7280"
                                }
                                MouseArea {
                                    id: tabMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: instructorController.setStatusFilter(modelData.value)
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }

                    // Search bar
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

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
                                    onTriggered: instructorController.setSearchQuery(searchInput.text)
                                }
                            }
                        }

                        Rectangle {
                            height: 40
                            width: searchBtnText.implicitWidth + 24
                            radius: 6
                            color: searchBtnMA.containsMouse ? "#C81779" : "#E91E8C"

                            Text {
                                id: searchBtnText
                                anchors.centerIn: parent
                                text: "Search"
                                font.pixelSize: 13
                                color: "white"
                            }
                            MouseArea {
                                id: searchBtnMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: instructorController.setSearchQuery(searchInput.text)
                            }
                        }
                    }
                }
            }

            // Table
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
                        height: 44
                        color: "#F9FAFB"
                        radius: 10

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: "#E5E7EB"
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 20
                            anchors.rightMargin: 20
                            spacing: 0

                            Text {
                                Layout.preferredWidth: 280
                                text: "Instructor"
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
                                Layout.preferredWidth: 130
                                text: "Registered"
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

                    // Table Body
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Loading
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12
                            visible: instructorController.isLoading
                            BusyIndicator {
                                Layout.alignment: Qt.AlignHCenter
                                running: instructorController.isLoading
                                palette.dark: "#E91E8C"
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Loading instructors..."
                                font.pixelSize: 13
                                color: "#9CA3AF"
                            }
                        }

                        // Empty state
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12
                            visible: !instructorController.isLoading && instructorController.instructors.length === 0
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "👥"
                                font.pixelSize: 48
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No instructors found"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "#18181B"
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Try changing filters or search query"
                                font.pixelSize: 13
                                color: "#9CA3AF"
                            }
                        }

                        // Instructor list
                        ScrollView {
                            anchors.fill: parent
                            visible: !instructorController.isLoading && instructorController.instructors.length > 0
                            clip: true
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            ColumnLayout {
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    model: instructorController.instructors

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
                                            anchors.leftMargin: 20
                                            anchors.rightMargin: 20
                                            spacing: 0

                                            // Instructor info
                                            RowLayout {
                                                Layout.preferredWidth: 280
                                                spacing: 12

                                                Rectangle {
                                                    width: 40; height: 40; radius: 20
                                                    color: "#EEF2FF"
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.firstName ? modelData.firstName.charAt(0).toUpperCase() : "?"
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
                                                color: {
                                                    var s = modelData.instructorStatus || ""
                                                    if (s === "verified") return "#DCFCE7"
                                                    if (s === "rejected") return "#FEE2E2"
                                                    return "#FEF3C7"
                                                }
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: {
                                                        var s = modelData.instructorStatus || "pending"
                                                        return s.charAt(0).toUpperCase() + s.slice(1)
                                                    }
                                                    font.pixelSize: 11
                                                    font.weight: Font.Medium
                                                    color: {
                                                        var s = modelData.instructorStatus || ""
                                                        if (s === "verified") return "#16A34A"
                                                        if (s === "rejected") return "#DC2626"
                                                        return "#D97706"
                                                    }
                                                }
                                            }

                                            // Registered date
                                            Text {
                                                Layout.preferredWidth: 130
                                                text: modelData.relativeDate || "Unknown"
                                                font.pixelSize: 13
                                                color: "#6B7280"
                                            }

                                            // Action Buttons
                                            RowLayout {
                                                Layout.fillWidth: true
                                                spacing: 8

                                                // Approve button - show for pending/rejected
                                                Rectangle {
                                                    height: 32
                                                    width: approveTxt.implicitWidth + 20
                                                    radius: 6
                                                    visible: modelData.instructorStatus !== "verified"
                                                    color: approveMA.containsMouse ? "#15803D" : "#16A34A"

                                                    Text {
                                                        id: approveTxt
                                                        anchors.centerIn: parent
                                                        text: "Approve"
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                        color: "white"
                                                    }
                                                    MouseArea {
                                                        id: approveMA
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        enabled: !instructorController.isLoading
                                                        onClicked: {
                                                            instructorController.approveInstructor(modelData.id)
                                                        }
                                                    }
                                                }

                                                // Reject button - show for pending/verified
                                                Rectangle {
                                                    height: 32
                                                    width: rejectTxt.implicitWidth + 20
                                                    radius: 6
                                                    visible: modelData.instructorStatus !== "rejected"
                                                    color: rejectMA.containsMouse ? "#B91C1C" : "#DC2626"

                                                    Text {
                                                        id: rejectTxt
                                                        anchors.centerIn: parent
                                                        text: "Reject"
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                        color: "white"
                                                    }
                                                    MouseArea {
                                                        id: rejectMA
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        enabled: !instructorController.isLoading
                                                        onClicked: {
                                                            instructorController.rejectInstructor(modelData.id)
                                                        }
                                                    }
                                                }

                                                // Revoke button - show only for verified
                                                Rectangle {
                                                    height: 32
                                                    width: revokeTxt.implicitWidth + 20
                                                    radius: 6
                                                    visible: modelData.instructorStatus === "verified"
                                                    color: revokeMA.containsMouse ? "#4B5563" : "#6B7280"

                                                    Text {
                                                        id: revokeTxt
                                                        anchors.centerIn: parent
                                                        text: "Revoke"
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                        color: "white"
                                                    }
                                                    MouseArea {
                                                        id: revokeMA
                                                        anchors.fill: parent
                                                        hoverEnabled: true
                                                        cursorShape: Qt.PointingHandCursor
                                                        enabled: !instructorController.isLoading
                                                        onClicked: {
                                                            instructorController.revokeInstructor(modelData.id)
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
}
