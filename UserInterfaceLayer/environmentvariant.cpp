#include "environmentvariant.h"
#include <QObject>
#include "configfilehandler.h"
#include "workmodels.h"
#include <QJsonArray>
#include <QJsonDocument>
#include <QDir>
#include <QCryptographicHash>

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
    m_workPlaceConstraint = handler.ParseWorkPlaceConstraint();

    m_workflowChecker.init(m_workPlaceConstraint);
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
    m_machineConfig.init(handler.ParseHostIP(), handler.ParseHostPort(), handler.ParseHostSingleOperationThreshold(), handler.GetLicense());

    handler.ParsePlanList(m_planList, m_paramDefaultValueMap);
    handler.ParseWorkSpaceTypeList(m_workLocationTypeList);

    calculateLicense(m_machineConfig.licenseNumber);
}

void EnvironmentVariant::calculateLicense(const QString& license)
{
    QByteArray encodedString;
    QByteArray licenseStr(license.toLocal8Bit());

    QCryptographicHash hash(QCryptographicHash::Sha1);
    encodedString = hash.hash(licenseStr, QCryptographicHash::Sha1);

    //2328-1768-0720-4852
    const uchar preCalculatedSha1[20] = {
        (uchar)0x9d,(uchar)0x1d,(uchar)0xa4,(uchar)0x38,(uchar)0x9a,(uchar)0x40,(uchar)0xd1,(uchar)0xd0,(uchar)0x9e,(uchar)0xc5,
        (uchar)0x44,(uchar)0xa1,(uchar)0xb2,(uchar)0xdd,(uchar)0x1e,(uchar)0xa0,(uchar)0xba,(uchar)0xb5,(uchar)0xc2,(uchar)0x79
    };
    if( 0 == memcmp(encodedString.data(), preCalculatedSha1, 20))
    {
        m_bAdministratorAccount.setAdministrator(true);
    }
    else
    {
        m_bAdministratorAccount.setAdministrator(false);
    }
}

void EnvironmentVariant::initModels(QQmlContext* context)
{
    m_context = context;
    m_currentDir = QDir::currentPath();
    context->setContextProperty("machineConfigObject", &m_machineConfig);
    context->setContextProperty("administratorChecker", &m_bAdministratorAccount);
    context->setContextProperty("currentDirectory", m_currentDir);
    context->setContextProperty("configFileConverter", &m_configFileConverter);
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
    for(QList<SinglePlanData>::Iterator iter = m_planList.begin(); iter != m_planList.end(); iter++)
    {
        strlist.append(iter->planName);
    }
    return strlist;
}

QStringList EnvironmentVariant::StepList(int planIndex)
{
    QStringList steplist;
    if(planIndex >= 0 && planIndex < m_planList.size())
    {
        const QList<SingleOperationData> & data = m_planList[planIndex].operations;
        foreach (const SingleOperationData& pda, data)
        {
            if(m_operationNameDispMap.contains(pda.operationName))
            {
                if(pda.operationName == "Group")
                {
                    QString groupName;
                    foreach( const OperationParamData& param, pda.params)
                    {
                        if(param.Name == "GroupName")
                        {
                            groupName = param.StringValue;
                            break;
                        }
                    }
                    steplist.append(m_operationNameDispMap[pda.operationName]+"["+groupName+"]");
                }
                else
                {
                    steplist.append(m_operationNameDispMap[pda.operationName]);
                }
            }
        }
    }
    return steplist;
}

