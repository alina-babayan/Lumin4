import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property string courseId: ""
    property var courseData: null
    property bool isLoading: false
    property bool isSaving: false
    property int activeTab: 0

    signal backRequested()
    signal courseSaved()

    onCourseIdChanged: { if (courseId !== "") { activeTab = 0; fetchCourse() } }

    Connections {
        target: authController
        function onAccessTokenChanged() {
            if (authController.accessToken && courseId !== "") fetchCourse()
        }
    }

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
                    if (r.success) { courseData = r.data.course || r.data; populateFields() }
                    else showError(r.message || "Failed to load course")
                } catch(e) { showError("Failed to parse course data") }
            } else { showError("Failed to load course. Status: " + xhr.status) }
        }
        xhr.send()
    }

    function populateFields() {
        if (!courseData) return
        titleField.text         = courseData.title              || ""
        subtitleField.text      = courseData.subtitle           || ""
        descriptionArea.text    = courseData.description        || ""
        shortDescArea.text      = courseData.shortDescription   || ""
        thumbnailField.text     = courseData.thumbnail          || ""
        promoVideoField.text    = courseData.promoVideo         || ""
        subCategoryField.text   = courseData.subCategory        || ""
        sectorField.text        = courseData.sector             || ""
        priceField.text         = courseData.price !== undefined ? courseData.price.toString() : "0"
        discountField.text      = courseData.discountPrice !== undefined ? courseData.discountPrice.toString() : ""
        isFreeCheck.checked     = courseData.isFree             || false
        requirementsArea.text   = (courseData.requirements      || []).join("\n")
        whatLearnArea.text      = (courseData.whatYouWillLearn  || []).join("\n")
        targetArea.text         = (courseData.targetAudience    || []).join("\n")
        var catIdx = categoryCombo.model.indexOf(courseData.category || "")
        categoryCombo.currentIndex = catIdx >= 0 ? catIdx : 0
        var langIdx = languageCombo.model.indexOf(courseData.language || "")
        languageCombo.currentIndex = langIdx >= 0 ? langIdx : 0
        var lvlIdx = levelCombo.model.indexOf(courseData.level || "")
        levelCombo.currentIndex = lvlIdx >= 0 ? lvlIdx : 0
    }

    function showError(msg)   { errLbl.text = msg; errLbl.visible = true;  errT.restart() }
    function showSuccess(msg) { okLbl.text  = msg; okLbl.visible  = true;  okT.restart()  }

    function doSave() {
        if (isSaving) return
        isSaving = true
        var payload = {
            title:            titleField.text.trim(),
            subtitle:         subtitleField.text.trim(),
            description:      descriptionArea.text.trim(),
            shortDescription: shortDescArea.text.trim(),
            thumbnail:        thumbnailField.text.trim(),
            promoVideo:       promoVideoField.text.trim(),
            category:         categoryCombo.currentText,
            subCategory:      subCategoryField.text.trim(),
            language:         languageCombo.currentText,
            level:            levelCombo.currentText,
            isFree:           isFreeCheck.checked,
            price:            isFreeCheck.checked ? 0 : (parseFloat(priceField.text) || 0),
            hasCertificate:   certCheck.checked,
            dripContent:      dripCheck.checked,
            whatYouWillLearn: whatLearnArea.text.trim().split("\n").filter(function(l){ return l.trim().length > 0 }),
            requirements:     requirementsArea.text.trim().split("\n").filter(function(l){ return l.trim().length > 0 }),
            targetAudience:   targetArea.text.trim().split("\n").filter(function(l){ return l.trim().length > 0 })
        }
        if (discountField.text.trim().length > 0)
            payload["discountPrice"] = parseFloat(discountField.text) || 0
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + courseId)
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            isSaving = false
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) { showSuccess("Course saved successfully!"); root.courseSaved() }
                    else showError(r.message || "Failed to save")
                } catch(e) { showError("Failed to parse response") }
            } else {
                try { showError(JSON.parse(xhr.responseText).message || "Save failed") }
                catch(_) { showError("Save failed. Status: " + xhr.status) }
            }
        }
        xhr.send(JSON.stringify(payload))
    }

    function submitForReview() {
        var xhr = new XMLHttpRequest()
        xhr.open("PUT", "https://learning-dashboard-rouge.vercel.app/api/courses/" + courseId + "/status")
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Content-Type", "application/json")
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) {
                        showSuccess("Course submitted for review!")
                        if (courseData) { var d = courseData; d.status = "pending_review"; courseData = null; courseData = d }
                    } else showError(r.message || "Failed to submit")
                } catch(e) { showError("Failed to submit for review") }
            } else showError("Submit failed. Status: " + xhr.status)
        }
        xhr.send(JSON.stringify({ status: "pending_review" }))
    }

    Rectangle {
        anchors.fill: parent
        color: "#F9FAFB"

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // TOP BAR
            Rectangle {
                Layout.fillWidth: true; height: 64; color: "white"
                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                RowLayout { anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 12
                    Rectangle { width: 36; height: 36; radius: 8; color: bkHov.containsMouse ? "#F3F4F6" : "transparent"; border.color: "#E5E7EB"; border.width: 1
                        Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: "#374151" }
                        MouseArea { id: bkHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.backRequested() } }
                    ColumnLayout { spacing: 2
                        Text { text: "Edit Course"; font.pixelSize: 20; font.weight: Font.DemiBold; color: "#18181B" }
                        Text { text: courseData ? (courseData.title || "") : ""; font.pixelSize: 12; color: "#6B7280"; elide: Text.ElideRight; maximumLineCount: 1 }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        visible: courseData !== null; height: 26; radius: 13; width: stTxt.implicitWidth + 20
                        color: !courseData ? "#F3F4F6" : courseData.status === "published" ? "#DCFCE7" : courseData.status === "pending_review" ? "#FEF9C3" : courseData.status === "rejected" ? "#FEE2E2" : "#F3F4F6"
                        Text { id: stTxt; anchors.centerIn: parent; font.pixelSize: 12; font.weight: Font.Medium
                            text: !courseData ? "" : courseData.status === "pending_review" ? "Pending Review" : courseData.status ? courseData.status.charAt(0).toUpperCase() + courseData.status.slice(1) : "Draft"
                            color: !courseData ? "#6B7280" : courseData.status === "published" ? "#16A34A" : courseData.status === "pending_review" ? "#92400E" : courseData.status === "rejected" ? "#DC2626" : "#6B7280" }
                    }
                    Rectangle { height: 38; radius: 8; width: topSvTxt.implicitWidth + 28
                        color: isSaving ? "#9CA3AF" : (topSvHov.containsMouse ? "#4338CA" : "#4F46E5")
                        Text { id: topSvTxt; anchors.centerIn: parent; text: isSaving ? "Saving…" : "Save"; color: "white"; font.pixelSize: 14; font.weight: Font.Medium }
                        MouseArea { id: topSvHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: !isSaving; onClicked: doSave() } }
                }
            }

            // TOAST
            Rectangle { Layout.fillWidth: true; height: 42; color: "#DCFCE7"; visible: okLbl.visible
                RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 10
                    Text { text: "✓"; color: "#16A34A"; font.pixelSize: 14 }
                    Text { id: okLbl; visible: false; color: "#15803D"; font.pixelSize: 13; Layout.fillWidth: true }
                    Timer { id: okT; interval: 3000; onTriggered: okLbl.visible = false } } }
            Rectangle { Layout.fillWidth: true; height: 42; color: "#FEE2E2"; visible: errLbl.visible
                RowLayout { anchors.fill: parent; anchors.margins: 16; spacing: 10
                    Text { text: "✕"; color: "#DC2626"; font.pixelSize: 14 }
                    Text { id: errLbl; visible: false; color: "#DC2626"; font.pixelSize: 13; Layout.fillWidth: true }
                    Timer { id: errT; interval: 5000; onTriggered: errLbl.visible = false } } }

            // LOADING
            Item { Layout.fillWidth: true; Layout.fillHeight: true; visible: isLoading
                ColumnLayout { anchors.centerIn: parent; spacing: 16
                    BusyIndicator { Layout.alignment: Qt.AlignHCenter; running: true; width: 48; height: 48 }
                    Text { text: "Loading course…"; font.pixelSize: 14; color: "#6B7280"; Layout.alignment: Qt.AlignHCenter } } }

            // MAIN CONTENT
            ColumnLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0; visible: !isLoading

                // Progress bar
                Rectangle { Layout.fillWidth: true; height: 4; color: "#E5E7EB"
                    Rectangle { width: parent.width * (activeTab + 1) / 4; height: 4; color: "#4F46E5"
                        Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } } } }

                // Tab bar
                Rectangle { Layout.fillWidth: true; height: 50; color: "white"
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 0
                        Repeater {
                            model: ["Basic Info", "Curriculum", "Additional Details", "Preview & Publish"]
                            Item { height: parent.height; width: tbLbl.implicitWidth + 32
                                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 2; color: index === activeTab ? "#4F46E5" : "transparent" }
                                Text { id: tbLbl; anchors.centerIn: parent; text: modelData; font.pixelSize: 13; font.weight: index === activeTab ? Font.DemiBold : Font.Normal; color: index === activeTab ? "#4F46E5" : "#6B7280" }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: activeTab = index }
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }

                StackLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true; currentIndex: activeTab

                    // ===== TAB 0: BASIC INFO — left/right split =====
                    ScrollView { clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        Flickable { contentHeight: t0row.implicitHeight + 60; clip: true
                            RowLayout {
                                id: t0row
                                x: 24; y: 24; width: parent.width - 48
                                spacing: 20

                                // LEFT column
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 20

                                    // Title & Description
                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c0a.implicitHeight + 40
                                        ColumnLayout { id: c0a; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                            Text { text: "Course Title & Description"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                Text { text: "Course Title *"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                TextField { id: titleField; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: "Enter course title"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                    background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                            ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                Text { text: "Course Subtitle"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                TextField { id: subtitleField; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: "Short, descriptive subtitle"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                    background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                            ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                Text { text: "Full Description *"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                Rectangle { Layout.fillWidth: true; height: 160; radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1; clip: true
                                                    ScrollView { anchors.fill: parent; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                                        TextArea { id: descriptionArea; width: parent.width; wrapMode: TextArea.Wrap; selectByMouse: true; placeholderText: "Describe what students will learn…"; padding: 10; background: null } } } }
                                            ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                Text { text: "Short Description"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                Rectangle { Layout.fillWidth: true; height: 90; radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1; clip: true
                                                    ScrollView { anchors.fill: parent; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                                        TextArea { id: shortDescArea; width: parent.width; wrapMode: TextArea.Wrap; selectByMouse: true; placeholderText: "Brief summary shown in course cards"; padding: 10; background: null } } }
                                            }
                                        }
                                    }

                                    // Category & Settings
                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c0c.implicitHeight + 40
                                        ColumnLayout { id: c0c; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                            Text { text: "Category & Settings"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            RowLayout { Layout.fillWidth: true; spacing: 16
                                                ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                    Text { text: "Category"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                    ComboBox { id: categoryCombo; Layout.fillWidth: true; Layout.preferredHeight: 42
                                                        model: ["Web Development","Mobile Development","Data Science","Machine Learning","UI/UX Design","Cybersecurity","Cloud Computing","DevOps","Game Development","Other"]
                                                        background: Rectangle { radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1 } } }
                                                ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                    Text { text: "Sub Category"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                    TextField { id: subCategoryField; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: "e.g. React, Node.js"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                        background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                            }
                                            RowLayout { Layout.fillWidth: true; spacing: 16
                                                ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                    Text { text: "Language"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                    ComboBox { id: languageCombo; Layout.fillWidth: true; Layout.preferredHeight: 42
                                                        model: ["English","Armenian","Russian","French","Spanish","German","Other"]
                                                        background: Rectangle { radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1 } } }
                                                ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                    Text { text: "Level"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                    ComboBox { id: levelCombo; Layout.fillWidth: true; Layout.preferredHeight: 42
                                                        model: ["beginner","intermediate","advanced","all-levels"]
                                                        background: Rectangle { radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1 } } }
                                            }
                                            RowLayout { Layout.fillWidth: true; spacing: 16
                                                ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                    Text { text: "Sector / Tag"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                    TextField { id: sectorField; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: "e.g. Technology"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                        background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                                ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                    Text { text: "Promo Video URL"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                    TextField { id: promoVideoField; Layout.fillWidth: true; Layout.preferredHeight: 42; placeholderText: "https://youtube.com/…"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                        background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                            }
                                        }
                                    }

                                    // Trainer info
                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c0e.implicitHeight + 40
                                        ColumnLayout { id: c0e; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                            Text { text: "Trainer Info"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            Text { text: "Instructor details are auto-populated from the course creator's profile."; font.pixelSize: 13; color: "#6B7280"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                            RowLayout { spacing: 12
                                                Rectangle { width: 44; height: 44; radius: 22; color: "#EEF2FF"
                                                    Text { anchors.centerIn: parent; text: courseData && courseData.instructor ? (courseData.instructor.name || "?").charAt(0).toUpperCase() : "?"; font.pixelSize: 18; font.weight: Font.Medium; color: "#4F46E5" } }
                                                ColumnLayout { spacing: 2
                                                    Text { text: courseData && courseData.instructor ? (courseData.instructor.name || "Unknown") : "Unknown"; font.pixelSize: 14; font.weight: Font.Medium; color: "#18181B" }
                                                    Text { text: courseData && courseData.instructor ? (courseData.instructor.email || "") : ""; font.pixelSize: 12; color: "#9CA3AF" }
                                                }
                                            }
                                        }
                                    }
                                    Item { height: 20 }
                                }

                                // RIGHT column — thumbnail + pricing
                                ColumnLayout {
                                    Layout.preferredWidth: 300; Layout.minimumWidth: 260; spacing: 20

                                    // Thumbnail card
                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c0b.implicitHeight + 40
                                        ColumnLayout { id: c0b; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 14
                                            Text { text: "Course Thumbnail"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            Rectangle { Layout.fillWidth: true; height: 180; radius: 8; color: "#F9FAFB"; border.color: "#E5E7EB"; border.width: 1; clip: true
                                                Image { anchors.fill: parent; source: thumbnailField.text; fillMode: Image.PreserveAspectCrop; visible: thumbnailField.text.length > 0 }
                                                ColumnLayout { anchors.centerIn: parent; spacing: 8; visible: thumbnailField.text.length === 0
                                                    Text { text: "🖼️"; font.pixelSize: 40; Layout.alignment: Qt.AlignHCenter }
                                                    Text { text: "No thumbnail set"; font.pixelSize: 13; color: "#9CA3AF"; Layout.alignment: Qt.AlignHCenter } }
                                                Rectangle { anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 8; width: 26; height: 26; radius: 13; color: "#EF4444"; visible: thumbnailField.text.length > 0
                                                    Text { anchors.centerIn: parent; text: "✕"; color: "white"; font.pixelSize: 13; font.weight: Font.Bold }
                                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: thumbnailField.text = "" } }
                                            }
                                            ColumnLayout { Layout.fillWidth: true; spacing: 6
                                                Text { text: "Thumbnail URL"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                TextField { id: thumbnailField; Layout.fillWidth: true; Layout.preferredHeight: 40; placeholderText: "https://example.com/thumbnail.jpg"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                    background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                        }
                                    }

                                    // Pricing card
                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c0d.implicitHeight + 40
                                        ColumnLayout { id: c0d; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 14
                                            Text { text: "Pricing"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            CheckBox { id: isFreeCheck; text: "Free Course"; font.pixelSize: 13 }
                                            ColumnLayout { Layout.fillWidth: true; spacing: 6; visible: !isFreeCheck.checked
                                                Text { text: "Price (USD)"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                TextField { id: priceField; Layout.fillWidth: true; Layout.preferredHeight: 40; placeholderText: "0.00"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                    background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                            ColumnLayout { Layout.fillWidth: true; spacing: 6; visible: !isFreeCheck.checked
                                                Text { text: "Discount Price (Optional)"; font.pixelSize: 13; font.weight: Font.Medium; color: "#374151" }
                                                TextField { id: discountField; Layout.fillWidth: true; Layout.preferredHeight: 40; placeholderText: "0.00"; selectByMouse: true; leftPadding: 12; rightPadding: 12
                                                    background: Rectangle { radius: 6; color: "white"; border.color: parent.activeFocus ? "#4F46E5" : "#E5E7EB"; border.width: parent.activeFocus ? 2 : 1 } } }
                                        }
                                    }
                                    Item { height: 20 }
                                }
                            }
                        }
                    }

                    // ===== TAB 1: CURRICULUM =====
                    ScrollView { clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        Flickable { contentHeight: t1col.implicitHeight + 48; clip: true
                            ColumnLayout { id: t1col; width: parent.width - 48; x: 24; y: 24; spacing: 20

                                RowLayout { Layout.fillWidth: true; spacing: 16
                                    Repeater {
                                        model: [
                                            { label: "Sections", val: courseData ? (courseData.sectionsCount || (courseData.sections ? courseData.sections.length : 0)).toString() : "0" },
                                            { label: "Lessons",  val: courseData ? (courseData.lessonsCount || 0).toString() : "0" },
                                            { label: "Duration", val: courseData ? (courseData.totalDuration || "0 min") : "0 min" }
                                        ]
                                        Rectangle { Layout.fillWidth: true; height: 80; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1
                                            ColumnLayout { anchors.fill: parent; anchors.margins: 16; spacing: 4
                                                Text { text: modelData.val; font.pixelSize: 26; font.weight: Font.Bold; color: "#18181B" }
                                                Text { text: modelData.label; font.pixelSize: 12; color: "#6B7280" }
                                            }
                                        }
                                    }
                                }

                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: currInner.implicitHeight + 40
                                    ColumnLayout { id: currInner; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                        RowLayout { Layout.fillWidth: true
                                            Text { text: "Course Curriculum"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Item { Layout.fillWidth: true }
                                            Rectangle { height: 34; radius: 6; width: addSecLbl.implicitWidth + 24; color: addSecHov.containsMouse ? "#4338CA" : "#4F46E5"
                                                Text { id: addSecLbl; anchors.centerIn: parent; text: "+ Add Section"; font.pixelSize: 13; color: "white" }
                                                MouseArea { id: addSecHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: showError("Section management via course API") } }
                                        }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }

                                        Repeater {
                                            model: courseData ? (courseData.sections || []) : []
                                            ColumnLayout { Layout.fillWidth: true; spacing: 1
                                                property var sec: modelData
                                                property int si: index
                                                Rectangle { Layout.fillWidth: true; height: 48; radius: 8; color: "#F9FAFB"; border.color: "#E5E7EB"; border.width: 1
                                                    RowLayout { anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 10
                                                        Text { text: "▸"; color: "#6B7280"; font.pixelSize: 14 }
                                                        Text { text: sec.title || ("Section " + (si+1)); font.pixelSize: 14; font.weight: Font.Medium; color: "#18181B"; Layout.fillWidth: true }
                                                        Text { text: (sec.lessons ? sec.lessons.length : 0) + " lessons"; font.pixelSize: 12; color: "#9CA3AF" }
                                                        Rectangle { width: 28; height: 28; radius: 6; color: eSecH.containsMouse ? "#EEF2FF" : "transparent"
                                                            Text { anchors.centerIn: parent; text: "✏️"; font.pixelSize: 14 }
                                                            MouseArea { id: eSecH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: showError("Edit section via API") } }
                                                        Rectangle { width: 28; height: 28; radius: 6; color: dSecH.containsMouse ? "#FEE2E2" : "transparent"
                                                            Text { anchors.centerIn: parent; text: "🗑️"; font.pixelSize: 14 }
                                                            MouseArea { id: dSecH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: showError("Delete section via API") } }
                                                    }
                                                }
                                                Repeater {
                                                    model: sec.lessons || []
                                                    Rectangle { Layout.fillWidth: true; height: 44; color: "transparent"
                                                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F3F4F6" }
                                                        RowLayout { anchors.fill: parent; anchors.leftMargin: 36; anchors.rightMargin: 12; spacing: 10
                                                            Text { text: modelData.type === "quiz" ? "❓" : modelData.type === "article" ? "📄" : "▶"; font.pixelSize: 13; color: "#6B7280" }
                                                            Text { text: modelData.title || ("Lesson "+(index+1)); font.pixelSize: 13; color: "#374151"; Layout.fillWidth: true; elide: Text.ElideRight }
                                                            Text { text: modelData.duration || ""; font.pixelSize: 12; color: "#9CA3AF" }
                                                            Rectangle { width: 24; height: 24; radius: 4; color: eLesH.containsMouse?"#EEF2FF":"transparent"
                                                                Text { anchors.centerIn: parent; text: "✏️"; font.pixelSize: 12 }
                                                                MouseArea { id: eLesH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: showError("Edit lesson via API") } }
                                                            Rectangle { width: 24; height: 24; radius: 4; color: dLesH.containsMouse?"#FEE2E2":"transparent"
                                                                Text { anchors.centerIn: parent; text: "🗑️"; font.pixelSize: 12 }
                                                                MouseArea { id: dLesH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: showError("Delete lesson via API") } }
                                                        }
                                                    }
                                                }
                                                Rectangle { Layout.fillWidth: true; height: 40; color: addLH.containsMouse?"#F9FAFB":"transparent"; radius: 4
                                                    RowLayout { anchors.fill: parent; anchors.leftMargin: 36; spacing: 8
                                                        Text { text: "+"; color: "#4F46E5"; font.pixelSize: 18 }
                                                        Text { text: "Add Lesson"; color: "#4F46E5"; font.pixelSize: 13 } }
                                                    MouseArea { id: addLH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: showError("Add lesson via API") }
                                                }
                                            }
                                        }

                                        ColumnLayout { Layout.fillWidth: true; spacing: 12; Layout.topMargin: 20; Layout.bottomMargin: 20
                                            visible: !courseData || !(courseData.sections && courseData.sections.length > 0)
                                            Text { Layout.alignment: Qt.AlignHCenter; text: "📂"; font.pixelSize: 48 }
                                            Text { Layout.alignment: Qt.AlignHCenter; text: "No sections yet"; font.pixelSize: 15; font.weight: Font.Medium; color: "#18181B" }
                                            Text { Layout.alignment: Qt.AlignHCenter; text: "Click '+ Add Section' to start building your curriculum"; font.pixelSize: 13; color: "#9CA3AF" }
                                        }
                                    }
                                }
                                Item { height: 20 }
                            }
                        }
                    }

                    // ===== TAB 2: ADDITIONAL DETAILS =====
                    ScrollView { clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        Flickable { contentHeight: t2col.implicitHeight + 48; clip: true
                            ColumnLayout { id: t2col; width: parent.width - 48; x: 24; y: 24; spacing: 20

                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c2a.implicitHeight + 40
                                    ColumnLayout { id: c2a; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                        Text { text: "What Students Will Learn"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Text { text: "Enter each learning outcome on a new line"; font.pixelSize: 13; color: "#6B7280" }
                                        Rectangle { Layout.fillWidth: true; height: 150; radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1; clip: true
                                            ScrollView { anchors.fill: parent; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                                TextArea { id: whatLearnArea; width: parent.width; wrapMode: TextArea.Wrap; selectByMouse: true; padding: 10; background: null; placeholderText: "Build full-stack web applications\nUnderstand modern JavaScript…" } } } } }

                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c2b.implicitHeight + 40
                                    ColumnLayout { id: c2b; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                        Text { text: "Course Prerequisites"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Text { text: "Enter each requirement on a new line"; font.pixelSize: 13; color: "#6B7280" }
                                        Rectangle { Layout.fillWidth: true; height: 110; radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1; clip: true
                                            ScrollView { anchors.fill: parent; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                                TextArea { id: requirementsArea; width: parent.width; wrapMode: TextArea.Wrap; selectByMouse: true; padding: 10; background: null; placeholderText: "Basic HTML & CSS knowledge\nFamiliarity with programming concepts…" } } } } }

                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c2c.implicitHeight + 40
                                    ColumnLayout { id: c2c; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                        Text { text: "Target Audience"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Text { text: "Who is this course intended for?"; font.pixelSize: 13; color: "#6B7280" }
                                        Rectangle { Layout.fillWidth: true; height: 110; radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1; clip: true
                                            ScrollView { anchors.fill: parent; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                                TextArea { id: targetArea; width: parent.width; wrapMode: TextArea.Wrap; selectByMouse: true; padding: 10; background: null; placeholderText: "Beginner web developers\nAnyone looking to transition into tech…" } } } } }

                                Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c2d.implicitHeight + 40
                                    ColumnLayout { id: c2d; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                        Text { text: "Frequently Asked Questions"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                        Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                        Text { text: "Common questions students ask before enrolling"; font.pixelSize: 13; color: "#6B7280" }
                                        Rectangle { Layout.fillWidth: true; height: 140; radius: 6; color: "white"; border.color: "#E5E7EB"; border.width: 1; clip: true
                                            ScrollView { anchors.fill: parent; clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                                                TextArea { id: faqArea; width: parent.width; wrapMode: TextArea.Wrap; selectByMouse: true; padding: 10; background: null; placeholderText: "Q: How long do I have access?\nA: Lifetime access after purchase." } } } } }
                                Item { height: 20 }
                            }
                        }
                    }

                    // ===== TAB 3: PREVIEW & PUBLISH — left/right split =====
                    ScrollView { clip: true; ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        Flickable { contentHeight: t3row.implicitHeight + 60; clip: true
                            RowLayout {
                                id: t3row
                                x: 24; y: 24; width: parent.width - 48
                                spacing: 20

                                // LEFT: checklist + completion + submit
                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 20

                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c3a.implicitHeight + 40
                                        ColumnLayout { id: c3a; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                            Text { text: "Publication Checklist"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            Text { text: "Complete all requirements before submitting for review."; font.pixelSize: 13; color: "#6B7280"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                            Repeater {
                                                model: [
                                                    { label: "Course has a title",       ok: courseData ? (courseData.title || "").length > 0 : false },
                                                    { label: "Course has a description", ok: courseData ? (courseData.description || "").length > 0 : false },
                                                    { label: "Thumbnail uploaded",       ok: courseData ? (courseData.thumbnail || "").length > 0 : false },
                                                    { label: "At least one section",     ok: courseData ? ((courseData.sectionsCount || (courseData.sections ? courseData.sections.length : 0)) > 0) : false },
                                                    { label: "At least one lesson",      ok: courseData ? ((courseData.lessonsCount || 0) > 0) : false }
                                                ]
                                                RowLayout { Layout.fillWidth: true; spacing: 12
                                                    Rectangle { width: 24; height: 24; radius: 12; color: modelData.ok ? "#DCFCE7" : "#FEE2E2"
                                                        Text { anchors.centerIn: parent; text: modelData.ok ? "✓" : "✕"; font.pixelSize: 12; font.weight: Font.Bold; color: modelData.ok ? "#16A34A" : "#DC2626" } }
                                                    Text { text: modelData.label; font.pixelSize: 13; color: modelData.ok ? "#18181B" : "#9CA3AF"; Layout.fillWidth: true }
                                                }
                                            }
                                        }
                                    }

                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c3b.implicitHeight + 40
                                        ColumnLayout { id: c3b; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 16
                                            Text { text: "Course Completion Settings"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            RowLayout { Layout.fillWidth: true; spacing: 16
                                                CheckBox { id: certCheck; checked: courseData ? (courseData.hasCertificate || false) : false }
                                                ColumnLayout { spacing: 2
                                                    Text { text: "Certificate on Completion"; font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B" }
                                                    Text { text: "Students receive a certificate when they complete all lessons."; font.pixelSize: 12; color: "#6B7280"; wrapMode: Text.WordWrap; Layout.fillWidth: true } } }
                                            RowLayout { Layout.fillWidth: true; spacing: 16
                                                CheckBox { id: dripCheck; checked: courseData ? (courseData.dripContent || false) : false }
                                                ColumnLayout { spacing: 2
                                                    Text { text: "Drip Content"; font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B" }
                                                    Text { text: "Release lessons gradually on a schedule."; font.pixelSize: 12; color: "#6B7280"; wrapMode: Text.WordWrap; Layout.fillWidth: true } } }
                                        }
                                    }

                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "#EFF6FF"; border.color: "#BFDBFE"; border.width: 1; implicitHeight: c3d.implicitHeight + 40
                                        ColumnLayout { id: c3d; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 14
                                            Text { text: "Submit for Review"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#1D4ED8" }
                                            Text { text: "Once submitted, our team will review the course and notify you by email."; font.pixelSize: 13; color: "#1D4ED8"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                            RowLayout { Layout.fillWidth: true; spacing: 16
                                                Rectangle { height: 42; radius: 8; width: subTxt.implicitWidth + 28; color: subH.containsMouse ? "#1D4ED8" : "#2563EB"
                                                    Text { id: subTxt; anchors.centerIn: parent; text: "Submit for Review"; color: "white"; font.pixelSize: 14; font.weight: Font.Medium }
                                                    MouseArea { id: subH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: submitForReview() } }
                                                Text { text: courseData ? "Status: " + (courseData.status || "draft") : ""; font.pixelSize: 13; color: "#6B7280" }
                                            }
                                        }
                                    }
                                    Item { height: 20 }
                                }

                                // RIGHT: live preview card
                                ColumnLayout {
                                    Layout.preferredWidth: 300; Layout.minimumWidth: 260; spacing: 20

                                    Rectangle { Layout.fillWidth: true; radius: 10; color: "white"; border.color: "#E5E7EB"; border.width: 1; implicitHeight: c3c.implicitHeight + 40
                                        ColumnLayout { id: c3c; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 20; spacing: 14
                                            Text { text: "Course Preview"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                                            Rectangle { Layout.fillWidth: true; height: 1; color: "#F3F4F6" }
                                            Rectangle { Layout.fillWidth: true; height: 200; radius: 8; color: "#F9FAFB"; clip: true
                                                Image { anchors.fill: parent; source: courseData ? (courseData.thumbnail || "") : ""; fillMode: Image.PreserveAspectCrop; visible: courseData && (courseData.thumbnail || "").length > 0 }
                                                Text { anchors.centerIn: parent; text: "🖼️"; font.pixelSize: 48; color: "#D1D5DB"; visible: !courseData || !(courseData.thumbnail || "").length > 0 } }
                                            Text { text: courseData ? (courseData.title || "Untitled") : ""; font.pixelSize: 16; font.weight: Font.DemiBold; color: "#18181B"; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                            RowLayout { spacing: 16
                                                Text { text: (courseData ? (courseData.lessonsCount || 0) : 0) + " lessons"; font.pixelSize: 12; color: "#6B7280" }
                                                Text { text: courseData ? (courseData.totalDuration || "0 min") : "0 min"; font.pixelSize: 12; color: "#6B7280" } }
                                            Text { text: courseData ? (courseData.shortDescription || courseData.description || "") : ""; font.pixelSize: 13; color: "#374151"; wrapMode: Text.WordWrap; Layout.fillWidth: true; maximumLineCount: 4; elide: Text.ElideRight }
                                            RowLayout { spacing: 8
                                                Rectangle { height: 24; radius: 12; width: catChipTxt.implicitWidth + 16; color: "#EEF2FF"
                                                    Text { id: catChipTxt; anchors.centerIn: parent; text: courseData ? (courseData.category || "") : ""; font.pixelSize: 12; color: "#4F46E5" } }
                                                Rectangle { height: 24; radius: 12; width: lvlChipTxt.implicitWidth + 16; color: "#F3F4F6"
                                                    Text { id: lvlChipTxt; anchors.centerIn: parent; text: courseData ? (courseData.level || "") : ""; font.pixelSize: 12; color: "#374151" } }
                                            }
                                            Text { text: courseData ? (courseData.isFree ? "Free" : ("$" + (courseData.price || "0"))) : ""; font.pixelSize: 20; font.weight: Font.Bold; color: "#18181B" }
                                        }
                                    }
                                    Item { height: 20 }
                                }
                            }
                        }
                    }
                }

                // BOTTOM NAV BAR
                Rectangle { Layout.fillWidth: true; height: 64; color: "white"
                    Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: "#E5E7EB" }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 12
                        Rectangle { height: 38; radius: 8; width: prvTxt.implicitWidth + 24; color: prvH.containsMouse ? "#F3F4F6" : "white"; border.color: "#E5E7EB"; border.width: 1; visible: activeTab > 0
                            Text { id: prvTxt; anchors.centerIn: parent; text: "← Previous"; font.pixelSize: 13; color: "#374151" }
                            MouseArea { id: prvH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: activeTab = Math.max(0, activeTab - 1) } }
                        Item { Layout.fillWidth: true }
                        Rectangle { height: 38; radius: 8; width: nxtTxt.implicitWidth + 24; color: nxtH.containsMouse ? "#F3F4F6" : "white"; border.color: "#E5E7EB"; border.width: 1; visible: activeTab < 3
                            Text { id: nxtTxt; anchors.centerIn: parent; text: "Next →"; font.pixelSize: 13; color: "#374151" }
                            MouseArea { id: nxtH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: activeTab = Math.min(3, activeTab + 1) } }
                        Rectangle { height: 38; radius: 8; width: botSvTxt.implicitWidth + 28; color: isSaving ? "#9CA3AF" : (botSvH.containsMouse ? "#4338CA" : "#4F46E5")
                            Text { id: botSvTxt; anchors.centerIn: parent; text: isSaving ? "Saving…" : "Save Changes"; color: "white"; font.pixelSize: 14; font.weight: Font.Medium }
                            MouseArea { id: botSvH; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; enabled: !isSaving; onClicked: doSave() } }
                    }
                }
            }
        }
    }
}
