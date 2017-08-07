#ifndef WORKMODELS_H
#define WORKMODELS_H
#include <QObject>
#include <qqmlcontext.h>
#include <qqml.h>
#include <QtQuick/qquickitem.h>
#include <QMap>
#include <QAbstractItemModel>
#include <QStringListModel>
#include <QtMath>
#include <QDoubleValidator>
#include <QJsonObject>
#include <QJsonArray>
#include <QFileSystemModel>

class OperationParamData
{
public:
    OperationParamData():BoolValue(false), IntegerValue(0), FloatValue(0.0) {}
    OperationParamData(const QString& oname, const QString& otype, const QString& ostringValue, const QStringList& ostringlistValue,
                       bool oboolvalue, int ointegerValue, int ofloatValue, const QString& display, const QList<int> intlist, const QString& switchVal,
                       const QString& unit, int bottomVal, int topVal)
    {
        Name = oname;
        Type = otype;
        StringValue = ostringValue;
        StringListValue = ostringlistValue;
        BoolValue = oboolvalue;
        IntegerValue = ointegerValue;
        FloatValue = ofloatValue;
        Display = display;
        IntListValue = intlist;
        SwitchValue = switchVal;
        Unit = unit;
        BottomValue = bottomVal;
        TopValue = topVal;
    }
    OperationParamData(const OperationParamData& opd)
    {
        Name = opd.Name;
        Type = opd.Type;
        StringValue = opd.StringValue;
        StringListValue = opd.StringListValue;
        BoolValue = opd.BoolValue;
        IntegerValue = opd.IntegerValue;
        FloatValue = opd.FloatValue;
        Display = opd.Display;
        IntListValue = opd.IntListValue;
        SwitchValue = opd.SwitchValue;
        Unit = opd.Unit;
        BottomValue = opd.BottomValue;
        TopValue = opd.TopValue;
    }

public:
    QString Name;
    QString Type;
    QString StringValue;
    QStringList StringListValue;
    bool BoolValue;
    int IntegerValue;
    double FloatValue;
    QString Display;
    QList<int> IntListValue;
    QString SwitchValue;
    QString Unit;
    int BottomValue;
    int TopValue;
};

class OperationParamObject: public QObject, public OperationParamData
{
    Q_OBJECT
    Q_PROPERTY(QString Name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString Type READ type WRITE settype NOTIFY typeChanged)
    Q_PROPERTY(QString StringValue READ stringValue WRITE setStringValue NOTIFY stringValueChanged)
    Q_PROPERTY(QStringList StringListValue READ stringListValue WRITE setStringlistValue NOTIFY stringlistValueChanged)
    Q_PROPERTY(bool BoolValue READ boolValue WRITE setBoolValue NOTIFY boolValueChanged)
    Q_PROPERTY(int IntegerValue READ integerValue WRITE setIntegerValue NOTIFY integerValueChanged)
    Q_PROPERTY(double FloatValue READ floatValue WRITE setFloatValue NOTIFY floatValueChanged)
    Q_PROPERTY(QString Display READ display WRITE setDisplay NOTIFY displayChanged)
    Q_PROPERTY(QList<int> IntListValue READ intListValue WRITE setIntListValue NOTIFY intListValueChanged)
    Q_PROPERTY(QString SwitchValue READ switchValue WRITE setSwitchValue NOTIFY switchValueChanged)
    Q_PROPERTY(QString Unit READ unit WRITE setUnit NOTIFY UnitChanged)
    Q_PROPERTY(int BottomValue READ bottomValue WRITE setBottomValue NOTIFY bottomValueChanged)
    Q_PROPERTY(int TopValue READ topValue WRITE setTopValue NOTIFY topValueChanged)

public:
    OperationParamObject(QObject* parent = NULL):QObject(parent){}

    OperationParamObject(const OperationParamData &opd, QObject* parent = NULL)
        :QObject(parent), OperationParamData(opd)
    {
    }

    QString name()const {return Name;}
    void setName(const QString& str)
    {
        if (str != Name)
        {
            Name = str;
            emit nameChanged();
        }
    }

    QString type()const {return Type;}
    void settype(const QString& type)
    {
        if(Type != type)
        {
            Type = type;
            emit typeChanged();
        }
    }

    QString display()const {return Display;}
    void setDisplay(const QString& dis)
    {
        if(dis != Display)
        {
            Display = dis;
            emit displayChanged();
        }
    }

    QString stringValue()const {return StringValue;}
    void setStringValue(const QString&str)
    {
        if (StringValue != str)
        {
            StringValue = str;
            emit stringValueChanged();
        }
    }

