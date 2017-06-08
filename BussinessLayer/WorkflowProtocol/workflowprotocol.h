#ifndef WORKFLOWPROTOCOL_H
#define WORKFLOWPROTOCOL_H

#include "workflowprotocol_global.h"
#include <QJsonObject>
#include <QThread>
#include "communication.h"
#include <QEvent>

class WORKFLOWPROTOCOLSHARED_EXPORT WorkflowProtocol
{
public:
    class sendFrame
    {
    public:
        sendFrame(){}

        uchar head;
        ushort length;
        ushort opcode;
        ushort seq;
        ushort params[16];
    };
    class recvFrame
    {
    public:
        recvFrame() {}

        uchar head;
        ushort length;
        ushort opcode;
        ushort seq;
        ushort result;
    };

public:
    WorkflowProtocol();

    bool initProtocol(const QString& protocolConfigFile);

    bool parseJsonObjectToSendFrame(const QJsonObject & jsObj, QJsonObject & retObj);
    bool formatRecvFrameToJsonObject(QJsonObject& retObj);

    bool parseAckFrame(const QByteArray&, QJsonObject& ret);

    QByteArray serializeSendFrame();
    void unserializeRecvFrame(const QByteArray&);

protected:
    template<typename T>
    QByteArray formatWord(T val);
    template<typename T>
    T getWord(QByteArray&);

private:
    QJsonObject m_protocolConfig;
    sendFrame m_sendFrame;
    recvFrame m_recvFrame;
};

class SubThreadWorker:public QObject
{
    Q_OBJECT
public:
    SubThreadWorker(WorkflowProtocol* protocol, QObject*parent);
    ~SubThreadWorker();


public slots:
    void doTunning(const QJsonObject&);
    void doWork(const QJsonObject&);
    void changeHost(const QString& host, quint16 port);
    void configProtocol(const QString& );
    void stopTask();

signals:
    void statusChanged(const QJsonObject&);
    void taskStateChanged(bool running, int index);

protected:
    bool handleControlCommand(Communication& com, QJsonObject& cmdObj);
    bool handleLogicalCommand(QJsonObject& cmdObj, int& currentIndex);
    bool isLogicalCommand(const QString& name);
    bool isLoopCommand(const QString& name);
    bool handleLoopCommand(QJsonObject& cmdObj, int& currentIndex);

private:
    WorkflowProtocol * m_protocol;
    QString m_ip;
    qint16 m_port;
    struct loopControl{
        int loopStartIndex;
        int loopCount;
        bool fakeLoop;

        loopControl():loopStartIndex(0), loopCount(0), fakeLoop(false){}
        loopControl(int index, int count): loopStartIndex(index), loopCount(count), fakeLoop((count == 0)?true:false){}
    };
    QList<loopControl> m_loopControl;

    volatile bool m_forceStop;
    int m_maxReceiveTime;
    int m_startIndex;
};

class WORKFLOWPROTOCOLSHARED_EXPORT WorkflowController:public QObject
{
    Q_OBJECT
public:
    WorkflowController(QObject* parent = NULL);
    ~WorkflowController() ;
    void init(const QString& protoconConfig);

    void runTask(const QJsonObject & jsObj);
    void runTunning(const QJsonObject& jsObj);
    void stopCurrentTask();
    void sethost(const QString& host, quint16 port);

signals:
    void runNewTunning(const QJsonObject&);
    void runNewTask(const QJsonObject&);
    void stopTask();
    void changeHost(const QString& host, quint16 port);
    void configProtocol(const QString&);

public slots:
    void statusChanged(const QJsonObject&);
    void taskStateChanged(bool running, int index);

protected:
    QThread m_thread;
};

class StatusChangeEvent:public QEvent
{
public:
    StatusChangeEvent():QEvent(static_cast<QEvent::Type>(QEvent::User+1)) {}

    QJsonObject jsObject;
};

class RunningStateChangeEvent: public QEvent
{
public:
    RunningStateChangeEvent(bool bRun, int index)
        :QEvent(static_cast<QEvent::Type>(QEvent::User+2)), running(bRun), stepIndex(index)
    {

    }

    bool running;
    int stepIndex;
};

#endif // WORKFLOWPROTOCOL_H
