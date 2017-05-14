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
    m_operationParamMap = handler.ParseListMap("OperationParam");
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
    QFile loadFile(str);
    if (!loadFile.open(QIODevice::ReadOnly))
    {
        qWarning("Couldn't open config file.");
    }

    QByteArray data = loadFile.readAll();

    QJsonDocument loadDoc(QJsonDocument::fromJson(data));
    QJsonObject configFileObj = loadDoc.object();
    loadFile.close();

    QJsonObject targetObj = configFileObj["target"].toObject();
    m_targetIp = targetObj["IP"].toString();
    m_targetPort = targetObj["port"].toInt();
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
    return parmList;
}

const QStringList EnvironmentVariant::OperationNameList()
{
    QStringList strlist;
    foreach (const QString& str, m_operationList) {
        if(m_operationNameDispMap.contains(str))
        {
            strlist.append(m_operationNameDispMap[str]);
        }
    }
    return strlist;
}

QJsonObject EnvironmentVariant::formatSingleOperationParam(const SingleOperationObject & obj)
{
    QJsonObject opObj;
    QJsonObject singleOperationObj;
    singleOperationObj["operation"] = m_operationDispNameMap[obj.operationName];
    singleOperationObj["sequence number"] = QJsonValue(obj.sequenceNumber);
    QJsonObject paramobj;
    foreach(QObject* pObj, obj.params)
    {
        OperationParamObject*pParm = dynamic_cast<OperationParamObject*>(pObj);
        if(pParm)
        {
//            qDebug()<<"ParamListModel item name:"<<pParm->name()<<\
//                      "\ntype:"<<pParm->type()<<\
//                      "\nString:"<<pParm->stringValue()<<\
//                      "\nEnums:"<<pParm->stringListValue()<<\
//                      "\nbool:"<<pParm->boolValue()<<\
//                      "\nInt:"<<pParm->integerValue()<<\
//                      "\nFloat:"<<pParm->floatValue()<<\
//                      "\nDisplay"<<pParm->display();

            if (pParm->type() == "enum")
            {
                paramobj[pParm->name()] = pParm->intListValue()[pParm->integerValue()];
            }
            else if(pParm->type() == "integer")
            {
                paramobj[pParm->name()] = pParm->integerValue();
            }
            else if(pParm->type() == "float")
            {
                paramobj[pParm->name()] = static_cast<int>(pParm->floatValue()*10.0);
            }
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
