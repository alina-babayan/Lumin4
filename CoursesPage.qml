import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // State management
    property var courses: []
    property string currentStatus: "all"
    property string searchQuery: ""
    property bool loadingCourses: false
    property bool deletingCourse: false

    // Pagination
    property int currentPage: 1
    property int pageSize: 12
    property int totalCourses: 0
    property int totalPages: 0

    Component.onCompleted: {
        console.log("CoursesPage loaded")
        courseController.loadStats()
        loadCourses()
    }

    Connections {
        target: courseController
        function onStatsLoaded() {
            console.log("Course stats loaded successfully")
        }
    }

    // Load courses with filters and pagination
    function loadCourses() {
        loadingCourses = true

        var endpoint = "https://learning-dashboard-rouge.vercel.app/api/courses"
        var params = []

        if (currentStatus !== "all") {
            params.push("status=" + encodeURIComponent(currentStatus))
        }

        if (searchQuery.trim().length > 0) {
            params.push("search=" + encodeURIComponent(searchQuery.trim()))
        }

        params.push("page=" + currentPage)
        params.push("limit=" + pageSize)

        if (params.length > 0) {
            endpoint += "?" + params.join("&")
        }

        console.log("Loading courses:", endpoint)

        var xhr = new XMLHttpRequest()
        xhr.open("GET", endpoint)
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Accept", "application/json")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                loadingCourses = false

                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)

                        if (response.success) {
                            courses = response.data.courses || []

                            if (response.data.pagination) {
                                currentPage = response.data.pagination.page || 1
                                totalCourses = response.data.pagination.total || 0
                                totalPages = response.data.pagination.pages || 1
                            } else {
                                totalCourses = courses.length
                                totalPages = 1
                            }

                            if (response.data.stats) {
                                updateStatsFromData(response.data.stats)
                            }

                            console.log("Loaded", courses.length, "courses, page", currentPage, "of", totalPages)
                        } else {
                            errorNotification.show(response.message || "Failed to load courses")
                        }
                    } catch (e) {
                        console.error("Parse error:", e)
                        errorNotification.show("Failed to load courses")
                    }
                } else {
                    errorNotification.show("Failed to load courses. Please try again.")
                }
            }
        }

        xhr.send()
    }

    function updateStatsFromData(stats) {
        console.log("Stats:", JSON.stringify(stats))
    }

    // Helper functions
    function getStatusColor(status) {
        switch(status) {
            case "draft": return Material.color(Material.Grey, Material.Shade100)
            case "pending_review": return Material.color(Material.Orange, Material.Shade100)
            case "published": return Material.color(Material.Green, Material.Shade100)
            case "rejected": return Material.color(Material.Red, Material.Shade100)
            default: return Material.color(Material.Grey, Material.Shade100)
        }
    }

    function getStatusTextColor(status) {
        switch(status) {
            case "draft": return Material.color(Material.Grey, Material.Shade900)
            case "pending_review": return Material.color(Material.Orange, Material.Shade900)
            case "published": return Material.color(Material.Green, Material.Shade900)
            case "rejected": return Material.color(Material.Red, Material.Shade900)
            default: return Material.color(Material.Grey, Material.Shade900)
        }
    }

    function getStatusText(status) {
        switch(status) {
            case "draft": return "Draft"
            case "pending_review": return "Pending Review"
            case "published": return "Published"
            case "rejected": return "Rejected"
            default: return status
        }
    }

    function formatPrice(price, isFree) {
        if (isFree) return "Free"
        return "$" + price.toFixed(2)
    }

    function formatDate(isoDate) {
        if (!isoDate) return ""
        var date = new Date(isoDate)
        return Qt.formatDate(date, "MMM dd, yyyy")
    }

    function getLevelColor(level) {
        switch(level) {
            case "beginner": return Material.color(Material.Green, Material.Shade100)
            case "intermediate": return Material.color(Material.Blue, Material.Shade100)
            case "advanced": return Material.color(Material.Purple, Material.Shade100)
            default: return Material.color(Material.Grey, Material.Shade100)
        }
    }

    function getLevelTextColor(level) {
        switch(level) {
            case "beginner": return Material.color(Material.Green, Material.Shade900)
            case "intermediate": return Material.color(Material.Blue, Material.Shade900)
            case "advanced": return Material.color(Material.Purple, Material.Shade900)
            default: return Material.color(Material.Grey, Material.Shade900)
        }
    }

    function capitalizeFirst(str) {
        if (!str) return ""
        return str.charAt(0).toUpperCase() + str.slice(1)
    }

    function generateStars(rating) {
        var stars = ""
        var fullStars = Math.floor(rating)
        var hasHalf = (rating % 1) >= 0.5

        for (var i = 0; i < fullStars; i++) {
            stars += "★"
        }
        if (hasHalf) {
            stars += "⯨"
        }
        while (stars.length < 5) {
            stars += "☆"
        }
        return stars
    }

    // Main Layout
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        // Page Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Label {
                text: "Courses Management"
                font.pixelSize: 28
                font.weight: Font.DemiBold
                color: Material.foreground
            }

            Item { Layout.fillWidth: true }

            Label {
                text: totalCourses + " total courses"
                font.pixelSize: 14
                color: Material.hintTextColor
                visible: !loadingCourses
            }

            Button {
                text: "Create Course"
                highlighted: true
                onClicked: {
                    successNotification.show("Create Course page - Coming soon!")
                    // TODO: Navigate to create course page
                    // stackView.push(createCourseComponent)
                }
            }

            Button {
                text: "Refresh"
                flat: true
                icon.source: "qrc:/icons/refresh.svg"
                onClicked: {
                    courseController.refresh()
                    loadCourses()
                }
                enabled: !courseController.isLoading && !loadingCourses
            }
        }

        // Statistics Cards
        GridLayout {
            Layout.fillWidth: true
            columns: 5
            columnSpacing: 16
            rowSpacing: 16

            CourseStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                title: "Total Courses"
                value: courseController.totalCourses
                status: "total"
            }

            CourseStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                title: "Draft"
                value: courseController.draftCourses
                status: "draft"
            }

            CourseStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                title: "Pending Review"
                value: courseController.pendingReviewCourses
                status: "pending_review"
            }

            CourseStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                title: "Published"
                value: courseController.publishedCourses
                status: "published"
            }

            CourseStatsCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                title: "Rejected"
                value: courseController.rejectedCourses
                status: "rejected"
            }
        }

        // Filters Section
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

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { label: "All", value: "all", count: courseController.totalCourses },
                            { label: "Draft", value: "draft", count: courseController.draftCourses },
                            { label: "Pending Review", value: "pending_review", count: courseController.pendingReviewCourses },
                            { label: "Published", value: "published", count: courseController.publishedCourses },
                            { label: "Rejected", value: "rejected", count: courseController.rejectedCourses }
                        ]

                        Button {
                            text: modelData.label + (modelData.count > 0 ? " (" + modelData.count + ")" : "")
                            flat: currentStatus !== modelData.value
                            highlighted: currentStatus === modelData.value
                            enabled: !loadingCourses

                            onClicked: {
                                currentStatus = modelData.value
                                currentPage = 1
                                loadCourses()
                            }

                            Material.background: currentStatus === modelData.value ? Material.accent : "transparent"
                        }
                    }

                    Item { Layout.fillWidth: true }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search courses by title or description..."
                        selectByMouse: true
                        enabled: !loadingCourses

                        onTextChanged: searchTimer.restart()
                        onAccepted: {
                            searchTimer.stop()
                            searchQuery = searchField.text
                            currentPage = 1
                            loadCourses()
                        }

                        Timer {
                            id: searchTimer
                            interval: 500
                            repeat: false
                            onTriggered: {
                                searchQuery = searchField.text
                                currentPage = 1
                                loadCourses()
                            }
                        }
                    }

                    Button {
                        text: "Search"
                        highlighted: true
                        enabled: !loadingCourses
                        onClicked: {
                            searchTimer.stop()
                            searchQuery = searchField.text
                            currentPage = 1
                            loadCourses()
                        }
                    }

                    Button {
                        text: "Clear"
                        flat: true
                        visible: searchField.text.length > 0
                        enabled: !loadingCourses
                        onClicked: {
                            searchTimer.stop()
                            searchField.text = ""
                            searchQuery = ""
                            currentPage = 1
                            loadCourses()
                        }
                    }
                }
            }
        }



        // Courses Table
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

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Label {
                            Layout.preferredWidth: 280
                            text: "Course"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                            color: Material.foreground
                        }

                        Label {
                            Layout.preferredWidth: 150
                            text: "Instructor"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }

                        Label {
                            Layout.preferredWidth: 100
                            text: "Category"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }

                        Label {
                            Layout.preferredWidth: 90
                            text: "Level"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }

                        Label {
                            Layout.preferredWidth: 70
                            text: "Price"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }

                        Label {
                            Layout.preferredWidth: 90
                            text: "Content"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }

                        Label {
                            Layout.preferredWidth: 120
                            text: "Enrollments"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }

                        Label {
                            Layout.preferredWidth: 100
                            text: "Status"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "Actions"
                            font.weight: Font.DemiBold
                            font.pixelSize: 12
                        }
                    }

                }

                // Content Area
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // Loading
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        visible: loadingCourses

                        BusyIndicator {
                            Layout.alignment: Qt.AlignHCenter
                            running: loadingCourses
                        }

                        Label {
                            text: "Loading courses..."
                            color: Material.hintTextColor
                        }
                    }

                    // Empty State
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        visible: !loadingCourses && courses.length === 0

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "📚"
                            font.pixelSize: 64
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No courses found"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                        }

                        Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: searchQuery ? "Try adjusting your search" : "Courses will appear here"
                            color: Material.hintTextColor
                        }
                    }

                    // Courses List
                    ScrollView {
                        anchors.fill: parent
                        visible: !loadingCourses && courses.length > 0
                        clip: true

                        ListView {
                            id: coursesList
                            model: courses
                            spacing: 0

                            delegate: Rectangle {
                                width: coursesList.width
                                height: 100
                                color: courseMA.containsMouse ? Material.color(Material.Grey, Material.Shade50) : "transparent"

                                Behavior on color { ColorAnimation { duration: 150 } }

                                MouseArea {
                                    id: courseMA
                                    anchors.fill: parent
                                    hoverEnabled: true
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: 1
                                    color: Material.dividerColor
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 12

                                    // Course (Thumbnail + Title + Date)
                                    RowLayout {
                                        Layout.preferredWidth: 280
                                        spacing: 12

                                        Rectangle {
                                            Layout.preferredWidth: 60
                                            Layout.preferredHeight: 60
                                            radius: 6
                                            color: Material.color(Material.Grey, Material.Shade200)
                                            clip: true

                                            Image {
                                                anchors.fill: parent
                                                source: modelData.thumbnail || ""
                                                fillMode: Image.PreserveAspectCrop
                                                visible: modelData.thumbnail && modelData.thumbnail.length > 0
                                            }

                                            Label {
                                                anchors.centerIn: parent
                                                text: "📚"
                                                font.pixelSize: 28
                                                visible: !modelData.thumbnail || modelData.thumbnail.length === 0
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Label {
                                                text: modelData.title || "Untitled"
                                                font.pixelSize: 14
                                                font.weight: Font.Medium
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            Label {
                                                text: formatDate(modelData.createdAt)
                                                font.pixelSize: 12
                                                color: Material.hintTextColor
                                            }
                                        }
                                    }

                                    // Instructor
                                    ColumnLayout {
                                        Layout.preferredWidth: 150
                                        spacing: 2

                                        Label {
                                            text: modelData.instructor ? modelData.instructor.name || "Unknown" : "Unknown"
                                            font.pixelSize: 13
                                            font.weight: Font.Medium
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Label {
                                            text: modelData.instructor ? modelData.instructor.email || "" : ""
                                            font.pixelSize: 11
                                            color: Material.hintTextColor
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // Category
                                    Item {
                                        Layout.preferredWidth: 100

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: Math.min(categoryLabel.implicitWidth + 12, 100)
                                            height: 24
                                            radius: 12
                                            color: Material.color(Material.LightBlue, Material.Shade100)

                                            Label {
                                                id: categoryLabel
                                                anchors.centerIn: parent
                                                text: modelData.category || "General"
                                                font.pixelSize: 11
                                                color: Material.color(Material.LightBlue, Material.Shade900)
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }

                                    // Level
                                    Item {
                                        Layout.preferredWidth: 90

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: levelLabel.implicitWidth + 12
                                            height: 24
                                            radius: 12
                                            color: getLevelColor(modelData.level)

                                            Label {
                                                id: levelLabel
                                                anchors.centerIn: parent
                                                text: capitalizeFirst(modelData.level || "beginner")
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: getLevelTextColor(modelData.level)
                                            }
                                        }
                                    }

                                    // Price
                                    Item {
                                        Layout.preferredWidth: 70

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: priceLabel.implicitWidth + 12
                                            height: 24
                                            radius: 12
                                            color: modelData.isFree ? Material.color(Material.Green, Material.Shade100) : Material.color(Material.Blue, Material.Shade100)

                                            Label {
                                                id: priceLabel
                                                anchors.centerIn: parent
                                                text: formatPrice(modelData.price || 0, modelData.isFree || false)
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: modelData.isFree ? Material.color(Material.Green, Material.Shade900) : Material.color(Material.Blue, Material.Shade900)
                                            }
                                        }
                                    }

                                    // Content
                                    ColumnLayout {
                                        Layout.preferredWidth: 90
                                        spacing: 2

                                        Label {
                                            text: (modelData.sectionsCount || 0) + " sections"
                                            font.pixelSize: 11
                                            color: Material.foreground
                                        }

                                        Label {
                                            text: (modelData.lessonsCount || 0) + " lessons"
                                            font.pixelSize: 11
                                            color: Material.hintTextColor
                                        }
                                    }

                                    // Enrollments
                                    ColumnLayout {
                                        Layout.preferredWidth: 120
                                        spacing: 2

                                        Label {
                                            text: (modelData.enrollmentCount || 0) + " students"
                                            font.pixelSize: 11
                                            color: Material.foreground
                                        }

                                        RowLayout {
                                            spacing: 4

                                            Label {
                                                text: generateStars(modelData.rating || 0)
                                                font.pixelSize: 12
                                                color: "#FFA500"
                                            }

                                            Label {
                                                text: (modelData.rating || 0).toFixed(1) + " (" + (modelData.reviewCount || 0) + ")"
                                                font.pixelSize: 10
                                                color: Material.hintTextColor
                                            }
                                        }
                                    }

                                    // Status
                                    Item {
                                        Layout.preferredWidth: 100

                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: statusLabel.implicitWidth + 12
                                            height: 24
                                            radius: 12
                                            color: getStatusColor(modelData.status)

                                            Label {
                                                id: statusLabel
                                                anchors.centerIn: parent
                                                text: getStatusText(modelData.status)
                                                font.pixelSize: 11
                                                font.weight: Font.Medium
                                                color: getStatusTextColor(modelData.status)
                                            }
                                        }
                                    }

                                    // Actions
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 4

                                        ToolButton {
                                            text: "✏️"
                                            font.pixelSize: 14
                                            ToolTip.text: "Edit"
                                            ToolTip.visible: hovered
                                            onClicked: {
                                                // Navigate to EditCoursePage via DashboardPage
                                                var dash = root
                                                while (dash && !dash.hasOwnProperty("editCourseId")) {
                                                    dash = dash.parent
                                                }
                                                if (dash) {
                                                    dash.editCourseId = modelData.id
                                                    dash.currentView = "edit_course"
                                                }
                                            }
                                        }

                                        ToolButton {
                                            text: "👁️"
                                            font.pixelSize: 14
                                            ToolTip.text: "Review"
                                            ToolTip.visible: hovered
                                            onClicked: {
                                                // Navigate to ReviewCoursePage via DashboardPage
                                                var dash = root
                                                while (dash && !dash.hasOwnProperty("reviewCourseId")) {
                                                    dash = dash.parent
                                                }
                                                if (dash) {
                                                    dash.reviewCourseId = modelData.id
                                                    dash.currentView = "review_course"
                                                }
                                            }
                                        }

                                        ToolButton {
                                            text: "🗑️"
                                            font.pixelSize: 14
                                            ToolTip.text: "Delete"
                                            ToolTip.visible: hovered
                                            onClicked: {
                                                deleteDialog.courseId = modelData.id
                                                deleteDialog.courseTitle = modelData.title
                                                deleteDialog.open()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Pagination
                Rectangle {
                    Layout.fillWidth: true
                    height: 60
                    color: "transparent"
                    visible: !loadingCourses && courses.length > 0 && totalPages > 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Button {
                            text: "←"
                            flat: true
                            enabled: currentPage > 1
                            onClicked: {
                                currentPage--
                                loadCourses()
                            }
                        }

                        Repeater {
                            model: {
                                var pages = []
                                var start = Math.max(1, currentPage - 2)
                                var end = Math.min(totalPages, currentPage + 2)

                                if (start > 1) pages.push(1)
                                if (start > 2) pages.push(-1)

                                for (var i = start; i <= end; i++) {
                                    pages.push(i)
                                }

                                if (end < totalPages - 1) pages.push(-1)
                                if (end < totalPages) pages.push(totalPages)

                                return pages
                            }

                            Button {
                                text: modelData === -1 ? "..." : modelData.toString()
                                flat: modelData !== currentPage
                                highlighted: modelData === currentPage
                                enabled: modelData !== -1 && modelData !== currentPage
                                onClicked: {
                                    if (modelData !== -1) {
                                        currentPage = modelData
                                        loadCourses()
                                    }
                                }
                            }
                        }

                        Button {
                            text: "→"
                            flat: true
                            enabled: currentPage < totalPages
                            onClicked: {
                                currentPage++
                                loadCourses()
                            }
                        }
                    }
                }
            }
        }
    }

    // Delete Confirmation Dialog
    Dialog {
        id: deleteDialog
        modal: true
        title: "Delete Course"
        anchors.centerIn: parent
        width: 400

        property string courseId: ""
        property string courseTitle: ""

        ColumnLayout {
            spacing: 16
            width: parent.width

            Label {
                text: "Are you sure you want to delete <b>" + deleteDialog.courseTitle + "</b>?"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Label {
                text: "⚠️ This action cannot be undone. All course content, enrollments, and progress will be permanently deleted."
                wrapMode: Text.WordWrap
                color: Material.color(Material.Red)
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Item { Layout.fillWidth: true }

                Button {
                    text: "Cancel"
                    flat: true
                    onClicked: deleteDialog.close()
                }

                Button {
                    text: deletingCourse ? "Deleting..." : "Delete"
                    highlighted: true
                    Material.background: Material.color(Material.Red)
                    enabled: !deletingCourse
                    onClicked: {
                        deletingCourse = true

                        var xhr = new XMLHttpRequest()
                        xhr.open("DELETE", "https://learning-dashboard-rouge.vercel.app/api/courses/" + deleteDialog.courseId)
                        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
                        xhr.setRequestHeader("Accept", "application/json")

                        xhr.onreadystatechange = function() {
                            if (xhr.readyState === XMLHttpRequest.DONE) {
                                deletingCourse = false

                                if (xhr.status === 200) {
                                    try {
                                        var response = JSON.parse(xhr.responseText)
                                        if (response.success) {
                                            successNotification.show("Course deleted successfully")
                                            deleteDialog.close()
                                            courseController.refresh()
                                            loadCourses()
                                        } else {
                                            errorNotification.show(response.message || "Failed to delete course")
                                            deleteDialog.close()
                                        }
                                    } catch (e) {
                                        errorNotification.show("Failed to delete course")
                                        deleteDialog.close()
                                    }
                                } else {
                                    try {
                                        var response = JSON.parse(xhr.responseText)
                                        errorNotification.show(response.message || "Failed to delete course")
                                    } catch (e) {
                                        errorNotification.show("Failed to delete course. Please try again.")
                                    }
                                    deleteDialog.close()
                                }
                            }
                        }

                        xhr.send()
                    }
                }
            }
        }
    }

    // Course Review Dialog
    CourseReviewDialog {
        id: reviewDialog

        onCourseApproved: {
            successNotification.show("✓ Course approved and published successfully!")
            courseController.refresh()
            loadCourses()
        }

        onCourseRejected: {
            successNotification.show("Course rejected. Instructor has been notified.")
            courseController.refresh()
            loadCourses()
        }
    }

    // Notifications
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

