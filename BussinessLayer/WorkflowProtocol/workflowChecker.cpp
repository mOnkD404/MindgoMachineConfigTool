#include"workflowChecker.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QStringList>
#include <QtEndian>
#include <QThread>
#include <QElapsedTimer>
#include <QFile>
#include <QCoreApplication>

SubThreadCheckWorker::SubThreadCheckWorker(QObject*parent)
    :QObject(parent), m_bForceStop(false)
{

}

SubThreadCheckWorker::~SubThreadCheckWorker()
{

}

void SubThreadCheckWorker::doCheck(const QJsonObject&jsObj)
{
    m_bForceStop = false;

    QJsonObject retObj;
    retObj["progress"] = 0;
    retObj["allow"] = false;
    retObj["end"] = false;
    retObj["errorStep"] = -1;
    emit statusChanged(retObj);

    QJsonArray opList = jsObj["operations"].toArray();
    m_boardConfig = jsObj["boardConfig"].toArray();
    m_paramComboConstraintTriggerState.clear();
    int errstep = -1;

    for (int currentIndex = 0; currentIndex < opList.size() && !m_bForceStop; currentIndex++)
    {
        QJsonObject sendobj = opList[currentIndex].toObject();

        bool check1 =  true;

        if(!isFilteredCommand(sendobj))
        {
            check1 = CheckBoardConstraint(sendobj);
            check1 = check1 && CheckParamConstraint(sendobj);
        }

        if(!check1)
        {
            errstep = currentIndex+1;
            break;
        }

        if(opList.size() > 1)
        {
            retObj["progress"] = 100*currentIndex / (opList.size()-1);
        }
        emit statusChanged(retObj);
        QThread::msleep(10);
    }

    if(retObj["progress"] == 100)
    {
        retObj["allow"] = true;
    }
    else
    {
        retObj["allow"] = false;
    }

    if(errstep != -1)
    {
        retObj["errorStep"] = errstep;
    }

    retObj["end"] = true;
    emit statusChanged(retObj);
}

bool SubThreadCheckWorker::isFilteredCommand(const QJsonObject& obj)
{
    QString opName = obj["operation"].toString();

    QList<QString> logicalList;
    logicalList.append("WaitArray");
    logicalList.append("Loop");
    logicalList.append("EndLoop");
    logicalList.append("Relative Motion");
    logicalList.append("Syringe Motion");
    logicalList.append("Reset");
    logicalList.append("XY Motion");
    logicalList.append("Machine Reset");

    foreach (const QString& str, logicalList)
    {
        if(opName == str)
        {
            return true;
        }
    }
    return false;
}

bool SubThreadCheckWorker::CheckBoardConstraint(const QJsonObject& obj)
{
    int position = obj["params"].toObject()["position"].toInt();
    if(position < 0 || position > m_boardConfig.size())
        return false;

    QString opName = obj["operation"].toString();
    QString boardName = m_boardConfig.at(position).toObject()["name"].toString();
    for(QJsonArray::Iterator iter = m_constraint.begin(); iter != m_constraint.end(); iter++)
    {
        QJsonObject consObj =  iter->toObject();
        if(boardName ==consObj["type"].toString())
        {
            QJsonArray opArray = consObj["operation"].toArray();
            for(QJsonArray::Iterator iter2 = opArray.begin(); iter2 != opArray.end(); iter2++)
            {
                if (iter2->toString() == opName)
                {
                    return true;
                }
            }
            break;
        }
    }
    return false;
}