    QStringList stringListValue()const {return StringListValue;}
    void setStringlistValue(const QStringList & strlist)
    {
        if (strlist != StringListValue)
        {
            StringListValue = strlist;
            emit stringlistValueChanged();
        }
    }

    bool boolValue()const {return BoolValue;}
    void setBoolValue(bool bl)
    {
        if (BoolValue != bl)
        {
            BoolValue = bl;
            emit boolValueChanged();
        }
    }

    int integerValue()const {return IntegerValue;}
    void setIntegerValue(int val)
    {
        if(IntegerValue != val)
        {
            IntegerValue = val;
            emit integerValueChanged();
        }
    }

    double floatValue()const {return FloatValue;}
    void setFloatValue(double val)
    {
        if ( qFabs(val - FloatValue) > 0.0001)
        {
            FloatValue = val;
            emit floatValueChanged();
        }
    }

    QList<int> intListValue(){ return IntListValue;}
    void setIntListValue(const QList<int> & val)
    {
        if(val != IntListValue)
        {
            IntListValue = val;
            emit intListValueChanged();
        }
    }

    QString switchValue() const {return SwitchValue;}
    void setSwitchValue(const QString &sval)
    {
        if (sval != SwitchValue)
        {
            SwitchValue = sval;
            emit switchValueChanged();
        }
    }

    QString unit()const {return Unit;}
    void setUnit(const QString& unit)
    {
        if(unit != Unit)
        {
            Unit = unit;
            emit UnitChanged();
        }
    }

    int bottomValue() const {return BottomValue;}
    void setBottomValue(int bottomval)
    {
        if(bottomval != BottomValue)
        {
            BottomValue = bottomval;
            emit bottomValueChanged();
        }
    }

    int topValue() const {return TopValue;}
    void setTopValue(int topval)
    {
        if(topval != TopValue)
        {
            TopValue = topval;
            emit topValueChanged();
        }
    }


signals:
    void nameChanged();
    void typeChanged();
    void stringValueChanged();
    void stringlistValueChanged();
    void boolValueChanged();
    void integerValueChanged();
    void floatValueChanged();
    void displayChanged();
    void intListValueChanged();
    void switchValueChanged();
    void UnitChanged();
    void bottomValueChanged();
    void topValueChanged();

//private:
//    QString Name;
//    QString Type;
//    QString StringValue;
//    QStringList StringListValue;
//    bool BoolValue;
//    int IntegerValue;
//    double FloatValue;
};

//class ParamListModel: public QAbstractListModel
//{
//    Q_OBJECT
//public:
//    enum ParamRoles{
//        nameRole = Qt::UserRole + 1,
//        typeRole,
//        stringValueRole,
//        stringlistValueRole,
//        boolValueRole,
//        integerValueRole,
//        floatValueRole,
//        displayRole
//    };
//    ParamListModel(QObject* parent = 0);

//    void addParam(const OperationParamData& par);
//    void resetParams(const QList<OperationParamData>& pars);
//    int rowCount(const QModelIndex &parent = QModelIndex()) const;
//    Q_INVOKABLE QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
//    Q_INVOKABLE virtual bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole);

//    Q_INVOKABLE void clear();
//    Q_INVOKABLE void printInfo();

//    Q_INVOKABLE OperationParamObject* getAt(int index);
//protected:
//    QHash<int, QByteArray> roleNames() const;

//private:
//    QList<OperationParamObject*> m_params;
//};


//class SingleStepPageModel: public QObject
//{
//public:
//    SingleStepPageModel(QObject *parent = 0);

//    QStringListModel& OperationModel() {return m_operationModel;}
//    ParamListModel& ParamModel() {return m_paramModel;}

//    void init(QQmlContext* context, const QStringList&,const QMap<QString, QString> &);
//private:
//    QStringListModel m_operationModel;
//    ParamListModel m_paramModel;
//    QString m_name;

//};

class OperationParamSelector: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> paramModel READ getParamModel WRITE setParamModel NOTIFY paramModelChanged)
public:
    OperationParamSelector(QObject* parent = 0);

    Q_INVOKABLE void init(const QString& pageName);

    QString pageName()const { return m_pagename;}
    void setPageName(const QString& name);

    int currentIndex()const {return m_currentIndex;}
    void setCurrentIndex(int index){
        if (index != m_currentIndex)
        {
            m_currentIndex = index;
            emit currentIndexChanged();
        }
    }

    Q_INVOKABLE QStringList operationModel() {return m_operationModel;}

    QList<QObject*> getParamModel() {return paramModel;}
    void setParamModel(const QList<QObject*> & params)
    {
        if(paramModel != params)
        {
            paramModel = params;
            emit paramModelChanged();
        }
    }

    //for qml
    Q_INVOKABLE void setSelectedOperation(int index);
    Q_INVOKABLE QObject* getSwitch(const QString& name);
    Q_INVOKABLE void onCompleteSingleOperation();
    Q_INVOKABLE int getBoardTypeIndexByPosition(int index);


