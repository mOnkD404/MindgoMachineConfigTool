#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QStringList>

#include <qqmlengine.h>
#include <qqmlcontext.h>
#include <qqml.h>
#include <QtQuick/qquickitem.h>
#include <QtQuick/qquickview.h>
#include "workmodels.h"
#include "environmentvariant.h"
#include <QTranslator>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QTranslator translator;
    translator.load("/Users/sunwp/Desktop/MindgoMachineConfigTool/MindgoMachineConfigTool/cn.qm");
    app.installTranslator(&translator);

    qmlRegisterType<OperationParamObject>("Common", 1,0, "OperationParamObject");
    qmlRegisterType<OperationParamSelector>("Common", 1,0,"OperationParamSelector");

    QQuickView view;

    EnvironmentVariant::instance()->parseConfigFile("/Users/sunwp/Desktop/MindgoMachineConfigTool/MindgoMachineConfigTool/UserInterfaceLayer/OperationParams.json");
    EnvironmentVariant::instance()->initUserConfig("/Users/sunwp/Desktop/MindgoMachineConfigTool/MindgoMachineConfigTool/UserInterfaceLayer/UserConfig.json");
    EnvironmentVariant::instance()->initProtocol("/Users/sunwp/Desktop/MindgoMachineConfigTool/MindgoMachineConfigTool/UserInterfaceLayer/Protocol.json");
    EnvironmentVariant::instance()->initModels(view.rootContext());


    view.setSource(QUrl("qrc:/main.qml"));
    view.show();

    return app.exec();
}
