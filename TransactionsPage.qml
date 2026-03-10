import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property var    transactions:   []
    property bool   isLoading:      false
    property string searchQuery:    ""
    property string statusFilter:   ""
    property int    currentPage:    1
    property int    totalPages:     1
    property double totalRevenue:   0.0
    property double monthlyRevenue: 0.0
    property int    totalCount:     0

    Component.onCompleted: {
        if (typeof userController !== "undefined") userController.reloadTokens()
        loadTransactions()
    }

    Connections {
        target: authController
        function onAccessTokenChanged() {
            if (!authController.accessToken || authController.accessToken === "") return
            loadTransactions()
        }
    }

    function loadTransactions() {
        isLoading = true
        var ep = "https://learning-dashboard-rouge.vercel.app/api/transactions"
        var p = ["page=" + currentPage, "limit=20"]
        if (statusFilter.length > 0)  p.push("status=" + encodeURIComponent(statusFilter))
        if (searchQuery.trim().length > 0) p.push("search=" + encodeURIComponent(searchQuery.trim()))
        ep += "?" + p.join("&")

        var xhr = new XMLHttpRequest()
        xhr.open("GET", ep)
        xhr.setRequestHeader("Authorization", "Bearer " + (authController ? authController.accessToken : ""))
        xhr.setRequestHeader("Accept", "application/json")
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            isLoading = false
            if (xhr.status === 200) {
                try {
                    var r = JSON.parse(xhr.responseText)
                    if (r.success) {
                        transactions   = r.data.transactions || []
                        totalRevenue   = r.data.stats ? (r.data.stats.totalRevenue   || 0) : 0
                        monthlyRevenue = r.data.stats ? (r.data.stats.monthlyRevenue || 0) : 0
                        totalCount     = r.data.pagination ? (r.data.pagination.total || 0) : transactions.length
                        totalPages     = r.data.pagination ? (r.data.pagination.pages || 1) : 1
                    }
                } catch(e) { console.log("Transactions parse error:", e) }
            }
        }
        xhr.send()
    }

    function fmtMoney(val) {
        var n = parseFloat(val) || 0
        return "$" + n.toFixed(2)
    }

    function fmtDate(iso) {
        if (!iso) return "—"
        var d = new Date(iso)
        return Qt.formatDateTime(d, "MMM d, yyyy")
    }

    function getStatusBg(s) {
        if (s === "completed") return "#D1FAE5"
        if (s === "pending")   return "#FEF9C3"
        if (s === "failed")    return "#FEE2E2"
        if (s === "refunded")  return "#EEF2FF"
        return "#F3F4F6"
    }
    function getStatusFg(s) {
        if (s === "completed") return "#065F46"
        if (s === "pending")   return "#92400E"
        if (s === "failed")    return "#DC2626"
        if (s === "refunded")  return "#4F46E5"
        return "#6B7280"
    }
    function getStatusLabel(s) {
        if (!s) return "—"
        return s.charAt(0).toUpperCase() + s.slice(1)
    }

    Rectangle {
        anchors.fill: parent
        color: "#FFFFFF"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 20

            // Header
            Column {
                spacing: 4
                Text { text: "Transactions"; font.pixelSize: 22; font.weight: Font.Bold; color: "#18181B" }
                Text { text: "View and manage your transaction history"; font.pixelSize: 13; color: "#6B7280" }
            }

            // Stat cards
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                Repeater {
                    model: [
                        { icon: "💵", label: "Total Revenue",     val: fmtMoney(totalRevenue),   sub: "Earn last time" },
                        { icon: "📅", label: "This Month",        val: fmtMoney(monthlyRevenue), sub: "Current month earnings" },
                        { icon: "🔢", label: "Total Transactions", val: totalCount.toString(),   sub: "All transactions" }
                    ]
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 96
                        radius: 10; color: "white"
                        border.color: "#E5E7EB"; border.width: 1

                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 16; spacing: 4
                            RowLayout {
                                spacing: 6
                                Text { text: modelData.icon; font.pixelSize: 15 }
                                Text { text: modelData.label; font.pixelSize: 12; color: "#6B7280" }
                            }
                            Text { text: modelData.val; font.pixelSize: 24; font.weight: Font.Bold; color: "#18181B" }
                            Text { text: modelData.sub; font.pixelSize: 11; color: "#9CA3AF" }
                        }
                    }
                }
            }

            // Transaction History card
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                radius: 10; color: "white"
                border.color: "#E5E7EB"; border.width: 1; clip: true

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 20; spacing: 14

                    // Card header
                    RowLayout {
                        Layout.fillWidth: true
                        Column {
                            spacing: 2
                            Text { text: "Transaction History"; font.pixelSize: 15; font.weight: Font.DemiBold; color: "#18181B" }
                            Text { text: "View all your transactions details and earnings"; font.pixelSize: 12; color: "#9CA3AF" }
                        }
                        Item { Layout.fillWidth: true }

                        // Export button
                        Rectangle {
                            height: 34; width: expTxt.implicitWidth + 28; radius: 8
                            color: expHov.containsMouse ? "#F3F4F6" : "white"
                            border.color: "#E5E7EB"; border.width: 1
                            RowLayout {
                                anchors.centerIn: parent; spacing: 6
                                Text { text: "↑"; font.pixelSize: 13; color: "#374151" }
                                Text { id: expTxt; text: "Export"; font.pixelSize: 13; color: "#374151" }
                            }
                            MouseArea { id: expHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
                        }
                    }

                    // Search + status filter bar
                    RowLayout {
                        Layout.fillWidth: true; spacing: 10

                        // Search
                        Rectangle {
                            Layout.fillWidth: true; height: 38; radius: 8
                            color: "#F9FAFB"; border.color: "#E5E7EB"; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 6
                                Text { text: "🔍"; font.pixelSize: 12; color: "#9CA3AF" }
                                TextField {
                                    id: txSearchField
                                    Layout.fillWidth: true
                                    placeholderText: "Search by order number, content, or course..."
                                    font.pixelSize: 12; color: "#18181B"; background: null
                                    onTextChanged: txSearchTimer.restart()
                                    Timer { id: txSearchTimer; interval: 500
                                        onTriggered: { root.searchQuery = txSearchField.text.trim(); root.currentPage = 1; root.loadTransactions() } }
                                }
                            }
                        }

                        // Status filter
                        Rectangle {
                            height: 38; width: stFilterRow.implicitWidth + 20; radius: 8
                            color: "white"; border.color: "#E5E7EB"; border.width: 1

                            RowLayout {
                                id: stFilterRow
                                anchors.centerIn: parent; spacing: 4

                                Repeater {
                                    model: [
                                        { label: "All Status", val: "" },
                                        { label: "Completed",  val: "completed" },
                                        { label: "Pending",    val: "pending" },
                                        { label: "Failed",     val: "failed" }
                                    ]
                                    delegate: Rectangle {
                                        height: 26; width: sfLbl.implicitWidth + 16; radius: 5
                                        color: root.statusFilter === modelData.val ? "#18181B" : (sfMA.containsMouse ? "#F3F4F6" : "transparent")
                                        Text { id: sfLbl; anchors.centerIn: parent; text: modelData.label; font.pixelSize: 11
                                            color: root.statusFilter === modelData.val ? "white" : "#6B7280" }
                                        MouseArea { id: sfMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: { root.statusFilter = modelData.val; root.currentPage = 1; root.loadTransactions() } }
                                    }
                                }
                            }
                        }
                    }

                    // Loading
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: isLoading
                        ColumnLayout { anchors.centerIn: parent; spacing: 12
                            BusyIndicator { Layout.alignment: Qt.AlignHCenter; running: true; width: 36; height: 36 }
                            Text { text: "Loading transactions…"; font.pixelSize: 13; color: "#9CA3AF"; Layout.alignment: Qt.AlignHCenter }
                        }
                    }

                    // Empty state
                    Item {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        visible: !isLoading && transactions.length === 0

                        ColumnLayout {
                            anchors.centerIn: parent; spacing: 12
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 64; height: 64; radius: 32; color: "#F9FAFB"
                                border.color: "#E5E7EB"; border.width: 1
                                Text { anchors.centerIn: parent; text: "$"; font.pixelSize: 28; color: "#D1D5DB" }
                            }
                            Text { text: "No Transactions Yet"; font.pixelSize: 16; font.weight: Font.Medium; color: "#18181B"; Layout.alignment: Qt.AlignHCenter }
                            Text { text: "Transactions will appear here once students purchase courses"; font.pixelSize: 13; color: "#9CA3AF"; Layout.alignment: Qt.AlignHCenter }
                        }
                    }

                    // Table header + rows
                    ColumnLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        spacing: 0
                        visible: !isLoading && transactions.length > 0

                        // Header
                        Rectangle {
                            Layout.fillWidth: true; height: 40; color: "#F9FAFB"
                            border.color: "#E5E7EB"; border.width: 1; radius: 6
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 0
                                Text { text: "Transaction";  Layout.preferredWidth: 200; font.pixelSize: 11; font.weight: Font.Medium; color: "#6B7280" }
                                Text { text: "Student";      Layout.preferredWidth: 160; font.pixelSize: 11; font.weight: Font.Medium; color: "#6B7280" }
                                Text { text: "Amount";       Layout.preferredWidth: 100; font.pixelSize: 11; font.weight: Font.Medium; color: "#6B7280" }
                                Text { text: "Status";       Layout.preferredWidth: 100; font.pixelSize: 11; font.weight: Font.Medium; color: "#6B7280" }
                                Text { text: "Date";         Layout.fillWidth: true;     font.pixelSize: 11; font.weight: Font.Medium; color: "#6B7280" }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            model: transactions; clip: true
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                            delegate: Rectangle {
                                width: ListView.view.width; height: 60
                                color: txRowHov.containsMouse ? "#FAFAFA" : "white"
                                Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F3F4F6" }

                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 0

                                    // Transaction ID + course
                                    Column {
                                        Layout.preferredWidth: 200; spacing: 2; Layout.alignment: Qt.AlignVCenter
                                        Text { text: "#" + (modelData.orderNumber || modelData.id || "—"); font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B"; elide: Text.ElideRight; width: parent.width }
                                        Text { text: modelData.courseName || modelData.course || "—"; font.pixelSize: 11; color: "#9CA3AF"; elide: Text.ElideRight; width: parent.width }
                                    }

                                    // Student
                                    Column {
                                        Layout.preferredWidth: 160; spacing: 2; Layout.alignment: Qt.AlignVCenter
                                        Text { text: modelData.studentName || modelData.student || "—"; font.pixelSize: 13; color: "#374151"; elide: Text.ElideRight; width: parent.width }
                                        Text { text: modelData.studentEmail || ""; font.pixelSize: 11; color: "#9CA3AF"; elide: Text.ElideRight; width: parent.width }
                                    }

                                    // Amount
                                    Text {
                                        Layout.preferredWidth: 100; Layout.alignment: Qt.AlignVCenter
                                        text: fmtMoney(modelData.amount || 0)
                                        font.pixelSize: 13; font.weight: Font.Medium; color: "#18181B"
                                    }

                                    // Status badge
                                    Item {
                                        Layout.preferredWidth: 100; Layout.alignment: Qt.AlignVCenter
                                        Rectangle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: txStLbl.implicitWidth + 16; height: 22; radius: 11
                                            color: getStatusBg(modelData.status)
                                            Text { id: txStLbl; anchors.centerIn: parent; text: getStatusLabel(modelData.status); font.pixelSize: 11; font.weight: Font.Medium; color: getStatusFg(modelData.status) }
                                        }
                                    }

                                    // Date
                                    Text {
                                        Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                                        text: fmtDate(modelData.createdAt)
                                        font.pixelSize: 12; color: "#6B7280"
                                    }
                                }

                                MouseArea { id: txRowHov; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
                            }
                        }
                    }

                    // Pagination
                    RowLayout {
                        Layout.fillWidth: true
                        visible: !isLoading && transactions.length > 0 && totalPages > 1
                        Item { Layout.fillWidth: true }
                        Text { text: "Page " + currentPage + " of " + totalPages; font.pixelSize: 12; color: "#9CA3AF" }
                        Rectangle {
                            width: 28; height: 28; radius: 6
                            color: currentPage > 1 && pgPH.containsMouse ? "#F3F4F6" : "white"
                            border.color: "#E5E7EB"; border.width: 1
                            Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 13; color: currentPage > 1 ? "#374151" : "#D1D5DB" }
                            MouseArea { id: pgPH; anchors.fill: parent; hoverEnabled: true; enabled: currentPage > 1; cursorShape: Qt.PointingHandCursor
                                onClicked: { currentPage--; loadTransactions() } }
                        }
                        Rectangle {
                            width: 28; height: 28; radius: 6
                            color: currentPage < totalPages && pgNH.containsMouse ? "#F3F4F6" : "white"
                            border.color: "#E5E7EB"; border.width: 1
                            Text { anchors.centerIn: parent; text: "→"; font.pixelSize: 13; color: currentPage < totalPages ? "#374151" : "#D1D5DB" }
                            MouseArea { id: pgNH; anchors.fill: parent; hoverEnabled: true; enabled: currentPage < totalPages; cursorShape: Qt.PointingHandCursor
                                onClicked: { currentPage++; loadTransactions() } }
                        }
                    }
                }
            }
        }
    }
}