QStringList EnvironmentVariant::planSelectStepListModel(int planIndex)
{
    QStringList steplist;
    int loopStack = 0;
    int currentIndex = 0;
    if(planIndex >= 0 && planIndex < m_planList.size())
    {
        const QList<SingleOperationData> & data = m_planList[planIndex].operations;
        foreach (const SingleOperationData& pda, data)
        {
            if(m_operationNameDispMap.contains(pda.operationName))
            {
                if ( loopStack == 0)
                {
                    if(pda.operationName == "Group")
                    {
                        QString groupName;
                        foreach( const OperationParamData& param, pda.params)
                        {
                            if(param.Name == "GroupName")
                            {
                                groupName = param.StringValue;
                                break;
                            }
                        }
                        steplist.append(QString::number(currentIndex+1) + ". "+m_operationNameDispMap[pda.operationName]+"["+groupName+"]");
                    }
                    else
                    {
                        steplist.append(QString::number(currentIndex+1) + ". "+m_operationNameDispMap[pda.operationName]);
                    }

                }
                currentIndex++;

                if(pda.operationName == "Loop")
                {
                    loopStack ++;
                }
                else if(pda.operationName == "EndLoop" && loopStack > 0)
                {
                    loopStack--;
                }

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

    const SinglePlanData & plan = m_planList[planIndex];
    if(stepIndex < 0 || stepIndex >= plan.operations.size())
        return retData;

    if(!m_operationParamMap.contains(plan.operations[stepIndex].operationName))
        return retData;

    retData = defaultValue(plan.operations[stepIndex].operationName);

    const QList<OperationParamData> & paramData = plan.operations[stepIndex].params;

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

int EnvironmentVariant::planBoardConfig(int planIndex)
{
    if(planIndex >= 0 && planIndex < m_planList.size())
    {
        QJsonArray boardList =  m_workLocationTypeList["config"].toArray();
        if(m_planList.at(planIndex).boardConfig >= boardList.size())
        {
            m_planList[planIndex].boardConfig = 0;
        }
        return m_planList.at(planIndex).boardConfig;
    }
    return 0;
}


void EnvironmentVariant::setPlanBoardConfig(int planIndex, int boardIndex)
{
    if(planIndex >= 0 && planIndex < m_planList.size())
    {
        if(m_planList[planIndex].boardConfig != boardIndex)
        {
            m_planList[planIndex].boardConfig = boardIndex;
        }
    }
}

void EnvironmentVariant::formatTipMotion(const SingleOperationData & obj, QJsonArray& oplist)
{
    int sequence = obj.sequenceNumber;
    QString tipPositionCmd;
    int loadTipBoard = 0;
    int suctionBoard = 0;
    int dispenseBoard = 0;
    int dumpBoard = 0;
    int suctionSpeed = 0;
    int dispenseSpeed = 0;
    int loadTipIndex = 0;
    int preSuctionVolume = 0;
    int postSuctionVolume = 0;
    int suctionHeight = 0;
    int drainHeight = 0;
    int postSuctionWaitTime= 0;
    int preDispenseWaitTIme = 0;

    foreach(const OperationParamData& data, obj.params)
    {
        if(data.Name == "motionSequence")
        {
            tipPositionCmd = data.StringValue;
        }
        else if(data.Name == "loadTipIndex")
        {
            loadTipIndex = data.IntegerValue;
        }
        else if(data.Name == "loadTipBoard")
        {
            loadTipBoard = m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];;
        }
        else if(data.Name == "sunctionBoard")
        {
            suctionBoard =m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];;
        }
        else if(data.Name == "dispenseBoard")
        {
            dispenseBoard = m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];;
        }
        else if(data.Name == "dumpTipBoard")
        {
            dumpBoard = m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];;
        }
        else if(data.Name == "sunctionSpeed")
        {
            suctionSpeed = m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];;
        }
        else if(data.Name == "dispenseSpeed")
        {
            dispenseSpeed = m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];;
        }
        else if(data.Name == "preSuctionVolume")
        {
            preSuctionVolume = data.IntegerValue;
        }
        else if(data.Name == "postSuctionVolume")
        {
            postSuctionVolume = data.IntegerValue;
        }
        else if(data.Name == "suctionHeight")
        {
            suctionHeight = (int)(data.FloatValue*data.Factor);
        }
        else if(data.Name == "drainHeight")
        {
            drainHeight =  (int)(data.FloatValue*data.Factor);
        }
        else if(data.Name == "postSuctionWaitTime")
        {
            postSuctionWaitTime = (int)(data.FloatValue*data.Factor);
        }
        else if(data.Name == "preDispenseWaitTime")
        {
            preDispenseWaitTIme =  (int)(data.FloatValue*data.Factor);
        }
    }

    QStringList lines = tipPositionCmd.split('\n');
    for(QStringList::iterator iter = lines.begin(); iter != lines.end(); iter++)
    {
        if(iter->size() > 0)
        {
            if (iter->at(iter->size()-1) == '\r')
            {
                iter->resize(iter->size()-1);
            }
        }
    }

    for(int lineIndex = 0; lineIndex < lines.size(); lineIndex++)
    {
        const QString& line = lines[lineIndex];
        QStringList words = line.split(',');
        if(words.size() == 3)
        {
            int suctionOnBoardIndex = words.at(0).toInt();
            int dispenseOnBoardIndex = words.at(1).toInt();
            int volume = words.at(2).toInt();

            if(suctionOnBoardIndex == 0 || dispenseOnBoardIndex == 0 || volume == 0)
            {
                continue;
            }

            //1.装载
            {
                QJsonObject opData;
                QJsonObject opParams;
                opData["operation"] = "Load Tip";
                opData["sequence"] = sequence;

                opParams["boardType"] = m_paramDefaultValueMap["boardType"].IntListValue[getBoardTypeIndexByPosition(loadTipBoard)];
                opParams["position"] = loadTipBoard;
                opParams["tipIndex"] = 96;
                opParams["onBoardIndex"] = loadTipIndex+lineIndex;

                opData["params"] = opParams;

                QJsonObject opObj;
                opObj["operation"] = opData;
                opObj["maxReceiveTime"] = m_machineConfig.maxReceiveTime;

                oplist.append(opData);
            }

            //2.吸液
            {
                QJsonObject opData;
                QJsonObject opParams;
                opData["operation"] = "Suction";
                opData["sequence"] = sequence;

                opParams["speed"] = suctionSpeed;
                opParams["boardType"] = m_paramDefaultValueMap["boardType"].IntListValue[getBoardTypeIndexByPosition(suctionBoard)];
                opParams["position"] = suctionBoard;
                opParams["tipIndex"] = 96;
                opParams["onBoardIndex"] = suctionOnBoardIndex;
                opParams["preSuction"] = 1;
                opParams["preSuctionVolume"] = preSuctionVolume;
                opParams["postSuction"] = 1;
                opParams["postSuctionVolume"] = postSuctionVolume;
                opParams["volume"] = volume;
                opParams["suctionHeight"] = suctionHeight;
                opParams["postSuctionWaitTime"] = postSuctionWaitTime;

                opData["params"] = opParams;

                oplist.append(opData);
            }

            //3.排液
            {
                QJsonObject opData;
                QJsonObject opParams;
                opData["operation"] = "Dispense";
                opData["sequence"] = sequence;

                opParams["speed"] = dispenseSpeed;
                opParams["boardType"] = m_paramDefaultValueMap["boardType"].IntListValue[getBoardTypeIndexByPosition(dispenseBoard)];
                opParams["position"] = dispenseBoard;
                opParams["tipIndex"] = 96;
                opParams["onBoardIndex"] = dispenseOnBoardIndex;
                opParams["drain"] = 1;
                opParams["drainVolume"] = volume;
                opParams["drainHeight"] = drainHeight;
                opParams["preDispenseWaitTime"] = preDispenseWaitTIme;

                opData["params"] = opParams;

                oplist.append(opData);
            }
            //4.卸载
            {
                QJsonObject opData;
                QJsonObject opParams;
                opData["operation"] = "Dump Tip";
                opData["sequence"] = sequence;

                opParams["boardType"] = m_paramDefaultValueMap["boardType"].IntListValue[getBoardTypeIndexByPosition(dumpBoard)];
                opParams["position"] = dumpBoard;
                opParams["tipIndex"] = 1;
                opParams["onBoardIndex"] =1;

                opData["params"] = opParams;

                oplist.append(opData);
            }
        }
    }
}

