#include "configfilehandler.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QDebug>
#include <QCryptographicHash>

configFileHandler::configFileHandler(QObject *parent)
    : QObject(parent)
{
}


bool configFileHandler::loadConfigFile(const QString& configFile)
{
    QFile loadFile(configFile);
    if (!loadFile.open(QIODevice::ReadOnly))
    {
        qWarning("Couldn't open config file.");
        return false;
    }

    QByteArray data = loadFile.readAll();

    QJsonDocument loadDoc(QJsonDocument::fromJson(data));

    m_configFileObj = loadDoc.object();
    loadFile.close();

    return true;
}


QStringList configFileHandler::toList(const QString &name)
{
    QStringList retList;
    QJsonArray array = m_configFileObj[name].toArray();
    for(int index = 0; index < array.size(); index++)
    {
        retList.append(array[index].toString());
    }
    return retList;
}

QMap<QString, QStringList> configFileHandler::ParseListMap(const QString&name)
{
    QMap<QString, QStringList> retMap;
    QJsonValue val = m_configFileObj[name];
    QJsonObject obj = val.toObject();
    QJsonObject::Iterator iter = obj.begin();
    for(; iter != obj.end(); iter++)
    {
        QStringList listTemp;
        QJsonArray subObj = iter.value().toArray();
        for (QJsonArray::Iterator iter2 = subObj.begin(); iter2 != subObj.end(); iter2++)
        {
            listTemp.append(iter2->toString());
        }
        retMap[iter.key()] = listTemp;
    }
    return retMap;
}

QMap<QString, QString> configFileHandler::ParseMap(const QString& name)
{
    QMap<QString, QString> retMap;
    QJsonValue val = m_configFileObj[name];
    QJsonObject obj = val.toObject();
    QJsonObject::Iterator iter = obj.begin();
    for(; iter != obj.end(); iter++)
    {
        retMap[iter.key()] = iter.value().toString();
    }
    return retMap;
}


QMap<QString, QString> configFileHandler::ParseMapRevertKeyValue(const QString& name)
{
    QMap<QString, QString> retMap;
    QJsonValue val = m_configFileObj[name];
    QJsonObject obj = val.toObject();
    QJsonObject::Iterator iter = obj.begin();
    for(; iter != obj.end(); iter++)
    {
        retMap[iter.value().toString()] = iter.key();
    }
    return retMap;
}


