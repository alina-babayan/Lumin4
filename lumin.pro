QT += quick quickcontrols2 network

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000

SOURCES += \
    main.cpp \
    apimanager.cpp \
    authcontroller.cpp

HEADERS += \
    apimanager.h \
    authcontroller.h

RESOURCES += qml.qrc


# Application name
TARGET = Lumin

# # Windows specific
# win32 {
#     RC_ICONS = icons/app_icon.ico
# }

# # macOS specific
# macx {
#     ICON = icons/app_icon.icns
#     QMAKE_INFO_PLIST = Info.plist
# }
