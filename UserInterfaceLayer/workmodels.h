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

class OperationParamData
{
public:
    OperationParamData() {}
    OperationParamData(const QString& oname, const QString& otype, const QString& ostringValue, const QStringList& ostringlistValue,
                       bool oboolvalue, int ointegerValue, const QString& display, const QList<int> intlist, const QString& switchVal)
    {
        Name = oname;
        Type = otype;
        StringValue = ostringValue;
        StringListValue = ostringlistValue;
        BoolValue = oboolvalue;
        IntegerValue = ointegerValue;
        Display = display;
        IntListValue = intlist;
        SwitchValue = switchVal;
    }
    OperationParamData(const OperationParamData& opd)
    {
        Name = opd.Name;
        Type = opd.Type;
        StringValue = opd.StringValue;
        StringListValue = opd.StringListValue;
        BoolValue = opd.BoolValue;
        IntegerValue = opd.IntegerValue;
        Display = opd.Display;
        IntListValue = opd.IntListValue;
        SwitchValue = opd.SwitchValue;
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

    int floatValue()const {return FloatValue;}
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

    QString switchValue() {return SwitchValue;}
    void setSwitchValue(QString sval)
    {
        if (sval != SwitchValue)
        {
            SwitchValue = sval;
            emit switchValueChanged();
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

public:
    OperationParamSelector(QObject* parent = 0);

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

    Q_INVOKABLE QList<QObject*> paramModel() {return m_paramModel;}

    //for qml
    Q_INVOKABLE void setSelectedOperation(int index);
    Q_INVOKABLE QObject* getSwitch(const QString& name);
    Q_INVOKABLE void onCompleteSingleOperation(int seq);


signals:
    void pageNameChanged();
    void currentIndexChanged();

private:
    QString m_pagename;
    int m_currentIndex;
    //SingleStepPageModel m_model;
    QStringList m_operationModel;
    QList<QObject*> m_paramModel;
    QList<OperationParamData> m_paramData;
};

class SingleOperationObject
{
public:

    QString operationName;
    int sequenceNumber;
    QList<OperationParamObject*> params;
};


#endif // WORKMODELS_H