QMap<QString, OperationParamData> configFileHandler::ParseParamValue(const QString& name)
{
    QStringList boardTypeList;
    QList<int> boardHeightList;
    QJsonArray workPlace = m_configFileObj["workPlace"].toArray();
    QJsonArray::Iterator ait = workPlace.begin();
    for(; ait != workPlace.end(); ait++)
    {
        boardTypeList.push_back(ait->toObject()["display"].toString());
        boardHeightList.push_back(ait->toObject()["params"].toObject()["height"].toObject()["default"].toInt());
    }


    QMap<QString, OperationParamData> retmap;
    QJsonValue val = m_configFileObj[name];
    QJsonObject obj= val.toObject();
    QJsonObject::Iterator iter = obj.begin();
    for(; iter != obj.end(); iter++)
    {
        QString display;
        QString type;
        QString strVal;
        QStringList enums;
        int intVal = 0;
        bool boolVal = false;
        double floatVal = 0.0;
        QList<int> valueEnum;
        QString switchVal;
        QString unit;
        int bottomVal = 0;
        int topVal = 0;
        bool revertSwitch = false;
        int factor = 1;

        QJsonObject subObj = iter.value().toObject();
        for (QJsonObject::Iterator iter2 = subObj.begin(); iter2 != subObj.end(); iter2++)
        {
            if (iter2.key() == "type")
            {
                type = iter2.value().toString();
            }
            else if (iter2.key() == "default")
            {
                strVal = iter2.value().toString();
                boolVal = iter2.value().toBool();
                intVal = iter2.value().toInt();
                floatVal = iter2.value().toDouble();
            }
            else if (iter2.key() == "enum")
            {
                enums.clear();
                QJsonArray enumObj = iter2.value().toArray();
                for (QJsonArray::Iterator iter3 = enumObj.begin(); iter3 != enumObj.end(); iter3++)
                {
                    enums.append(iter3->toString());
                }
            }
            else if(iter2.key() == "display")
            {
                display = iter2.value().toString();
            }
            else if(iter2.key() == "valueEnum")
            {
                valueEnum.clear();
                QJsonArray enumObj = iter2.value().toArray();
                for (QJsonArray::Iterator iter3 = enumObj.begin(); iter3 != enumObj.end(); iter3++)
                {
                    valueEnum.append(iter3->toInt());
                }
            }
            else if (iter2.key() == "switch")
            {
                switchVal = iter2.value().toString();
            }
            else if(iter2.key() == "unit")
            {
                unit = iter2.value().toString();
            }
            else if(iter2.key() == "bottomValue")
            {
                bottomVal = iter2.value().toInt();
            }
            else if(iter2.key() == "topValue")
            {
                topVal = iter2.value().toInt();
            }
            else if(iter2.key() == "revertSwitch")
            {
                revertSwitch = iter2.value().toBool();
            }
            else if(iter2.key() == "factor")
            {
                factor = iter2.value().toInt();
            }
        }
        if(iter.key() == "boardType")
        {
            enums = boardTypeList;
            valueEnum = boardHeightList;
        }
        retmap[iter.key()] = OperationParamData(iter.key(), type, strVal, enums, boolVal, intVal, floatVal, display, valueEnum, switchVal, unit, bottomVal, topVal, revertSwitch, factor);
    }
    return retmap;
}

QString configFileHandler::ParseHostIP()
{
    QJsonObject targetObj = m_configFileObj["target"].toObject();
    return targetObj["IP"].toString();
}

qint16 configFileHandler::ParseHostPort()
{
    QJsonObject targetObj = m_configFileObj["target"].toObject();

    return  targetObj["port"].toInt();
}

qint32 configFileHandler::ParseHostSingleOperationThreshold()
{
    QJsonObject targetObj = m_configFileObj["target"].toObject();

    return  targetObj["maxReceiveTime"].toInt();
}

QJsonArray configFileHandler::ParseWorkPlaceConstraint()
{
    QJsonArray workSpace =  m_configFileObj["workPlace"].toArray();

    return workSpace;
}

void configFileHandler::ParsePlanList(QList<SinglePlanData>& planMap, const QMap<QString, OperationParamData> & defaultParamMap)
{
    planMap.clear();

    QJsonArray planArray = m_configFileObj["plan"].toArray();
    for(QJsonArray::Iterator objIter = planArray.begin(); objIter != planArray.end(); objIter++)
    {
        QJsonObject planObj = objIter->toObject();
        QString planName = planObj["name"].toString();
        int boardConfig = planObj["workSpace"].toInt();

        QJsonArray steplist = planObj["operations"].toArray();
        QList<SingleOperationData> oplist;

        for(QJsonArray::Iterator iter = steplist.begin(); iter != steplist.end(); iter++)
        {
            QJsonObject opObj = iter->toObject();
            QJsonObject paramObj = opObj["params"].toObject();

            SingleOperationData opData;
            opData.operationName = opObj["operation"].toString();

            for(QJsonObject::Iterator iter2 = paramObj.begin(); iter2 != paramObj.end(); iter2++)
            {
                OperationParamData paramData;
                paramData.Name = iter2.key();

                if (defaultParamMap.contains(paramData.Name))
                {
                    const OperationParamData& data = defaultParamMap[paramData.Name];
                    paramData.Type = data.Type;
                    if(data.Type == "enum")
                    {
                        paramData.IntegerValue = iter2->toInt();
                        paramData.IntListValue = data.IntListValue;
                    }
                    else if(data.Type == "integer")
                    {
                        paramData.IntegerValue = iter2->toInt();
                        paramData.StringValue = QString::number(paramData.IntegerValue);
                    }
                    else if(data.Type == "float")
                    {
                        paramData.FloatValue = iter2->toDouble();
                        paramData.StringValue = QString::number(paramData.FloatValue, 'f', 2);
                        paramData.Factor = data.Factor;
                    }
                    else if(data.Type == "bool")
                    {
                        paramData.BoolValue = iter2->toBool();
                    }
                    else if(data.Type == "string")
                    {
                        paramData.StringValue = iter2->toString();
                    }
                    opData.params.append(paramData);
                }

            }
            oplist.append(opData);
        }
        planMap.append(SinglePlanData(planName,boardConfig, oplist));
    }

}

