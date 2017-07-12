#include "workmodels.h"
#include "configfilehandler.h"
#include "environmentvariant.h"
#include <QJsonDocument>
#include <QJsonArray>
#include "BussinessLayer/WorkflowProtocol/workflowChecker.h"

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
        m_operationModel = EnvironmentVariant::instance()->LogicalControlList();
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

        foreach (QObject* obj, paramModel) {
            if(obj)
                delete obj;
        }
        paramModel.clear();
        foreach(const OperationParamData& data, m_paramData)
        {
            paramModel.append(new OperationParamObject(data, this));
        }
        emit paramModelChanged();
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
    foreach(QObject* pObj, paramModel)
    {
        OperationParamObject* pParam = dynamic_cast<OperationParamObject*>(pObj);
        if (pParam && name == pParam->name())
        {
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
    foreach(QObject* pObj, paramModel)
    {
        OperationParamObject* pParam = qobject_cast<OperationParamObject*>(pObj);
        if (pParam)
        {
            OperationParamData* data = static_cast<OperationParamData*>(pParam);
            if (data)
                opobj.params.append(*data);
        }
    }

    EnvironmentVariant::instance()->StartTunning(opobj);
}

int OperationParamSelector::getBoardTypeIndexByPosition(int index)
{
    return EnvironmentVariant::instance()->getBoardTypeIndexByPosition(index);
}

PlanSelector::PlanSelector(QObject* parent )
    :QObject(parent)
{
    m_operationListModel = EnvironmentVariant::instance()->LogicalControlList();
    qApp->installEventFilter(this);
}

PlanSelector::~PlanSelector()
{
    qApp->removeEventFilter(this);
}

QStringList PlanSelector::planListModel()
{
    return EnvironmentVariant::instance()->PlanList();
}

QStringList PlanSelector::stepListModel(int planIndex)
{
    return EnvironmentVariant::instance()->StepList(planIndex);
}

QStringList PlanSelector::planSelectStepListModel(int planIndex)
{
    return EnvironmentVariant::instance()->planSelectStepListModel(planIndex);
}

void PlanSelector::setSelectedStep(int planIndex, int stepIndex)
{
    m_operationData = EnvironmentVariant::instance()->planStepParam(planIndex, stepIndex);

    foreach (QObject* obj, paramListModel) {
        if(obj)
            delete obj;
    }
    paramListModel.clear();
    foreach(const OperationParamData& data, m_operationData.params)
    {
        paramListModel.append(new OperationParamObject(data, this));
    }
    emit paramListModelChanged();
}

void PlanSelector::setSelectedOperation(int planIndex, int stepIndex, int opIndex)
{
    if (opIndex >= 0 && opIndex < m_operationListModel.size())
    {
        EnvironmentVariant::instance()->SetPlanStepToDefault(planIndex, stepIndex, opIndex);

        QList<OperationParamData> paramData = EnvironmentVariant::instance()->getOperationParams(opIndex);

        foreach (QObject* obj, paramListModel) {
            if(obj)
                delete obj;
        }
        paramListModel.clear();
        foreach(const OperationParamData& data, paramData)
        {
            paramListModel.append(new OperationParamObject(data, this));
        }
        emit paramListModelChanged();
    }
}

int PlanSelector::operationCurrentIndex()
{
    return EnvironmentVariant::instance()->getOperationIndex(m_operationData.operationName);
}

void PlanSelector::addStep(int planIndex, int pos, int index)
{
    EnvironmentVariant::instance()->AddPlanStep(planIndex, pos, index);
}

void PlanSelector::removeStep(int planIndex, int stepIndex)
{
    EnvironmentVariant::instance()->RemovePlanStep(planIndex, stepIndex);
}

void PlanSelector::moveStep(int planIndex, int stepIndex, int newIndex)
{
    EnvironmentVariant::instance()->MovePlanStep(planIndex, stepIndex, newIndex);
}

void PlanSelector::setPlanName(int planIndex, const QString &name)
{
    EnvironmentVariant::instance()->SetPlanName(planIndex, name);
}

void PlanSelector::addPlan(const QString &name)
{
    EnvironmentVariant::instance()->AddPlan(name);
}

void PlanSelector::removePlan(int index)
{
    EnvironmentVariant::instance()->RemovePlan(index);
}

void PlanSelector::onComplete()
{
}

void PlanSelector::onSave()
{
    EnvironmentVariant::instance()->SavePlan();
}

void PlanSelector::commitParam(int planIndex, int stepIndex, const QString& paramName, const QVariant& value)
{
    EnvironmentVariant::instance()->SetPlanStepSingleParam(planIndex, stepIndex, paramName, value);
}

int PlanSelector::getBoardTypeIndexByPosition(int index)
{
    return EnvironmentVariant::instance()->getBoardTypeIndexByPosition(index);
}

QObject* PlanSelector::getSwitch(const QString &name)
{
    foreach(QObject* pObj, paramListModel)
    {
        OperationParamObject* pParam = dynamic_cast<OperationParamObject*>(pObj);
        if (pParam && name == pParam->name())
        {
            return pParam;
        }
    }
    return NULL;
}

void PlanSelector::startCheckPlan(int planIndex)
{
    EnvironmentVariant::instance()->startCheckPlan(planIndex);
}

bool PlanSelector::eventFilter(QObject *watched, QEvent *event)
{
    if(event->type() == QEvent::User+3)
    {
        CheckStateChangeEvent* evt = dynamic_cast<CheckStateChangeEvent*>(event);
        if(evt)
        {
            emit planCheckStatusChanged(evt->m_status);
            return true;
        }
    }
    return false;
}

PlanController::PlanController(QObject *parent)
    :QObject(parent), m_planIndex(-1),m_pauseIndex(-1)
{
    qApp->installEventFilter(this);
}

PlanController::~PlanController()
{
    qApp->removeEventFilter(this);
}

void PlanController::startPlan(int planIndex, int startStepIndex)
{
    m_planIndex = planIndex;
    m_pauseIndex = 0;
    EnvironmentVariant::instance()->StartPlan(planIndex, startStepIndex);
}

void PlanController::stopPlan()
{
    EnvironmentVariant::instance()->StopPlan();
}

void PlanController::resumePlan()
{
    if(m_planIndex >= 0 && m_pauseIndex >= 0)
    {
        startPlan(m_planIndex, m_pauseIndex);
    }
}

bool PlanController::eventFilter(QObject *watched, QEvent *event)
{
    if(event->type() == QEvent::User+2)
    {
        RunningStateChangeEvent* evt = dynamic_cast<RunningStateChangeEvent*>(event);
        if(evt)
        {
            emit taskStateChanged(evt->running);
            m_pauseIndex = evt->stepIndex;
            return true;
        }
    }
    return false;
}

StatusViewWatcher::StatusViewWatcher(QObject* parent)
    :QObject(parent)
{
    qApp->installEventFilter(this);
    connect(EnvironmentVariant::instance(), &EnvironmentVariant::workLocationTypeChanged, this, &StatusViewWatcher::workLocationTypeChanged);
}

StatusViewWatcher::~StatusViewWatcher()
{
    qApp->removeEventFilter(this);
    disconnect(EnvironmentVariant::instance(), &EnvironmentVariant::workLocationTypeChanged, this, &StatusViewWatcher::workLocationTypeChanged);
}

bool StatusViewWatcher::eventFilter(QObject *watched, QEvent *event)
{
    if(event->type() == QEvent::User+1)
    {
        StatusChangeEvent* evt = dynamic_cast<StatusChangeEvent*>(event);
        if(evt)
        {
            emit statusChanged(evt->jsObject);
        }
    }
    return false;
}

QJsonObject StatusViewWatcher::getWorkLocationTypeList()
{
    return EnvironmentVariant::instance()->getWorkLocationTypeList();
}

bool StatusViewWatcher::setWorkLocationType(int configIndex, int workPlaceIndex, const QString& type)
{
    if(EnvironmentVariant::instance()->setWorkLocationType(configIndex, workPlaceIndex, type))
    {
        return true;
    }
    return false;
}

bool StatusViewWatcher::updateWorkPlace(const QJsonObject &jsobj)
{
    if(EnvironmentVariant::instance()->updateWorkPlace(jsobj))
    {
        return true;
    }
    else
    {
        return false;
    }
}

QJsonArray StatusViewWatcher::getWorkPlaceConstraint()
{
    return EnvironmentVariant::instance()->WorkPlaceConstraint();
}

void TargetMachineObject::onMachineConfigChanged()
{
    EnvironmentVariant::instance()->SaveMachineConfig(MachineConfigData(IpAddress, port, maxReceiveTime));
}
