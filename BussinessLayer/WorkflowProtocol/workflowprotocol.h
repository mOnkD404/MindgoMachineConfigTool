#ifndef WORKFLOWPROTOCOL_H
#define WORKFLOWPROTOCOL_H

#include "workflowprotocol_global.h"
#include <QJsonObject>
#include <QThread>
#include "communication.h"

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
    void doWork(const QJsonObject&);
    void changeHost(const QString& host, quint16 port);
    void configProtocol(const QString& );

signals:
    void statusChanged(const QJsonObject&);

private:

    WorkflowProtocol * m_protocol;

    QString m_ip;
    qint16 m_port;
};

class WORKFLOWPROTOCOLSHARED_EXPORT WorkflowController:public QObject
{
    Q_OBJECT
public:
    WorkflowController(QObject* parent = NULL);
    ~WorkflowController() ;
    void init(const QString& protoconConfig);

    void runTask(const QJsonObject & jsObj);
    void sethost(const QString& host, quint16 port);

signals:
    void statusChanged(const QJsonObject&);
    void runNewTask(const QJsonObject&);
    void changeHost(const QString& host, quint16 port);
    void configProtocol(const QString&);

protected:
    QThread m_thread;
};

#endif // WORKFLOWPROTOCOL_H
