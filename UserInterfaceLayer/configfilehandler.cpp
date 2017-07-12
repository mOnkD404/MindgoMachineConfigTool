﻿#include "configfilehandler.h"
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
        int bottomVal;
        int topVal;

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
        }
        if(iter.key() == "boardType")
        {
            enums = boardTypeList;
            valueEnum = boardHeightList;
        }
        retmap[iter.key()] = OperationParamData(iter.key(), type, strVal, enums, boolVal, intVal, floatVal, display, valueEnum, switchVal, unit, bottomVal, topVal);
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

void configFileHandler::ParsePlanList(QList<QPair<QString, QList<SingleOperationData> > >& planMap, const QMap<QString, OperationParamData> & defaultParamMap)
{
    planMap.clear();

    QJsonObject planObj = m_configFileObj["plan"].toObject();
    for(QJsonObject::Iterator objIter = planObj.begin(); objIter != planObj.end(); objIter++)
    {
        QString planName = objIter.key();

        QJsonArray steplist = objIter.value().toArray();
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
        planMap.append(qMakePair(planName,oplist));
    }

}

void configFileHandler::SavePlanList(const QString& configFile, const QList<QPair<QString, QList<SingleOperationData> > > & planData, const QMap<QString, QStringList> &paramMap)
{
    QFile loadFile(configFile);
    if(!loadFile.open(QIODevice::ReadWrite))
    {
        qFatal("configFile error");
        return;
    }
    QByteArray data = loadFile.readAll();
    loadFile.close();

    QJsonDocument loadDoc(QJsonDocument::fromJson(data));
    QJsonObject fileObj = loadDoc.object();
    fileObj.remove("plan");

    QJsonObject planObj;

    for(QList<QPair<QString, QList<SingleOperationData> > >::const_iterator iter = planData.begin(); iter != planData.end(); iter++)
    {
        int seq = 1;
        QString planName = iter->first;
        const QList<SingleOperationData>& opList = iter->second;
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


        planObj[planName] = planStepList;
    }


    fileObj["plan"] = planObj;
    QJsonDocument writeDoc(fileObj);
    QFile::resize(configFile, 0);
    loadFile.open(QIODevice::ReadWrite);
    loadFile.write(writeDoc.toJson());
    loadFile.close();
}

void configFileHandler::SaveMachineConfig(const QString& configFile, const MachineConfigData& cfgData, const QJsonObject& typeConfig)
{
    QFile loadFile(configFile);
    if(!loadFile.open(QIODevice::ReadWrite))
    {
        qFatal("configFile error");
        return;
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

    QJsonDocument writeDoc(fileObj);
    QFile::resize(configFile, 0);
    loadFile.open(QIODevice::ReadWrite);
    loadFile.write(writeDoc.toJson());
    loadFile.close();

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
