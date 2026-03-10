import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Pure-QML dialog — no Material imports, no mixed styling
Popup {
    id: root
    modal: true
    anchors.centerIn: parent
    width: 520
    padding: 0
    closePolicy: Popup.CloseOnEscape

    property string courseId:    ""
    property string courseTitle: ""
    property bool   isProcessing: false

    signal courseApproved()
    signal courseRejected()

    // Reset state each time it opens
    onOpened: {
        approveRadio.checked = true
        rejectReasonInput.text = ""
        errorMsg.visible = false
        isProcessing = false
    }

    // ── Background card ───────────────────────────────────────────────────────
    background: Rectangle {
        radius: 12; color: "white"
        layer.enabled: true
        layer.effect: null  // shadow-free, clean
        border.color: "#E5E7EB"; border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // ── Header bar ────────────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true; height: 56
            color: "#3B4BC8"; radius: 12  // blue-indigo header like screenshot

            // round only top corners
            Rectangle { width: parent.width; height: parent.height / 2; anchors.bottom: parent.bottom; color: "#3B4BC8" }

            RowLayout {
                anchors { fill: parent; leftMargin: 20; rightMargin: 16 }
                spacing: 12
                Text { text: "📋"; font.pixelSize: 20 }
                Text { text: "Review Course"; font.pixelSize: 17; font.weight: Font.DemiBold; color: "white"; Layout.fillWidth: true }
                Rectangle {
                    width: 28; height: 28; radius: 14
                    color: closeHov.containsMouse ? "rgba(255,255,255,0.25)" : "transparent"
                    Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 15; color: "white" }
                    MouseArea { id: closeHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
                }
            }
        }

        // ── Body ──────────────────────────────────────────────────────────────
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: 24
            spacing: 20

            // Course title display
            Rectangle {
                Layout.fillWidth: true; height: courseTitleCol.implicitHeight + 20
                color: "#F9FAFB"; radius: 8; border.color: "#E5E7EB"; border.width: 1
                Column {
                    id: courseTitleCol
                    anchors { fill: parent; margins: 12 }
                    spacing: 4
                    Text { text: "Course Title"; font.pixelSize: 11; color: "#9CA3AF" }
                    Text {
                        text: root.courseTitle || "Untitled Course"
                        font.pixelSize: 15; font.weight: Font.Medium; color: "#18181B"
                        wrapMode: Text.WordWrap; width: parent.width
                    }
                }
            }

            // Select Action label
            Text { text: "Select Action"; font.pixelSize: 14; font.weight: Font.Medium; color: "#18181B" }

            // Approve radio
            Rectangle {
                Layout.fillWidth: true; height: 52; radius: 10
                color: "white"; border.color: approveRadio.checked ? "#22C55E" : "#E5E7EB"; border.width: approveRadio.checked ? 2 : 1
                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 14
                    // Custom radio dot
                    Rectangle {
                        width: 20; height: 20; radius: 10
                        border.color: approveRadio.checked ? "#22C55E" : "#D1D5DB"; border.width: 2
                        color: approveRadio.checked ? "#22C55E" : "white"
                        Rectangle {
                            anchors.centerIn: parent; width: 8; height: 8; radius: 4
                            color: "white"; visible: approveRadio.checked
                        }
                    }
                    Text {
                        text: "✓  Approve and Publish"
                        font.pixelSize: 14; color: "#18181B"; Layout.fillWidth: true
                    }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: approveRadio.checked = true }
                // invisible CheckBox for state tracking
                CheckBox { id: approveRadio; visible: false; checked: true }
            }

            // Reject radio
            Rectangle {
                Layout.fillWidth: true; height: 52; radius: 10
                color: "white"; border.color: rejectRadio.checked ? "#EF4444" : "#E5E7EB"; border.width: rejectRadio.checked ? 2 : 1
                RowLayout {
                    anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
                    spacing: 14
                    Rectangle {
                        width: 20; height: 20; radius: 10
                        border.color: rejectRadio.checked ? "#EF4444" : "#D1D5DB"; border.width: 2
                        color: rejectRadio.checked ? "#EF4444" : "white"
                        Rectangle {
                            anchors.centerIn: parent; width: 8; height: 8; radius: 4
                            color: "white"; visible: rejectRadio.checked
                        }
                    }
                    Text {
                        text: "✕  Reject Course"
                        font.pixelSize: 14; color: "#18181B"; Layout.fillWidth: true
                    }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: { rejectRadio.checked = true; approveRadio.checked = false }
                }
                CheckBox { id: rejectRadio; visible: false; checked: false }
            }

            // Rejection reason textarea (only when reject selected)
            ColumnLayout {
                Layout.fillWidth: true; spacing: 8
                visible: rejectRadio.checked

                Text { text: "Rejection Reason *"; font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B" }

                Rectangle {
                    Layout.fillWidth: true; height: 100; radius: 8
                    border.color: rejectReasonInput.activeFocus ? "#6366F1" : "#E5E7EB"; border.width: 1
                    clip: true
                    ScrollView {
                        anchors.fill: parent
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        TextArea {
                            id: rejectReasonInput
                            wrapMode: TextArea.Wrap
                            placeholderText: "Provide a clear reason so the instructor can improve their course…"
                            font.pixelSize: 13; color: "#18181B"
                            background: null; padding: 10
                        }
                    }
                }
                Text {
                    text: rejectReasonInput.text.length + " / 500"
                    font.pixelSize: 11; Layout.alignment: Qt.AlignRight
                    color: rejectReasonInput.text.length > 500 ? "#EF4444" : "#9CA3AF"
                }
            }

            // Warning / info box
            Rectangle {
                Layout.fillWidth: true; height: warnTxt.implicitHeight + 20; radius: 8
                color: approveRadio.checked ? "#F0FDF4" : "#FFF7ED"
                border.color: approveRadio.checked ? "#BBF7D0" : "#FED7AA"; border.width: 1
                RowLayout {
                    anchors { fill: parent; margins: 12 }
                    spacing: 8
                    Text { text: "⚠️"; font.pixelSize: 14; Layout.alignment: Qt.AlignTop }
                    Text {
                        id: warnTxt; Layout.fillWidth: true
                        text: approveRadio.checked
                            ? "This will publish the course and make it visible to all students."
                            : "The instructor will be notified and can resubmit after improvements."
                        font.pixelSize: 12; color: approveRadio.checked ? "#166534" : "#92400E"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Error message
            Text {
                id: errorMsg; visible: false; Layout.fillWidth: true
                font.pixelSize: 12; color: "#DC2626"; wrapMode: Text.WordWrap
                Timer { id: errTimer; interval: 5000; onTriggered: errorMsg.visible = false }
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true; spacing: 12

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 40; width: cancelTxt.implicitWidth + 28; radius: 8
                    color: cancelHov.containsMouse ? "#F3F4F6" : "white"
                    border.color: "#E5E7EB"; border.width: 1
                    Text { id: cancelTxt; anchors.centerIn: parent; text: "Cancel"; font.pixelSize: 14; color: "#374151" }
                    MouseArea { id: cancelHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        enabled: !root.isProcessing; onClicked: root.close() }
                }

                Rectangle {
                    height: 40; width: submitTxt.implicitWidth + 28; radius: 8
                    color: {
                        if (root.isProcessing || !canSubmit()) return "#D1D5DB"
                        if (submitHov.containsMouse) return approveRadio.checked ? "#15803D" : "#B91C1C"
                        return approveRadio.checked ? "#22C55E" : "#EF4444"
                    }
                    Text {
                        id: submitTxt; anchors.centerIn: parent
                        text: root.isProcessing ? "Processing…"
                            : (approveRadio.checked ? "Approve & Publish" : "Reject Course")
                        font.pixelSize: 14; font.weight: Font.Medium; color: "white"
                    }
                    MouseArea {
                        id: submitHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        enabled: !root.isProcessing && canSubmit()
                        onClicked: approveRadio.checked ? doApprove() : doReject()
                    }
                }
            }
        }
    }

    // ── Logic ─────────────────────────────────────────────────────────────────
    function canSubmit() {
        if (rejectRadio.checked) {
            return rejectReasonInput.text.trim().length >= 10
                && rejectReasonInput.text.length <= 500
        }
        return true
    }

    function showError(msg) {
        errorMsg.text = msg
        errorMsg.visible = true
        errTimer.restart()
    }

    function doApprove() {
        if (root.isProcessing) return
        root.isProcessing = true
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + root.courseId + "/status")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            root.isProcessing = false
            try {
                var r = JSON.parse(xhr.responseText)
                if (xhr.status === 200 && r.success) { root.courseApproved(); root.close() }
                else showError(r.message || "Failed to approve course")
            } catch(e) { showError("Failed to process response") }
        }
        xhr.send(JSON.stringify({ status: "published" }))
    }

    function doReject() {
        if (root.isProcessing) return
        var reason = rejectReasonInput.text.trim()
        if (reason.length < 10) { showError("Please provide a reason (at least 10 characters)"); return }
        if (reason.length > 500) { showError("Reason too long (max 500 characters)"); return }
        root.isProcessing = true
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + root.courseId + "/status")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            root.isProcessing = false
            try {
                var r = JSON.parse(xhr.responseText)
                if (xhr.status === 200 && r.success) { root.courseRejected(); root.close() }
                else showError(r.message || "Failed to reject course")
            } catch(e) { showError("Failed to process response") }
        }
        xhr.send(JSON.stringify({ status: "rejected", rejectionReason: reason }))
    }
}
