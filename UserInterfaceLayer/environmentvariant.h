#ifndef ENVIRONMENTVARIANT_H
#define ENVIRONMENTVARIANT_H

#include <QQmlContext>
#include <QMap>
#include <QString>
#include <QStringList>
#include <QJsonArray>
#include "workmodels.h"
#ifdef MINDGO_ALL_IN_ONE
#include "BussinessLayer/WorkflowProtocol/workflowprotocol.h"
#include "BussinessLayer/WorkflowProtocol/workflowChecker.h"
#else
#include "workflowprotocol.h"
#endif
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

    void calculateLicense(const QString& license);

    const QMap<QString, QStringList> & operationParamMap() {return m_operationParamMap;}

    QStringList OperationNameList();
    QStringList LogicalControlList();

    QJsonArray WorkPlaceConstraint(){return m_workPlaceConstraint;}

    QStringList PlanList();
    QStringList StepList(int planIndex );
    QStringList planSelectStepListModel(int planIndex);
    SingleOperationData planStepParam(int planIndex, int stepIndex);
    int planBoardConfig(int planIndex);
    void setPlanBoardConfig(int planIndex, int boardIndex);

    void AddPlanStep(int planIndex, int before, int operationIndex);
    void SetPlanStepToDefault(int planIndex, int stepIndex, int operationIndex);
    void SetPlanStepParam(int planIndex, int stepIndex, const QList<OperationParamData>& data);
    void SetPlanStepSingleParam(int planIndex, int stepIndex, const QString& paramName, const QVariant& value);
    void RemovePlanStep(int planIndex, int stepIndex);
    void MovePlanStep(int planIndex, int stepIndex, int newIndex);
    QString CopyPlanStep(int planIndex, int fromStepIndex, int toStepIndex);
    void copyStep(int planIndex, int stepIndex);
    void pasteStep(int planIndex, int stepIndex);

    void SetPlanName(int planIndex, const QString& name);
    void AddPlan(const QString& name);
    void RemovePlan(int planIndex);
    bool SavePlan();

    void StartPlan(int planIndex, int stepIndex);
    void StopPlan();
    void PausePlan();

    bool SaveMachineConfig(const MachineConfigData& data);

    void formatTipMotion(const SingleOperationData &, QJsonArray&);

    void StartTunning(const SingleOperationData& data);
    void runTask(const QJsonObject& task);
    void runTunning(const QJsonObject& tunning);

    WorkflowController& workFlow(){ return m_workFlow; }

    SingleOperationData defaultValue(const QString& Operationname);

    QJsonObject getWorkLocationTypeList();
    bool setWorkLocationType(int configIndex, int workPlaceIndex, const QString& type);

    bool updateWorkPlace(const QJsonObject &jsobj);
    bool removeBoardIndex(int index);

    bool isAdministrator(){return m_bAdministratorAccount.isAdministrator();}

    void startCheckPlan(int planIndex);
    void stopCheckPlan();

    int getBoardTypeIndexByPosition(int index);
    int getPlanBoardTypeIndexByPosition(int planIndex, int index);

    bool ImportConfig(const QString& file);
    bool ExportConfig(const QString& file);

    void reloadUserConfig();

signals:
    void workLocationTypeChanged();
private:
    EnvironmentVariant():m_context(0), m_bAdministratorAccount(this), m_machineConfig(this), m_workFlow(this) {}
    ~EnvironmentVariant() {}

    static EnvironmentVariant* m_instance;


    QQmlContext* m_context;
    QStringList m_operationList;
    QStringList m_controlOperationList;
    QMap<QString, QStringList> m_operationParamMap;
    QMap<QString, QString> m_operationNameDispMap;
    QMap<QString, QString> m_operationDispNameMap;
    QMap<QString, OperationParamData> m_paramDefaultValueMap;

    QList<SinglePlanData>  m_planList;

    QString m_configFilename;

    WorkflowController m_workFlow;
    WorkflowCheckerController m_workflowChecker;

    QString m_userConfigFile;

    TargetMachineObject m_machineConfig;
    ConfigFileConverter m_configFileConverter;
    QJsonObject m_workLocationTypeList;
    AdministratorChecker m_bAdministratorAccount;

    QJsonArray m_workPlaceConstraint;

    QString m_currentDir;

    SingleOperationData m_clipBoard;
};

#endif // ENVIRONMENTVARIANT_H