signals:
    void pageNameChanged();
    void currentIndexChanged();
    void paramModelChanged();

private:
    QString m_pagename;
    int m_currentIndex;
    //SingleStepPageModel m_model;
    QStringList m_operationModel;
    QList<QObject*> paramModel;
    QList<OperationParamData> m_paramData;
};

class SingleOperationData
{
public:
    QString operationName;
    int sequenceNumber;
    QList<OperationParamData> params;
};

class SingleOperationObject:public QObject, SingleOperationData
{
    Q_OBJECT
    Q_PROPERTY(QString operationName READ getOperationName WRITE setOperationName NOTIFY operationNameChanged)
public:

    QString getOperationName(){return operationName;}
    void setOperationName(const QString& name)
    {
        if(operationName != name)
        {
            operationName = name;
            emit operationNameChanged();
        }
    }

signals:
    void operationNameChanged();
};

class PlanSelector: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QList<QObject*> paramListModel READ getParamListModel WRITE setParamListModel NOTIFY paramListModelChanged)
public:
    PlanSelector(QObject* parent = 0);
    ~PlanSelector();

    Q_INVOKABLE QStringList planListModel();
    Q_INVOKABLE QStringList stepListModel(int planIndex);
    Q_INVOKABLE QStringList planSelectStepListModel(int planIndex);
    Q_INVOKABLE QStringList operationListModel() {return m_operationListModel;}

    Q_INVOKABLE void startCheckPlan(int planIndex);
    Q_INVOKABLE void stopCheckPlan();

    QList<QObject*> getParamListModel() {return paramListModel;}
    void setParamListModel(const QList<QObject*> &paramlist)
    {
        if(paramListModel != paramlist)
        {
            paramListModel = paramlist;
            emit paramListModelChanged();
        }
    }

    Q_INVOKABLE void setSelectedStep(int planIndex, int stepIndex);
    Q_INVOKABLE void setSelectedOperation(int planIndex, int stepIndex, int index);

    Q_INVOKABLE int operationCurrentIndex();
    Q_INVOKABLE void addStep(int planIndex, int pos, int );
    Q_INVOKABLE void removeStep(int planIndex, int stepIndex);
    Q_INVOKABLE void moveStep(int planIndex, int stepIndex, int newIndex);

    Q_INVOKABLE void setPlanName(int planIndex, const QString& name);
    Q_INVOKABLE void addPlan(const QString& name);
    Q_INVOKABLE void removePlan(int index);

    Q_INVOKABLE QObject* getSwitch(const QString& name);

    Q_INVOKABLE void onComplete();
    Q_INVOKABLE bool onSave();
    Q_INVOKABLE void commitParam(int planIndex, int stepIndex, const QString& paramName, const QVariant& value);

    Q_INVOKABLE int getBoardTypeIndexByPosition(int index);

protected:
    bool eventFilter(QObject *watched, QEvent *event);
signals:
    void paramListModelChanged();
    void planCheckStatusChanged(const QJsonObject &jsObj);

private:
    QStringList m_operationListModel;
    QList<QObject*> paramListModel;
    SingleOperationData m_operationData;
};

class PlanController: public QObject
{
    Q_OBJECT
public:
    PlanController(QObject* parent = NULL);
    ~PlanController();

    Q_INVOKABLE void startPlan(int planIndex, int startStepIndex);
    Q_INVOKABLE void stopPlan();
    Q_INVOKABLE void resumePlan();


    virtual bool eventFilter(QObject *watched, QEvent *event);

 signals:
    void taskStateChanged(bool isRunning);

protected:
    int m_planIndex;
    int m_pauseIndex;
};

class StatusViewWatcher: public QObject
{
    Q_OBJECT
public:
    StatusViewWatcher(QObject* parent = 0);
    ~StatusViewWatcher();

    virtual bool eventFilter(QObject *watched, QEvent *event);

    Q_INVOKABLE QJsonObject getWorkLocationTypeList();
    Q_INVOKABLE bool setWorkLocationType(int configIndex, int workPlaceISndex, const QString& type);
    Q_INVOKABLE bool updateWorkPlace(const QJsonObject &jsobj);
    Q_INVOKABLE QJsonArray getWorkPlaceConstraint();


signals:
    void statusChanged(const QJsonObject& jsobj);
    void workLocationTypeChanged();
};

class MachineConfigData
{
public:
    MachineConfigData():port(0), maxReceiveTime(0) {}
    MachineConfigData(const QString& ip, qint16 pt, qint32 time, const QString& license):IpAddress(ip), port(pt), maxReceiveTime(time), licenseNumber(license){}

