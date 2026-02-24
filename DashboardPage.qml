import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    anchors.fill: parent
    color: "#FAFAFA"

    signal logout()
    signal navigateToInstructors()


    property var pendingInstructors: []
    property int totalPending: 0
    property var recentActivities: []
    property int totalActivities: 0
    property int activitiesLimit: 10
    property bool loadingActivities: false

    property string currentView: "dashboard"
    property string editCourseId: ""
    property string reviewCourseId: ""

    // ─── reload tokens on every controller so API calls succeed ────────────────
    function reloadAllTokens() {
        if (dashboardController)  dashboardController.reloadTokens()
        if (courseController)     courseController.reloadTokens()
        if (instructorController) instructorController.reloadTokens()
    }

    Component.onCompleted: {
        reloadAllTokens()
        if (dashboardController) dashboardController.loadStats()
        loadPendingInstructors()
        loadRecentActivities()
    }

    // Re-reload whenever a fresh login completes
    Connections {
        target: authController
        function onAccessTokenChanged() { reloadAllTokens() }
    }

    function loadPendingInstructors() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://learning-dashboard-rouge.vercel.app/api/instructors?status=pending")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Accept", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.success) {
                            pendingInstructors = response.data.instructors.slice(0, 5)
                            totalPending = response.data.stats.pending || response.data.instructors.length
                        }
                    } catch (e) {
                        console.log("Failed to parse instructors:", e)
                    }
                }
            }
        }
        xhr.send()
    }

    function getRelativeTime(isoDate) {
        var now = new Date()
        var date = new Date(isoDate)
        var seconds = Math.floor((now - date) / 1000)

        if (seconds < 60) return "just now"
        if (seconds < 3600) return Math.floor(seconds / 60) + " minutes ago"
        if (seconds < 86400) return Math.floor(seconds / 3600) + " hours ago"
        if (seconds < 2592000) return Math.floor(seconds / 86400) + " days ago"
        return Math.floor(seconds / 2592000) + " months ago"
    }

    function getInitials(firstName, lastName) {
        return ((firstName || "").charAt(0) + (lastName || "").charAt(0)).toUpperCase()
    }

    function loadRecentActivities() {
        loadingActivities = true
        var xhr = new XMLHttpRequest()
        xhr.open("GET", "https://learning-dashboard-rouge.vercel.app/api/dashboard/activity?limit=" + activitiesLimit)
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Accept", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loadingActivities = false
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.success) {
                            recentActivities = response.data.activities
                            totalActivities = response.data.total
                        }
                    } catch (e) {
                        console.log("Failed to parse activities:", e)
                    }
                }
            }
        }
        xhr.send()
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.preferredWidth: 240
            Layout.fillHeight: true
            color: "white"

            Rectangle {
                anchors.right: parent.right
                width: 1
                height: parent.height
                color: "#E5E7EB"
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 32
                    spacing: 10

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 6
                        color: "#18181B"
                        Text {
                            text: "L"
                            color: "white"
                            font.pixelSize: 16
                            font.bold: true
                            anchors.centerIn: parent
                        }
                    }

                    Text {
                        text: "Lumin Admin Panel"
                        color: "#18181B"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6
                        color: currentView === "dashboard" ? "#F3F4F6" : (nav0MA.containsMouse ? "#F9FAFB" : "transparent")
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 10
                            Text {
                                text: "📊"
                                font.pixelSize: 16
                            }
                            Text {
                                text: "Dashboard"
                                color: currentView === "dashboard" ? "#18181B" : "#6B7280"
                                font.pixelSize: 13
                                font.weight: currentView === "dashboard" ? Font.Medium : Font.Normal
                            }
                        }
                        MouseArea {
                            id: nav0MA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: currentView = "dashboard"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6
                        color: currentView === "instructors" ? "#F3F4F6" : (nav1MA.containsMouse ? "#F9FAFB" : "transparent")
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 10
                            Text {
                                text: "👥"
                                font.pixelSize: 16
                            }
                            Text {
                                text: "Instructors"
                                color: currentView === "instructors" ? "#18181B" : "#6B7280"
                                font.pixelSize: 13
                                font.weight: currentView === "instructors" ? Font.Medium : Font.Normal
                            }
                        }
                        MouseArea {
                            id: nav1MA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentView = "instructors"
                                if (instructorController) {
                                    instructorController.loadInstructors()
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6
                        color: currentView === "courses" ? "#F3F4F6" : (nav2MA.containsMouse ? "#F9FAFB" : "transparent")
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 10
                            Text { text: "📚"; font.pixelSize: 16 }
                            Text {
                                text: "Courses"
                                color: currentView === "courses" ? "#18181B" : "#6B7280"
                                font.pixelSize: 13
                                font.weight: currentView === "courses" ? Font.Medium : Font.Normal
                            }
                        }
                        MouseArea {
                            id: nav2MA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentView = "courses"
                                courseController.loadStats()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6
                        color: currentView === "users" ? "#F3F4F6" : (nav3MA.containsMouse ? "#F9FAFB" : "transparent")
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 10
                            Text { text: "👤"; font.pixelSize: 16 }
                            Text {
                                text: "Users"
                                color: currentView === "users" ? "#18181B" : "#6B7280"
                                font.pixelSize: 13
                                font.weight: currentView === "users" ? Font.Medium : Font.Normal
                            }
                        }
                        MouseArea {
                            id: nav3MA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentView = "users"
                                userController.loadStudents()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6
                        color: currentView === "transactions" ? "#F3F4F6" : (nav4MA.containsMouse ? "#F9FAFB" : "transparent")
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 10
                            Text { text: "💳"; font.pixelSize: 16 }
                            Text {
                                text: "Transactions"
                                color: currentView === "transactions" ? "#18181B" : "#6B7280"
                                font.pixelSize: 13
                                font.weight: currentView === "transactions" ? Font.Medium : Font.Normal
                            }
                        }
                        MouseArea {
                            id: nav4MA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentView = "transactions"
                                transactionController.loadTransactions()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6
                        color: currentView === "settings" ? "#F3F4F6" : (nav5MA.containsMouse ? "#F9FAFB" : "transparent")
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            spacing: 10
                            Text { text: "⚙️"; font.pixelSize: 16 }
                            Text {
                                text: "Settings"
                                color: currentView === "settings" ? "#18181B" : "#6B7280"
                                font.pixelSize: 13
                                font.weight: currentView === "settings" ? Font.Medium : Font.Normal
                            }
                        }
                        MouseArea {
                            id: nav5MA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                currentView = "settings"
                            }
                        }
                    }
                }


                Item { Layout.fillHeight: true }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    radius: 6
                    color: profileMA.containsMouse ? "#F9FAFB" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Rectangle {
                            width: 36
                            height: 36
                            radius: 18
                            color: "#E5E7EB"
                            Text {
                                text: authController && authController.userName ? authController.userName.charAt(0).toUpperCase() : "U"
                                color: "#6B7280"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                anchors.centerIn: parent
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: authController ? authController.userName || "User" : "User"
                                color: "#18181B"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Text {
                                text: authController ? authController.userEmail || "user@email.com" : "user@email.com"
                                color: "#9CA3AF"
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 4
                            color: "transparent"
                            Text {
                                text: "↪"
                                color: "#9CA3AF"
                                font.pixelSize: 16
                                rotation: 180
                                anchors.centerIn: parent
                            }
                        }
                    }

                    MouseArea {
                        id: profileMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            authController.logout()
                            root.logout()
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

            // ===== SHARED HEADER (search + bell) — visible on ALL pages =====
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "white"
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
                    TextField {
                        Layout.preferredWidth: 300
                        Layout.preferredHeight: 38
                        placeholderText: "Search anything..."
                        leftPadding: 38
                        background: Rectangle {
                            radius: 8
                            color: "#F9FAFB"
                            border.color: "#E5E7EB"
                            border.width: 1
                            Text {
                                text: "🔍"
                                font.pixelSize: 14
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                color: "#9CA3AF"
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }

                    // ===== NOTIFICATION BELL + POPUP =====
                    Item {
                        id: bellContainer
                        width: 38
                        height: 38

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: bellMA.containsMouse ? "#F9FAFB" : "transparent"
                            Text {
                                text: "🔔"
                                font.pixelSize: 18
                                anchors.centerIn: parent
                            }
                            // Red unread-count badge
                            Rectangle {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 1
                                anchors.rightMargin: 1
                                width: Math.max(17, badgeText.implicitWidth + 9)
                                height: 17
                                radius: 9
                                color: "#EF4444"
                                visible: notificationController && notificationController.unreadCount > 0
                                Text {
                                    id: badgeText
                                    anchors.centerIn: parent
                                    text: notificationController ? notificationController.unreadCount.toString() : "0"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: "white"
                                }
                            }
                            MouseArea {
                                id: bellMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (bellPopup.opened) {
                                        bellPopup.close()
                                    } else {
                                        notificationController.loadRecentNotifications()
                                        bellPopup.open()
                                    }
                                }
                            }
                        }

                        // ===== POPUP =====
                        Popup {
                            id: bellPopup
                            x: bellContainer.width - width + 10
                            y: bellContainer.height + 6
                            width: 360
                            height: Math.min(520, popupCol.implicitHeight + 2)
                            padding: 0
                            closePolicy: Popup.CloseOnEscape | Popup.CloseOnClickOutside

                            background: Rectangle {
                                radius: 12
                                color: "white"
                                border.color: "#E5E7EB"
                                border.width: 1
                            }

                            ColumnLayout {
                                id: popupCol
                                anchors.fill: parent
                                spacing: 0

                                // Header
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 52
                                    color: "#18181B"
                                    topLeftRadius: 12
                                    topRightRadius: 12
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 16
                                        anchors.rightMargin: 16
                                        Text {
                                            text: "Notifications"
                                            color: "white"
                                            font.pixelSize: 15
                                            font.weight: Font.DemiBold
                                        }
                                        Item { Layout.fillWidth: true }
                                        Text {
                                            text: "Mark all as read"
                                            color: "#60A5FA"
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                            visible: notificationController && notificationController.unreadCount > 0
                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: notificationController.markAllAsRead()
                                            }
                                        }
                                    }
                                }

                                // List
                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.min(390, bellList.contentHeight + 8)
                                    clip: true

                                    ListView {
                                        id: bellList
                                        width: parent.width
                                        model: notificationController ? notificationController.recentNotifications : []
                                        spacing: 0

                                        delegate: Rectangle {
                                            width: bellList.width
                                            height: 76
                                            color: {
                                                if (itemMA.pressed)  return "#F3F4F6"
                                                if (itemMA.containsMouse) return "#F9FAFB"
                                                if (!modelData.isRead)  return "#EFF6FF"
                                                return "white"
                                            }
                                            // Divider
                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                width: parent.width
                                                height: 1
                                                color: "#F3F4F6"
                                            }
                                            // Left-edge unread indicator
                                            Rectangle {
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                width: 3
                                                height: 36
                                                radius: 2
                                                color: "#3B82F6"
                                                visible: !modelData.isRead
                                            }
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: modelData.isRead ? 12 : 18
                                                anchors.rightMargin: 12
                                                anchors.topMargin: 12
                                                anchors.bottomMargin: 12
                                                spacing: 10

                                                // Type-icon circle
                                                Rectangle {
                                                    width: 36
                                                    height: 36
                                                    radius: 18
                                                    color: {
                                                        var t = modelData.type || ""
                                                        if (t === "course_submitted")  return "#DBEAFE"
                                                        if (t === "course_approved")   return "#DCFCE7"
                                                        if (t === "course_rejected")   return "#FEE2E2"
                                                        if (t === "instructor_request") return "#EDE9FE"
                                                        if (t === "new_student")       return "#F3E8FF"
                                                        if (t === "transaction")       return "#D1FAE5"
                                                        return "#F3F4F6"
                                                    }
                                                    Text {
                                                        anchors.centerIn: parent
                                                        font.pixelSize: 16
                                                        text: {
                                                            var t = modelData.type || ""
                                                            if (t === "course_submitted")  return "📚"
                                                            if (t === "course_approved")   return "✅"
                                                            if (t === "course_rejected")   return "❌"
                                                            if (t === "instructor_request") return "👤"
                                                            if (t === "new_student")       return "👥"
                                                            if (t === "transaction")       return "💳"
                                                            return "🔔"
                                                        }
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2
                                                    Text {
                                                        text: modelData.title || ""
                                                        font.pixelSize: 13
                                                        font.weight: modelData.isRead ? Font.Normal : Font.DemiBold
                                                        color: "#18181B"
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }
                                                    Text {
                                                        text: modelData.message || ""
                                                        font.pixelSize: 12
                                                        color: "#6B7280"
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }
                                                    Text {
                                                        text: modelData.relativeTime || ""
                                                        font.pixelSize: 11
                                                        color: "#9CA3AF"
                                                    }
                                                }
                                            }
                                            MouseArea {
                                                id: itemMA
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (!modelData.isRead) {
                                                        notificationController.markAsRead(modelData.id)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                // Footer: "View all notifications"
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 44
                                    color: "#F9FAFB"
                                    bottomLeftRadius: 12
                                    bottomRightRadius: 12
                                    Rectangle {
                                        anchors.top: parent.top
                                        width: parent.width
                                        height: 1
                                        color: "#E5E7EB"
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: "View all notifications"
                                        color: "#3B82F6"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                bellPopup.close()
                                                currentView = "notifications"
                                                notificationController.loadNotifications()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // ===== END BELL =====
                }
            }
            // ===== END SHARED HEADER =====

            // Page switcher
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: currentView === "dashboard" ? 0 :
                              currentView === "instructors" ? 1 :
                              currentView === "courses" ? 2 :
                              currentView === "users" ? 3 :
                              currentView === "transactions" ? 4 :
                              currentView === "notifications" ? 5 :
                              currentView === "settings" ? 6 :
                              currentView === "edit_course" ? 7 :
                              currentView === "review_course" ? 8 : 0

            // ========== PAGE 0: DASHBOARD VIEW ==========
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentHeight: mainContent.height + 40
                        clip: true

                        ColumnLayout {
                            id: mainContent
                            width: parent.width
                            spacing: 20

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.topMargin: 24
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                spacing: 4
                                Text {
                                    text: "Home - Empty state - Profile/Settings"
                                    color: "#9CA3AF"
                                    font.pixelSize: 12
                                }
                                Text {
                                    text: "Admin Dashboard"
                                    font.pixelSize: 24
                                    font.bold: true
                                    color: "#18181B"
                                }
                                Text {
                                    text: "Welcome back! Here's an overview of your platform."
                                    font.pixelSize: 13
                                    color: "#6B7280"
                                }
                            }

                            GridLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                columns: 4
                                rowSpacing: 16
                                columnSpacing: 16

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 120
                                    color: "white"
                                    radius: 10
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Rectangle {
                                                width: 32
                                                height: 32
                                                radius: 6
                                                color: "#EEF2FF"
                                                Text {
                                                    text: "👥"
                                                    font.pixelSize: 16
                                                    anchors.centerIn: parent
                                                }
                                            }
                                            Item { Layout.fillWidth: true }
                                        }

                                        Text {
                                            text: "Total Instructors"
                                            font.pixelSize: 12
                                            color: "#6B7280"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.totalInstructors.toString() : "0"
                                            font.pixelSize: 28
                                            font.bold: true
                                            color: "#18181B"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.verifiedInstructors + " verified" : "0 verified"
                                            font.pixelSize: 11
                                            color: "#9CA3AF"
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 120
                                    color: "white"
                                    radius: 10
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Rectangle {
                                                width: 32
                                                height: 32
                                                radius: 6
                                                color: "#FEF3C7"
                                                Text {
                                                    text: "📚"
                                                    font.pixelSize: 16
                                                    anchors.centerIn: parent
                                                }
                                            }
                                            Item { Layout.fillWidth: true }
                                        }

                                        Text {
                                            text: "Total Courses"
                                            font.pixelSize: 12
                                            color: "#6B7280"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.totalCourses.toString() : "0"
                                            font.pixelSize: 28
                                            font.bold: true
                                            color: "#18181B"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.activeCourses + " active courses" : "0 active courses"
                                            font.pixelSize: 11
                                            color: "#9CA3AF"
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 120
                                    color: "white"
                                    radius: 10
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Rectangle {
                                                width: 32
                                                height: 32
                                                radius: 6
                                                color: "#DBEAFE"
                                                Text {
                                                    text: "👤"
                                                    font.pixelSize: 16
                                                    anchors.centerIn: parent
                                                }
                                            }
                                            Item { Layout.fillWidth: true }
                                        }

                                        Text {
                                            text: "Total Students"
                                            font.pixelSize: 12
                                            color: "#6B7280"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.totalStudents.toString() : "0"
                                            font.pixelSize: 28
                                            font.bold: true
                                            color: "#18181B"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.activeStudents + " active students" : "0 active students"
                                            font.pixelSize: 11
                                            color: "#9CA3AF"
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 120
                                    color: "white"
                                    radius: 10
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 16
                                        spacing: 8

                                        RowLayout {
                                            Layout.fillWidth: true
                                            Rectangle {
                                                width: 32
                                                height: 32
                                                radius: 6
                                                color: "#D1FAE5"
                                                Text {
                                                    text: "💵"
                                                    font.pixelSize: 16
                                                    anchors.centerIn: parent
                                                }
                                            }
                                            Item { Layout.fillWidth: true }
                                        }

                                        Text {
                                            text: "Total Revenue"
                                            font.pixelSize: 12
                                            color: "#6B7280"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.formattedTotalRevenue : "$0"
                                            font.pixelSize: 28
                                            font.bold: true
                                            color: "#18181B"
                                        }

                                        Text {
                                            text: dashboardController ? dashboardController.formattedMonthlyRevenue + " this month" : "$0 this month"
                                            font.pixelSize: 11
                                            color: "#9CA3AF"
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 280
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                radius: 10
                                color: "white"
                                border.color: "#E5E7EB"
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 20
                                    spacing: 16

                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text {
                                            text: "Revenue Overview"
                                            font.pixelSize: 16
                                            font.weight: Font.DemiBold
                                            color: "#18181B"
                                        }
                                        Item { Layout.fillWidth: true }
                                        ComboBox {
                                            model: ["Last 30 days", "Last 7 days", "Last 90 days"]
                                            currentIndex: 0
                                            font.pixelSize: 12
                                            Layout.preferredWidth: 130
                                            Layout.preferredHeight: 32
                                        }
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 1
                                        color: "#F3F4F6"
                                    }

                                    Item { Layout.fillHeight: true }

                                    ColumnLayout {
                                        Layout.alignment: Qt.AlignCenter
                                        spacing: 12

                                        Text {
                                            text: "📈"
                                            font.pixelSize: 48
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: "No Revenue Data Yet"
                                            font.pixelSize: 16
                                            font.weight: Font.Medium
                                            color: "#18181B"
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: "Revenue data will appear here once students start purchasing courses"
                                            font.pixelSize: 13
                                            color: "#9CA3AF"
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                    }

                                    Item { Layout.fillHeight: true }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 24
                                Layout.rightMargin: 24
                                Layout.bottomMargin: 24
                                spacing: 16

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 400
                                    Layout.fillHeight: false
                                    radius: 10
                                    color: "white"
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 16

                                        Text {
                                            text: "Pending Instructor Requests"
                                            font.pixelSize: 15
                                            font.weight: Font.DemiBold
                                            color: "#18181B"
                                        }

                                        Text {
                                            text: "Review and approve new instructor applications"
                                            font.pixelSize: 12
                                            color: "#9CA3AF"
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 1
                                            color: "#F3F4F6"
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            visible: pendingInstructors.length === 0

                                            ColumnLayout {
                                                anchors.centerIn: parent
                                                spacing: 8

                                                Text {
                                                    text: "👥"
                                                    font.pixelSize: 40
                                                    Layout.alignment: Qt.AlignHCenter
                                                }

                                                Text {
                                                    text: "No pending requests"
                                                    font.pixelSize: 13
                                                    color: "#9CA3AF"
                                                    Layout.alignment: Qt.AlignHCenter
                                                }
                                            }
                                        }

                                        ScrollView {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            visible: pendingInstructors.length > 0
                                            clip: true

                                            ColumnLayout {
                                                width: parent.width
                                                spacing: 0

                                                Repeater {
                                                    model: pendingInstructors
                                                    delegate: Rectangle {
                                                        width: parent.width
                                                        height: 64
                                                        color: instructorMA.containsMouse ? "#F9FAFB" : "transparent"
                                                        radius: 6

                                                        RowLayout {
                                                            anchors.fill: parent
                                                            anchors.leftMargin: 8
                                                            anchors.rightMargin: 8
                                                            spacing: 12

                                                            Rectangle {
                                                                width: 40
                                                                height: 40
                                                                radius: 20
                                                                color: "#E5E7EB"
                                                                Text {
                                                                    text: getInitials(modelData.firstName, modelData.lastName)
                                                                    color: "#6B7280"
                                                                    font.pixelSize: 14
                                                                    font.weight: Font.Medium
                                                                    anchors.centerIn: parent
                                                                }
                                                            }

                                                            ColumnLayout {
                                                                Layout.fillWidth: true
                                                                spacing: 2

                                                                Text {
                                                                    text: modelData.firstName + " " + modelData.lastName
                                                                    font.pixelSize: 13
                                                                    font.weight: Font.Medium
                                                                    color: "#18181B"
                                                                }

                                                                Text {
                                                                    text: modelData.email
                                                                    font.pixelSize: 12
                                                                    color: "#9CA3AF"
                                                                }
                                                            }
                                                        }

                                                        MouseArea {
                                                            id: instructorMA
                                                            anchors.fill: parent
                                                            hoverEnabled: true
                                                            cursorShape: Qt.PointingHandCursor
                                                            onClicked: currentView = "instructors"
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 400
                                    Layout.fillHeight: false
                                    radius: 10
                                    color: "white"
                                    border.color: "#E5E7EB"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 20
                                        spacing: 16

                                        Text {
                                            text: "Recent Activity"
                                            font.pixelSize: 15
                                            font.weight: Font.DemiBold
                                            color: "#18181B"
                                        }

                                        Text {
                                            text: "Latest activities on the platform"
                                            font.pixelSize: 12
                                            color: "#9CA3AF"
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 1
                                            color: "#F3F4F6"
                                        }

                                        // Loading spinner for activities
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignHCenter
                                            visible: loadingActivities
                                            spacing: 8
                                            BusyIndicator {
                                                Layout.alignment: Qt.AlignHCenter
                                                running: loadingActivities
                                                width: 36; height: 36
                                            }
                                            Text {
                                                Layout.alignment: Qt.AlignHCenter
                                                text: "Loading activities..."
                                                font.pixelSize: 12; color: "#9CA3AF"
                                            }
                                        }

                                        Item {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            visible: !loadingActivities && recentActivities.length === 0

                                            ColumnLayout {
                                                anchors.centerIn: parent
                                                spacing: 8

                                                Text {
                                                    text: "📌"
                                                    font.pixelSize: 40
                                                    Layout.alignment: Qt.AlignHCenter
                                                }

                                                Text {
                                                    text: "No recent activity"
                                                    font.pixelSize: 13
                                                    color: "#9CA3AF"
                                                    Layout.alignment: Qt.AlignHCenter
                                                }

                                                Text {
                                                    text: "Activity will appear here as students enroll in courses"
                                                    font.pixelSize: 11
                                                    color: "#D1D5DB"
                                                    Layout.alignment: Qt.AlignHCenter
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

            // ========== PAGE 1: INSTRUCTORS ==========
            InstructorsPage {
            }

            // ========== PAGE 2: COURSES ==========
            CoursesPage {
            }

            // ========== PAGE 3: USERS ==========
            UsersPage {
            }

            // ========== PAGE 4: TRANSACTIONS ==========
            TransactionsPage {
            }

            // ========== PAGE 5: NOTIFICATIONS ==========
            NotificationsPage {
            }

            // ========== PAGE 6: SETTINGS ==========
            SettingsPage {
            }

            // ========== PAGE 7: EDIT COURSE ==========
            EditCoursePage {
                id: editCoursePage
                courseId: root.editCourseId
                onBackRequested: {
                    root.currentView = "courses"
                    root.editCourseId = ""
                }
                onCourseSaved: {
                    root.currentView = "courses"
                    root.editCourseId = ""
                    if (courseController) courseController.reloadTokens()
                }
            }

            // ========== PAGE 8: REVIEW COURSE ==========
            ReviewCoursePage {
                id: reviewCoursePage
                courseId: root.reviewCourseId
                onBackRequested: {
                    root.currentView = "courses"
                    root.reviewCourseId = ""
                }
                onCourseApproved: {
                    root.currentView = "courses"
                    root.reviewCourseId = ""
                    if (courseController) { courseController.reloadTokens(); courseController.refresh() }
                }
                onCourseRejected: {
                    root.currentView = "courses"
                    root.reviewCourseId = ""
                    if (courseController) { courseController.reloadTokens(); courseController.refresh() }
                }
            }
            }
        }
    }
}

