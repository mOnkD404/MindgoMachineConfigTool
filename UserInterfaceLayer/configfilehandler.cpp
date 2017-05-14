#include "configfilehandler.h"
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QMap>
#include <QDebug>
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
        QList<int> valueEnum;
        QString switchVal;

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
        }
        retmap[iter.key()] = OperationParamData(iter.key(), type, strVal, enums, boolVal, intVal, display, valueEnum, switchVal);
    }
    return retmap;
}

