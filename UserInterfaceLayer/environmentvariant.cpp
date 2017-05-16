#include "environmentvariant.h"
#include <QObject>
#include "configfilehandler.h"
#include "workmodels.h"
#include <QJsonArray>
#include <QJsonDocument>

EnvironmentVariant* EnvironmentVariant::m_instance = 0;

EnvironmentVariant* EnvironmentVariant::instance()
{
    if (m_instance == 0)
    {
        m_instance = new EnvironmentVariant;
    }
    return m_instance;
}

void EnvironmentVariant::parseConfigFile(const QString& str)
{
    m_configFilename = str;

    configFileHandler handler(NULL);
    handler.loadConfigFile(m_configFilename);
    m_operationList = handler.toList("OperationEnum");
    m_logicalControlList = handler.toList("LogicalControlEnum");

    m_operationParamMap = handler.ParseListMap("NormalOperation");
    QMap<QString, QStringList> controls = handler.ParseListMap("logicalControl");
    for(QMap<QString, QStringList>::ConstIterator iter = controls.begin(); iter != controls.end(); iter++)
    {
        m_operationParamMap[iter.key()] = iter.value();
    }

    m_operationNameDispMap = handler.ParseMap("Operation Display Name");
    m_operationDispNameMap = handler.ParseMapRevertKeyValue("Operation Display Name");
    m_paramDefaultValueMap = handler.ParseParamValue("params");
}

void EnvironmentVariant::initProtocol(const QString &protoconConfig)
{
     m_workFlow.init(protoconConfig);
     m_workFlow.sethost(m_targetIp, m_targetPort);
}

void EnvironmentVariant::initUserConfig(const QString &str)
{
    m_userConfigFile = str;
    configFileHandler handler(NULL);
    handler.loadConfigFile(str);
    m_targetIp = handler.ParseHostIP();
    m_targetPort = handler.ParseHostPort();

    handler.ParsePlanList(m_planList, m_paramDefaultValueMap);
}

void EnvironmentVariant::initModels(QQmlContext* context)
{
    m_context = context;
    //m_singleStepPageModel.init(context, m_operationList, m_operationNameDispMap);
}


//void EnvironmentVariant::changeModel(const QString& pagename, const QString& modelname, const QString& opname)
//{
//    if (pagename == "SingleStepPage")
//    {
//        if (modelname == "ParamModel")
//        {
//            QList<OperationParamData> opList;
//            if (m_operationDispNameMap.contains(opname) && m_operationParamMap.contains(m_operationDispNameMap[opname]))
//            {
//                foreach(const QString& parmname, m_operationParamMap[m_operationDispNameMap[opname]])
//                {
//                    if (m_paramDefaultValueMap.contains(parmname))
//                    {
//                        opList.append(m_paramDefaultValueMap[parmname]);
//                    }

//                }
//            }
//            m_singleStepPageModel.ParamModel().resetParams(opList);
//        }
//    }
//}

QList<OperationParamData> EnvironmentVariant::getOperationParams(int index)
{
    QList<OperationParamData> parmList;
    if (index >= 0 && index < m_operationList.size())
    {
        foreach(const QString& parmname, m_operationParamMap[m_operationList[index]])
        {
            if (m_paramDefaultValueMap.contains(parmname))
            {
                parmList.append(m_paramDefaultValueMap[parmname]);
            }

        }
    }
    else if (index >= m_operationList.size() && index < m_operationList.size() + m_logicalControlList.size())
    {
        foreach(const QString& parmname, m_operationParamMap[m_logicalControlList[index - m_operationList.size()]])
        {
            if (m_paramDefaultValueMap.contains(parmname))
            {
                parmList.append(m_paramDefaultValueMap[parmname]);
            }

        }
    }
    return parmList;
}

int EnvironmentVariant::getOperationIndex(const QString& name)
{
    for (int index = 0; index < m_operationList.size(); index++)
    {
        if(name == m_operationList[index])
            return index;
    }
    return -1;
}

QStringList EnvironmentVariant::OperationNameList()
{
    QStringList strlist;
    foreach (const QString& str, m_operationList)
    {
        if(m_operationNameDispMap.contains(str))
        {
            strlist.append(m_operationNameDispMap[str]);
        }
    }
    return strlist;
}

