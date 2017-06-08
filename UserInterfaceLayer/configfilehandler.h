﻿#ifndef CONFIGFILEHANDLER_H
#define CONFIGFILEHANDLER_H

#include <QObject>
#include <QJsonObject>
#include "workmodels.h"

class configFileHandler : public QObject
{
    Q_OBJECT
public:
    explicit configFileHandler(QObject *parent);

    bool loadConfigFile(const QString& configFile);

    QStringList toList(const QString &);
    QMap<QString, QStringList> ParseListMap(const QString&);
    QMap<QString, QString> ParseMap(const QString&);
    QMap<QString, QString> ParseMapRevertKeyValue(const QString&);
    QMap<QString, OperationParamData> ParseParamValue(const QString&);

    QString ParseHostIP();
    qint16 ParseHostPort();
    qint32 ParseHostSingleOperationThreshold();
    void ParsePlanList(QList<QPair<QString, QList<SingleOperationData> > >& planMap, const QMap<QString, OperationParamData> &);
    void SavePlanList(const QString& configFile, const QList<QPair<QString, QList<SingleOperationData> > > & planData, const QMap<QString, QStringList> &);

    void SaveMachineConfig(const QString& configFile, const MachineConfigData&, const QStringList& );

    void ParseWorkLocationTypeList(QStringList& typelist);
    void ParseLicense(QByteArray& encodedString);

signals:

public slots:

private:
    QJsonObject m_configFileObj;
};

#endif // CONFIGFILEHANDLER_H