QJsonArray EnvironmentVariant::formatSingleOperationParam(const SingleOperationData & obj)
{
    QJsonArray opList;
    if(m_operationDispNameMap[obj.operationName]=="Single Tip Motion")
    {
        formatTipMotion(obj, opList);
    }
    else
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
                    paramobj[data.Name] =  m_paramDefaultValueMap[data.Name].IntListValue[data.IntegerValue];
                }
                else if(data.Type == "integer")
                {
                    paramobj[data.Name] = data.IntegerValue;
                }
                else if(data.Type == "float")
                {
                    paramobj[data.Name] = qRound(data.FloatValue*(double)data.Factor);
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

        opList.append(singleOperationObj);
    }

    return opList;
}


void EnvironmentVariant::StartTunning(const SingleOperationData& data)
{
    QJsonArray operationObj = EnvironmentVariant::instance()->formatSingleOperationParam(data);
    foreach (const QJsonValue& obj, operationObj) {
        QJsonObject sendObj;

        sendObj["operation"] = obj;
        sendObj["maxReceiveTime"] = m_machineConfig.maxReceiveTime;

        EnvironmentVariant::instance()->runTunning(sendObj);
    }
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

    SinglePlanData plan = m_planList[planIndex];

    SingleOperationData data = defaultValue(m_controlOperationList[operationIndex]);

    if(before < 0 || before > plan.operations.size())
    {
        plan.operations.append(data);
    }
    else
    {
        plan.operations.insert(before, data);
    }

    m_planList[planIndex] = plan;
}