QStringList EnvironmentVariant::LogicalControlList()
{
    QStringList strlist;
    foreach (const QString& str, m_logicalControlList)
    {
        if(m_operationNameDispMap.contains(str))
        {
            strlist.append(m_operationNameDispMap[str]);
        }
    }
    return strlist;
}


QStringList EnvironmentVariant::PlanList()
{
    QStringList strlist;
    for(QList<QPair<QString, QList<SingleOperationData> > >::Iterator iter = m_planList.begin(); iter != m_planList.end(); iter++)
    {
        strlist.append(iter->first);
    }
    return strlist;
}

QStringList EnvironmentVariant::StepList(int planIndex)
{
    QStringList steplist;
    if(planIndex >= 0 && planIndex < m_planList.size())
    {
        const QList<SingleOperationData> & data = m_planList[planIndex].second;
        foreach (const SingleOperationData& pda, data)
        {
            steplist.append(pda.operationName);
        }
    }
    return steplist;
}

SingleOperationData EnvironmentVariant::planStepParam(int planIndex, int stepIndex)
{
    SingleOperationData retData;
    if (planIndex < 0 || planIndex >= m_planList.size())
        return retData;

    const QPair<QString, QList<SingleOperationData> > & plan = m_planList[planIndex];
    if(stepIndex < 0 || stepIndex >= plan.second.size())
        return retData;

    if(!m_operationParamMap.contains(plan.second[stepIndex].operationName))
        return retData;

    retData = defaultValue(plan.second[stepIndex].operationName);

    const QList<OperationParamData> & paramData = plan.second[stepIndex].params;
    foreach(const OperationParamData& realData, paramData)
    {
        for(int index = 0; index < retData.params.size(); index++)
        {
            OperationParamData defaultData = retData.params.at(index);
            if (defaultData.Name == realData.Name)
            {
                if(defaultData.Type == "integer")
                {
                    defaultData.IntegerValue = realData.IntegerValue;
                }
                else if(defaultData.Type == "float")
                {
                    defaultData.FloatValue = realData.FloatValue;
                }
                else if (defaultData.Type == "bool")
                {
                    defaultData.BoolValue = realData.BoolValue;
                }
            }
            retData.params[index] = defaultData;
        }
    }
    return retData;
}

QJsonObject EnvironmentVariant::formatSingleOperationParam(const SingleOperationData & obj)
{
    QJsonObject opObj;
    QJsonObject singleOperationObj;
    singleOperationObj["operation"] = m_operationDispNameMap[obj.operationName];
    singleOperationObj["sequence number"] = QJsonValue(obj.sequenceNumber);
    QJsonObject paramobj;
    foreach(const OperationParamData& data, obj.params)
    {

            if (data.Type == "enum")
            {
                paramobj[data.Name] = data.IntListValue[data.IntegerValue];
            }
            else if(data.Type == "integer")
            {
                paramobj[data.Name] = data.IntegerValue;
            }
            else if(data.Type == "float")
            {
                paramobj[data.Name] = static_cast<int>(data.FloatValue*10.0);
            }

    }
    singleOperationObj["params"] = paramobj;


    QJsonArray oparray;
    oparray.append(singleOperationObj);
    opObj["operations"] = oparray;


    return opObj;
}

void EnvironmentVariant::runTask(const QJsonObject &task)
{
     m_workFlow.sethost(m_targetIp, m_targetPort);
     m_workFlow.runTask(task);
}

void EnvironmentVariant::AddPlanStep(int planIndex, int before, const QString &opName)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > plan = m_planList[planIndex];

    SingleOperationData data = defaultValue(opName);

    if(before < 0 || before > plan.second.size())
    {
        plan.second.append(data);
    }
    else
    {
        plan.second.insert(before, data);
    }

    m_planList[planIndex] = plan;
}


SingleOperationData EnvironmentVariant::defaultValue(const QString& Operationname)
{
    if(m_operationParamMap.contains(Operationname))
    {
        SingleOperationData data;
        data.operationName = Operationname;
        const QStringList &paramList = m_operationParamMap[Operationname];
        foreach (const QString& str, paramList)
        {
            if(m_paramDefaultValueMap.contains(str))
            {
                data.params.append(m_paramDefaultValueMap[str]);
            }
        }
        return data;
    }
    return SingleOperationData();
}
