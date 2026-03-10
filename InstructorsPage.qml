import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    Component.onCompleted: {
        instructorController.reloadTokens()
        instructorController.loadInstructors()
    }

    Connections {
        target: authController
        function onOtpVerified() {
            instructorController.reloadTokens()
            instructorController.loadInstructors()
        }
        function onAccessTokenChanged() {
            if (!authController || !authController.accessToken) return
            instructorController.reloadTokens()
            instructorController.loadInstructors()
        }
        function onIsLoggedInChanged() {
            if (authController && authController.isLoggedIn) {
                instructorController.reloadTokens()
                instructorController.loadInstructors()
            }
        }
    }

    property string toastMessage: ""
    property bool   toastSuccess: true

    Timer { id: toastTimer; interval: 3500; onTriggered: toastMessage = "" }

    function showToast(msg, ok) {
        toastMessage = msg
        toastSuccess = ok !== false
        toastTimer.restart()
    }

    Connections {
        target: instructorController
        function onInstructorUpdated(message) { showToast(message, true)  }
        function onActionFailed(error)         { showToast(error,   false) }
    }

    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"

        Rectangle {
            z: 20
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 16 }
            width: toastLbl.implicitWidth + 48; height: 40; radius: 20
            color: root.toastSuccess ? "#DCFCE7" : "#FEE2E2"
            border.color: root.toastSuccess ? "#86EFAC" : "#FCA5A5"; border.width: 1
            visible: root.toastMessage.length > 0
            Row {
                anchors.centerIn: parent; spacing: 8
                Text { text: root.toastSuccess ? "✓" : "✕"; font.pixelSize: 13
                       color: root.toastSuccess ? "#16A34A" : "#DC2626" }
                Text { id: toastLbl; text: root.toastMessage; font.pixelSize: 13
                       color: root.toastSuccess ? "#15803D" : "#DC2626" }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Column {
                    spacing: 4
                    Text { text: "Instructor Management";                    font.pixelSize: 22; font.weight: Font.Bold; color: "#18181B" }
                    Text { text: "Manage instructor accounts and approvals"; font.pixelSize: 13; color: "#6B7280" }
                }
                Item { Layout.fillWidth: true }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Repeater {
                    model: [
                        { label: "Total Instructors", val: instructorController.totalInstructors,    valColor: "#18181B" },
                        { label: "Pending Requests",  val: instructorController.pendingInstructors,  valColor: "#F59E0B" },
                        { label: "Verified",          val: instructorController.verifiedInstructors, valColor: "#0EA5E9" },
                        { label: "Rejected",          val: instructorController.rejectedInstructors, valColor: "#EF4444" }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 88
                        radius: 10; color: "white"
                        border.color: "#E5E7EB"; border.width: 1
                        Column {
                            anchors { fill: parent; margins: 16 }
                            spacing: 6
                            Text { text: modelData.label;          font.pixelSize: 12; color: "#6B7280" }
                            Text { text: modelData.val.toString(); font.pixelSize: 28; font.weight: Font.Bold; color: modelData.valColor }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Row {
                    spacing: 2
                    Repeater {
                        model: [
                            { label: "All",                                                           value: "all"      },
                            { label: "Pending (" + instructorController.pendingInstructors + ")",     value: "pending"  },
                            { label: "Verified",                                                      value: "verified" },
                            { label: "Rejected",                                                      value: "rejected" }
                        ]
                        delegate: Rectangle {
                            height: 32; width: tabTxt.implicitWidth + 20; radius: 16
                            color: instructorController.currentStatus === modelData.value ? "#18181B"
                                   : (tabMA2.containsMouse ? "#F3F4F6" : "transparent")
                            Text {
                                id: tabTxt; anchors.centerIn: parent
                                text: modelData.label; font.pixelSize: 13
                                color: instructorController.currentStatus === modelData.value ? "white" : "#6B7280"
                            }
                            MouseArea {
                                id: tabMA2; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: instructorController.setStatusFilter(modelData.value)
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                radius: 10; color: "white"
                border.color: "#E5E7EB"; border.width: 1; clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true; height: 42
                        color: "#F9FAFB"; radius: 10
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                        RowLayout {
                            anchors { fill: parent; leftMargin: 20; rightMargin: 20 }
                            spacing: 0
                            Text { Layout.preferredWidth: 280; text: "Instructor"; font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280" }
                            Text { Layout.preferredWidth: 140; text: "Status";     font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280" }
                            Text { Layout.preferredWidth: 130; text: "Registered"; font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280" }
                            Text { Layout.fillWidth: true;     text: "Actions";    font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280";
                                   horizontalAlignment: Text.AlignRight }
                        }
                    }

                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: instructorController.isLoading
                        Column {
                            anchors.centerIn: parent; spacing: 12
                            BusyIndicator { anchors.horizontalCenter: parent.horizontalCenter; running: true; width: 36; height: 36 }
                            Text { anchors.horizontalCenter: parent.horizontalCenter
                                   text: "Loading instructors…"; font.pixelSize: 13; color: "#9CA3AF" }
                        }
                    }

                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: !instructorController.isLoading && instructorController.instructors.length === 0
                        Column {
                            anchors.centerIn: parent; spacing: 10
                            Text { anchors.horizontalCenter: parent.horizontalCenter; text: "👥"; font.pixelSize: 44 }
                            Text { anchors.horizontalCenter: parent.horizontalCenter
                                   text: "No instructors found"; font.pixelSize: 15; font.weight: Font.Medium; color: "#18181B" }
                            Text { anchors.horizontalCenter: parent.horizontalCenter
                                   text: "Try changing filters or search query"; font.pixelSize: 13; color: "#9CA3AF" }
                        }
                    }

                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: !instructorController.isLoading && instructorController.instructors.length > 0
                        clip: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy:   ScrollBar.AsNeeded

                        ColumnLayout {
                            width: parent.width
                            spacing: 0

                            Repeater {
                                model: instructorController.instructors

                                Rectangle {
                                    Layout.fillWidth: true; height: 68
                                    color: rowHov.containsMouse ? "#FAFAFA" : "white"
                                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F3F4F6" }

                                    RowLayout {
                                        anchors { fill: parent; leftMargin: 20; rightMargin: 20 }
                                        spacing: 0

                                        RowLayout {
                                            Layout.preferredWidth: 280; spacing: 12
                                            Rectangle {
                                                width: 38; height: 38; radius: 19; color: "#EEF2FF"
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: (modelData.firstName || "?").charAt(0).toUpperCase()
                                                    font.pixelSize: 15; font.weight: Font.Medium; color: "#6366F1"
                                                }
                                            }
                                            Column {
                                                spacing: 2; Layout.fillWidth: true
                                                Text {
                                                    text: (modelData.firstName || "") + " " + (modelData.lastName || "")
                                                    font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B"
                                                    elide: Text.ElideRight; width: parent.width
                                                }
                                                Text {
                                                    text: modelData.email || ""
                                                    font.pixelSize: 12; color: "#6B7280"
                                                    elide: Text.ElideRight; width: parent.width
                                                }
                                            }
                                        }

                                        // Status badge — width matches header
                                        Item {
                                            Layout.preferredWidth: 140
                                            Layout.fillHeight: true
                                            Rectangle {
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: stLbl.implicitWidth + 20; height: 24; radius: 12
                                                color: {
                                                    var s = modelData.instructorStatus || ""
                                                    if (s === "verified") return "#DCFCE7"
                                                    if (s === "rejected") return "#FEE2E2"
                                                    return "#FEF3C7"
                                                }
                                                Text {
                                                    id: stLbl; anchors.centerIn: parent
                                                    text: {
                                                        var s = modelData.instructorStatus || "pending"
                                                        return s.charAt(0).toUpperCase() + s.slice(1)
                                                    }
                                                    font.pixelSize: 11; font.weight: Font.Medium
                                                    color: {
                                                        var s = modelData.instructorStatus || ""
                                                        if (s === "verified") return "#16A34A"
                                                        if (s === "rejected") return "#DC2626"
                                                        return "#D97706"
                                                    }
                                                }
                                            }
                                        }

                                        // Registered date — width matches header
                                        Text {
                                            Layout.preferredWidth: 130
                                            Layout.alignment: Qt.AlignVCenter
                                            text: modelData.relativeDate || "Unknown"
                                            font.pixelSize: 12; color: "#6B7280"
                                        }

                                        RowLayout {
                                            Layout.fillWidth: true; spacing: 8
                                            Item { Layout.fillWidth: true }

                                            Text {
                                                visible: modelData.instructorStatus === "verified"
                                                text: "× Revoke"; font.pixelSize: 13; color: "#6B7280"
                                                MouseArea {
                                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                    enabled: !instructorController.isLoading
                                                    onClicked: instructorController.revokeInstructor(modelData.id)
                                                }
                                            }

                                            Rectangle {
                                                visible: modelData.instructorStatus !== "verified"
                                                height: 30; width: appTxt.implicitWidth + 28; radius: 15
                                                color: appMA.containsMouse ? "#15803D" : "#16A34A"
                                                Row {
                                                    anchors.centerIn: parent; spacing: 4
                                                    Text { text: "✓"; font.pixelSize: 11; color: "white" }
                                                    Text { id: appTxt; text: "Approve"; font.pixelSize: 12; font.weight: Font.Medium; color: "white" }
                                                }
                                                MouseArea {
                                                    id: appMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    enabled: !instructorController.isLoading
                                                    onClicked: instructorController.approveInstructor(modelData.id)
                                                }
                                            }

                                            Rectangle {
                                                visible: modelData.instructorStatus !== "verified"
                                                height: 30; width: rejTxt.implicitWidth + 28; radius: 15
                                                color: rejMA.containsMouse ? "#B91C1C" : "#DC2626"
                                                Row {
                                                    anchors.centerIn: parent; spacing: 4
                                                    Text { text: "✕"; font.pixelSize: 11; color: "white" }
                                                    Text { id: rejTxt; text: "Reject"; font.pixelSize: 12; font.weight: Font.Medium; color: "white" }
                                                }
                                                MouseArea {
                                                    id: rejMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                                    enabled: !instructorController.isLoading
                                                    onClicked: instructorController.rejectInstructor(modelData.id)
                                                }
                                            }
                                        }
                                    }

                                    MouseArea { id: rowHov; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
