import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // Load instructors when page becomes visible
    Component.onCompleted: {
        instructorController.loadInstructors()
    }

    Connections {
        target: instructorController

        function onInstructorUpdated(message) {
            successNotification.show(message)
        }

        function onActionFailed(error) {
            errorNotification.show(error)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        // Page Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Label {
                text: "Instructors Management"
                font.pixelSize: 28
                font.weight: Font.DemiBold
                color: Material.foreground
            }

            Item { Layout.fillWidth: true }

            Button {
                text: "Refresh"
                flat: true
                icon.source: "qrc:/icons/refresh.svg"
                onClicked: instructorController.refresh()
                enabled: !instructorController.isLoading
            }
        }

        // Statistics Cards (Task 2.1)
        GridLayout {
            Layout.fillWidth: true
            columns: 4
            columnSpacing: 16
            rowSpacing: 16

            InstructorStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Total Instructors"
                value: instructorController.totalInstructors
                iconColor: Material.color(Material.Blue)
                backgroundColor: Material.color(Material.Blue, Material.Shade50)
            }

            InstructorStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Pending Requests"
                value: instructorController.pendingInstructors
                iconColor: Material.color(Material.Orange)
                backgroundColor: Material.color(Material.Orange, Material.Shade50)
                showBadge: instructorController.pendingInstructors > 0
            }

            InstructorStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Verified"
                value: instructorController.verifiedInstructors
                iconColor: Material.color(Material.Green)
                backgroundColor: Material.color(Material.Green, Material.Shade50)
            }

            InstructorStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                title: "Rejected"
                value: instructorController.rejectedInstructors
                iconColor: Material.color(Material.Red)
                backgroundColor: Material.color(Material.Red, Material.Shade50)
            }
        }

        // Filters Section (Task 2.2)
        Rectangle {
            Layout.fillWidth: true
            height: filtersLayout.implicitHeight + 32
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor
            border.width: 1

            ColumnLayout {
                id: filtersLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Status Filter Tabs
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { label: "All", value: "all" },
                            { label: "Pending", value: "pending", count: instructorController.pendingInstructors },
                            { label: "Verified", value: "verified" },
                            { label: "Rejected", value: "rejected" }
                        ]

                        Button {
                            text: {
                                let label = modelData.label
                                if (modelData.count !== undefined && modelData.count > 0) {
                                    label += " (" + modelData.count + ")"
                                }
                                return label
                            }
                            flat: instructorController.currentStatus !== modelData.value
                            highlighted: instructorController.currentStatus === modelData.value
                            onClicked: instructorController.setStatusFilter(modelData.value)
                            Material.background: instructorController.currentStatus === modelData.value ?
                                               Material.accent : "transparent"
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                // Search Bar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search by name or email..."
                        selectByMouse: true
                        onTextChanged: searchTimer.restart()

                        Timer {
                            id: searchTimer
                            interval: 500
                            onTriggered: instructorController.setSearchQuery(searchField.text)
                        }
                    }

                    Button {
                        text: "Search"
                        highlighted: true
                        onClicked: instructorController.setSearchQuery(searchField.text)
                        enabled: !instructorController.isLoading
                    }

                    Button {
                        text: "Clear"
                        flat: true
                        visible: searchField.text.length > 0
                        onClicked: {
                            searchField.text = ""
                            instructorController.setSearchQuery("")
                        }
                    }
                }
            }
        }

        // Instructors Table (Task 2.3)
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Material.backgroundColor
            radius: 8
            border.color: Material.dividerColor
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Table Header
                Rectangle {
                    Layout.fillWidth: true
                    height: 56
                    color: Material.color(Material.Grey, Material.Shade100)
                    radius: 8

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 24
                        anchors.rightMargin: 24
                        spacing: 16

                        Label {
                            Layout.preferredWidth: 300
                            text: "Instructor"
                            font.weight: Font.DemiBold
                            color: Material.foreground
                        }

                        Label {
                            Layout.preferredWidth: 120
                            text: "Status"
                            font.weight: Font.DemiBold
                            color: Material.foreground
                        }

                        Label {
                            Layout.preferredWidth: 150
                            text: "Registered"
                            font.weight: Font.DemiBold
                            color: Material.foreground
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "Actions"
                            font.weight: Font.DemiBold
                            color: Material.foreground
                        }
                    }
                }

                // Table Content
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Loading Indicator
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: instructorController.isLoading
                        visible: instructorController.isLoading
                    }

                    // Empty State
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        visible: !instructorController.isLoading &&
                                instructorController.instructors.length === 0

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No instructors found"
                            font.pixelSize: 18
                            color: Material.hintTextColor
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Try adjusting your filters or search query"
                            color: Material.hintTextColor
                        }
                    }

                    // Instructors List
                    ScrollView {
                        anchors.fill: parent
                        visible: !instructorController.isLoading &&
                                instructorController.instructors.length > 0
                        clip: true

                        ListView {
                            id: instructorsList
                            model: instructorController.instructors
                            spacing: 0

                            delegate: InstructorRow {
                                width: instructorsList.width
                                instructor: modelData

                                onApproveClicked: {
                                    confirmDialog.instructorId = modelData.id
                                    confirmDialog.instructorName = modelData.fullName
                                    confirmDialog.action = "approve"
                                    confirmDialog.open()
                                }

                                onRejectClicked: {
                                    confirmDialog.instructorId = modelData.id
                                    confirmDialog.instructorName = modelData.fullName
                                    confirmDialog.action = "reject"
                                    confirmDialog.open()
                                }

                                onRevokeClicked: {
                                    confirmDialog.instructorId = modelData.id
                                    confirmDialog.instructorName = modelData.fullName
                                    confirmDialog.action = "revoke"
                                    confirmDialog.open()
                                }
                            }
                        }
                    }
                }
            }
        }

        // Error Message
        Label {
            Layout.fillWidth: true
            text: instructorController.errorMessage
            color: Material.color(Material.Red)
            wrapMode: Text.WordWrap
            visible: instructorController.errorMessage.length > 0
        }
    }

    // Confirmation Dialog (Task 2.4)
    ConfirmationDialog {
        id: confirmDialog

        property string instructorId: ""
        property string instructorName: ""
        property string action: "approve" // approve, reject, revoke

        title: {
            if (action === "approve") return "Approve Instructor"
            if (action === "reject") return "Reject Instructor"
            if (action === "revoke") return "Revoke Instructor"
            return ""
        }

        message: {
            if (action === "approve") {
                return "Are you sure you want to approve <b>" + instructorName +
                       "</b>? They will be able to create courses."
            }
            if (action === "reject") {
                return "Are you sure you want to reject <b>" + instructorName + "</b>?"
            }
            if (action === "revoke") {
                return "Are you sure you want to revoke <b>" + instructorName +
                       "</b>'s instructor status? They will no longer be able to create courses."
            }
            return ""
        }

        confirmText: action === "approve" ? "Approve" :
                    action === "reject" ? "Reject" : "Revoke"

        confirmColor: action === "approve" ? Material.Green : Material.Red

        onConfirmed: {
            if (action === "approve") {
                instructorController.approveInstructor(instructorId)
            } else if (action === "reject") {
                instructorController.rejectInstructor(instructorId)
            } else if (action === "revoke") {
                instructorController.revokeInstructor(instructorId)
            }
        }
    }

    // Success Notification
    ToolTip {
        id: successNotification
        timeout: 3000

        function show(message) {
            text = message
            x = (parent.width - width) / 2
            y = parent.height - height - 32
            open()
        }

        background: Rectangle {
            color: Material.color(Material.Green)
            radius: 4
        }

        contentItem: Label {
            text: successNotification.text
            color: "white"
            font.pixelSize: 14
        }
    }

    // Error Notification
    ToolTip {
        id: errorNotification
        timeout: 4000

        function show(message) {
            text = message
            x = (parent.width - width) / 2
            y = parent.height - height - 32
            open()
        }

        background: Rectangle {
            color: Material.color(Material.Red)
            radius: 4
        }

        contentItem: Label {
            text: errorNotification.text
            color: "white"
            font.pixelSize: 14
        }
    }
}
