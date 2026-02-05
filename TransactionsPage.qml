import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    Component.onCompleted: {
        transactionController.loadTransactions()
    }

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 24

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Transactions"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                    color: "#18181B"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 36
                    width: refreshText.implicitWidth + 24
                    radius: 6
                    color: refreshMA.containsMouse ? "#F3F4F6" : "white"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Text {
                        id: refreshText
                        anchors.centerIn: parent
                        text: "↻ Refresh"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }

                    MouseArea {
                        id: refreshMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: transactionController.refresh()
                    }
                }
            }

            // Summary Cards
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Repeater {
                    model: [
                        { title: "Total Revenue", icon: "💰", bg: "#DCFCE7", val: transactionController.formattedTotalRevenue },
                        { title: "This Month", icon: "📊", bg: "#EEF2FF", val: transactionController.formattedThisMonthRevenue },
                        { title: "Total Transactions", icon: "📝", bg: "#FCE7F3", val: transactionController.totalTransactions.toString() }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        height: 120
                        radius: 10
                        color: "white"
                        border.color: "#E5E7EB"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 8

                            RowLayout {
                                Layout.fillWidth: true

                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 8
                                    color: modelData.bg

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.icon
                                        font.pixelSize: 18
                                    }
                                }

                                Item { Layout.fillWidth: true }
                            }

                            Text {
                                text: modelData.title
                                font.pixelSize: 12
                                color: "#6B7280"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.val
                                font.pixelSize: 28
                                font.weight: Font.Bold
                                color: "#18181B"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                wrapMode: Text.NoWrap
                            }
                        }
                    }
                }
            }

            // Filter Section
            Rectangle {
                Layout.fillWidth: true
                height: filterRow.implicitHeight + 24
                radius: 10
                color: "white"
                border.color: "#E5E7EB"
                border.width: 1

                RowLayout {
                    id: filterRow
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    // Search Bar
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 6
                        color: "white"
                        border.color: "#E5E7EB"
                        border.width: 1

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            verticalAlignment: TextInput.AlignVCenter
                            font.pixelSize: 13
                            color: "#18181B"

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "🔍 Search by order number, student, or course..."
                                font.pixelSize: 13
                                color: "#9CA3AF"
                                visible: searchInput.text.length === 0
                            }

                            onTextChanged: searchTimer.restart()

                            Timer {
                                id: searchTimer
                                interval: 500
                                onTriggered: transactionController.setSearchQuery(searchInput.text)
                            }
                        }
                    }

                    // Status Filter
                    Rectangle {
                        Layout.preferredWidth: 140
                        height: 40
                        radius: 6
                        color: "white"
                        border.color: "#E5E7EB"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                text: statusCombo.currentText
                                font.pixelSize: 13
                                color: "#18181B"
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "▼"
                                font.pixelSize: 10
                                color: "#6B7280"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: statusMenu.open()
                        }

                        Menu {
                            id: statusMenu
                            y: parent.height

                            MenuItem {
                                text: "All"
                                onTriggered: {
                                    statusCombo.currentText = "All"
                                    transactionController.setStatusFilter("all")
                                }
                            }
                            MenuItem {
                                text: "Completed"
                                onTriggered: {
                                    statusCombo.currentText = "Completed"
                                    transactionController.setStatusFilter("completed")
                                }
                            }
                            MenuItem {
                                text: "Failed"
                                onTriggered: {
                                    statusCombo.currentText = "Failed"
                                    transactionController.setStatusFilter("failed")
                                }
                            }
                            MenuItem {
                                text: "Refunded"
                                onTriggered: {
                                    statusCombo.currentText = "Refunded"
                                    transactionController.setStatusFilter("refunded")
                                }
                            }
                        }

                        QtObject {
                            id: statusCombo
                            property string currentText: "All"
                        }
                    }

                    Rectangle {
                        height: 40
                        width: clearText.implicitWidth + 24
                        radius: 6
                        color: clearMA.containsMouse ? "#F3F4F6" : "white"
                        border.color: "#E5E7EB"
                        border.width: 1
                        visible: searchInput.text.length > 0

                        Text {
                            id: clearText
                            anchors.centerIn: parent
                            text: "Clear"
                            font.pixelSize: 13
                            color: "#6B7280"
                        }

                        MouseArea {
                            id: clearMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchInput.text = ""
                                transactionController.setSearchQuery("")
                            }
                        }
                    }
                }
            }

            // Transactions Table
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "white"
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Table Header
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: "#F9FAFB"

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
                            spacing: 12

                            Text {
                                Layout.preferredWidth: 140
                                text: "Order"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.preferredWidth: 180
                                text: "Student"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Course(s)"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.preferredWidth: 100
                                text: "Amount"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.preferredWidth: 100
                                text: "Status"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }

                            Text {
                                Layout.preferredWidth: 140
                                text: "Date"
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                color: "#6B7280"
                            }
                        }
                    }

                    // Table Content
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Loading State
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 16
                            visible: transactionController.isLoading

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "⏳"
                                font.pixelSize: 48
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Loading transactions..."
                                font.pixelSize: 13
                                color: "#9CA3AF"
                            }
                        }

                        // Empty State
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 12
                            visible: !transactionController.isLoading && transactionController.transactions.length === 0

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "💳"
                                font.pixelSize: 48
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No transactions found"
                                font.pixelSize: 15
                                font.weight: Font.Medium
                                color: "#18181B"
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "Try adjusting your filters or search query"
                                font.pixelSize: 13
                                color: "#9CA3AF"
                            }
                        }

                        // Transactions List
                        ScrollView {
                            anchors.fill: parent
                            visible: !transactionController.isLoading && transactionController.transactions.length > 0
                            clip: true

                            ColumnLayout {
                                width: parent.parent.width
                                spacing: 0

                                Repeater {
                                    model: transactionController.transactions

                                    Rectangle {
                                        Layout.fillWidth: true
                                        height: 80
                                        color: rowMA.containsMouse ? "#F9FAFB" : "transparent"

                                        Rectangle {
                                            anchors.bottom: parent.bottom
                                            width: parent.width
                                            height: 1
                                            color: "#F3F4F6"
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.leftMargin: 24
                                            anchors.rightMargin: 24
                                            spacing: 12

                                            // Order Info
                                            ColumnLayout {
                                                Layout.preferredWidth: 140
                                                spacing: 2

                                                Text {
                                                    text: modelData.orderNumber || "N/A"
                                                    font.pixelSize: 13
                                                    font.weight: Font.Medium
                                                    color: "#18181B"
                                                }

                                                Text {
                                                    text: modelData.paymentMethodDisplay || ""
                                                    font.pixelSize: 11
                                                    color: "#6B7280"
                                                }
                                            }

                                            // Student Info
                                            RowLayout {
                                                Layout.preferredWidth: 180
                                                spacing: 10

                                                Rectangle {
                                                    width: 36
                                                    height: 36
                                                    radius: 18
                                                    color: "#EEF2FF"

                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: modelData.studentName ? modelData.studentName.charAt(0).toUpperCase() : "S"
                                                        font.pixelSize: 14
                                                        font.weight: Font.Medium
                                                        color: "#6366F1"
                                                    }
                                                }

                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 2

                                                    Text {
                                                        text: modelData.studentName || "Unknown"
                                                        font.pixelSize: 12
                                                        font.weight: Font.Medium
                                                        color: "#18181B"
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }

                                                    Text {
                                                        text: modelData.studentEmail || ""
                                                        font.pixelSize: 11
                                                        color: "#6B7280"
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                    }
                                                }
                                            }

                                            // Courses
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 3

                                                Repeater {
                                                    model: modelData.courses || []

                                                    RowLayout {
                                                        spacing: 6

                                                        Text {
                                                            text: "•"
                                                            color: "#6366F1"
                                                            font.pixelSize: 12
                                                        }

                                                        Text {
                                                            text: modelData.title || ""
                                                            font.pixelSize: 12
                                                            color: "#18181B"
                                                            Layout.fillWidth: true
                                                            elide: Text.ElideRight
                                                        }

                                                        Text {
                                                            text: modelData.formattedPrice || ""
                                                            font.pixelSize: 11
                                                            color: "#6B7280"
                                                        }
                                                    }
                                                }
                                            }

                                            // Amount
                                            Text {
                                                Layout.preferredWidth: 100
                                                text: modelData.formattedAmount || "$0.00"
                                                font.pixelSize: 15
                                                font.weight: Font.Bold
                                                color: "#16A34A"
                                                horizontalAlignment: Text.AlignRight
                                            }

                                            // Status Badge
                                            Rectangle {
                                                Layout.preferredWidth: 100
                                                height: 24
                                                radius: 12
                                                color: {
                                                    if (modelData.status === "completed") return "#DCFCE7"
                                                    if (modelData.status === "failed") return "#FEE2E2"
                                                    if (modelData.status === "refunded") return "#F3F4F6"
                                                    return "#F3F4F6"
                                                }

                                                Text {
                                                    anchors.centerIn: parent
                                                    text: modelData.statusText || "Unknown"
                                                    font.pixelSize: 11
                                                    font.weight: Font.Medium
                                                    color: {
                                                        if (modelData.status === "completed") return "#16A34A"
                                                        if (modelData.status === "failed") return "#DC2626"
                                                        if (modelData.status === "refunded") return "#6B7280"
                                                        return "#6B7280"
                                                    }
                                                }
                                            }

                                            // Date
                                            ColumnLayout {
                                                Layout.preferredWidth: 140
                                                spacing: 2

                                                Text {
                                                    text: modelData.formattedDate || "Unknown"
                                                    font.pixelSize: 12
                                                    color: "#18181B"
                                                }

                                                Text {
                                                    text: modelData.relativeTime || ""
                                                    font.pixelSize: 11
                                                    color: "#6B7280"
                                                }
                                            }
                                        }

                                        MouseArea {
                                            id: rowMA
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Pagination
                    Rectangle {
                        Layout.fillWidth: true
                        height: 56
                        color: "#F9FAFB"
                        visible: transactionController.totalPages > 1

                        Rectangle {
                            anchors.top: parent.top
                            width: parent.width
                            height: 1
                            color: "#E5E7EB"
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            spacing: 12

                            Text {
                                text: "Page " + transactionController.currentPage +
                                      " of " + transactionController.totalPages
                                font.pixelSize: 13
                                color: "#6B7280"
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                height: 36
                                width: prevText.implicitWidth + 24
                                radius: 6
                                color: {
                                    if (transactionController.currentPage <= 1) return "#F3F4F6"
                                    if (prevMA.containsMouse) return "#EEF2FF"
                                    return "white"
                                }
                                border.color: "#E5E7EB"
                                border.width: 1

                                Text {
                                    id: prevText
                                    anchors.centerIn: parent
                                    text: "← Previous"
                                    font.pixelSize: 13
                                    color: transactionController.currentPage > 1 ? "#6366F1" : "#9CA3AF"
                                }

                                MouseArea {
                                    id: prevMA
                                    anchors.fill: parent
                                    enabled: transactionController.currentPage > 1
                                    hoverEnabled: true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: transactionController.previousPage()
                                }
                            }

                            Rectangle {
                                height: 36
                                width: nextText.implicitWidth + 24
                                radius: 6
                                color: {
                                    if (transactionController.currentPage >= transactionController.totalPages) return "#F3F4F6"
                                    if (nextMA.containsMouse) return "#EEF2FF"
                                    return "white"
                                }
                                border.color: "#E5E7EB"
                                border.width: 1

                                Text {
                                    id: nextText
                                    anchors.centerIn: parent
                                    text: "Next →"
                                    font.pixelSize: 13
                                    color: transactionController.currentPage < transactionController.totalPages ? "#6366F1" : "#9CA3AF"
                                }

                                MouseArea {
                                    id: nextMA
                                    anchors.fill: parent
                                    enabled: transactionController.currentPage < transactionController.totalPages
                                    hoverEnabled: true
                                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: transactionController.nextPage()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
