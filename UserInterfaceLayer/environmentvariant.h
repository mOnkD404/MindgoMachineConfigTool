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

    const QMap<QString, QStringList> & operationParamMap() {return m_operationParamMap;}

    const QStringList OperationNameList();

    QJsonObject formatSingleOperationParam(const SingleOperationObject & obj);

    void runTask(const QJsonObject& task);

    WorkflowController& workFlow(){ return m_workFlow; }

private:
    EnvironmentVariant():m_context(0) {}
    ~EnvironmentVariant() {}

    static EnvironmentVariant* m_instance;


    QQmlContext* m_context;
    QStringList m_operationList;
    QMap<QString, QStringList> m_operationParamMap;
    QMap<QString, QString> m_operationNameDispMap;
    QMap<QString, QString> m_operationDispNameMap;
    QMap<QString, OperationParamData> m_paramDefaultValueMap;
    QString m_configFilename;

    WorkflowController m_workFlow;

    QString m_userConfigFile;
    QString m_targetIp;
    qint16 m_targetPort;

};

#endif // ENVIRONMENTVARIANT_H
