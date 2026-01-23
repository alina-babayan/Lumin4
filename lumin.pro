QT += quick quickcontrols2 network

CONFIG += c++17

SOURCES += \
    dashboardcontroller.cpp \
    instructorcontroller.cpp \
    main.cpp \
    apimanager.cpp \
    authcontroller.cpp

HEADERS += \
    apimanager.h \
    authcontroller.h \
    dashboardcontroller.h \
    instructorcontroller.h

RESOURCES += qml.qrc

TARGET = Lumin

