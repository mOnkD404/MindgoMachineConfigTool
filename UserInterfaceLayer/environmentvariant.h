#ifndef ENVIRONMENTVARIANT_H
#define ENVIRONMENTVARIANT_H

#include <QQmlContext>
#include <QMap>
#include <QString>
#include <QStringList>
#include "workmodels.h"
#include "workflowprotocol.h"

class EnvironmentVariant
{
public:
    static EnvironmentVariant* instance();

    void parseConfigFile(const QString& );
    void initProtocol(const QString&);
    void initUserConfig(const QString&);
    void initModels(QQmlContext* context);
    QQmlContext* context(){return m_context;}
    //void changeModel(const QString& pagename, const QString& modelname, const QString& opname);
    QList<OperationParamData> getOperationParams(int index);
    int getOperationIndex(const QString& name);

    const QMap<QString, QStringList> & operationParamMap() {return m_operationParamMap;}

    QStringList OperationNameList();
    QStringList LogicalControlList();

    QStringList PlanList();
    QStringList StepList(int planIndex );
    SingleOperationData planStepParam(int planIndex, int stepIndex);

    void AddPlanStep(int planIndex, int before, int operationIndex);
    void SetPlanStepToDefault(int planIndex, int stepIndex, int operationIndex);
    void SetPlanStepParam(int planIndex, int stepIndex, const QList<OperationParamData>& data);
    void RemovePlanStep(int planIndex, int stepIndex);
    void MovePlanStep(int planIndex, int stepIndex, int newIndex);
    void SetPlanName(int planIndex, const QString& name);
    void AddPlan(const QString& name);
    void RemovePlan(int planIndex);
    void SavePlan();

    void StartPlan(int planIndex);
    void StopPlan();

    void SaveIpAddress(const QString& , qint16);


    QJsonObject formatSingleOperationParam(const SingleOperationData & obj);

    void runTask(const QJsonObject& task);

    WorkflowController& workFlow(){ return m_workFlow; }

    SingleOperationData defaultValue(const QString& Operationname);

private:
    EnvironmentVariant():m_context(0) {}
    ~EnvironmentVariant() {}

    static EnvironmentVariant* m_instance;


    QQmlContext* m_context;
    QStringList m_operationList;
    QStringList m_controlOperationList;
    QMap<QString, QStringList> m_operationParamMap;
    QMap<QString, QString> m_operationNameDispMap;
    QMap<QString, QString> m_operationDispNameMap;
    QMap<QString, OperationParamData> m_paramDefaultValueMap;

    QList<QPair<QString, QList<SingleOperationData> > >  m_planList;

    QString m_configFilename;

    WorkflowController m_workFlow;

    QString m_userConfigFile;

    IpAddressObject m_targetIp;
};

#endif // ENVIRONMENTVARIANT_H
