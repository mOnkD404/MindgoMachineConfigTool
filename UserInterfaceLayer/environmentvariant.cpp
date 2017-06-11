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
    m_controlOperationList = m_operationList;
    m_controlOperationList.append(handler.toList("LogicalControlEnum"));

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
     m_workFlow.sethost(m_machineConfig.getIpAddress(), m_machineConfig.getPort());
}

void EnvironmentVariant::initUserConfig(const QString &str)
{
    m_userConfigFile = str;
    configFileHandler handler(NULL);
    handler.loadConfigFile(str);
    m_machineConfig.init(handler.ParseHostIP(), handler.ParseHostPort(), handler.ParseHostSingleOperationThreshold());

    handler.ParsePlanList(m_planList, m_paramDefaultValueMap);
    handler.ParseWorkLocationTypeList(m_workLocationTypeList);

    //2328-1768-0720-4852
    const uchar preCalculatedSha1[20] = {
        (uchar)0x9d,(uchar)0x1d,(uchar)0xa4,(uchar)0x38,(uchar)0x9a,(uchar)0x40,(uchar)0xd1,(uchar)0xd0,(uchar)0x9e,(uchar)0xc5,
        (uchar)0x44,(uchar)0xa1,(uchar)0xb2,(uchar)0xdd,(uchar)0x1e,(uchar)0xa0,(uchar)0xba,(uchar)0xb5,(uchar)0xc2,(uchar)0x79
    };
    QByteArray Sha1;
    handler.ParseLicense(Sha1);
    if( 0 == memcmp(Sha1.data(), preCalculatedSha1, 20))
    {
        m_bAdministratorAccount = true;
    }
    else
    {
        m_bAdministratorAccount = false;
    }
}

void EnvironmentVariant::initModels(QQmlContext* context)
{
    m_context = context;
    context->setContextProperty("IPAddressObject", &m_machineConfig);
    context->setContextProperty("isAdministratorAccount", m_bAdministratorAccount);
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

    if (index >= 0 && index < m_controlOperationList.size())
    {
        foreach(const QString& parmname, m_operationParamMap[m_controlOperationList[index]])
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
    foreach (const QString& str, m_controlOperationList)
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
            if(m_operationNameDispMap.contains(pda.operationName))
            {
                steplist.append(m_operationNameDispMap[pda.operationName]);
            }
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

    for(int index = 0; index < retData.params.size(); index++)
    {
        OperationParamData defaultData = retData.params.at(index);
        foreach(const OperationParamData& realData, paramData)
        {
            if (defaultData.Name == realData.Name)
            {
                defaultData.IntegerValue = realData.IntegerValue;
                defaultData.FloatValue = realData.FloatValue;
                defaultData.BoolValue = realData.BoolValue;
                defaultData.StringValue = realData.StringValue;

                retData.params[index] = defaultData;
                break;
            }
        }
    }
    return retData;
}

QJsonObject EnvironmentVariant::formatSingleOperationParam(const SingleOperationData & obj)
{
    QJsonObject opObj;
    QJsonObject singleOperationObj;
    singleOperationObj["operation"] = m_operationDispNameMap[obj.operationName];
    singleOperationObj["sequence"] = QJsonValue(0xffff);//QJsonValue(obj.sequenceNumber);
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
                paramobj[data.Name] = qRound(data.FloatValue*10.0);
            }
            else if(data.Type == "string")
            {
                paramobj[data.Name] = data.StringValue;
            }
            else if(data.Type == "bool")
            {
                paramobj[data.Name] = (int)data.BoolValue;
            }

    }
    singleOperationObj["params"] = paramobj;


//    QJsonArray oparray;
//    oparray.append(singleOperationObj);
    opObj["operation"] = singleOperationObj;
    opObj["maxReceiveTime"] = m_machineConfig.maxReceiveTime;
//    opObj["startIndex"] = 0;

    return opObj;
}


void EnvironmentVariant::StartTunning(const SingleOperationData& data)
{
    QJsonObject operationObj = EnvironmentVariant::instance()->formatSingleOperationParam(data);

    EnvironmentVariant::instance()->runTunning(operationObj);
}

void EnvironmentVariant::runTask(const QJsonObject &task)
{
     m_workFlow.sethost(m_machineConfig.getIpAddress(), m_machineConfig.getPort());
     m_workFlow.runTask(task);
}

void EnvironmentVariant::runTunning(const QJsonObject& tunning)
{
    m_workFlow.sethost(m_machineConfig.getIpAddress(), m_machineConfig.getPort());
    m_workFlow.runTunning(tunning);
}

void EnvironmentVariant::AddPlanStep(int planIndex, int before, int operationIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > plan = m_planList[planIndex];

    SingleOperationData data = defaultValue(m_controlOperationList[operationIndex]);

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

void EnvironmentVariant::RemovePlanStep(int planIndex, int stepIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.second.size())
    {
        plan.second.removeAt(stepIndex);
    }
}

