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

signals:

public slots:

private:
    QJsonObject m_configFileObj;
};

#endif // CONFIGFILEHANDLER_H