bool SubThreadCheckWorker::CheckParamConstraint(const QJsonObject& obj)
{
    QJsonObject paramObj = obj["params"].toObject();
    int position = paramObj["position"].toInt();
    if(position < 0 || position > m_boardConfig.size())
        return false;

    QString opName = obj["operation"].toString();
    QString boardName = m_boardConfig.at(position).toObject()["name"].toString();

    for(QJsonObject::Iterator iter = m_paramComboContraint.begin(); iter != m_paramComboContraint.end(); iter++)
    {
        if(boardName == iter.key())
        {
            if(!m_paramComboConstraintTriggerState.contains(boardName))
            {
                QJsonArray triggerArray =  iter.value().toObject()["startTrigger"].toArray();
                for(QJsonArray::Iterator iter2 = triggerArray.begin(); iter2 != triggerArray.end(); iter2++)
                {
                    if(iter2->toString() == opName)
                    {
                        QString valueName =  iter.value().toObject()["value"].toString();
                        m_paramComboConstraintTriggerState[boardName] = m_boardConfig.at(position).toObject()[valueName].toInt();
                        break;
                    }
                }
            }
            else
            {
                QJsonArray triggerArray =  iter.value().toObject()["endTrigger"].toArray();
                for(QJsonArray::Iterator iter2 = triggerArray.begin(); iter2 != triggerArray.end(); iter2++)
                {
                    if(iter2->toString() == opName)
                    {
                        m_paramComboConstraintTriggerState.remove(boardName);
                    }
                }
            }
        }

        if(m_paramComboConstraintTriggerState.isEmpty())
            continue;

        if(m_paramComboConstraintTriggerState.contains(iter.key()))
        {
            int comboValue = 0;
            QJsonArray paramArray =  iter.value().toObject()["comboJudge"].toArray();
            for(QJsonArray::Iterator iter2 = paramArray.begin(); iter2 != paramArray.end(); iter2++)
            {
                for(QJsonObject::Iterator iter3 = paramObj.begin(); iter3 != paramObj.end(); iter3++)
                {
                    if(iter3.key() == iter2->toString())
                    {
                        comboValue += iter3.value().toInt();
                    }
                }
            }
            if(comboValue > m_paramComboConstraintTriggerState[iter.key()])
                return false;
        }
    }
    return true;
}

void SubThreadCheckWorker::configChecker(const QJsonArray &jsobj)
{
    m_constraint = jsobj;
    for(QJsonArray::Iterator iter = m_constraint.begin(); iter != m_constraint.end(); iter++)
    {
        if(iter->toObject().contains("constraint"))
        {
            QJsonObject consObj = iter->toObject()["constraint"].toObject();
            for(QJsonObject::Iterator iter2 = consObj.begin(); iter2 != consObj.end(); iter2++)
            {
                if(iter2.value().toObject().contains("comboJudge"))
                {
                    QJsonObject singleCons = iter2.value().toObject();
                    singleCons["value"] = iter2.key();
                    m_paramComboContraint[iter->toObject()["type"].toString()] = singleCons;
                }
                //add more
            }
        }
    }
}

void SubThreadCheckWorker::forceStop()
{
    m_bForceStop = true;
}

WorkflowCheckerController::WorkflowCheckerController(QObject* parent)
    :QObject(parent)
{
    SubThreadCheckWorker *worker = new SubThreadCheckWorker(NULL);
    worker->moveToThread(&m_thread);
    connect(&m_thread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &WorkflowCheckerController::runNewCheck, worker, &SubThreadCheckWorker::doCheck);
    connect(worker, &SubThreadCheckWorker::statusChanged, this, &WorkflowCheckerController::statusChanged);
    connect(this, &WorkflowCheckerController::configChecker, worker, &SubThreadCheckWorker::configChecker);
    connect(this, &WorkflowCheckerController::stopCheck, worker, &SubThreadCheckWorker::forceStop, Qt::DirectConnection);
    m_thread.start();
}
WorkflowCheckerController::~WorkflowCheckerController()
{
    if(m_thread.isRunning())
    {
        m_thread.quit();
        m_thread.wait();
    }
}
void WorkflowCheckerController::init(const QJsonArray& protoconConfig)
{
    emit configChecker(protoconConfig);
}

void WorkflowCheckerController::checkTask(const QJsonObject & jsObj)
{
    emit runNewCheck(jsObj);
}

void WorkflowCheckerController::stopCurrentCheck()
{
    if(m_thread.isRunning())
    {
        emit stopCheck();
    }
}

void WorkflowCheckerController::statusChanged(const QJsonObject &obj)
{
    CheckStateChangeEvent* userEvent = new CheckStateChangeEvent(obj);
    userEvent->m_status = obj;
    qApp->postEvent(qApp, userEvent);
}