    QString IpAddress;
    qint16 port;
    qint32 maxReceiveTime;
    QString licenseNumber;
};

class TargetMachineObject: public QObject, public MachineConfigData
{
    Q_OBJECT
    Q_PROPERTY(QString IpAddress READ getIpAddress WRITE setIpAddress NOTIFY MachineConfigChanged)
    Q_PROPERTY(qint16 port READ getPort WRITE setPort NOTIFY MachineConfigChanged)
    Q_PROPERTY(qint32 maxReceiveTime READ getMaxReceiveTime WRITE setMaxReceiveTime NOTIFY MachineConfigChanged)
    Q_PROPERTY(QString licenseNumber READ getLicenseNumber WRITE setLicenseNumber NOTIFY MachineConfigChanged)
public:
    TargetMachineObject(QObject* parent = NULL): QObject(parent)
    {
        //connect(this, &TargetMachineObject::MachineConfigChanged, this ,&TargetMachineObject::onMachineConfigChanged);
    }

    void init(const QString& ip, qint16 pt, qint32 time, const QString& license)
    {
        IpAddress = ip;
        port = pt;
        maxReceiveTime = time;
        licenseNumber = license;
    }

    QString getIpAddress()const {return IpAddress;}
    void setIpAddress(const QString& ip)
    {
        if(IpAddress != ip)
        {
            IpAddress = ip;
            emit MachineConfigChanged();
        }
    }

    qint16 getPort()const{return port;}
    void setPort(qint16 pt)
    {
        if(port != pt)
        {
            port = pt;
            emit MachineConfigChanged();
        }
    }

    qint32 getMaxReceiveTime()const{return maxReceiveTime;}
    void setMaxReceiveTime(qint32 time)
    {
        if(maxReceiveTime != time)
        {
            maxReceiveTime = time;
            emit MachineConfigChanged();
        }
    }
    QString getLicenseNumber()const{return licenseNumber;}
    void setLicenseNumber(const QString& licenseStr)
    {
        if(licenseNumber != licenseStr)
        {
            licenseNumber = licenseStr;
            emit MachineConfigChanged();
        }
    }

signals:
    void MachineConfigChanged();

public slots:
    bool onMachineConfigChanged();


private:
};

class TextFieldDoubleValidator: public QDoubleValidator
{
public:
    TextFieldDoubleValidator(QObject* parent = 0): QDoubleValidator(parent){}
    TextFieldDoubleValidator(double bottom, double top, int decimals, QObject* parent)
        :QDoubleValidator(bottom, top, decimals, parent){}

    QValidator::State validate(QString &s, int &pos) const
    {
        if (s.isEmpty() || s.startsWith("-"))
        {
            return QValidator::Intermediate;
        }

        QChar point = locale().decimalPoint();
        if(s.indexOf(point) != -1)
        {
            int lengthDecimals = s.length() - s.indexOf(point) - 1;
            if(lengthDecimals > decimals())
            {
                return QValidator::Invalid;
            }
        }
        bool isNumber;
        double value = locale().toDouble(s, &isNumber);
        if(isNumber && bottom() <= value && value <= top())
        {
            return QValidator::Acceptable;
        }
        return QValidator::Invalid;
    }
};

class ConfigFileConverter:public QObject
{
    Q_OBJECT
public:
    ConfigFileConverter(QObject* parent = NULL);

    Q_INVOKABLE bool importConfigFile(const QString& filename);
    Q_INVOKABLE bool exportConfigFile(const QString& filename);
};

class FileViewModel: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool dirOnly READ getDirOnly WRITE setDirOnly NOTIFY dirOnlyChanged)
public:
    FileViewModel(QObject* parent = NULL);

    void setDirOnly(bool dir);
    bool getDirOnly();

    Q_INVOKABLE QModelIndex rootIndex();
    Q_INVOKABLE QAbstractItemModel* fileSystemModel();
    Q_INVOKABLE QString fullFileName(const QModelIndex&);

signals:
    void dirOnlyChanged();

private:
    bool dirOnly;
    QFileSystemModel *m_Model;
};


class AdministratorChecker: public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool bAdministrator READ isAdministrator WRITE setAdministrator NOTIFY administratorChanged)

public:
    AdministratorChecker(QObject* parent=NULL):QObject(parent), bAdministrator(false){}

    bool isAdministrator()
    {
        return bAdministrator;
    }
    void setAdministrator(bool isAdmin)
    {
        if(bAdministrator != isAdmin)
        {
            bAdministrator = isAdmin;
            emit administratorChanged();
        }
    }
signals:
    void administratorChanged();

private:
    bool bAdministrator;
};

#endif // WORKMODELS_H