bool configFileHandler::SavePlanList(const QString& configFile, const QList<SinglePlanData > & planData, const QMap<QString, QStringList> &paramMap)
{
    QFile loadFile(configFile);
    if(!loadFile.open(QIODevice::ReadWrite))
    {
        qWarning("configFile error");
        return false;
    }
    QByteArray data = loadFile.readAll();
    loadFile.close();

    QJsonDocument loadDoc(QJsonDocument::fromJson(data));
    QJsonObject fileObj = loadDoc.object();
    fileObj.remove("plan");

    QJsonArray planArray;


    for(QList<SinglePlanData>::const_iterator iter = planData.begin(); iter != planData.end(); iter++)
    {
        QJsonObject planObj;
        int seq = 1;
        QString planName = iter->planName;
        int boardConfig = iter->boardConfig;
        const QList<SingleOperationData>& opList = iter->operations;
        QJsonArray planStepList;
        for(QList<SingleOperationData>::const_iterator iter2 = opList.begin(); iter2 != opList.end(); iter2++)
        {
            QJsonObject value;
            value["operation"] = iter2->operationName;
            value["sequenceNumber"] = seq++;

            QJsonObject paramObj;
            foreach(const OperationParamData& data, iter2->params)
            {
                if(data.Type == "enum" || data.Type == "integer")
                {
                    paramObj[data.Name] = data.IntegerValue;
                }
                else if(data.Type == "float")
                {
                    paramObj[data.Name] = data.FloatValue;
                }
                else if(data.Type == "string")
                {
                    paramObj[data.Name] = data.StringValue;
                }
                else if(data.Type == "bool")
                {
                    paramObj[data.Name] = data.BoolValue;
                }
            }

            value["params"] = paramObj;
            planStepList.append(value);
        }


        planObj["name"] = planName;
        planObj["workSpace"] = boardConfig;
        planObj["operations"] = planStepList;

        planArray.append(planObj);
    }


    fileObj["plan"] = planArray;
    QJsonDocument writeDoc(fileObj);
    QFile::resize(configFile, 0);
    loadFile.open(QIODevice::ReadWrite);
    loadFile.write(writeDoc.toJson());
    loadFile.close();

    return true;
}

bool configFileHandler::SaveMachineConfig(const QString& configFile, const MachineConfigData& cfgData, const QJsonObject& typeConfig)
{
    QFile loadFile(configFile);
    if(!loadFile.open(QIODevice::ReadWrite))
    {
        qWarning("configFile error");
        return false;
    }
    QByteArray data = loadFile.readAll();
    loadFile.close();

    QJsonDocument loadDoc(QJsonDocument::fromJson(data));
    QJsonObject fileObj = loadDoc.object();
    fileObj.remove("target");

    QJsonObject ipobj;
    ipobj["IP"] = cfgData.IpAddress;
    ipobj["port"] = cfgData.port;
    ipobj["maxReceiveTime"] = cfgData.maxReceiveTime;

    fileObj["target"] = ipobj;

//    QJsonObject workers = fileObj["workers"].toObject();
//    fileObj.remove("workers");
//    workers.remove("type");
//    QJsonArray newTypeList;
//    foreach (const QString& str, typeConfig) {
//        newTypeList.append(str);
//    }
//    workers["type"] = newTypeList;
    fileObj["workSpace"] = typeConfig;

    fileObj.remove("license");
    fileObj["license"] = cfgData.licenseNumber;

    QJsonDocument writeDoc(fileObj);
    QFile::resize(configFile, 0);
    loadFile.open(QIODevice::ReadWrite);
    loadFile.write(writeDoc.toJson());
    loadFile.close();

    return true;
}

