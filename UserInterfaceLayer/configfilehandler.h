#ifndef CONFIGFILEHANDLER_H
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
    QJsonArray ParseWorkPlaceConstraint();

    QString ParseHostIP();
    qint16 ParseHostPort();
    qint32 ParseHostSingleOperationThreshold();
    void ParsePlanList(QList<QPair<QString, QList<SingleOperationData> > >& planMap, const QMap<QString, OperationParamData> &);
    bool SavePlanList(const QString& configFile, const QList<QPair<QString, QList<SingleOperationData> > > & planData, const QMap<QString, QStringList> &);

    bool SaveMachineConfig(const QString& configFile, const MachineConfigData&, const QJsonObject& );

    void ParseWorkSpaceTypeList(QJsonObject& typelist);
    void ParseLicense(QByteArray& encodedString);
    QString GetLicense();

    bool ConvertCSVtoJSON(const QString &csvFile, const QString& jsonFile);
    bool ConvertJSONtoCSV(const QString &jsonFile, const QString& csvFile);

    QString ParsePlan(const QJsonArray& obj);
    QString ParseWorkSpace(const QJsonObject& obj);

    bool ImportConfig(QJsonObject& fileObj, const QByteArray&importdata);
    bool ImportWorkSpace(const QList<QByteArray> & filelines, QJsonObject& fileObj);
    bool ImportPlan(const QList<QByteArray> & filelines, QJsonObject& fileObj);

signals:

public slots:

private:
    QJsonObject m_configFileObj;
};

#endif // CONFIGFILEHANDLER_H
