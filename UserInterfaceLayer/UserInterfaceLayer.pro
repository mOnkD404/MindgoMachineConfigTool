TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp \
    workmodels.cpp \
    configfilehandler.cpp \
    environmentvariant.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

INCLUDEPATH += $$PWD/../InfrastructureLayer/Communication
DEPENDPATH += $$PWD/../InfrastructureLayer/Communication

INCLUDEPATH += $$PWD/../BussinessLayer/WorkflowProtocol
DEPENDPATH += $$PWD/../BussinessLayer/WorkflowProtocol


DISTFILES += \
    OperationParams.json \
    Protocol.json \
    config/OperationParams.json \
    config/Protocol.json \
    config/UserConfig.json

HEADERS += \
    workmodels.h \
    configfilehandler.h \
    environmentvariant.h

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../InfrastructureLayer/Communication/release/ -lCommunication
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../InfrastructureLayer/Communication/debug/ -lCommunication
else:unix: LIBS += -L$$OUT_PWD/../InfrastructureLayer/Communication/ -lCommunication

#INCLUDEPATH += $$PWD/../../build-MindgoMachineConfigTool-Desktop_Qt_5_8_0_MSVC2015_64bit-Debug/InfrastructureLayer/Communication/debug
#DEPENDPATH += $$PWD/../../build-MindgoMachineConfigTool-Desktop_Qt_5_8_0_MSVC2015_64bit-Debug/InfrastructureLayer/Communication/debug

win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../BussinessLayer/WorkflowProtocol/release/ -lWorkflowProtocol
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../BussinessLayer/WorkflowProtocol/debug/ -lWorkflowProtocol
else:unix: LIBS += -L$$OUT_PWD/../BussinessLayer/WorkflowProtocol/ -lWorkflowProtocol

#INCLUDEPATH += $$PWD/../../build-MindgoMachineConfigTool-Desktop_Qt_5_8_0_MSVC2015_64bit-Debug/BussinessLayer/WorkflowProtocol
#DEPENDPATH += $$PWD/../../build-MindgoMachineConfigTool-Desktop_Qt_5_8_0_MSVC2015_64bit-Debug/BussinessLayer/WorkflowProtocol

win32: LIBS += -lDbgHelp


QMAKE_LFLAGS_RELEASE += /MAP
QMAKE_CFLAGS_RELEASE += /Zi
QMAKE_LFLAGS_RELEASE += /debug /opt:ref

win32:CONFIG(release, debug|release): QMAKE_LFLAGS += /MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\"