void configFileHandler::ParseWorkSpaceTypeList(QJsonObject& typelist)
{
    typelist = m_configFileObj["workSpace"].toObject();

//    typelist.clear();
//    QJsonObject workerObj = m_configFileObj["workSpace"].toObject();
//    int count = workerObj["count"].toInt();
//    QJsonArray types = workerObj["type"].toArray();
//    if(types.size() < count)
//    {
//        qDebug()<<"ParseWorkLocationTypeList config file error.";
//        return;
//    }
//    for(int index = 0; index < count; index++)
//    {
//        QString str = types.at(index).toString();
//        typelist.append(str);
//    }
}

void configFileHandler::ParseLicense(QByteArray& encodedString)
{
    encodedString.clear();
    QByteArray licenseStr(m_configFileObj["license"].toString().toLocal8Bit());

    QCryptographicHash hash(QCryptographicHash::Sha1);
    encodedString = hash.hash(licenseStr, QCryptographicHash::Sha1);
}
QString configFileHandler::GetLicense()
{
    return m_configFileObj["license"].toString();
}

bool configFileHandler::ConvertCSVtoJSON(const QString &csvFile, const QString& jsonFile)
{
    QFile loadFile(csvFile);
    if(!loadFile.open(QIODevice::ReadWrite))
    {
        qWarning("configFile error");
        return false;
    }
    QByteArray importdata = loadFile.readAll();
    loadFile.close();

    QFile imFile(jsonFile);
    if(!imFile.open(QIODevice::ReadWrite))
    {
        qWarning("import file error");
        return false;
    }
    QByteArray olddata = imFile.readAll();

    QJsonDocument loadDoc(QJsonDocument::fromJson(olddata));
    QJsonObject fileObj = loadDoc.object();

    if(!ImportConfig(fileObj, importdata))
    {
        qWarning("import config error");
        return false;
    }


    QJsonDocument writeDoc(fileObj);
    imFile.resize(0);
    imFile.write(writeDoc.toJson());
    imFile.close();

    return true;
}

