#include "workmodels.h"
#include "configfilehandler.h"
#include "environmentvariant.h"
#include <QJsonDocument>
#include <QJsonArray>

const char* operationModelName = "OperationModel";
const char* paramModelName = "ParamModel";

//ParamListModel::ParamListModel(QObject *parent)
//    : QAbstractListModel(parent)
//{
//}

//void ParamListModel::addParam(const OperationParamData &operation)
//{
//    beginInsertRows(QModelIndex(), rowCount(), rowCount());
//    m_params.append(new OperationParamObject(operation));
//    endInsertRows();
//}

//void ParamListModel::resetParams(const QList<OperationParamData>& pars)
//{
//    beginResetModel();
//    m_params.clear();
//    foreach (const OperationParamData& dat, pars) {
//        m_params.append(new OperationParamObject(dat));
//    }
//    endResetModel();
//}

//int ParamListModel::rowCount(const QModelIndex & parent) const {
//    Q_UNUSED(parent);
//    return m_params.count();
//}

//QVariant ParamListModel::data(const QModelIndex & index, int role) const {
//    if (index.row() < 0 || index.row() >= m_params.count())
//        return QVariant();

//    const OperationParamObject &op = *m_params[index.row()];
//    if (role == nameRole)
//        return op.name();
//    else if (role == typeRole)
//        return op.type();
//    else if (role == stringValueRole)
//        return op.stringValue();
//    else if(role == stringlistValueRole)
//        return op.stringListValue();
//    else if(role == boolValueRole)
//        return op.boolValue();
//    else if (role == integerValueRole)
//        return op.integerValue();
//    else if (role == floatValueRole)
//        return op.floatValue();
//    else if(role == displayRole)
//        return op.display();
//    return QVariant();
//}


//bool ParamListModel::setData(const QModelIndex &index, const QVariant &value, int role)
//{
//    if (index.row() < 0 || index.row() >= m_params.count())
//        return false;

//    OperationParamObject &op = *m_params[index.row()];
//    if (role == nameRole)
//    {
//        op.setName(value.toString());
//        return true;
//    }
//    else if (role == typeRole)
//    {
//        op.settype(value.toString());
//        return true;
//    }
//    else if (role == stringValueRole)
//    {
//        op.setStringValue(value.toString());
//        return true;
//    }
//    else if(role == stringlistValueRole)
//    {
//        op.setStringlistValue(value.toStringList());
//        return true;
//    }
//    else if(role == boolValueRole)
//    {
//        op.setBoolValue(value.toBool());
//        return true;
//    }
//    else if (role == integerValueRole)
//    {
//        op.setIntegerValue(value.toInt());
//        return true;
//    }
//    else if(role == floatValueRole)
//    {
//        op.setFloatValue(value.toDouble());
//        return true;
//    }
//    else if(role == displayRole)
//    {
//        op.setDisplay(value.toString());
//        return true;
//    }
//    return false;
//}

//void ParamListModel::clear()
//{
//    beginRemoveRows(QModelIndex(), 0, m_params.size()-1);
//    m_params.clear();
//    endRemoveRows();
//}

//void ParamListModel::printInfo()
//{
//    foreach(OperationParamObject* pParm, m_params)
//    {
//        qDebug()<<"ParamListModel item name:"<<pParm->name()<<\
//                  "\ntype:"<<pParm->type()<<\
//                  "\nString:"<<pParm->stringValue()<<\
//                  "\nEnums:"<<pParm->stringListValue()<<\
//                  "\nbool:"<<pParm->boolValue()<<\
//                  "\nInt:"<<pParm->integerValue()<<\
//                  "\nFloat:"<<pParm->floatValue()<<\
//                  "\nDisplay"<<pParm->display();
//    }
//}

//OperationParamObject* ParamListModel::getAt(int index)
//{
//    if(index< 0 || index > m_params.count())
//        return NULL;
//    return m_params[index];
//}


//QHash<int, QByteArray> ParamListModel::roleNames() const {
//    QHash<int, QByteArray> roles;
//    roles[nameRole] = "name";
//    roles[typeRole] = "type";
//    roles[stringValueRole] = "stringValue";
//    roles[stringlistValueRole] = "stringlistValue";
//    roles[boolValueRole] = "boolValue";
//    roles[integerValueRole] = "integerValue";
//    roles[floatValueRole] = "floatValue";
//    roles[displayRole] = "display";
//    return roles;
//}


//SingleStepPageModel::SingleStepPageModel(QObject *parent)
//    :QObject(parent),m_name("SingleStepPage")
//{

//}

//void SingleStepPageModel::init(QQmlContext* context, const QStringList& operationList, const QMap<QString, QString> & operationName)
//{
//    QStringList operationStr;
//    foreach(const QString& str, operationList)
//    {
//        operationStr.append(operationName[str]);
//    }
//    m_operationModel.setStringList(operationStr);
//    m_paramModel.clear();

//    //context->setContextProperty(m_name+operationModelName, &m_operationModel);
//    //context->setContextProperty(m_name+paramModelName, &m_paramModel);
//}

OperationParamSelector::OperationParamSelector(QObject* parent)
    :QObject(parent),m_currentIndex(-1)
{

}

