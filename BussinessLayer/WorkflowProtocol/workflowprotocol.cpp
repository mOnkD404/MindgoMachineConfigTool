#include "workflowprotocol.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QStringList>
#include <QtEndian>
#include <QThread>
#include <QElapsedTimer>
#include <QFile>

WorkflowProtocol::WorkflowProtocol()
{
}



bool WorkflowProtocol::initProtocol(const QString& protocolConfigFile)
{
    QFile loadFile(protocolConfigFile);
    if (!loadFile.open(QIODevice::ReadOnly))
    {
        qWarning("Couldn't open config file.");
        return false;
    }

    QByteArray data = loadFile.readAll();

    QJsonDocument loadDoc(QJsonDocument::fromJson(data));

    m_protocolConfig = loadDoc.object()["Protocol"].toObject();
    loadFile.close();

    return true;
}

bool WorkflowProtocol::parseJsonObjectToSendFrame(const QJsonObject & jsObj, QJsonObject& retObj)
{
    QJsonObject sendConfig = m_protocolConfig["send buffer"].toObject();

    QString operationName = jsObj["operation"].toString();

    ushort code = 0;
    QString codeStr = sendConfig["operation"].toObject()["data"].toObject()[operationName].toString();
    if(codeStr.at(0) == '0' && codeStr.at(1) == 'x')
    {
        code = codeStr.right(codeStr.length()-2).toInt(NULL,16);
    }
    QJsonObject paramObj = sendConfig["params"].toObject()[operationName].toObject();

    ushort length = paramObj["byte size"].toInt();
    QJsonArray paramArray = paramObj["data"].toArray();
    QStringList paramList;
    for( int index = 0; index < paramArray.size(); index++)
    {
        paramList.append(paramArray[index].toString());
    }

    ushort seq = jsObj["sequence number"].toInt();
    QJsonObject userParams = jsObj["params"].toObject();


    retObj["operation"] = operationName;
    retObj["sequence number"] = seq;


    //1.head
    const uchar headCode = 0x02;
    m_sendFrame.head = headCode;


    //2.length
    m_sendFrame.length = length;


    //3.operation
    m_sendFrame.opcode = code;


    //4.sequence number
    m_sendFrame.seq = seq;


    //5.params
    int index = 0;
    memset(m_sendFrame.params, 0, sizeof(m_sendFrame.params));
    foreach( const QString& str, paramList)
    {
        m_sendFrame.params[index] = userParams[str].toInt();
        index++;
    }

    return true;
}

bool WorkflowProtocol::formatRecvFrameToJsonObject(QJsonObject & retObject)
{
    //1.head

    //2.length

    //3.operation
    char tempstring[25];
    sprintf(tempstring, "0x%2x", m_recvFrame.opcode);
    retObject["ack operation"] = QString(tempstring);


    //4.sequence number
    retObject["ack sequence number"] = QString::number(m_recvFrame.seq);

    //5.result
    retObject["ack result"] = QString::number(m_recvFrame.result);

    return true;
}
template<typename T>
QByteArray WorkflowProtocol::formatWord(T val)
{
    char temp[sizeof(T)];
    qToBigEndian<T>(val, temp);
    return QByteArray(temp, sizeof(T));
}
template<typename T>
T WorkflowProtocol::getWord(QByteArray& btArray)
{
    T val;
    uchar temp[sizeof(T)];
    memcpy(temp, btArray.data(), sizeof(T));
    val = qFromBigEndian<T>(temp);
    btArray.remove(0, sizeof(T));

    return val;
}

QByteArray WorkflowProtocol::serializeSendFrame()
{
    QByteArray buffer;

    buffer.append(formatWord<uchar>(m_sendFrame.head));
    buffer.append(formatWord<ushort>(m_sendFrame.length));
    buffer.append(formatWord<ushort>(m_sendFrame.opcode));
    buffer.append(formatWord<ushort>(m_sendFrame.seq));
    for(int index = 0; index < m_sendFrame.length; index++)
    {
        buffer.append(formatWord<ushort>(m_sendFrame.params[index]));
    }

    return buffer;
}

bool WorkflowProtocol::parseAckFrame(const QByteArray& buff, QJsonObject& ret)
{
    const uchar head = 0x02;
    const ushort length = 0x0006;

    uchar standardHead[3];
    standardHead[0] = head;
    qToBigEndian<ushort>(length, standardHead+1);

    const int frameLen = sizeof(standardHead) + length;

    if (buff.size() < frameLen)
        return false;



    for(int index = 0; index + frameLen < buff.size(); index++)
    {
        if(memcmp(standardHead, buff.data()+index, sizeof(standardHead)) == 0)
        {
            QByteArray recvarray(buff.data()+index, frameLen);
            unserializeRecvFrame(recvarray);


            if (m_sendFrame.opcode != m_recvFrame.opcode || \
                m_sendFrame.seq != m_recvFrame.seq || \
                m_recvFrame.result != 0)
            {
                formatRecvFrameToJsonObject(ret);
                return false;
            }
            else
            {
                return true;
            }
        }
    }
    return false;
}

