// Theme.qml
pragma Singleton
import QtQuick 2.15

QtObject {
    // Colors
    readonly property color primary: "#18181B"      // Black color for all text/menus
    readonly property color secondary: "#6B7280"   // Gray for secondary text
    readonly property color hint: "#9CA3AF"        // Hint/disabled text
    readonly property color background: "#FAFAFA"  // Page background
    readonly property color surface: "white"       // Card/surface background
    readonly property color divider: "#E5E7EB"     // Dividers/borders

    // Accent colors (for specific purposes only)
    readonly property color accent: "#6366F1"      // Primary accent (Indigo)
    readonly property color success: "#10B981"     // Success green
    readonly property color warning: "#F59E0B"     // Warning orange
    readonly property color error: "#EF4444"       // Error red

    // Status colors
    readonly property color pending: "#F59E0B"
    readonly property color verified: "#10B981"
    readonly property color rejected: "#EF4444"
    readonly property color draft: "#6B7280"
    readonly property color published: "#10B981"

    // Sizes
    readonly property int spacingSmall: 8
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int spacingXLarge: 32

    // Font sizes
    readonly property int fontSizeXs: 10
    readonly property int fontSizeSm: 12
    readonly property int fontSizeMd: 14
    readonly property int fontSizeLg: 16
    readonly property int fontSizeXl: 18
    readonly property int fontSize2xl: 24
    readonly property int fontSize3xl: 28

    // Border radius
    readonly property int radiusSm: 4
    readonly property int radiusMd: 8
    readonly property int radiusLg: 12
    readonly property int radiusXl: 16

    // Heights
    readonly property int heightXs: 24
    readonly property int heightSm: 32
    readonly property int heightMd: 40
    readonly property int heightLg: 48
    readonly property int heightXl: 56
}
