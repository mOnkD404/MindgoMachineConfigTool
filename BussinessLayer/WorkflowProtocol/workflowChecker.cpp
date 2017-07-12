#include"workflowChecker.h"

SubThreadCheckWorker::SubThreadCheckWorker(QObject*parent)
    :QObject(parent)
{

}

SubThreadCheckWorker::~SubThreadCheckWorker()
{

}

void SubThreadCheckWorker::doCheck(const QJsonObject&)
{

}

void SubThreadCheckWorker::configChecker(const QJsonObject&)
{

}

WorkflowCheckerController::WorkflowCheckerController(QObject* parent)
{
    SubThreadCheckWorker *worker = new SubThreadCheckWorker(NULL);
    worker->moveToThread(&m_thread);
    connect(&m_thread, &QThread::finished, worker, &QObject::deleteLater);
    connect(this, &WorkflowCheckerController::runNewCheck, worker, &SubThreadCheckWorker::doCheck);
    connect(worker, &SubThreadCheckWorker::statusChanged, this, &WorkflowCheckerController::statusChanged);
    connect(this, &WorkflowCheckerController::configChecker, worker, &SubThreadCheckWorker::configChecker);
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
void WorkflowCheckerController::init(const QJsonObject& protoconConfig)
{
    emit configChecker(protoconConfig);
}

void WorkflowCheckerController::checkTask(const QJsonObject & jsObj)
{
    emit runNewCheck(jsObj);
}

void WorkflowCheckerController::stopCurrentCheck()
{
    //todo
}

void WorkflowCheckerController::taskStateChanged(bool running, int index)
{
    //todo
}

