QT += quick quickcontrols2 network

CONFIG += c++17

SOURCES += \
    main.cpp \
    apimanager.cpp \
    authcontroller.cpp

HEADERS += \
    apimanager.h \
    authcontroller.h

RESOURCES += qml.qrc

TARGET = Lumin
