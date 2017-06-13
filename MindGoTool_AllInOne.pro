QT += qml quick

CONFIG += c++11

SOURCES += \
    InfrastructureLayer/Communication/communication.cpp \
    BussinessLayer/WorkflowProtocol/workflowprotocol.cpp \
    UserInterfaceLayer/configfilehandler.cpp \
    UserInterfaceLayer/environmentvariant.cpp \
    UserInterfaceLayer/main.cpp \
    UserInterfaceLayer/workmodels.cpp

RESOURCES += \
    UserInterfaceLayer/qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS MINDGO_ALL_IN_ONE

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    InfrastructureLayer/Communication/communication.h \
    BussinessLayer/WorkflowProtocol/workflowprotocol.h \
    UserInterfaceLayer/configfilehandler.h \
    UserInterfaceLayer/environmentvariant.h \
    UserInterfaceLayer/workmodels.h

DISTFILES += \
    UserInterfaceLayer/config/OperationParams.json \
    UserInterfaceLayer/config/Protocol.json \
    UserInterfaceLayer/config/UserConfig.json \
    UserInterfaceLayer/config/cn.qm

win32: {LIBS += -lDbgHelp
QMAKE_LFLAGS_RELEASE += /MAP
QMAKE_CFLAGS_RELEASE += /Zi
QMAKE_LFLAGS_RELEASE += /debug /opt:ref
}

win32:CONFIG(release, debug|release): QMAKE_LFLAGS += /MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\"