void EnvironmentVariant::MovePlanStep(int planIndex, int stepIndex, int newIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.second.size() && newIndex >=0 && newIndex < plan.second.size())
    {
        SingleOperationData data = plan.second.at(stepIndex);
        plan.second.removeAt(stepIndex);
        plan.second.insert(newIndex, data);
    }
}

void EnvironmentVariant::SetPlanStepToDefault(int planIndex, int stepIndex, int operationIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.second.size())
    {
        SingleOperationData data = defaultValue(m_controlOperationList[operationIndex]);
        plan.second[stepIndex] = data;
        //m_planList[planIndex] = plan;
    }

}

void EnvironmentVariant::SetPlanStepParam(int planIndex, int stepIndex, const QList<OperationParamData>& data)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.second.size())
    {
        plan.second[stepIndex].params = data;
    }
}


void EnvironmentVariant::SetPlanStepSingleParam(int planIndex, int stepIndex, const QString& paramName, const QVariant& value)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > &plan = m_planList[planIndex];

    if(stepIndex < 0 || stepIndex >= plan.second.size())
        return;

    QList<OperationParamData> & params = plan.second[stepIndex].params;

    for(QList<OperationParamData>::Iterator iterdata = params.begin(); iterdata != params.end(); iterdata++)
    {
        if(iterdata->Name == paramName)
        {
            if(iterdata->Type == "integer" || iterdata->Type == "enum")
            {
                iterdata->IntegerValue = value.toInt();
            }
            else if(iterdata->Type == "float")
            {
                iterdata->FloatValue = value.toDouble();
            }
            else if(iterdata->Type == "bool")
            {
                iterdata->BoolValue = value.toBool();
            }

            break;
        }
    }
}

void EnvironmentVariant::SetPlanName(int planIndex, const QString &name)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    QPair<QString, QList<SingleOperationData> > &plan = m_planList[planIndex];

    plan.first = name;
}

void EnvironmentVariant::AddPlan(const QString &name)
{
    m_planList.append(qMakePair(name, QList<SingleOperationData>()));
}

void EnvironmentVariant::RemovePlan(int planIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    m_planList.removeAt(planIndex);
}

void EnvironmentVariant::SavePlan()
{
    configFileHandler handler(NULL);
    handler.SavePlanList(m_userConfigFile, m_planList, m_operationParamMap);
}

void EnvironmentVariant::SaveMachineConfig(const MachineConfigData& data)
{
    configFileHandler handler(NULL);
    handler.SaveMachineConfig(m_userConfigFile, data, m_workLocationTypeList);

    //todo
    m_machineConfig.setIpAddress(data.IpAddress);
    m_machineConfig.setPort(data.port);
    m_machineConfig.setMaxReceiveTime(data.maxReceiveTime);
}

void EnvironmentVariant::StartPlan(int planIndex, int stepIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    const QList<SingleOperationData> & stepList = m_planList.at(planIndex).second;


    QJsonObject planObj;
    QJsonArray oparray;
    int seq = 1;
    foreach(const SingleOperationData& opData, stepList)
    {
        QJsonObject singleOperationObj;
        singleOperationObj["operation"] = opData.operationName;
        singleOperationObj["sequence"] = seq++;
        QJsonObject paramobj;
        foreach(const OperationParamData& data, opData.params)
        {
            if (data.Type == "enum")
            {
                paramobj[data.Name] = m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];
            }
            else if(data.Type == "integer")
            {
                paramobj[data.Name] = data.IntegerValue;
            }
            else if(data.Type == "float")
            {
                paramobj[data.Name] = qRound(data.FloatValue*10.0);
            }
            else if(data.Type == "string")
            {
                paramobj[data.Name] = data.StringValue;
            }
            else if(data.Type == "bool")
            {
                paramobj[data.Name] = data.BoolValue;
            }
        }
        singleOperationObj["params"] = paramobj;

        oparray.append(singleOperationObj);

    }
    planObj["operations"] = oparray;
    planObj["maxReceiveTime"] = m_machineConfig.maxReceiveTime;
    planObj["startIndex"] = stepIndex;

    runTask(planObj);
}

void EnvironmentVariant::StopPlan()
{
    m_workFlow.stopCurrentTask();
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

QStringList EnvironmentVariant::getWorkLocationTypeList()
{
    return m_workLocationTypeList;
}

bool EnvironmentVariant::setWorkLocationType(int index, const QString& type)
{
    if(index < 0 || index >= m_workLocationTypeList.size())
        return false;
    if(m_workLocationTypeList[index] == type)
    {
        return false;
    }
    else
    {
        m_workLocationTypeList[index] = type;
        emit workLocationTypeChanged();
        return true;
    }
}