bool configFileHandler::ConvertJSONtoCSV(const QString &jsonFile, const QString& csvFile)
{
    QFile loadFile(jsonFile);
    if(!loadFile.open(QIODevice::ReadWrite))
    {
        qWarning("configFile error");
        return false;
    }
    QByteArray data = loadFile.readAll();
    loadFile.close();

    QJsonDocument loadDoc(QJsonDocument::fromJson(data));
    QJsonObject fileObj = loadDoc.object();

    QString fileData;
    if(fileObj.contains("plan"))
    {
        fileData += ParsePlan(fileObj["plan"].toArray());
    }
    if(fileObj.contains("workSpace"))
    {
        fileData += ParseWorkSpace(fileObj["workSpace"].toObject());

    }

    QFile exFile(csvFile);
    if(!exFile.open(QIODevice::ReadWrite))
    {
        qWarning("export file error");
        return false;
    }
    exFile.resize(0);
    exFile.write(fileData.toLocal8Bit());
    exFile.close();
    return true;
}
QString configFileHandler::ParsePlan(const QJsonArray& obj)
{
    QString retString;
    for(QJsonArray::const_iterator iter = obj.begin(); iter != obj.end(); iter++)
    {
        QJsonObject planObj = iter->toObject();
        //plan header
        QString headerString;
        headerString += "plan name,";
        headerString += planObj["name"].toString();
        headerString += ',';
        headerString += "\r\n";
        //board index
        headerString += "board index,";
        headerString += QString::number(planObj["workSpace"].toInt());
        headerString += ',';
        headerString += "\r\n";
        //param header
        headerString += "params,";
        QStringList paramList;

        QJsonArray opArray = planObj["operations"].toArray();
        for(QJsonArray::iterator iter2 = opArray.begin(); iter2 != opArray.end(); iter2++)
        {
            QJsonObject param = iter2->toObject()["params"].toObject();
            for(QJsonObject::iterator iter3 = param.begin(); iter3 != param.end(); iter3++)
            {
                if(!paramList.contains(iter3.key()))
                {
                    paramList.push_back(iter3.key());
                    headerString+=(iter3.key() + ',');
                }
            }
        }
        headerString+="\r\n";

        retString+=headerString;

        //operation line

        for(QJsonArray::iterator iter2 = opArray.begin(); iter2 != opArray.end(); iter2++)
        {
            QString opString;
            opString += iter2->toObject()["operation"].toString();
            opString+=',';

            QJsonObject param = iter2->toObject()["params"].toObject();
            for(int index = 0; index < paramList.size(); index++)
            {
                if(param.contains(paramList[index]))
                {
                    QJsonValue::Type type = param[paramList[index]].type();
                    if(type == QJsonValue::String)
                    {
                        QString strtemp = convertStringToASCII(param[paramList[index]].toString());
                        opString += strtemp;
                    }
                    else if(type == QJsonValue::Bool)
                    {
                        opString += QString::number(param[paramList[index]].toBool()?1:0);
                    }
                    else
                    {
                        opString +=      QString::number(param[paramList[index]].toInt());
                    }
                }
                opString += ',';
            }
            opString += "\r\n";

            retString += opString;
        }
        retString += "plan end\r\n";
        retString+="\r\n";
    }
    retString += "\r\n";
    return retString;
}
QString configFileHandler::ParseWorkSpace(const QJsonObject& obj)
{
//    int currentIndex = obj["current"].toInt();
    QJsonArray wkConfig = obj["config"].toArray();
//    if(currentIndex < 0 || currentIndex >= wkConfig.size())
//        return QString();

    QString retString;
    for(QJsonArray::iterator iter = wkConfig.begin(); iter != wkConfig.end(); iter++)
    {
        QJsonObject convertObj = iter->toObject();
        //header
        retString += "work space name,"+convertObj["name"].toString()+"\r\n";
        //paramheader
        QString paramHeaderString("params,");
        QString boardString;
        QStringList paramList;
        QJsonArray typeArray = convertObj["type"].toArray();
        for(QJsonArray::Iterator iter = typeArray.begin(); iter != typeArray.end(); iter++)
        {
            QJsonObject board = iter->toObject();

            boardString += board["name"].toString();
            boardString += ',';

            for(QJsonObject::Iterator iter2 = board.begin(); iter2 != board.end(); iter2++)
            {
                if(iter2.key() != "name")
                {
                    if(!paramList.contains(iter2.key()))
                    {
                        paramList.push_back(iter2.key());
                        paramHeaderString+=(iter2.key() + ',');
                    }
                }
            }

            for(int index = 0; index < paramList.size(); index++)
            {
                if(board.contains(paramList[index]))
                {
                    boardString+=QString::number(board[paramList[index]].toInt());
                }
                boardString+=',';
            }

            boardString+="\r\n";
        }
        retString += paramHeaderString;
        retString += "\r\n";
        retString += boardString;
        retString += "work space end\r\n\r\n";
    }
    return retString;
}