void WorkflowProtocol::unserializeRecvFrame(const QByteArray& buff)
{
    QByteArray recvbuffer(buff);

    //1.head
    m_recvFrame.head = getWord<uchar>(recvbuffer);
    if (m_recvFrame.head != 0x02)
    {
        qWarning("recv head code error %d", m_recvFrame.head);
    }

    //2.length
    m_recvFrame.length = getWord<ushort>(recvbuffer);
    if (m_recvFrame.length != 0x06)
    {
        qWarning("recv length code error %d", m_recvFrame.length);
    }

    //3.operation
    m_recvFrame.opcode = getWord<ushort>(recvbuffer);


    //4.sequence number
    m_recvFrame.seq = getWord<ushort>(recvbuffer);

    //5.result
    m_recvFrame.result = getWord<ushort>(recvbuffer);

    return ;
}


SubThreadWorker::SubThreadWorker(WorkflowProtocol* protocol, QObject*parent)
    :QObject(parent), m_protocol(protocol)
{

}

SubThreadWorker::~SubThreadWorker()
{
    if( m_protocol)
    {
        delete m_protocol;
        m_protocol = NULL;
    }
}

void SubThreadWorker::doWork(const QJsonObject &jsObj)
{
    Communication com;
    if(!com.connectToServer(m_ip, m_port))
    {
        return;
    }

    QJsonArray opList = jsObj["operations"].toArray();

    for (int index = 0; index < opList.size(); index++)
    {
        QJsonObject retObj;
        QJsonObject sendobj = opList[index].toObject();
        m_protocol->parseJsonObjectToSendFrame(sendobj, retObj);
        QByteArray btarray = m_protocol->serializeSendFrame();

        int sendlen = btarray.size();

        QElapsedTimer timer;
        timer.start();
        bool sendret = false;
        while(com.connected() && timer.elapsed() < 1000)
        {
            int send = com.write(btarray);
            qDebug()<<"client write "<<send<<" bytes"<<btarray.left(send);
            if(send < 0)
            {
                break;
            }
            sendlen -= send;
            if(sendlen == 0)
            {
                sendret = true;
                break;
            }
            else
            {
                btarray = btarray.right(sendlen);
            }
        }


        retObj["send"] = sendret;
        emit statusChanged(retObj);

        if (!sendret)
        {
            return;
        }

        timer.restart();
        bool recvret = false;
        QByteArray recvArray;
        while(com.connected() && timer.elapsed() < 1000)
        {
            const QByteArray &array = com.readData();
            if(array.size() > 0)
            {
                recvArray.append(array);
                if (m_protocol->parseAckFrame(recvArray, retObj))
                {
                    recvret = true;
                    break;
                }
            }
        }

        retObj["ack"] = recvret;

        emit statusChanged(retObj);
        if(!recvret)
            return;
    }
}

void SubThreadWorker::changeHost(const QString& host, quint16 port)
{
    m_ip = host;
    m_port = port;
}

void SubThreadWorker::configProtocol(const QString &filename)
{
    if (m_protocol)
        m_protocol->initProtocol(filename);
}

WorkflowController::WorkflowController(QObject *parent)
    :QObject(parent)
{

    SubThreadWorker *worker = new SubThreadWorker(new WorkflowProtocol(), NULL);
    worker->moveToThread(&m_thread);
    connect(&m_thread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &WorkflowController::runNewTask, worker, &SubThreadWorker::doWork);
    connect(worker, &SubThreadWorker::statusChanged, this, &WorkflowController::statusChanged);
    connect(this, &WorkflowController::changeHost, worker, &SubThreadWorker::changeHost);
    connect(this, &WorkflowController::configProtocol, worker, &SubThreadWorker::configProtocol);
    m_thread.start();
}

WorkflowController::~WorkflowController()
{
    if(m_thread.isRunning())
    {
        m_thread.quit();
        m_thread.wait();
    }
}

void WorkflowController::init(const QString &protoconConfig)
{
    emit configProtocol(protoconConfig);
}

void WorkflowController::runTask(const QJsonObject &jsObj)
{
    if(m_thread.isRunning())
    {
        emit runNewTask(jsObj);
    }
    else
    {
        qWarning("worker thread is dead.");
    }
}


void WorkflowController::sethost(const QString& host, quint16 port)
{
    emit changeHost(host, port);
}



