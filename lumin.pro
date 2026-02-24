QT += quick quickcontrols2 network

CONFIG += c++17

SOURCES += \
    coursecontroller.cpp \
    dashboardcontroller.cpp \
    instructorcontroller.cpp \
    main.cpp \
    apimanager.cpp \
    authcontroller.cpp \
    notificationcontroller.cpp \
    transactioncontroller.cpp \
    usercontroller.cpp

HEADERS += \
    apimanager.h \
    authcontroller.h \
    coursecontroller.h \
    dashboardcontroller.h \
    instructorcontroller.h \
    notificationcontroller.h \
    transactioncontroller.h \
    usercontroller.h

RESOURCES += qml.qrc \
    մ.qrc

TARGET = Lumin

