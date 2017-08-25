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
#include <QFont>
#include <QFontDatabase>
#include <QTime>

#include <QScreen>
#include <QtPlugin>


#ifdef WIN32
#include <Windows.h>
#include <iostream>
#include "dbghelp.h"

#include "windows.h"
#include <Netfw.h>
#include "atldef.h"
#include "atlbase.h"
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
#ifdef WIN32
void openFireWall(const char* path, const char* name )
{
    if(path==NULL || name==NULL)
    {
        return;
    }

    LPCSTR lpszPath =  path;
    LPCSTR lpszName = name;

    HRESULT hr = S_OK;
    hr = ::CoInitialize(NULL);
    if (FAILED(hr))
    {
        return ;
    }

    CComPtr<INetFwMgr> fwMgr = NULL;
    CComPtr<INetFwPolicy> fwPolicy = NULL;
    CComPtr<INetFwProfile> fwProfile = NULL;
    // Create an instance of the firewall settings manager.
    hr = CoCreateInstance(__uuidof(NetFwMgr), NULL, CLSCTX_INPROC_SERVER, __uuidof(INetFwMgr), (void**)&fwMgr);
    if (FAILED(hr))
    {
        ::CoUninitialize();
        return ;
    }
    // Retrieve the local firewall policy.
    hr = fwMgr->get_LocalPolicy(&fwPolicy);
    if (FAILED(hr))
    {
        ::CoUninitialize();
        return ;
    }
    // Retrieve the firewall profile currently in effect.
    hr = fwPolicy->get_CurrentProfile(&fwProfile);
    if (FAILED(hr))
    {
        ::CoUninitialize();
        return ;
    }
    // Get the current state of the firewall.
    VARIANT_BOOL fwEnabled;
    hr = fwProfile->get_FirewallEnabled(&fwEnabled);
    if (FAILED(hr))
    {
        ::CoUninitialize();
        return ;
    }
    // Check to see if the firewall is on.
    if (fwEnabled == VARIANT_FALSE)
    {
        ::CoUninitialize();
        return ;
    }
    CComPtr<INetFwAuthorizedApplication> fwApp = NULL;
    CComPtr<INetFwAuthorizedApplications> fwApps = NULL;
    // Retrieve the authorized application collection.
    hr = fwProfile->get_AuthorizedApplications(&fwApps);
    if (FAILED(hr))
    {
        ::CoUninitialize();
        return ;
    }
    CComBSTR bstrProcessImageFileName = lpszPath;
    CComBSTR bstrName = lpszName;
    // Attempt to retrieve the authorized application.
    hr = fwApps->Item(bstrProcessImageFileName, &fwApp);
    if (SUCCEEDED(hr))
    {
        // Find out if the authorized application is enabled.
        hr = fwApp->get_Enabled(&fwEnabled);
        if (SUCCEEDED(hr))
        {
            if (fwEnabled == VARIANT_FALSE)
            {
                hr = fwApp->put_Enabled(VARIANT_TRUE);
                if (SUCCEEDED(hr))
                {
                    ::CoUninitialize();
                    return ;
                }
            }
            else
            {
                ::CoUninitialize();
                return ;
            }
        }
    }
    else
    {
        hr = CoCreateInstance(__uuidof(NetFwAuthorizedApplication), NULL, CLSCTX_INPROC_SERVER, __uuidof(INetFwAuthorizedApplication), (void**)&fwApp);
        if (SUCCEEDED(hr))
        {
            // Set the process image file name.
            hr = fwApp->put_ProcessImageFileName(bstrProcessImageFileName);
            if (SUCCEEDED(hr))
            {
                // Set the application friendly name.
                hr = fwApp->put_Name(bstrName);
                if (SUCCEEDED(hr))
                {
                    // Add the application to the collection.
                    hr = fwApps->Add(fwApp);
                    if (SUCCEEDED(hr))
                    {
                        ::CoUninitialize();
                        return ;
                    }
                }
            }
        }
    }

    ::CoUninitialize();
    return ;
}
#endif
int main(int argc, char *argv[])
{
#ifndef NO_VIRTUAL_KEYBOARD
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));
#endif

    QGuiApplication app(argc, argv);
    app.setApplicationName("Mindgo");


#ifdef WIN32
    SetUnhandledExceptionFilter(TopLevelExceptionFilter);

    openFireWall((QFileInfo( QCoreApplication::applicationFilePath() ).absoluteFilePath().toStdString().c_str()), (QFileInfo( QCoreApplication::applicationFilePath() ).fileName().toStdString().c_str()));
#endif

#ifdef QT_NO_DEBUG
    qInstallMessageHandler(customMessageHandler);
#endif
    QTranslator translator;
    translator.load(getConfigFullName("cn.qm"));
    app.installTranslator(&translator);

    qmlRegisterType<TextFieldDoubleValidator>("Common", 1,0, "TextFieldDoubleValidator");
    qmlRegisterType<OperationParamObject>("Common", 1,0, "OperationParamObject");
    qmlRegisterType<OperationParamSelector>("Common", 1,0,"OperationParamSelector");
    qmlRegisterType<PlanSelector>("Common" ,1,0,"PlanSelector");
    qmlRegisterType<StatusViewWatcher>("Common", 1,0,"StatusViewWatcher");
    qmlRegisterType<PlanController>("Common", 1,0,"PlanController");
    qmlRegisterType<WorkLocationManager>("Common", 1, 0,"WorkLocationManager");

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
    view.setMinimumSize(QSize(1400,720));
    QScreen* scn = view.screen();
    qDebug()<<scn->physicalSize();
#ifdef QT_WS_QWS

    view.showFullScreen();
#else
    view.show();
#endif

    return app.exec();
}
