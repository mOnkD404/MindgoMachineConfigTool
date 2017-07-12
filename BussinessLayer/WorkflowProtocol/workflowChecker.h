#ifndef WORKFLOWCHECKER_H
#define WORKFLOWCHECKER_H

#include <QJsonObject>
#include <QThread>
#include <QEvent>

#include "InfrastructureLayer/Communication/communication.h"


class SubThreadCheckWorker:public QObject
{
    Q_OBJECT
public:
    SubThreadCheckWorker(QObject*parent);
    ~SubThreadCheckWorker();


public slots:
    void doCheck(const QJsonObject&);
    void configChecker(const QJsonObject&);

signals:
    void statusChanged(const QJsonObject& );

protected:


private:
};

class WorkflowCheckerController: public QObject
{
    Q_OBJECT
public:
    WorkflowCheckerController(QObject* parent = NULL);
    ~WorkflowCheckerController();
    void init(const QJsonObject& protocolConfig);

    void checkTask(const QJsonObject & jsObj);
    void stopCurrentCheck();

signals:
    void runNewCheck(const QJsonObject&);
    void stopCheck();
    void configChecker(const QJsonObject&);
    void statusChanged(const QJsonObject&);

public slots:
    void taskStateChanged(bool running, int index);

protected:
    QThread m_thread;
};

class CheckStateChangeEvent: public QEvent
{
public:
    CheckStateChangeEvent(const QJsonObject &status)
        :QEvent(static_cast<QEvent::Type>(QEvent::User+3)), m_status(status)
    {

    }
    QJsonObject m_status;
};


#endif // WORKFLOWPROTOCOL_H