bool configFileHandler::ImportConfig(QJsonObject& fileObj, const QByteArray&importdata)
{
    QList<QByteArray> lines = importdata.split('\n');
    for(QList<QByteArray>::iterator iter = lines.begin(); iter != lines.end(); iter++)
    {
        if(iter->size() > 0)
        {
            if (iter->at(iter->size()-1) == '\r')
            {
                iter->resize(iter->size()-1);
            }
        }
    }

    int oldWorkCount = 0;
    int newWorkCount = 0;
    //work space
    ImportWorkSpace(lines, fileObj, oldWorkCount, newWorkCount);

    //plan
    ImportPlan(lines, fileObj, oldWorkCount, newWorkCount);

    return true;
}

bool configFileHandler::ImportWorkSpace(const QList<QByteArray> & lines, QJsonObject& fileObj, int& oldWorkCount, int& newWorkCount)
{
    QJsonObject workSpaceOld = fileObj["workSpace"].toObject();
    QJsonArray configArray = workSpaceOld["config"].toArray();
    oldWorkCount = configArray.size();

    QJsonObject workSpaceObj;

    bool header = false;
    bool params = false;
    const char* workHeaderName = "work space name";
    QStringList paramList;
    int count = 0;
    QJsonArray typeArray;
    for(QList<QByteArray>::const_iterator iter = lines.begin(); iter != lines.end(); iter++)
    {
        if(!header)
        {
            if(iter->left(strlen(workHeaderName)) == QString(workHeaderName))
            {
                QList<QByteArray> words = iter->split(',');
                if(words.size() >= 2)
                {
                    workSpaceObj["name"] = QString(words[1]);
                    header = true;
                }
            }
        }
        else if(!params)
        {
            QList<QByteArray> words = iter->split(',');
            for(QList<QByteArray>::iterator iter2 = words.begin(); iter2 != words.end(); iter2++)
            {
                if(!QString(*iter2).isEmpty() && iter2->at(0) != '\r'&& *iter2!= "params")
                    paramList.push_back(*iter2);
            }
            params = true;
        }
        else
        {
            QList<QByteArray> words = iter->split(',');
            if(words.isEmpty() || words[0]=="")
            {
                continue;
            }
            if(words[0] == "work space end")
            {
                workSpaceObj["type"] = typeArray;
                workSpaceObj["count"] = count;
                configArray.append(workSpaceObj);

                header = false;
                params = false;
                paramList.clear();
                count = 0;
                typeArray = QJsonArray();

                continue;
            }
            QJsonObject singleSpace;
            singleSpace["name"] = QString(words[0]);
            for(int index = 0; index < words.size(); index++)
            {
                if(index > 0 && !words.at(index).isEmpty() && words.at(index)!="\r" && paramList.size() > index-1)
                {
                    singleSpace[paramList.at(index-1)] = QString::number(words.at(index).toInt());

                }
            }
            typeArray.append(singleSpace);
            count++;
        }
    }

    newWorkCount = configArray.size();
    workSpaceOld["config"] = configArray;
    workSpaceOld["current"] = configArray.size()-1;
    fileObj.remove("workSpace");
    fileObj["workSpace"] = workSpaceOld;

    return true;
}

