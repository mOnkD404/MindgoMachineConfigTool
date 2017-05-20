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
#include <QDir>

void customMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QString txtMessage;

    switch (type)
    {
    case QtDebugMsg:    //调试信息提示
        txtMessage = QString("Debug: %1").arg(msg);
        break;

    case QtWarningMsg:    //一般的warning提示
        txtMessage = QString("Warning: %1").arg(msg);
        break;

    case QtCriticalMsg:    //严重错误提示
        txtMessage = QString("Critical: %1").arg(msg);
        break;

    case QtInfoMsg:
        txtMessage = QString("Info: %1").arg(msg);
        break;

    case QtFatalMsg:    //致命错误提示
        txtMessage = QString("Fatal: %1").arg(msg);
        abort();
    }

    //保存输出相关信息到指定文件
    QFile outputFile("./customMessageLog.txt");
    outputFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream textStream(&outputFile);
    textStream << txtMessage << endl;
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("Mindgo");

    qInstallMessageHandler(customMessageHandler);

    qDebug()<<QDir::currentPath();
    QTranslator translator;
    translator.load("./config/cn.qm");
    app.installTranslator(&translator);

    qmlRegisterType<OperationParamObject>("Common", 1,0, "OperationParamObject");
    qmlRegisterType<OperationParamSelector>("Common", 1,0,"OperationParamSelector");
    qmlRegisterType<PlanSelector>("Common" ,1,0,"PlanSelector");
    qmlRegisterType<StatusViewWatcher>("Common", 1,0,"StatusViewWatcher");
    qmlRegisterType<PlanController>("Common", 1,0,"PlanController");

    QQuickView view;

    EnvironmentVariant::instance()->parseConfigFile("./config/OperationParams.json");
    EnvironmentVariant::instance()->initUserConfig("./config/UserConfig.json");
    EnvironmentVariant::instance()->initProtocol("./config/Protocol.json");
    EnvironmentVariant::instance()->initModels(view.rootContext());


    view.connect(view.engine(), &QQmlEngine::quit, &app, &QCoreApplication::quit);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.setSource(QUrl("qrc:/main.qml"));
    view.show();

    return app.exec();
}
