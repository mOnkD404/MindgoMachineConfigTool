#include <QGuiApplication>
#include <QApplication>
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
#include <QFont>
#include <QFontDatabase>
#include <QTime>

#include <QScreen>
#include <QtPlugin>


#ifdef WIN32
#include <Windows.h>
#include <iostream>
#include "dbghelp.h"

LONG WINAPI TopLevelExceptionFilter(struct _EXCEPTION_POINTERS *pExceptionInfo)
{
    HANDLE hFile = CreateFile(L"MindGoProject.dmp",GENERIC_WRITE,0,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
    MINIDUMP_EXCEPTION_INFORMATION stExceptionParam;
    stExceptionParam.ThreadId    = GetCurrentThreadId();
    stExceptionParam.ExceptionPointers = pExceptionInfo;
    stExceptionParam.ClientPointers    = FALSE;
    MiniDumpWriteDump(GetCurrentProcess(),GetCurrentProcessId(),hFile,MiniDumpWithFullMemory,&stExceptionParam,NULL,NULL);
    CloseHandle(hFile);
    return EXCEPTION_EXECUTE_HANDLER;
}
#endif

void customMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QString txtMessage;
    switch (type)
    {
    case QtDebugMsg:    //调试信息提示
        txtMessage = QTime::currentTime().toString() + QString("Debug: %1").arg(msg);
        break;

    case QtInfoMsg:
      txtMessage = QTime::currentTime().toString() + QString("Debug: %1").arg(msg);
        break;

    case QtWarningMsg:    //一般的warning提示
        txtMessage = QTime::currentTime().toString() + QString("Warning: %1").arg(msg);
        break;

    case QtCriticalMsg:    //严重错误提示
        txtMessage = QTime::currentTime().toString() + QString("Critical: %1").arg(msg);
        break;

    case QtFatalMsg:    //致命错误提示
        txtMessage = QTime::currentTime().toString() + QString("Fatal: %1").arg(msg);
        abort();
    default:
        break;
    }

    //保存输出相关信息到指定文件
    QFile outputFile("./customMessageLog.txt");
    outputFile.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream textStream(&outputFile);
    textStream << txtMessage << endl;
}

#ifdef MINDGO_ALL_IN_ONE
#define CONFIG_PREFIX "./UserInterfaceLayer/config/"
#else
#define CONFIG_PREFIX "./config/"
#endif

QString getConfigFullName(const char* name)
{
    return QString(CONFIG_PREFIX)+name;
}

int main(int argc, char *argv[])
{
#ifdef WIN32
    SetUnhandledExceptionFilter(TopLevelExceptionFilter);
#endif


#ifndef NO_VIRTUAL_KEYBOARD
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
#endif

    QApplication app(argc, argv);
    app.setApplicationName("Mindgo");

#ifdef QT_NO_DEBUG
    qInstallMessageHandler(customMessageHandler);
#endif
    qDebug()<<QDir::currentPath();
    QTranslator translator;
    translator.load(getConfigFullName("cn.qm"));
    app.installTranslator(&translator);

    qmlRegisterType<TextFieldDoubleValidator>("Common", 1,0, "TextFieldDoubleValidator");
    qmlRegisterType<OperationParamObject>("Common", 1,0, "OperationParamObject");
    qmlRegisterType<OperationParamSelector>("Common", 1,0,"OperationParamSelector");
    qmlRegisterType<PlanSelector>("Common" ,1,0,"PlanSelector");
    qmlRegisterType<StatusViewWatcher>("Common", 1,0,"StatusViewWatcher");
    qmlRegisterType<PlanController>("Common", 1,0,"PlanController");

    QFontDatabase::addApplicationFont(getConfigFullName("FZHTJW.TTF"));
    QFont font;
    font.setFamily(QString::fromWCharArray(L"方正黑体简体"));
    app.setFont(font);

    QQuickView view;

    EnvironmentVariant::instance()->parseConfigFile(getConfigFullName("OperationParams.json"));
    EnvironmentVariant::instance()->initUserConfig(getConfigFullName("UserConfig.json"));
    EnvironmentVariant::instance()->initProtocol(getConfigFullName("Protocol.json"));
    EnvironmentVariant::instance()->initModels(view.rootContext());


    view.connect(view.engine(), &QQmlEngine::quit, &app, &QCoreApplication::quit);
    view.setResizeMode(QQuickView::SizeRootObjectToView);
#ifndef NO_VIRTUAL_KEYBOARD
    view.setSource(QUrl("qrc:/main.qml"));

#else
    view.setSource(QUrl("qrc:/MainNoKeyboard.qml"));
#endif
    view.setMinimumSize(QSize(800,480));
    QScreen* scn = view.screen();
    qDebug()<<scn->physicalSize();
#ifdef QT_WS_QWS

    view.showFullScreen();
#else
    view.show();
#endif

    return app.exec();
}