bool configFileHandler::ImportPlan(const QList<QByteArray> & lines, QJsonObject& fileObj, int& oldWorkCount, int& newWorkCount)
{
    QJsonArray planArray = fileObj["plan"].toArray();

    bool header = false;
    bool boardconfig = false;
    bool params = false;
    const char* workHeaderName = "plan name";
    const char* boardIndexName = "board index";
    QStringList paramList;
    int seq = 1;
    QJsonArray singlePlan;
    QString planName;
    int boardIndex = 0;

    for(QList<QByteArray>::const_iterator iter = lines.begin(); iter != lines.end(); iter++)
    {
        if(!header)
        {
            if(iter->left(strlen(workHeaderName)) == QString(workHeaderName))
            {
                QList<QByteArray> words = iter->split(',');
                if(words.size() >= 2)
                {
                    planName = QString(words[1]);
                    header = true;
                }
            }
        }
        else if(!boardconfig)
        {
            if(iter->left(strlen(boardIndexName)) == QString(boardIndexName))
            {
                QList<QByteArray> words = iter->split(',');
                if(words.size() >= 2)
                {
                    int indextemp = QString(words[1]).toInt();
                    if(indextemp >= newWorkCount){
                        indextemp = 0;
                    }

                    boardIndex = indextemp + oldWorkCount;
                    boardconfig = true;
                }
            }
        }
        else if(!params)
        {
            QList<QByteArray> words = iter->split(',');
            for(QList<QByteArray>::iterator iter2 = words.begin(); iter2 != words.end(); iter2++)
            {
                if(!QString(*iter2).isEmpty() && iter2->at(0) != '\r' && *iter2!= "params")
                    paramList.push_back(*iter2);
            }
            params = true;
        }
        else
        {
            QList<QByteArray> words = iter->split(',');
            if(words.isEmpty() || words[0]=="")
            {
                continue;
            }
            if(words[0] == "plan end")
            {
                QJsonObject planObj;
                planObj["name"] = planName;
                planObj["operations"] = singlePlan;
                planObj["workSpace"] = boardIndex;
                planArray.append(planObj);

                header = false;
                params = false;
                boardconfig = false;
                boardIndex = 0;
                paramList.clear();
                seq = 1;
                singlePlan = QJsonArray();
                planName.clear();

                continue;
            }
            QJsonObject operation;
            operation["operation"] = QString(words[0]);
            QJsonObject paramObj;
            const QString strHead("ASCII");
            for(int index = 0; index < words.size(); index++)
            {
                if(index > 0 && !words.at(index).isEmpty() && words.at(index)!="\r" && paramList.size() > index-1)
                {
                    QString strtemp(words.at(index));
                    if(strtemp.left(strHead.length()) == strHead)
                    {
                        paramObj[paramList.at(index-1)] = convertASCIIToString(strtemp);
                    }
                    else
                    {
                        paramObj[paramList.at(index-1)] = QJsonValue(strtemp.toInt());
                    }
                }
            }
            operation["params"] =paramObj;
            operation["sequenceNumber"] = seq;
            singlePlan.append(operation);
            seq++;
        }
    }

    fileObj.remove("plan");
    fileObj["plan"] = planArray;

    return true;
}

QChar configFileHandler::toChar(quint8 val)
{
    static const QChar  mapTable[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};

    if(val < sizeof(mapTable)/sizeof(QChar))
    {
        return mapTable[val];
    }
    return '\0';
}

quint8 configFileHandler::fromChar(QChar ch)
{
    static const QChar  mapTable[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};

    for(int indx = 0; indx < sizeof(mapTable)/sizeof(QChar); indx++)
    {
        if(ch == mapTable[indx])
        {
            return (quint8)indx;
        }
    }
    return 0;
}

QString configFileHandler::convertStringToASCII(const QString&str)
{
    const QString head = "ASCII";
    QString decodeStr;
    decodeStr+=head;

    for(int indx = 0; indx < str.length(); indx++)
    {
        QChar qch = str.at(indx);
        quint8 ch = (quint8)qch.toLatin1();
        QChar ch1 = toChar(((ch&0xf0)>>4));
        QChar ch2 = toChar(ch&0x0f);
        if(ch1 != 0 && ch2 != 0 )
        {
            decodeStr +=ch1;
            decodeStr += ch2;
        }
    }
    return decodeStr;
}

QString configFileHandler::convertASCIIToString(const QString&str)
{
    const QString head = "ASCII";
    QString encodeStr;
    if(str.left(head.length()) != head)
        return QString();

    for(int indx = head.length(); indx+1 < str.length(); indx+=2)
    {
        quint8 val1 = fromChar(str.at(indx));
        quint8 val2 = fromChar(str.at(indx+1));

        QChar ch = ((val1<<4)|val2);

        if(ch != 0)
            encodeStr += ch;
    }
    return encodeStr;
}
