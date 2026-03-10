import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // ── Signals ────────────────────────────────────────────────────────────
    signal editCourseRequested(string courseId)

    // ── State ──────────────────────────────────────────────────────────────
    property var    courses:       []
    property string currentStatus: "all"
    property string searchQuery:   ""
    property bool   loadingCourses: false
    property bool   deletingCourse: false
    property int    currentPage:   1
    property int    pageSize:      12
    property int    totalCourses:  0
    property int    totalPages:    0

    Component.onCompleted: {
        courseController.reloadTokens()
        courseController.loadStats()
        loadCourses()
    }

    Connections {
        target: authController
        function onAccessTokenChanged() {
            if (!authController.accessToken || authController.accessToken === "") return
            courseController.reloadTokens()
            courseController.loadStats()
            loadCourses()
        }
    }

    // ── Helpers ────────────────────────────────────────────────────────────
    function loadCourses() {
        loadingCourses = true
        var ep = "https://learning-dashboard-rouge.vercel.app/api/courses"
        var p = []
        if (currentStatus !== "all") p.push("status=" + encodeURIComponent(currentStatus))
        if (searchQuery.trim().length > 0) p.push("search=" + encodeURIComponent(searchQuery.trim()))
        p.push("page=" + currentPage)
        p.push("limit=" + pageSize)
        if (p.length > 0) ep += "?" + p.join("&")
        var xhr = new XMLHttpRequest()
        xhr.open("GET", ep)
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            loadingCourses = false
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) {
                        courses = r.data.courses || []
                        if (r.data.pagination) {
                            currentPage  = r.data.pagination.page  || 1
                            totalCourses = r.data.pagination.total || 0
                            totalPages   = r.data.pagination.pages || 1
                        } else {
                            totalCourses = courses.length
                            totalPages   = 1
                        }
                    } else { showToast(r.message || "Failed to load courses", false) }
                } catch(e) { showToast("Failed to load courses", false) }
            } else { showToast("Failed to load courses", false) }
        }
        xhr.send()
    }

    function deleteCourse(id) {
        deletingCourse = true
        var xhr = new XMLHttpRequest()
        xhr.open("DELETE", "https://learning-dashboard-rouge.vercel.app/api/courses/" + id)
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            deletingCourse = false
            deleteDialog.close()
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) {
                        showToast("Course deleted successfully", true)
                        courseController.refresh()
                        loadCourses()
                    } else { showToast(r.message || "Failed to delete course", false) }
                } catch(e) { showToast("Failed to delete course", false) }
            } else { showToast("Failed to delete course", false) }
        }
        xhr.send()
    }

    function getStatusBg(s) {
        if (s === "published")     return "#18181B"
        if (s === "pending_review") return "#FEF9C3"
        if (s === "draft")         return "#F3F4F6"
        if (s === "rejected")      return "#FEE2E2"
        return "#F3F4F6"
    }
    function getStatusFg(s) {
        if (s === "published")     return "#FFFFFF"
        if (s === "pending_review") return "#92400E"
        if (s === "draft")         return "#6B7280"
        if (s === "rejected")      return "#DC2626"
        return "#6B7280"
    }
    function getStatusLabel(s) {
        if (s === "published")     return "Published"
        if (s === "pending_review") return "Pending Review"
        if (s === "draft")         return "Draft"
        if (s === "rejected")      return "Rejected"
        return s || "Unknown"
    }
    function formatDate(iso) {
        if (!iso) return ""
        var d = new Date(iso)
        var diff = Math.floor((new Date() - d) / 1000)
        if (diff < 60) return "just now"
        if (diff < 3600) return Math.floor(diff/60) + " min ago"
        if (diff < 86400) return Math.floor(diff/3600) + " hr ago"
        if (diff < 2592000) return Math.floor(diff/86400) + " days ago"
        return Qt.formatDate(d, "MMM d, yyyy")
    }
    function fmtPrice(price, isFree) {
        if (isFree) return "Free"
        var p = parseFloat(price) || 0
        return "$" + p.toFixed(2)
    }

    // ── Toast ──────────────────────────────────────────────────────────────
    function showToast(msg, ok) {
        toastLabel.text = msg
        toastRect.color = ok ? "#18181B" : "#DC2626"
        toast.opacity = 1
        toastTimer.restart()
    }

    Rectangle {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 32
        width: toastLabel.implicitWidth + 40
        height: 40; radius: 20
        color: "#18181B"
        visible: opacity > 0; opacity: 0; z: 100
        Rectangle { id: toastRect; anchors.fill: parent; radius: 20; color: parent.color }
        Text { id: toastLabel; anchors.centerIn: parent; color: "white"; font.pixelSize: 13 }
        Timer { id: toastTimer; interval: 3000; onTriggered: toast.opacity = 0 }
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    // ── Main Layout ────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 20

            // ── Header ─────────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 0
                Column {
                    spacing: 4
                    Text { text: "Course Management"; font.pixelSize: 22; font.weight: Font.Bold; color: "#18181B" }
                    Text { text: "Manage all courses on the platform"; font.pixelSize: 13; color: "#6B7280" }
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    height: 34; width: rfTxt.implicitWidth + 24; radius: 6
                    color: rfMA.containsMouse ? "#F3F4F6" : "white"
                    border.color: "#E5E7EB"; border.width: 1
                    Text { id: rfTxt; anchors.centerIn: parent; text: "↻ Refresh"; font.pixelSize: 13; color: "#6B7280" }
                    MouseArea { id: rfMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: { courseController.reloadTokens(); courseController.refresh(); loadCourses() } }
                }
            }

            // ── Stat Cards ─────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Repeater {
                    model: [
                        { label: "Total Courses", val: courseController.totalCourses,         valColor: "#18181B" },
                        { label: "Drafts",         val: courseController.draftCourses,         valColor: "#18181B" },
                        { label: "Pending",        val: courseController.pendingReviewCourses, valColor: "#F59E0B" },
                        { label: "Published",      val: courseController.publishedCourses,     valColor: "#10B981" },
                        { label: "Rejected",       val: courseController.rejectedCourses,      valColor: "#EF4444" }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 88
                        radius: 8; color: "white"
                        border.color: "#E5E7EB"; border.width: 1

                        Column {
                            anchors.fill: parent; anchors.margins: 16; spacing: 8
                            Text { text: modelData.label; font.pixelSize: 12; color: "#6B7280" }
                            Text { text: modelData.val.toString(); font.pixelSize: 26; font.weight: Font.Bold; color: modelData.valColor }
                        }
                    }
                }
            }

            // ── Filter Tabs ────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: [
                        { label: "All",            cnt: courseController.totalCourses,         val: "all" },
                        { label: "Drafts",         cnt: courseController.draftCourses,         val: "draft" },
                        { label: "Pending Reviews",cnt: courseController.pendingReviewCourses, val: "pending_review" },
                        { label: "Published",      cnt: courseController.publishedCourses,     val: "published" },
                        { label: "Rejected",       cnt: courseController.rejectedCourses,      val: "rejected" }
                    ]
                    delegate: Rectangle {
                        height: 32; radius: 6
                        width: ftLbl.implicitWidth + 20
                        color: currentStatus === modelData.val ? "#18181B" : (ftMA.containsMouse ? "#F3F4F6" : "transparent")
                        border.color: currentStatus === modelData.val ? "transparent" : "#E5E7EB"
                        border.width: 1

                        Text {
                            id: ftLbl; anchors.centerIn: parent
                            text: modelData.label + " (" + modelData.cnt + ")"
                            font.pixelSize: 12
                            color: currentStatus === modelData.val ? "white" : "#6B7280"
                        }
                        MouseArea { id: ftMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { currentStatus = modelData.val; currentPage = 1; loadCourses() } }
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }
                }
                Item { Layout.fillWidth: true }
            }

            // ── Search Bar ─────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; height: 40; radius: 8
                color: "white"; border.color: "#E5E7EB"; border.width: 1

                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                    Text { text: "🔍"; font.pixelSize: 13; color: "#9CA3AF" }
                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search Courses"
                        font.pixelSize: 13; color: "#18181B"
                        background: null; selectByMouse: true

                        onTextChanged: searchDebounce.restart()
                        onAccepted:    { searchDebounce.stop(); searchQuery = text.trim(); currentPage = 1; loadCourses() }

                        Timer {
                            id: searchDebounce; interval: 500
                            onTriggered: { searchQuery = searchField.text.trim(); currentPage = 1; loadCourses() }
                        }
                    }
                    Rectangle {
                        visible: searchField.text.length > 0
                        width: 18; height: 18; radius: 9; color: "#9CA3AF"
                        Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 11; color: "white" }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: { searchField.text = ""; searchQuery = ""; currentPage = 1; loadCourses() } }
                    }
                }
            }

            // ── Table ──────────────────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                radius: 8; color: "white"
                border.color: "#E5E7EB"; border.width: 1; clip: true

                ColumnLayout {
                    anchors.fill: parent; spacing: 0

                    // Table header
                    Rectangle {
                        Layout.fillWidth: true; height: 44; color: "#F9FAFB"
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 0

                            Text { text: "Course";      Layout.preferredWidth: 260; font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                            Text { text: "Instructor";  Layout.preferredWidth: 120; font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                            Text { text: "Category";   Layout.preferredWidth: 90;  font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                            Text { text: "Price";      Layout.preferredWidth: 90;  font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                            Text { text: "Content";    Layout.preferredWidth: 100; font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                            Text { text: "Enrollments";Layout.preferredWidth: 90;  font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                            Text { text: "Status";     Layout.preferredWidth: 110; font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                            Text { text: "Actions";    Layout.fillWidth: true;     font.pixelSize: 12; font.weight: Font.Medium; color: "#6B7280"; Layout.alignment: Qt.AlignVCenter }
                        }
                    }

                    // Loading
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: loadingCourses
                        ColumnLayout { anchors.centerIn: parent; spacing: 12
                            BusyIndicator { Layout.alignment: Qt.AlignHCenter; running: true; width: 36; height: 36 }
                            Text { text: "Loading courses…"; font.pixelSize: 13; color: "#9CA3AF"; Layout.alignment: Qt.AlignHCenter }
                        }
                    }

                    // Empty
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: !loadingCourses && courses.length === 0
                        ColumnLayout { anchors.centerIn: parent; spacing: 12
                            Text { text: "📚"; font.pixelSize: 48; Layout.alignment: Qt.AlignHCenter }
                            Text { text: "No courses found"; font.pixelSize: 16; font.weight: Font.Medium; color: "#18181B"; Layout.alignment: Qt.AlignHCenter }
                            Text { text: searchQuery ? "Try a different search" : "Courses will appear here"; font.pixelSize: 13; color: "#9CA3AF"; Layout.alignment: Qt.AlignHCenter }
                        }
                    }

                    // Rows
                    ListView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: !loadingCourses && courses.length > 0
                        model: courses; clip: true
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                        delegate: Rectangle {
                            width: ListView.view.width; height: 80
                            color: rowHov.containsMouse ? "#FAFAFA" : "white"
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F3F4F6" }

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 0

                                // Course thumbnail + title + date
                                RowLayout {
                                    Layout.preferredWidth: 260; spacing: 10; Layout.alignment: Qt.AlignVCenter

                                    Rectangle {
                                        width: 48; height: 48; radius: 6
                                        color: "#F3F4F6"; clip: true
                                        Image {
                                            anchors.fill: parent
                                            source: modelData.thumbnail || ""
                                            fillMode: Image.PreserveAspectCrop
                                            visible: modelData.thumbnail && modelData.thumbnail.length > 0
                                        }
                                        Text {
                                            anchors.centerIn: parent; text: "📚"; font.pixelSize: 22
                                            visible: !modelData.thumbnail || modelData.thumbnail.length === 0
                                        }
                                    }

                                    Column {
                                        spacing: 3; Layout.fillWidth: true
                                        Text {
                                            text: modelData.title || "Untitled"
                                            font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B"
                                            elide: Text.ElideRight; width: parent.width
                                        }
                                        Text {
                                            text: formatDate(modelData.createdAt)
                                            font.pixelSize: 11; color: "#9CA3AF"
                                        }
                                    }
                                }

                                // Instructor
                                Text {
                                    Layout.preferredWidth: 120; Layout.alignment: Qt.AlignVCenter
                                    text: modelData.instructor ? (modelData.instructor.name || modelData.instructor.fullName || "—") : "—"
                                    font.pixelSize: 12; color: "#374151"; elide: Text.ElideRight
                                }

                                // Category
                                Text {
                                    Layout.preferredWidth: 90; Layout.alignment: Qt.AlignVCenter
                                    text: modelData.category || "—"
                                    font.pixelSize: 12; color: "#374151"; elide: Text.ElideRight
                                }

                                // Price (two lines: full price + discounted)
                                Column {
                                    Layout.preferredWidth: 90; Layout.alignment: Qt.AlignVCenter; spacing: 2
                                    Text {
                                        text: fmtPrice(modelData.price || 0, modelData.isFree || false)
                                        font.pixelSize: 12; font.weight: Font.Medium; color: "#18181B"
                                    }
                                    Text {
                                        visible: modelData.discountPrice !== undefined && modelData.discountPrice > 0 && !modelData.isFree
                                        text: "$" + (parseFloat(modelData.discountPrice) || 0).toFixed(2)
                                        font.pixelSize: 11; color: "#9CA3AF"
                                        font.strikeout: false
                                    }
                                }

                                // Content
                                Column {
                                    Layout.preferredWidth: 100; Layout.alignment: Qt.AlignVCenter; spacing: 2
                                    Text { text: (modelData.sectionsCount || 0) + " sections"; font.pixelSize: 12; color: "#374151" }
                                    Text { text: (modelData.lessonsCount  || 0) + " lessons";  font.pixelSize: 11; color: "#9CA3AF" }
                                }

                                // Enrollments
                                Text {
                                    Layout.preferredWidth: 90; Layout.alignment: Qt.AlignVCenter
                                    text: (modelData.enrollmentCount || modelData.enrollments || 0).toString()
                                    font.pixelSize: 12; font.weight: Font.Medium; color: "#374151"
                                    horizontalAlignment: Text.AlignLeft
                                }

                                // Status badge
                                Item {
                                    Layout.preferredWidth: 110; Layout.alignment: Qt.AlignVCenter
                                    Rectangle {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: Math.min(stLbl.implicitWidth + 20, 100); height: 26; radius: 13
                                        color: getStatusBg(modelData.status)
                                        Text {
                                            id: stLbl; anchors.centerIn: parent
                                            text: getStatusLabel(modelData.status)
                                            font.pixelSize: 11; font.weight: Font.Medium
                                            color: getStatusFg(modelData.status)
                                        }
                                    }
                                }

                                // Actions: edit icon | Review button | delete icon
                                RowLayout {
                                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 6

                                    // Edit icon
                                    Rectangle {
                                        width: 30; height: 30; radius: 6
                                        color: editHov.containsMouse ? "#F3F4F6" : "transparent"
                                        border.color: editHov.containsMouse ? "#E5E7EB" : "transparent"; border.width: 1
                                        Text { anchors.centerIn: parent; text: "✏"; font.pixelSize: 14; color: "#6B7280" }
                                        MouseArea {
                                            id: editHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: root.editCourseRequested(modelData.id)
                                        }
                                    }

                                    // Review button
                                    Rectangle {
                                        height: 28; width: rvTxt.implicitWidth + 20; radius: 6
                                        color: rvHov.containsMouse ? "#F3F4F6" : "white"
                                        border.color: "#E5E7EB"; border.width: 1
                                        Text { id: rvTxt; anchors.centerIn: parent; text: "Review"; font.pixelSize: 12; color: "#374151" }
                                        MouseArea {
                                            id: rvHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                reviewDialog.courseId    = modelData.id
                                                reviewDialog.courseTitle = modelData.title
                                                reviewDialog.open()
                                            }
                                        }
                                    }

                                    // Delete icon
                                    Rectangle {
                                        width: 30; height: 30; radius: 6
                                        color: delHov.containsMouse ? "#FEF2F2" : "transparent"
                                        border.color: delHov.containsMouse ? "#FECACA" : "transparent"; border.width: 1
                                        Text { anchors.centerIn: parent; text: "🗑"; font.pixelSize: 14 }
                                        MouseArea {
                                            id: delHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                deleteDialog.courseId    = modelData.id
                                                deleteDialog.courseTitle = modelData.title
                                                deleteDialog.open()
                                            }
                                        }
                                    }

                                    Item { Layout.fillWidth: true }
                                }
                            }

                            MouseArea { id: rowHov; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                        }
                    }

                    // Pagination
                    Rectangle {
                        Layout.fillWidth: true; height: 52
                        visible: !loadingCourses && courses.length > 0 && totalPages > 1
                        color: "#FAFAFA"
                        Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: "#E5E7EB" }

                        RowLayout {
                            anchors.centerIn: parent; spacing: 6

                            Rectangle {
                                width: 32; height: 32; radius: 6
                                color: currentPage > 1 && pgPrevHov.containsMouse ? "#F3F4F6" : "white"
                                border.color: "#E5E7EB"; border.width: 1
                                Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 14; color: currentPage > 1 ? "#374151" : "#D1D5DB" }
                                MouseArea {
                                    id: pgPrevHov; anchors.fill: parent; hoverEnabled: true; enabled: currentPage > 1
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { currentPage--; loadCourses() }
                                }
                            }

                            Repeater {
                                model: {
                                    var pg = []; var s = Math.max(1, currentPage-2); var e = Math.min(totalPages, currentPage+2)
                                    if (s > 1) { pg.push(1); if (s > 2) pg.push(-1) }
                                    for (var i = s; i <= e; i++) pg.push(i)
                                    if (e < totalPages) { if (e < totalPages-1) pg.push(-1); pg.push(totalPages) }
                                    return pg
                                }
                                delegate: Rectangle {
                                    width: 32; height: 32; radius: 6
                                    color: modelData === currentPage ? "#18181B" : (pgNumHov.containsMouse && modelData !== -1 ? "#F3F4F6" : "white")
                                    border.color: modelData === currentPage ? "transparent" : "#E5E7EB"; border.width: 1
                                    Text { anchors.centerIn: parent; text: modelData === -1 ? "…" : modelData.toString()
                                        font.pixelSize: 13; color: modelData === currentPage ? "white" : "#374151" }
                                    MouseArea { id: pgNumHov; anchors.fill: parent; hoverEnabled: true; enabled: modelData !== -1 && modelData !== currentPage
                                        cursorShape: Qt.PointingHandCursor; onClicked: { currentPage = modelData; loadCourses() } }
                                }
                            }

                            Rectangle {
                                width: 32; height: 32; radius: 6
                                color: currentPage < totalPages && pgNextHov.containsMouse ? "#F3F4F6" : "white"
                                border.color: "#E5E7EB"; border.width: 1
                                Text { anchors.centerIn: parent; text: "→"; font.pixelSize: 14; color: currentPage < totalPages ? "#374151" : "#D1D5DB" }
                                MouseArea {
                                    id: pgNextHov; anchors.fill: parent; hoverEnabled: true; enabled: currentPage < totalPages
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { currentPage++; loadCourses() }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Delete Dialog ──────────────────────────────────────────────────────
    Dialog {
        id: deleteDialog
        modal: true; anchors.centerIn: parent; width: 400
        property string courseId: ""
        property string courseTitle: ""

        background: Rectangle { color: "white"; radius: 12; border.color: "#E5E7EB"; border.width: 1 }

        ColumnLayout {
            width: parent.width; spacing: 16

            Text { text: "Delete Course"; font.pixelSize: 18; font.weight: Font.Bold; color: "#18181B" }

            Text {
                text: "Are you sure you want to delete <b>" + deleteDialog.courseTitle + "</b>? This cannot be undone."
                wrapMode: Text.WordWrap; Layout.fillWidth: true; font.pixelSize: 13; color: "#374151"
            }

            Rectangle {
                Layout.fillWidth: true; height: 48; radius: 8
                color: "#FEF2F2"; border.color: "#FECACA"; border.width: 1
                Text { anchors.centerIn: parent; text: "⚠ All content, enrollments and progress will be permanently deleted"
                    font.pixelSize: 12; color: "#DC2626"; width: parent.width - 24; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter }
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 8

                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8
                    color: cancelDlgHov.containsMouse ? "#F3F4F6" : "white"
                    border.color: "#E5E7EB"; border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; font.pixelSize: 14; color: "#374151" }
                    MouseArea { id: cancelDlgHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: deleteDialog.close() }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8
                    color: deleteDlgHov.containsMouse ? "#B91C1C" : "#DC2626"
                    Text { anchors.centerIn: parent; text: deletingCourse ? "Deleting…" : "Delete"; font.pixelSize: 14; font.weight: Font.Medium; color: "white" }
                    MouseArea { id: deleteDlgHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: !deletingCourse
                        onClicked: deleteCourse(deleteDialog.courseId) }
                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }
        }
    }

    // ── Review Dialog ──────────────────────────────────────────────────────
    CourseReviewDialog {
        id: reviewDialog
        onCourseApproved: { showToast("✓ Course approved and published!", true);  courseController.refresh(); loadCourses() }
        onCourseRejected: { showToast("Course rejected. Instructor notified.", false); courseController.refresh(); loadCourses() }
    }
}