void EnvironmentVariant::RemovePlanStep(int planIndex, int stepIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    SinglePlanData &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.operations.size())
    {
        plan.operations.removeAt(stepIndex);
    }
}

void EnvironmentVariant::MovePlanStep(int planIndex, int stepIndex, int newIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    SinglePlanData &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.operations.size() && newIndex >=0 && newIndex < plan.operations.size())
    {
        SingleOperationData data = plan.operations.at(stepIndex);
        plan.operations.removeAt(stepIndex);
        plan.operations.insert(newIndex, data);
    }
}

QString EnvironmentVariant::CopyPlanStep(int planIndex, int fromStepIndex, int toStepIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return QString();

    SinglePlanData &plan = m_planList[planIndex];

    if(fromStepIndex >= 0 && fromStepIndex < plan.operations.size() && toStepIndex >=0 && toStepIndex < plan.operations.size()+1)
    {
        SingleOperationData data = plan.operations.at(fromStepIndex);
        plan.operations.insert(toStepIndex, data);
        return m_operationNameDispMap[data.operationName];
    }
    return QString();
}

void EnvironmentVariant::copyStep(int planIndex, int stepIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return ;

    SinglePlanData &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.operations.size())
    {
        m_clipBoard = plan.operations.at(stepIndex);
    }
}

void EnvironmentVariant::pasteStep(int planIndex, int stepIndex)
{
    if(m_clipBoard.operationName.isEmpty())
        return ;
    if(planIndex < 0 || planIndex >= m_planList.size())
        return ;

    SinglePlanData &plan = m_planList[planIndex];

    plan.operations.insert(stepIndex, m_clipBoard);

}

void EnvironmentVariant::SetPlanStepToDefault(int planIndex, int stepIndex, int operationIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    SinglePlanData &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.operations.size())
    {
        SingleOperationData data = defaultValue(m_controlOperationList[operationIndex]);
        plan.operations[stepIndex] = data;
        //m_planList[planIndex] = plan;
    }

}

void EnvironmentVariant::SetPlanStepParam(int planIndex, int stepIndex, const QList<OperationParamData>& data)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    SinglePlanData &plan = m_planList[planIndex];

    if(stepIndex >= 0 && stepIndex < plan.operations.size())
    {
        plan.operations[stepIndex].params = data;
    }
}


void EnvironmentVariant::SetPlanStepSingleParam(int planIndex, int stepIndex, const QString& paramName, const QVariant& value)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    SinglePlanData &plan = m_planList[planIndex];

    if(stepIndex < 0 || stepIndex >= plan.operations.size())
        return;

    QList<OperationParamData> & params = plan.operations[stepIndex].params;

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
            else if(iterdata->Type == "string")
            {
                iterdata->StringValue = value.toString();
            }

            break;
        }
    }
}

