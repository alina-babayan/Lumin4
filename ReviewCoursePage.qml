import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property string courseId: ""
    property var courseData: null
    property bool isLoading: false
    property bool isActing: false

    signal backRequested()
    signal courseApproved()
    signal courseRejected()

    onCourseIdChanged: { if (courseId !== "") fetchCourse() }

    function fetchCourse() {
        isLoading = true
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://learning-dashboard-rouge.vercel.app/api/courses/" + courseId)
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            isLoading = false
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) courseData = r.data.course || r.data
                    else showError(r.message || "Failed to load course")
                } catch(e) { showError("Failed to parse course data") }
            } else { showError("Failed to load course. Status: " + xhr.status) }
        }
        xhr.send()
    }

    function showError(msg)   { rvErrLbl.text = msg; rvErrLbl.visible = true;  rvErrT.restart() }
    function showSuccess(msg) { rvOkLbl.text  = msg; rvOkLbl.visible  = true;  rvOkT.restart()  }

    function approveCourse() {
        isActing = true
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + courseId + "/status")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            isActing = false
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) {
                        showSuccess("✓ Course approved and published!")
                        if (courseData) { var d = courseData; d.status = "published"; courseData = null; courseData = d }
                        root.courseApproved()
                    } else showError(r.message || "Failed to approve")
                } catch(e) { showError("Failed to approve course") }
            } else showError("Approve failed. Status: " + xhr.status)
        }
        xhr.send(JSON.stringify({ status: "published" }))
    }

    function rejectCourse() {
        var reason = rejectionInput.text.trim()
        if (reason.length < 10) { showError("Please provide a rejection reason (min 10 characters)"); return }
        isActing = true
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + courseId + "/status")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            isActing = false
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) {
                        showSuccess("Course rejected. Instructor notified.")
                        if (courseData) { var d = courseData; d.status = "rejected"; courseData = null; courseData = d }
                        rejectionPanel.visible = false
                        rejectionInput.text = ""
                        root.courseRejected()
                    } else showError(r.message || "Failed to reject")
                } catch(e) { showError("Failed to reject course") }
            } else showError("Reject failed. Status: " + xhr.status)
        }
        xhr.send(JSON.stringify({ status: "rejected", rejectionReason: reason }))
    }

    function formatDate(iso) {
        if (!iso) return ""
        try { var d = new Date(iso); return d.toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" }) }
        catch(e) { return iso }
    }

    Rectangle {
        anchors.fill: parent; color: "#F9FAFB"

        ColumnLayout {
            anchors.fill: parent; spacing: 0

            // TOP BAR
            Rectangle { Layout.fillWidth: true; height: 64; color: "white"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                RowLayout { anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 12
                    Rectangle { width: 36; height: 36; radius: 8; color: rvBkH.containsMouse ? "#F3F4F6" : "transparent"; border.color: "#E5E7EB"; border.width: 1
                        Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: "#374151" }
                        MouseArea { id: rvBkH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.backRequested() } }
                    ColumnLayout { spacing: 2
                        RowLayout { spacing: 10
                            Text { text: "Review Course"; font.pixelSize: 20; font.weight: Font.DemiBold; color: "#18181B" }
                            Rectangle {
                                height: 22; radius: 11; width: rvStTxt.implicitWidth + 16; visible: courseData !== null
                                color: !courseData ? "#F3F4F6" : courseData.status === "published" ? "#DCFCE7" : courseData.status === "pending_review" ? "#FEF9C3" : courseData.status === "rejected" ? "#FEE2E2" : "#F3F4F6"
                                Text { id: rvStTxt; anchors.centerIn: parent; font.pixelSize: 11; font.weight: Font.Medium
                                    text: !courseData ? "" : courseData.status === "pending_review" ? "Pending Review" : courseData.status ? courseData.status.charAt(0).toUpperCase() + courseData.status.slice(1) : ""
                                    color: !courseData ? "#6B7280" : courseData.status === "published" ? "#16A34A" : courseData.status === "pending_review" ? "#92400E" : courseData.status === "rejected" ? "#DC2626" : "#6B7280" } }
                        }
                        Text { text: courseData ? (courseData.instructor ? courseData.instructor.name || "" : "") : ""; font.pixelSize: 12; color: "#6B7280" }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            // TOAST
            Rectangle { Layout.fillWidth: true; height: 42; color: "#DCFCE7"; visible: rvOkLbl.visible
                RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 10
                    Text { text: "✓"; color: "#16A34A"; font.pixelSize: 14 }
                    Text { id: rvOkLbl; visible: false; color: "#15803D"; font.pixelSize: 13; Layout.fillWidth: true }
                    Timer { id: rvOkT; interval: 3000; onTriggered: rvOkLbl.visible = false } } }
            Rectangle { Layout.fillWidth: true; height: 42; color: "#FEE2E2"; visible: rvErrLbl.visible
                RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 10
                    Text { text: "✕"; color: "#DC2626"; font.pixelSize: 14 }
                    Text { id: rvErrLbl; visible: false; color: "#DC2626"; font.pixelSize: 13; Layout.fillWidth: true }
                    Timer { id: rvErrT; interval: 5000; onTriggered: rvErrLbl.visible = false } } }

            // LOADING
            Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: isLoading
                ColumnLayout { anchors.centerIn: parent; spacing: 16
                    BusyIndicator { Layout.alignment: Qt.AlignHCenter; running: true; width: 48; height: 48 }
                    Text { text: "Loading course…"; font.pixelSize: 14; color: "#6B7280"; Layout.alignment: Qt.AlignHCenter } } }

            // CONTENT
            ScrollView { Layout.fillWidth: true; Layout.fillHeight: true; clip: true; visible: !isLoading; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                Flickable { contentHeight: rvMainCol.height + 48; clip: true
                    ColumnLayout { id: rvMainCol; width: parent.width - 48; x: 24; y: 24; spacing: 20

                        // Hero thumbnail
                        Rectangle { Layout.fillWidth: true; height: 260; radius: 12; color: "#1F2937"; clip: true
                            Image { anchors.fill: parent; source: courseData ? (courseData.thumbnail || "") : ""; fillMode: Image.PreserveAspectCrop; opacity: 0.85; visible: courseData && (courseData.thumbnail || "").length > 0 }
                            Text { anchors.centerIn: parent; text: "🎓"; font.pixelSize: 64; visible: !courseData || !(courseData.thumbnail || "").length > 0 }
                            // Overlay info
                            Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 100; opacity: 0.7
                                gradient: Gradient { GradientStop { position: 0.0; color: "transparent" } GradientStop { position: 1.0; color: "#000000" } } }
                            ColumnLayout { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; anchors.margins: 20; anchors.bottomMargin: 16; spacing: 6
                                RowLayout { spacing: 10
                                    Rectangle { height: 22; radius: 11; width: heroCatTxt.implicitWidth + 16; color: "#4F46E5"
                                        Text { id: heroCatTxt; anchors.centerIn: parent; text: courseData ? (courseData.category || "") : ""; font.pixelSize: 11; color: "white" } }
                                    Rectangle { height: 22; radius: 11; width: heroLvlTxt.implicitWidth + 16; color: "#374151"
                                        Text { id: heroLvlTxt; anchors.centerIn: parent; text: courseData ? (courseData.level || "") : ""; font.pixelSize: 11; color: "white" } }
                                }
                                Text { text: courseData ? (courseData.title || "Untitled") : ""; font.pixelSize: 20; font.weight: Font.Bold; color: "white"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                            }
                        }

                        // Quick stats
                        RowLayout { Layout.fillWidth: true; spacing: 16
                            Repeater {
                                model: [
                                    { icon: "📚", label: "Sections", val: courseData ? (courseData.sectionsCount || (courseData.sections ? courseData.sections.length : 0)).toString() : "0" },
                                    { icon: "📄", label: "Lessons",  val: courseData ? (courseData.lessonsCount || 0).toString() : "0" },
                                    { icon: "⏱️", label: "Duration", val: courseData ? (courseData.totalDuration || "0 min") : "0 min" },
                                    { icon: "👥", label: "Students", val: courseData ? (courseData.enrollmentCount || 0).toString() : "0" }
                                ]
                                Rectangle { Layout.fillWidth: true; height: 72; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1
                                    ColumnLayout { anchors.centerIn: parent; spacing: 4
                                        Text { text: modelData.icon; font.pixelSize: 20; Layout.alignment: Qt.AlignHCenter }
                                        Text { text: modelData.val; font.pixelSize: 16; font.weight: Font.Bold; color: "#18181B"; Layout.alignment: Qt.AlignHCenter }
                                        Text { text: modelData.label; font.pixelSize: 11; color: "#9CA3AF"; Layout.alignment: Qt.AlignHCenter }
                                    }
                                }
                            }
                        }

                        // Two-column layout
                        RowLayout { Layout.fillWidth: true; spacing: 20; Layout.alignment: Qt.AlignTop

                            // LEFT COLUMN — main content
                            ColumnLayout { Layout.fillWidth: true; spacing: 20; Layout.alignment: Qt.AlignTop

                                // Short Description
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvShortCol.implicitHeight + 40; visible: courseData && (courseData.shortDescription || "").length > 0
                                    ColumnLayout { id: rvShortCol; anchors.fill: parent; anchors.margins: 20; spacing: 12
                                        Text { text: "Short Description"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Text { text: courseData ? (courseData.shortDescription || "") : ""; font.pixelSize: 13; color: "#374151"; wrapMode: Text.WordWrap; Layout.fillWidth: true } } }

                                // Full Description
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvDescCol.implicitHeight + 40
                                    ColumnLayout { id: rvDescCol; anchors.fill: parent; anchors.margins: 20; spacing: 12
                                        Text { text: "Full Description"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Text { text: courseData ? (courseData.description || "No description provided.") : ""; font.pixelSize: 13; color: "#374151"; wrapMode: Text.WordWrap; Layout.fillWidth: true } } }

                                // What you'll learn
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvLearnCol.implicitHeight + 40
                                    visible: courseData && courseData.whatYouWillLearn && courseData.whatYouWillLearn.length > 0
                                    ColumnLayout { id: rvLearnCol; anchors.fill: parent; anchors.margins: 20; spacing: 12
                                        Text { text: "What You'll Learn"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Repeater {
                                            model: courseData ? (courseData.whatYouWillLearn || []) : []
                                            RowLayout { spacing: 10; Layout.fillWidth: true
                                                Rectangle { width: 20; height: 20; radius: 10; color: "#DCFCE7"
                                                    Text { anchors.centerIn: parent; text: "✓"; font.pixelSize: 11; font.weight: Font.Bold; color: "#16A34A" } }
                                                Text { text: modelData; font.pixelSize: 13; color: "#374151"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                            }
                                        }
                                    }
                                }

                                // Requirements
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvReqCol.implicitHeight + 40
                                    visible: courseData && courseData.requirements && courseData.requirements.length > 0
                                    ColumnLayout { id: rvReqCol; anchors.fill: parent; anchors.margins: 20; spacing: 12
                                        Text { text: "Requirements"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Repeater {
                                            model: courseData ? (courseData.requirements || []) : []
                                            RowLayout { spacing: 10; Layout.fillWidth: true
                                                Text { text: "•"; font.pixelSize: 18; color: "#4F46E5" }
                                                Text { text: modelData; font.pixelSize: 13; color: "#374151"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                            }
                                        }
                                    }
                                }

                                // What Curriculum
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvCurrCol.implicitHeight + 40
                                    visible: courseData && courseData.sections && courseData.sections.length > 0
                                    ColumnLayout { id: rvCurrCol; anchors.fill: parent; anchors.margins: 20; spacing: 12
                                        Text { text: "Curriculum"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Repeater {
                                            model: courseData ? (courseData.sections || []) : []
                                            ColumnLayout { Layout.fillWidth: true; spacing: 1
                                                property var sec: modelData
                                                property int si: index
                                                Rectangle { Layout.fillWidth: true; height: 44; radius: 6; color: "#F9FAFB"; border.color: "#E5E7EB"; border.width: 1
                                                    RowLayout { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                                        Text { text: "▸"; font.pixelSize: 13; color: "#6B7280" }
                                                        Text { text: sec.title || ("Section " + (si+1)); font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B"; Layout.fillWidth: true }
                                                        Text { text: (sec.lessons ? sec.lessons.length : 0) + " lessons"; font.pixelSize: 12; color: "#9CA3AF" } } }
                                                Repeater {
                                                    model: sec.lessons || []
                                                    Rectangle { Layout.fillWidth: true; height: 38; color: "transparent"
                                                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F9FAFB" }
                                                        RowLayout { anchors.fill: parent; anchors.leftMargin: 28; anchors.rightMargin: 12; spacing: 10
                                                            Text { text: { var t = modelData.type || "video"; return t==="video"?"▶":t==="quiz"?"❓":"📄" } font.pixelSize: 12; color: "#6B7280" }
                                                            Text { text: modelData.title || ("Lesson "+(index+1)); font.pixelSize: 13; color: "#374151"; Layout.fillWidth: true; elide: Text.ElideRight }
                                                            Text { text: modelData.duration || ""; font.pixelSize: 12; color: "#9CA3AF" } } }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // RIGHT COLUMN — metadata + review actions (fixed width)
                            ColumnLayout { Layout.preferredWidth: 300; Layout.minimumWidth: 260; spacing: 16; Layout.alignment: Qt.AlignTop

                                // Course metadata
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvMetaCol.implicitHeight + 40
                                    ColumnLayout { id: rvMetaCol; anchors.fill: parent; anchors.margins: 20; spacing: 14
                                        Text { text: "Course Details"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Repeater {
                                            model: [
                                                { label: "Category",   val: courseData ? (courseData.category || "—") : "—" },
                                                { label: "Sub Cat.",   val: courseData ? (courseData.subCategory || "—") : "—" },
                                                { label: "Level",      val: courseData ? (courseData.level || "—") : "—" },
                                                { label: "Language",   val: courseData ? (courseData.language || "—") : "—" },
                                                { label: "Price",      val: courseData ? (courseData.isFree ? "Free" : ("$" + (courseData.price || "0"))) : "—" },
                                                { label: "Created",    val: courseData ? formatDate(courseData.createdAt) : "—" }
                                            ]
                                            RowLayout { Layout.fillWidth: true
                                                Text { text: modelData.label; font.pixelSize: 12; color: "#6B7280"; Layout.preferredWidth: 80 }
                                                Text { text: modelData.val; font.pixelSize: 13; color: "#18181B"; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                                            }
                                        }
                                    }
                                }

                                // Instructor card
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvInstrCol.implicitHeight + 40; visible: courseData && courseData.instructor !== undefined
                                    ColumnLayout { id: rvInstrCol; anchors.fill: parent; anchors.margins: 20; spacing: 12
                                        Text { text: "Instructor"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        RowLayout { spacing: 12
                                            Rectangle { width: 42; height: 42; radius: 21; color: "#EEF2FF"
                                                Text { anchors.centerIn: parent; text: courseData && courseData.instructor ? (courseData.instructor.name || "?").charAt(0).toUpperCase() : "?"; font.pixelSize: 17; font.weight: Font.Medium; color: "#4F46E5" } }
                                            ColumnLayout { spacing: 2; Layout.fillWidth: true
                                                Text { text: courseData && courseData.instructor ? (courseData.instructor.name || "Unknown") : "Unknown"; font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B"; elide: Text.ElideRight; Layout.fillWidth: true }
                                                Text { text: courseData && courseData.instructor ? (courseData.instructor.email || "") : ""; font.pixelSize: 12; color: "#9CA3AF"; elide: Text.ElideRight; Layout.fillWidth: true }
                                            }
                                        }
                                    }
                                }

                                // Review Action Panel — only show for pending courses
                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; height: rvActionCol.implicitHeight + 40
                                    visible: courseData && courseData.status === "pending_review"
                                    ColumnLayout { id: rvActionCol; anchors.fill: parent; anchors.margins: 20; spacing: 16
                                        Text { text: "Review Decision"; font.pixelSize: 14; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Text { text: "Approve or reject this course. The instructor will be notified by email."; font.pixelSize: 12; color: "#6B7280"; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                                        // Approve button
                                        Rectangle { Layout.fillWidth: true; height: 42; radius: 8; color: appH.containsMouse ? "#15803D" : "#16A34A"
                                            opacity: isActing ? 0.6 : 1.0
                                            RowLayout { anchors.centerIn: parent; spacing: 8
                                                Text { text: "✓"; color: "white"; font.pixelSize: 16; font.weight: Font.Bold }
                                                Text { text: isActing ? "Processing…" : "Approve & Publish"; color: "white"; font.pixelSize: 14; font.weight: Font.Medium } }
                                            MouseArea { id: appH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: !isActing; onClicked: approveCourse() } }

                                        // Reject toggle
                                        Rectangle { Layout.fillWidth: true; height: 42; radius: 8; color: rejectionPanel.visible ? "#FEE2E2" : (rejH.containsMouse ? "#FEE2E2" : "white"); border.color: "#EF4444"; border.width: 1
                                            RowLayout { anchors.centerIn: parent; spacing: 8
                                                Text { text: "✕"; color: "#EF4444"; font.pixelSize: 16; font.weight: Font.Bold }
                                                Text { text: "Reject Course"; color: "#EF4444"; font.pixelSize: 14; font.weight: Font.Medium } }
                                            MouseArea { id: rejH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: rejectionPanel.visible = !rejectionPanel.visible } }

                                        // Rejection reason panel
                                        ColumnLayout { id: rejectionPanel; Layout.fillWidth: true; spacing: 10; visible: false
                                            Text { text: "Rejection Reason *"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                            ScrollView { Layout.fillWidth: true; Layout.preferredHeight: 90; clip: true
                                                TextArea { id: rejectionInput; wrapMode: TextArea.Wrap; selectByMouse: true; placeholderText: "Explain why the course is being rejected (min 10 characters)…"
                                                    background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#EF4444" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                            Text { text: rejectionInput.text.length + " / 500"; font.pixelSize: 11; color: rejectionInput.text.length > 500 ? "#DC2626" : "#9CA3AF"; Layout.alignment: Qt.AlignRight }
                                            Rectangle { Layout.fillWidth: true; height: 42; radius: 8; color: confirmRejH.containsMouse ? "#B91C1C" : "#DC2626"
                                                opacity: isActing ? 0.6 : 1.0
                                                Text { anchors.centerIn: parent; text: isActing ? "Submitting…" : "Confirm Rejection"; color: "white"; font.pixelSize: 14; font.weight: Font.Medium }
                                                MouseArea { id: confirmRejH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: !isActing && rejectionInput.text.trim().length >= 10; onClicked: rejectCourse() } }
                                        }
                                    }
                                }

                                // Approved/Rejected status panel
                                Rectangle { Layout.fillWidth: true; radius: 10; border.width: 1; height: rvStatusCol.implicitHeight + 40
                                    visible: courseData && courseData.status !== "pending_review"
                                    color: courseData && courseData.status === "published" ? "#F0FDF4" : courseData && courseData.status === "rejected" ? "#FFF1F2" : "#F9FAFB"
                                    border.color: courseData && courseData.status === "published" ? "#86EFAC" : courseData && courseData.status === "rejected" ? "#FECACA" : "#E5E7EB"
                                    ColumnLayout { id: rvStatusCol; anchors.fill: parent; anchors.margins: 20; spacing: 12
                                        RowLayout { spacing: 10
                                            Text { text: courseData && courseData.status === "published" ? "✓" : courseData && courseData.status === "rejected" ? "✕" : "●"; font.pixelSize: 18; font.weight: Font.Bold
                                                color: courseData && courseData.status === "published" ? "#16A34A" : courseData && courseData.status === "rejected" ? "#DC2626" : "#6B7280" }
                                            Text { text: courseData && courseData.status === "published" ? "Course Published" : courseData && courseData.status === "rejected" ? "Course Rejected" : (courseData ? (courseData.status || "Draft") : "Draft")
                                                font.pixelSize: 14; font.weight: Font.DemiBold
                                                color: courseData && courseData.status === "published" ? "#15803D" : courseData && courseData.status === "rejected" ? "#DC2626" : "#6B7280" }
                                        }
                                        Text { text: courseData && courseData.status === "published" ? "This course is visible to students." : courseData && courseData.status === "rejected" ? "The instructor has been notified." : ""
                                            font.pixelSize: 12; color: "#6B7280"; wrapMode: Text.WordWrap; Layout.fillWidth: true; visible: text.length > 0 }
                                    }
                                }
                            }
                        }
                        Item { height: 20 }
                    }
                }
            }
        }
    }
}
