#include "workflowprotocol.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QStringList>
#include <QtEndian>
#include <QThread>
#include <QElapsedTimer>
#include <QFile>
#include <QCoreApplication>

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
    if(codeStr.size() > 2 && codeStr.at(0) == '0' && codeStr.at(1) == 'x')
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

    ushort seq = jsObj["sequence"].toInt();
    QJsonObject userParams = jsObj["params"].toObject();
    qDebug()<<userParams;

    retObj["operation"] = operationName;
    retObj["sequence"] = seq;


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
    //char tempstring[25];
    //sprintf(tempstring, "0x%2x", m_recvFrame.opcode);
    //retObject["ackOperation"] = QString(tempstring);


    //4.sequence number
    //retObject["ackSequence"] = QString::number(m_recvFrame.seq);

    //5.result
    retObject["ackResult"] = m_recvFrame.result;

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
    buffer.append(formatWord<ushort>(m_sendFrame.length));//words behind
    buffer.append(formatWord<ushort>(m_sendFrame.opcode));
    buffer.append(formatWord<ushort>(m_sendFrame.seq));

    qint32 paramByteCount = m_sendFrame.length - sizeof(m_sendFrame.opcode) - sizeof(m_sendFrame.seq);
    if(paramByteCount > 0)
    {
        qint32 paramCount = paramByteCount/2;
        for(int index = 0; index < paramCount; index++)
        {
            buffer.append(formatWord<ushort>(m_sendFrame.params[index]));
        }
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



    for(int index = 0; index + frameLen <= buff.size(); index++)
    {
        if(memcmp(standardHead, buff.data()+index, sizeof(standardHead)) == 0)
        {
            QByteArray recvarray(buff.data()+index, frameLen);
            unserializeRecvFrame(recvarray);


            formatRecvFrameToJsonObject(ret);
            if (m_sendFrame.opcode != m_recvFrame.opcode || \
                m_sendFrame.seq != m_recvFrame.seq || \
                m_recvFrame.result != 0)
            {
                return true;
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
    :QObject(parent), m_protocol(protocol), m_forceStop(false), m_maxReceiveTime(0), m_pause(false),m_com(this)
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

void SubThreadWorker::doTunning(const QJsonObject& jsObj)
{
    if(!m_com.connectToServer(m_ip, m_port))
    {
        return;
    }

    m_forceStop = false;
    m_pause = false;
    m_maxReceiveTime = jsObj["maxReceiveTime"].toInt();
    QJsonObject sendobj = jsObj["operation"].toObject();
    const QString opName = sendobj["operation"].toString();
    //emit taskStateChanged(true, currentIndex);


    handleControlCommand(m_com, sendobj);

    m_com.disconnectLater();

    //emit taskStateChanged(false, currentIndex);
}

void SubThreadWorker::doWork(const QJsonObject &jsObj)
{
    if(!m_com.connectToServer(m_ip, m_port))
    {
        return;
    }

    m_forceStop = false;
    m_pause = false;
    m_maxReceiveTime = jsObj["maxReceiveTime"].toInt();
    QJsonArray opList = jsObj["operations"].toArray();
    int currentIndex = jsObj["startIndex"].toInt();
    m_stateString = "start";
    emit taskStateChanged(m_stateString, currentIndex);
    m_stateString = "";

    while (currentIndex >=0 && currentIndex < opList.size())
    {
        QJsonObject sendobj = opList[currentIndex].toObject();
        bool retVal = false;
        const QString opName = sendobj["operation"].toString();

        if(isLoopCommand(opName))
        {
            retVal = handleLoopCommand(sendobj, currentIndex);
        }
        else
        {
            if(m_loopControl.empty()  || (!m_loopControl.empty() && !m_loopControl.back().fakeLoop))
            {
                if(isDummyCommand(opName))
                {
                    retVal = true;
                }
                else
                {
                    if(isLogicalCommand(opName))
                    {
                        retVal = handleLogicalCommand(sendobj, currentIndex);
                    }
                    else
                    {
                        retVal = handleControlCommand(m_com, sendobj);
                    }
                }
            }
            else
            {
                retVal = true;
            }
        }

        if(!retVal)
            break;

        currentIndex++;
        if(currentIndex >= opList.size())
            break;

        if(m_forceStop)
        {
            break;
        }
        else if(m_pause)
        {
            m_stateString = "pause";
            break;
        }
    }
    m_com.disconnectLater();

    emit taskStateChanged(m_stateString, currentIndex);
    if(m_forceStop || m_pause)
    {
        m_forceStop = false;
        m_pause  =  false;
    }
    else
    {
        m_loopControl.clear();
    }
}

bool SubThreadWorker::isLogicalCommand(const QString& name)
{
    QList<QString> logicalList;
    logicalList.append("WaitArray");

    foreach (const QString& str, logicalList)
    {
        if(name == str)
        {
            return true;
        }
    }
    return false;
}

bool SubThreadWorker::isDummyCommand(const QString& name)
{
    QList<QString> dummyList;
    dummyList.append("Group");
    dummyList.append("EndGroup");

    foreach (const QString& str, dummyList)
    {
        if(name == str)
        {
            return true;
        }
    }
    return false;
}

bool SubThreadWorker::isLoopCommand(const QString& name)
{
    QList<QString> logicalList;
    logicalList.append("Loop");
    logicalList.append("EndLoop");

    foreach (const QString& str, logicalList)
    {
        if(name == str)
        {
            return true;
        }
    }
    return false;
}

bool SubThreadWorker::handleLogicalCommand(QJsonObject& cmdObj, int& currentIndex)
{
    bool retVal = true;
    QJsonObject retObj;

    retObj["operation"] = cmdObj["operation"];
    retObj["position"] = -1;
    retObj["sequence"] = cmdObj["sequence"];
    retObj["send"] = false;
    retObj["ack"] = false;
    retObj["ackResult"] = 0;
    retObj["newOperationItem"] = true;
    retObj["logicalCommand"] = true;
    retObj["waitArray"] = 0;
    retObj["waitting"] = 0;
    retObj["waitPermanent"] = false;
    retObj["loopCount"] = 0;
    retObj["remainLoopCount"] = 0;


    QString opname = cmdObj["operation"].toString();
    QJsonObject param = cmdObj["params"].toObject();

    if(opname == "WaitArray")
    {
        int time = param["waitTime"].toInt();
        bool permanent = (bool)(param["permanent"].toInt());
        if(permanent)
        {
            retObj["waitPermanent"] = true;
            emit statusChanged(retObj);
            m_pause = true;

            return true;
        }
        if (time > 0)
        {
            retObj["waitArray"] = time;
            retObj["waitting"] = 0;

            emit statusChanged(retObj);

            for(int index = 0; index < time; index++)
            {
                if(m_forceStop || m_pause)
                {
                    //retVal = false;
                    break;
                }

                QThread::msleep(1000);

                retObj["newOperationItem"] = false;
                retObj["waitting"] = index+1;

                emit statusChanged(retObj);

            }
        }
    }

    return retVal;
}

bool SubThreadWorker::handleLoopCommand(QJsonObject& cmdObj, int& currentIndex)
{
    bool retVal = false;
    QJsonObject retObj;

    retObj["operation"] = cmdObj["operation"];
    retObj["position"] = -1;
    retObj["sequence"] = cmdObj["sequence"];
    retObj["send"] = false;
    retObj["ack"] = false;
    retObj["ackResult"] = 0;
    retObj["newOperationItem"] = true;
    retObj["logicalCommand"] = true;
    retObj["waitArray"] = 0;
    retObj["waitting"] = 0;
    retObj["waitPermanent"] = false;
    retObj["loopCount"] = 0;
    retObj["remainLoopCount"] = 0;


    QString opname = cmdObj["operation"].toString();
    QJsonObject param = cmdObj["params"].toObject();

    if(opname == "Loop")
    {
        loopControl ctrl;
        ctrl.loopCount = param["cycleCount"].toInt();
        ctrl.loopStartIndex = currentIndex;
        if(ctrl.loopCount == 0 || (!m_loopControl.isEmpty() && m_loopControl.back().fakeLoop))
        {
            ctrl.fakeLoop = true;
        }
        m_loopControl.push_back(ctrl);

        retObj["loopCount"] = ctrl.loopCount;
        emit statusChanged(retObj);

        retVal = true;
    }
    else if(opname == "EndLoop")
    {
        if(!m_loopControl.isEmpty())
        {
            loopControl &ctrl = m_loopControl.back();

            if(ctrl.fakeLoop)
            {
                retObj["remainLoopCount"] = 0;
                emit statusChanged(retObj);
                m_loopControl.pop_back();
            }
            else
            {
                if(ctrl.loopCount > 0)
                {
                    ctrl.loopCount--;
                }
                retObj["remainLoopCount"] = ctrl.loopCount;
                emit statusChanged(retObj);

                if(ctrl.loopCount <= 0)
                {
                    //ctrl.loopStartIndex = currentIndex;
                    //m_inFakeLoop = false;
                    m_loopControl.pop_back();
                }
                else
                {
                    currentIndex = ctrl.loopStartIndex;
                }
            }
        }
        retVal = true;
    }

    return retVal;
}

bool SubThreadWorker::handleControlCommand(Communication& com, QJsonObject& cmdObj)
{
    QJsonObject retObj;
    retObj["operation"] = "";
    retObj["position"] = cmdObj["params"].toObject()["position"].toInt()+1;
    retObj["sequence"] = 0;
    retObj["send"] = false;
    retObj["ack"] = false;
    retObj["ackResult"] = 0;
    retObj["newOperationItem"] = true;
    retObj["logicalCommand"] = false;
    retObj["waitArray"] = 0;
    retObj["waitting"] = 0;
    retObj["waitPermanent"] = false;
    retObj["loopCount"] = 0;
    retObj["remainLoopCount"] = 0;
    retObj["running"] = true;

    m_protocol->parseJsonObjectToSendFrame(cmdObj, retObj);
    QByteArray btarray = m_protocol->serializeSendFrame();

    emit statusChanged(retObj);

    int sendlen = btarray.size();
    QElapsedTimer timer;
    timer.start();
    bool sendret = false;
    while(com.connected() && timer.elapsed() < 1000)
    {
        int send = com.write(btarray);
        qDebug()<<"client write "<<send<<" bytes"<<hex<<btarray.left(send);
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

    retObj["newOperationItem"] = false;
    retObj["send"] = sendret;

    emit statusChanged(retObj);
    if (!sendret)
    {
        retObj["running"] = false;
        emit statusChanged(retObj);
        return false;
    }

    timer.restart();
    bool recvret = false;
    QByteArray recvArray;
    while(com.connected() && timer.elapsed() < m_maxReceiveTime*1000)// && !m_forceStop)
    {
        const QByteArray &array = com.readData(1000);
        if(array.size() > 0)
        {
            qDebug()<<"recv ack"<<hex<<array;
            recvArray.append(array);
            if (m_protocol->parseAckFrame(recvArray, retObj))
            {
                recvret = true;
                break;
            }
        }
    }

    retObj["newOperationItem"] = false;
    retObj["ack"] = recvret;

    retObj["running"] = false;

    emit statusChanged(retObj);
    if(!recvret || retObj["ackResult"] != 0)
        return false;

    return true;
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

void SubThreadWorker::stopTask()
{
    m_forceStop = true;
}

void SubThreadWorker::pauseTask()
{
    m_pause = true;
}

void SubThreadWorker::updateStopState()
{
    if(m_stateString != "")
    {
        m_stateString = "";
        emit taskStateChanged(m_stateString, 0);
    }
}

WorkflowController::WorkflowController(QObject *parent)
    :QObject(parent)
{

    SubThreadWorker *worker = new SubThreadWorker(new WorkflowProtocol(), NULL);
    worker->moveToThread(&m_thread);
    connect(&m_thread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &WorkflowController::runNewTask, worker, &SubThreadWorker::doWork);
    connect(this, &WorkflowController::runNewTunning, worker, &SubThreadWorker::doTunning);
    connect(worker, &SubThreadWorker::statusChanged, this, &WorkflowController::statusChanged);
    connect(this, &WorkflowController::changeHost, worker, &SubThreadWorker::changeHost);
    connect(this, &WorkflowController::configProtocol, worker, &SubThreadWorker::configProtocol);
    connect(this, &WorkflowController::stopTask, worker, &SubThreadWorker::stopTask, Qt::DirectConnection);
    connect(this, &WorkflowController::pauseTask, worker, &SubThreadWorker::pauseTask, Qt::DirectConnection);
    connect(worker, &SubThreadWorker::taskStateChanged, this, &WorkflowController::taskStateChanged);
    connect(this, &WorkflowController::updateStopState, worker, &SubThreadWorker::updateStopState);
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

void WorkflowController::runTunning(const QJsonObject &jsObj)
{
    if(m_thread.isRunning())
    {
        emit runNewTunning(jsObj);
    }
    else
    {
        qWarning("worker thread is dead.");
    }
}

void WorkflowController::stopCurrentTask()
{
    if(m_thread.isRunning())
    {
        emit stopTask();
        emit updateStopState();
    }
}

void WorkflowController::pauseCurrentTask()
{
    if(m_thread.isRunning())
    {
        emit pauseTask();
    }
}

void WorkflowController::sethost(const QString& host, quint16 port)
{
    emit changeHost(host, port);
}

void WorkflowController::statusChanged(const QJsonObject &obj)
{
    StatusChangeEvent* userEvent = new StatusChangeEvent();
    userEvent->jsObject = obj;
    qApp->postEvent(qApp, userEvent);
}

void WorkflowController::taskStateChanged(const QString& runningState, int index)
{
    RunningStateChangeEvent* userEvent = new RunningStateChangeEvent(runningState, index);
    qApp->postEvent(qApp, userEvent);
}