void EnvironmentVariant::SetPlanName(int planIndex, const QString &name)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    SinglePlanData &plan = m_planList[planIndex];

    plan.planName = name;
}

void EnvironmentVariant::AddPlan(const QString &name)
{
    m_planList.append(SinglePlanData(name, 0,QList<SingleOperationData>()));
}

void EnvironmentVariant::RemovePlan(int planIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    m_planList.removeAt(planIndex);
}

bool EnvironmentVariant::SavePlan()
{
    configFileHandler handler(NULL);
    return handler.SavePlanList(m_userConfigFile, m_planList, m_operationParamMap);
}

bool EnvironmentVariant::SaveMachineConfig(const MachineConfigData& data)
{
    configFileHandler handler(NULL);
    bool ret = handler.SaveMachineConfig(m_userConfigFile, data, m_workLocationTypeList);

    //todo
    m_machineConfig.setIpAddress(data.IpAddress);
    m_machineConfig.setPort(data.port);
    m_machineConfig.setMaxReceiveTime(data.maxReceiveTime);
    m_machineConfig.setLicenseNumber(data.licenseNumber);

    calculateLicense(m_machineConfig.licenseNumber);

    return ret;
}

void EnvironmentVariant::StartPlan(int planIndex, int stepIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    const QList<SingleOperationData> & stepList = m_planList.at(planIndex).operations;


    QJsonObject planObj;
    QJsonArray oparray;
    int seq = 1;

    foreach(const SingleOperationData& opsData, stepList)
    {
        SingleOperationData opData = opsData;
        opData.sequenceNumber = seq++;
        if(opData.operationName=="Single Tip Motion")
        {
            formatTipMotion(opData, oparray);
        }
        else
        {
            QJsonObject singleOperationObj;
            singleOperationObj["operation"] = opData.operationName;
            singleOperationObj["sequence"] = opData.sequenceNumber;
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
                    paramobj[data.Name] = qRound(data.FloatValue*(double)data.Factor);
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

            oparray.append(singleOperationObj);
        }

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

void EnvironmentVariant::PausePlan()
{
    m_workFlow.pauseCurrentTask();
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

QJsonObject EnvironmentVariant::getWorkLocationTypeList()
{
    return m_workLocationTypeList;
}

bool EnvironmentVariant::setWorkLocationType(int configIndex, int workSpaceIndex, const QString& type)
{
    QJsonArray list = m_workLocationTypeList["config"].toArray();
    if(configIndex < 0 || configIndex >= list.size())
        return false;
    if(workSpaceIndex < 0 || workSpaceIndex >= list.at(configIndex).toObject()["type"].toArray().size())
    {
        return false;
    }
    if(list.at(configIndex).toObject()["type"].toArray()[workSpaceIndex] != type)
    {
        QJsonArray changeConfig = m_workLocationTypeList["config"].toArray();
        QJsonObject changeObj = changeConfig[configIndex].toObject();
        QJsonArray typeList = changeObj["type"].toArray();
        typeList[workSpaceIndex] = type;
        changeObj["type"] = typeList;
        changeConfig[configIndex] = changeObj;
        m_workLocationTypeList["config"] = changeConfig;
        emit workLocationTypeChanged();
        return true;
    }
    else
    {
        return false;
    }
}

bool EnvironmentVariant::updateWorkPlace(const QJsonObject &jsobj)
{
    if(m_workLocationTypeList != jsobj)
    {
        m_workLocationTypeList = jsobj;
        SaveMachineConfig(m_machineConfig);
        emit workLocationTypeChanged();
        return true;
    }
    else
    {
        return false;
    }
}

bool EnvironmentVariant::removeBoardIndex(int index)
{
    if(index >= 0)
    {
        for(QList<SinglePlanData>::iterator iter = m_planList.begin(); iter != m_planList.end(); iter++)
        {
            if(iter->boardConfig == index)
            {
                iter->boardConfig = 0;
            }
            else if(iter->boardConfig > index)
            {
                iter->boardConfig = iter->boardConfig - 1;
            }
        }
        return true;
    }
    return false;
}

void EnvironmentVariant::startCheckPlan(int planIndex)
{
    if(planIndex < 0 || planIndex >= m_planList.size())
        return;

    const QList<SingleOperationData> & stepList = m_planList.at(planIndex).operations;
    int boardIndex = m_planList.at(planIndex).boardConfig;

    QJsonObject planObj;
    QJsonArray oparray;
    int seq = 1;

    foreach(const SingleOperationData& opsData, stepList)
    {
        SingleOperationData opData = opsData;
        opData.sequenceNumber = seq++;
        if(opData.operationName=="Single Tip Motion")
        {
            formatTipMotion(opData, oparray);
        }
        else
        {
            QJsonObject singleOperationObj;
            singleOperationObj["operation"] = opData.operationName;
            singleOperationObj["sequence"] = opData.sequenceNumber ;
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
    }
    planObj["operations"] = oparray;
    QJsonArray boardList =  m_workLocationTypeList["config"].toArray();
    if(boardIndex >= boardList.size())
    {
        boardIndex = 0;
        m_planList[planIndex].boardConfig = 0;
    }
    planObj["boardConfig"] =boardList[boardIndex].toObject()["type"];

    m_workflowChecker.checkTask(planObj);
}

void EnvironmentVariant::stopCheckPlan()
{
    m_workflowChecker.stopCurrentCheck();
}

int EnvironmentVariant::getBoardTypeIndexByPosition(int index)
{
    const QJsonObject& workPlace = m_workLocationTypeList;
    const QJsonArray& workConstraint = m_workPlaceConstraint;

    QJsonArray boardConfig = workPlace["config"].toArray()[workPlace["current"].toInt()].toObject()["type"].toArray();
    if(index < 0 || index >= boardConfig.size())
    {
        return -1;
    }

    QString boardtype = boardConfig[index].toObject()["name"].toString();
    int boardIndex = 0;
    for(; boardIndex < workConstraint.size(); boardIndex++)
    {
        if(workConstraint[boardIndex].toObject()["type"].toString() == boardtype)
        {
            break;
        }
    }
    if(boardIndex < workConstraint.size())
    {
        return boardIndex;
    }
    return -1;
}


int EnvironmentVariant::getPlanBoardTypeIndexByPosition(int planIndex, int index)
{
    const QJsonArray& workConstraint = m_workPlaceConstraint;

    int workIndex = m_workLocationTypeList["current"].toInt();
    QJsonArray configArray = m_workLocationTypeList["config"].toArray();

    if(planIndex >= 0 && planIndex < m_planList.size())
    {
        workIndex = m_planList[planIndex].boardConfig;
        if(workIndex >= configArray.size())
        {
            workIndex = 0;
            m_planList[planIndex].boardConfig = workIndex;
        }
    }

    QJsonArray boardConfig = configArray[workIndex].toObject()["type"].toArray();
    if(index < 0 || index >= boardConfig.size())
    {
        return -1;
    }

    QString boardtype = boardConfig[index].toObject()["name"].toString();
    int boardIndex = 0;
    for(; boardIndex < workConstraint.size(); boardIndex++)
    {
        if(workConstraint[boardIndex].toObject()["type"].toString() == boardtype)
        {
            break;
        }
    }
    if(boardIndex < workConstraint.size())
    {
        return boardIndex;
    }
    return -1;
}

bool EnvironmentVariant::ImportConfig(const QString& file)
{
    qDebug()<<"Import config file "<<file;
    configFileHandler handler(NULL);
    bool ret =  handler.ConvertCSVtoJSON(file, m_userConfigFile);
    if(ret)
    {
        //reload config
        reloadUserConfig();
    }
    return ret;
}

bool EnvironmentVariant::ExportConfig(const QString& file)
{
    qDebug()<<"Export config file "<<file;

    configFileHandler handler(NULL);
    return handler.ConvertJSONtoCSV(m_userConfigFile, file);
}


void EnvironmentVariant::reloadUserConfig()
{
    initUserConfig(m_userConfigFile);
}
