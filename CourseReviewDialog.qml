import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: root
    modal: true
    title: "Review Course"
    anchors.centerIn: parent
    width: 500
    closePolicy: Dialog.CloseOnEscape

    property string courseId: ""
    property string courseTitle: ""
    property bool isProcessing: false

    signal approved()
    signal courseRejected()


    header: ToolBar {
        Material.background: Material.primary
        Material.foreground: "white"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 16

            Label {
                text: "📋"
                font.pixelSize: 24
            }

            Label {
                text: root.title
                font.pixelSize: 18
                font.weight: Font.Medium
                Layout.fillWidth: true
            }

            ToolButton {
                text: "✕"
                font.pixelSize: 18
                onClicked: root.close()
            }
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 24

        // Course Info
        Rectangle {
            Layout.fillWidth: true
            height: courseInfoLayout.height + 32
            radius: 8
            color: Material.color(Material.Grey, Material.Shade100)

            ColumnLayout {
                id: courseInfoLayout
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Label {
                    text: "Course Title"
                    font.pixelSize: 12
                    color: Material.hintTextColor
                }

                Label {
                    text: root.courseTitle || "Untitled Course"
                    font.pixelSize: 16
                    font.weight: Font.Medium
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }

        // Action Selection
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            Label {
                text: "Select Action"
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            ButtonGroup {
                id: actionGroup
                exclusive: true
            }

            RadioButton {
                id: approveRadio
                text: "✓ Approve and Publish"
                checked: true
                ButtonGroup.group: actionGroup

                contentItem: RowLayout {
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: 10
                        border.width: 2
                        border.color: approveRadio.checked ? Material.color(Material.Green) : Material.hintTextColor
                        color: approveRadio.checked ? Material.color(Material.Green) : "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 10
                            radius: 5
                            color: "white"
                            visible: approveRadio.checked
                        }
                    }

                    Label {
                        text: approveRadio.text
                        font.pixelSize: 14
                        Layout.fillWidth: true
                    }
                }
            }

            RadioButton {
                id: rejectRadio
                text: "✗ Reject Course"
                ButtonGroup.group: actionGroup

                contentItem: RowLayout {
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: 10
                        border.width: 2
                        border.color: rejectRadio.checked ? Material.color(Material.Red) : Material.hintTextColor
                        color: rejectRadio.checked ? Material.color(Material.Red) : "transparent"

                        Rectangle {
                            anchors.centerIn: parent
                            width: 10
                            height: 10
                            radius: 5
                            color: "white"
                            visible: rejectRadio.checked
                        }
                    }

                    Label {
                        text: rejectRadio.text
                        font.pixelSize: 14
                        Layout.fillWidth: true
                    }
                }
            }
        }

        // Rejection Reason (shown when reject is selected)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: rejectRadio.checked

            Label {
                text: "Rejection Reason *"
                font.pixelSize: 14
                font.weight: Font.Medium
                color: Material.foreground
            }

            Label {
                text: "Please provide a clear reason for rejection to help the instructor improve their course."
                font.pixelSize: 12
                color: Material.hintTextColor
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                clip: true

                TextArea {
                    id: rejectionReasonInput
                    placeholderText: "Example: The course content does not meet our quality standards. Please review sections 3 and 5 for accuracy and add more detailed examples."
                    wrapMode: TextArea.Wrap
                    selectByMouse: true

                    background: Rectangle {
                        radius: 4
                        border.width: rejectionReasonInput.activeFocus ? 2 : 1
                        border.color: rejectionReasonInput.activeFocus ? Material.accent : Material.dividerColor
                        color: "white"
                    }
                }
            }

            Label {
                text: rejectionReasonInput.text.length + " / 500 characters"
                font.pixelSize: 11
                color: rejectionReasonInput.text.length > 500 ? Material.color(Material.Red) : Material.hintTextColor
                Layout.alignment: Qt.AlignRight
            }
        }

        // Warning Messages
        Rectangle {
            Layout.fillWidth: true
            height: warningText.height + 24
            radius: 4
            color: approveRadio.checked ?
                Material.color(Material.Green, Material.Shade100) :
                Material.color(Material.Orange, Material.Shade100)
            visible: true

            Label {
                id: warningText
                anchors.fill: parent
                anchors.margins: 12
                text: approveRadio.checked ?
                    "⚠️ This will publish the course and make it visible to all students." :
                    "⚠️ The instructor will be notified and can resubmit the course after making improvements."
                wrapMode: Text.WordWrap
                font.pixelSize: 12
                color: approveRadio.checked ?
                    Material.color(Material.Green, Material.Shade900) :
                    Material.color(Material.Orange, Material.Shade900)
            }
        }

        // Action Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Item { Layout.fillWidth: true }

            Button {
                text: "Cancel"
                flat: true
                onClicked: root.close()
                enabled: !root.isProcessing
            }

            Button {
                id: submitButton
                text: root.isProcessing ? "Processing..." : (approveRadio.checked ? "Approve & Publish" : "Reject Course")
                highlighted: true
                enabled: !root.isProcessing && validateForm()
                Material.background: approveRadio.checked ?
                    Material.color(Material.Green) :
                    Material.color(Material.Red)

                onClicked: {
                    if (approveRadio.checked) {
                        approveCourse()
                    } else {
                        rejectCourse()
                    }
                }
            }
        }
    }

    function validateForm() {
        if (rejectRadio.checked) {
            return rejectionReasonInput.text.trim().length >= 10 &&
                   rejectionReasonInput.text.length <= 500
        }
        return true
    }

    function approveCourse() {
        if (root.isProcessing) return

        root.isProcessing = true

        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + root.courseId + "/status")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.isProcessing = false

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.success) {
                            root.approved()
                            root.close()
                        } else {
                            showError(response.message || "Failed to approve course")
                        }
                    } catch (e) {
                        showError("Failed to process response")
                    }
                } else {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        showError(response.message || "Failed to approve course")
                    } catch (e) {
                        showError("Failed to approve course. Please try again.")
                    }
                }
            }
        }

        var data = JSON.stringify({
            status: "published"
        })

        xhr.send(data)
    }

    function rejectCourse() {
        if (root.isProcessing) return

        var reason = rejectionReasonInput.text.trim()
        if (reason.length < 10) {
            showError("Please provide a detailed rejection reason (at least 10 characters)")
            return
        }

        if (reason.length > 500) {
            showError("Rejection reason is too long (maximum 500 characters)")
            return
        }

        root.isProcessing = true

        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + root.courseId + "/status")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                root.isProcessing = false

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.success) {
                            root.rejected()
                            root.close()
                        } else {
                            showError(response.message || "Failed to reject course")
                        }
                    } catch (e) {
                        showError("Failed to process response")
                    }
                } else {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        showError(response.message || "Failed to reject course")
                    } catch (e) {
                        showError("Failed to reject course. Please try again.")
                    }
                }
            }
        }

        var data = JSON.stringify({
            status: "rejected",
            rejectionReason: reason
        })

        xhr.send(data)
    }

    function showError(message) {
        errorLabel.text = message
        errorLabel.visible = true
        errorTimer.restart()
    }

    // Error message display
    Label {
        id: errorLabel
        visible: false
        text: ""
        color: Material.color(Material.Red)
        font.pixelSize: 12
        wrapMode: Text.WordWrap
        Layout.fillWidth: true

        Timer {
            id: errorTimer
            interval: 5000
            onTriggered: errorLabel.visible = false
        }
    }

    // Reset form when opened
    onOpened: {
        approveRadio.checked = true
        rejectionReasonInput.text = ""
        errorLabel.visible = false
        isProcessing = false
    }
}


