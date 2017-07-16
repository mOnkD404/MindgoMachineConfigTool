#ifndef WORKFLOWCHECKER_H
#define WORKFLOWCHECKER_H

#include <QJsonObject>
#include <QThread>
#include <QEvent>
#include <QJsonArray>

#include "InfrastructureLayer/Communication/communication.h"


class SubThreadCheckWorker:public QObject
{
    Q_OBJECT
public:
    SubThreadCheckWorker(QObject*parent);
    ~SubThreadCheckWorker();


public slots:
    void doCheck(const QJsonObject&);
    void configChecker(const QJsonArray&);
    void forceStop();

signals:
    void statusChanged(const QJsonObject& );

protected:
    bool CheckBoardConstraint(const QJsonObject&);
    bool CheckParamConstraint(const QJsonObject&);

private:
    bool m_bForceStop;
    QJsonArray m_constraint;
    QJsonArray m_boardConfig;
    QJsonObject m_paramComboContraint;
    QMap<QString, int> m_paramComboConstraintTriggerState;
};

class WorkflowCheckerController: public QObject
{
    Q_OBJECT
public:
    WorkflowCheckerController(QObject* parent = NULL);
    ~WorkflowCheckerController();
    void init(const QJsonArray& protocolConfig);

    void checkTask(const QJsonObject & jsObj);
    void stopCurrentCheck();

signals:
    void runNewCheck(const QJsonObject&);
    void stopCheck();
    void configChecker(const QJsonArray&);

public slots:
    void statusChanged(const QJsonObject &obj);

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
