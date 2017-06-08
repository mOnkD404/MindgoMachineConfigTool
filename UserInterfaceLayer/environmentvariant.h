#ifndef ENVIRONMENTVARIANT_H
#define ENVIRONMENTVARIANT_H

#include <QQmlContext>
#include <QMap>
#include <QString>
#include <QStringList>
#include "workmodels.h"
#include "workflowprotocol.h"

class EnvironmentVariant: public QObject
{
    Q_OBJECT
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
    void SetPlanStepSingleParam(int planIndex, int stepIndex, const QString& paramName, const QVariant& value);
    void RemovePlanStep(int planIndex, int stepIndex);
    void MovePlanStep(int planIndex, int stepIndex, int newIndex);
    void SetPlanName(int planIndex, const QString& name);
    void AddPlan(const QString& name);
    void RemovePlan(int planIndex);
    void SavePlan();

    void StartPlan(int planIndex, int stepIndex);
    void StopPlan();

    void SaveMachineConfig(const MachineConfigData& data);


    QJsonObject formatSingleOperationParam(const SingleOperationData & obj);

    void StartTunning(const SingleOperationData& data);
    void runTask(const QJsonObject& task);
    void runTunning(const QJsonObject& tunning);

    WorkflowController& workFlow(){ return m_workFlow; }

    SingleOperationData defaultValue(const QString& Operationname);

    QStringList getWorkLocationTypeList();
    bool setWorkLocationType(int index, const QString& type);

    bool isAdministrator(){return m_bAdministratorAccount;}

signals:
    void workLocationTypeChanged();
private:
    EnvironmentVariant():m_context(0), m_bAdministratorAccount(false), m_machineConfig(this), m_workFlow(this) {}
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

    TargetMachineObject m_machineConfig;
    QStringList m_workLocationTypeList;
    bool m_bAdministratorAccount;
};

#endif // ENVIRONMENTVARIANT_H