void OperationParamSelector::init(const QString& group)
{
    if (group == "NormalOperation")
    {
        m_operationModel = EnvironmentVariant::instance()->OperationNameList();
    }
    else if (group == "LogicalControl")
    {
        m_operationModel = EnvironmentVariant::instance()->OperationNameList();
        m_operationModel.append(EnvironmentVariant::instance()->LogicalControlList());
    }
}

void OperationParamSelector::setSelectedOperation(int index)
{
    //    if (selectedOp == "")
    //    {
    //        m_selectedOperation = "";
    //        EnvironmentVariant::instance()->changeModel(m_pagename, paramModelName, QString());
    //    }
    //    else if (selectedOp != m_selectedOperation)
    //    {
    //        m_selectedOperation = selectedOp;

    //        EnvironmentVariant::instance()->changeModel(m_pagename, paramModelName, selectedOp);
    //    }

    if (index != m_currentIndex)
    {
        m_currentIndex = index;
        m_paramData = EnvironmentVariant::instance()->getOperationParams(index);

        foreach (QObject* obj, m_paramModel) {
            if(obj)
                delete obj;
        }
        m_paramModel.clear();
        foreach(const OperationParamData& data, m_paramData)
        {
            m_paramModel.append(new OperationParamObject(data));
        }
    }
}

void OperationParamSelector::setPageName(const QString& name)
{
    if (name != m_pagename)
    {
        m_pagename = name;
        emit pageNameChanged();
    }
}

QObject* OperationParamSelector::getSwitch(const QString &name)
{
    foreach(QObject* pObj, m_paramModel)
    {
        OperationParamObject* pParam = dynamic_cast<OperationParamObject*>(pObj);
        if (pParam && name == pParam->name())
        {
            qDebug()<<"getswitch:"<<pParam->name()<<" value:"<<pParam->boolValue();
            return pParam;
        }
    }
    return NULL;
}

void OperationParamSelector::onCompleteSingleOperation()
{
    SingleOperationData opobj;
    opobj.operationName = EnvironmentVariant::instance()->OperationNameList().at(m_currentIndex);
    opobj.sequenceNumber = 0;
    foreach(QObject* pObj, m_paramModel)
    {
        OperationParamObject* pParam = qobject_cast<OperationParamObject*>(pObj);
        if (pParam)
        {
            OperationParamData* data = static_cast<OperationParamData*>(pParam);
            if (data)
                opobj.params.append(*data);
        }
    }
    QJsonObject operationObj = EnvironmentVariant::instance()->formatSingleOperationParam(opobj);

    EnvironmentVariant::instance()->runTask(operationObj);
}


PlanSelector::PlanSelector(QObject* parent )
    :QObject(parent)
{
    m_planListModel = EnvironmentVariant::instance()->PlanList();

    m_operationListModel = EnvironmentVariant::instance()->OperationNameList();
    m_operationListModel.append(EnvironmentVariant::instance()->LogicalControlList());

}

void PlanSelector::setSelectedPlan(int index)
{
    m_stepListModel = EnvironmentVariant::instance()->StepList(index);
}

void PlanSelector::setSelectedStep(int planIndex, int stepIndex)
{
    m_operationData = EnvironmentVariant::instance()->planStepParam(planIndex, stepIndex);

    foreach (QObject* obj, m_paramListModel) {
        if(obj)
            delete obj;
    }
    m_paramListModel.clear();
    foreach(const OperationParamData& data, m_operationData.params)
    {
        m_paramListModel.append(new OperationParamObject(data));
    }
}

void PlanSelector::setSelectedOperation(int stepIndex, int opIndex)
{
    if (stepIndex >= 0 && stepIndex < m_stepListModel.size() && opIndex >= 0 && opIndex < m_operationListModel.size())
    {
        m_paramData = EnvironmentVariant::instance()->getOperationParams(opIndex);
        m_stepListModel[stepIndex] = m_operationListModel[opIndex];

        foreach (QObject* obj, m_paramListModel) {
            if(obj)
                delete obj;
        }
        m_paramListModel.clear();
        foreach(const OperationParamData& data, m_paramData)
        {
            m_paramListModel.append(new OperationParamObject(data));
        }
    }
}

int PlanSelector::operationCurrentIndex()
{
    return EnvironmentVariant::instance()->getOperationIndex(m_operationData.operationName);
}

void PlanSelector::addStep(int planIndex, int pos, int index)
{
    if (pos == -1)
    {
        m_stepListModel.append(m_operationListModel[index]);
    }
    else
    {
        m_stepListModel.insert(pos, m_operationListModel[index]);
    }

    EnvironmentVariant::instance()->AddPlanStep(planIndex, pos, m_operationListModel[index]);
}

void PlanSelector::onComplete()
{
}

void PlanSelector::onSave()
{
}

QObject* PlanSelector::getSwitch(const QString &name)
{
    foreach(QObject* pObj, m_paramListModel)
    {
        OperationParamObject* pParam = dynamic_cast<OperationParamObject*>(pObj);
        if (pParam && name == pParam->name())
        {
            qDebug()<<"getswitch:"<<pParam->name()<<" value:"<<pParam->boolValue();
            return pParam;
        }
    }
    return NULL;
}



