#-------------------------------------------------
#
# Project created by QtCreator 2017-05-09T00:57:15
#
#-------------------------------------------------

QT       -= gui
QT       += network

TARGET = WorkflowProtocol
TEMPLATE = lib

DEFINES += WORKFLOWPROTOCOL_LIBRARY

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked as deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += workflowprotocol.cpp

HEADERS += workflowprotocol.h\
        workflowprotocol_global.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}


INCLUDEPATH += $$PWD/../../InfrastructureLayer/Communication
DEPENDPATH += $$PWD/../../InfrastructureLayer/Communication

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../../InfrastructureLayer/Communication/release/ -lCommunication
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../../InfrastructureLayer/Communication/debug/ -lCommunication
else:unix: LIBS += -L$$OUT_PWD/../../InfrastructureLayer/Communication/ -lCommunication

INCLUDEPATH += $$PWD/../../../build-MindgoMachineConfigTool-Desktop_Qt_5_8_0_MSVC2015_64bit-Debug/InfrastructureLayer/Communication/debug
DEPENDPATH += $$PWD/../../../build-MindgoMachineConfigTool-Desktop_Qt_5_8_0_MSVC2015_64bit-Debug/InfrastructureLayer/Communication/debug


QMAKE_LFLAGS_RELEASE += /MAP
QMAKE_CFLAGS_RELEASE += /Zi
QMAKE_LFLAGS_RELEASE += /debug /opt:ref
