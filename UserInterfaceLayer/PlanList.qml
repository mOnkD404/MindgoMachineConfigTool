import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import QtQml.Models 2.2

Item {
    id: root

    function savePlan(){
        selector.onSave();
    }

    PlanSelector{
        id:selector
    }

    property var columnWidth;

    columnWidth: 150

    Row {
        id: row
        anchors.topMargin: 10
        spacing: 10
        anchors.fill: parent

        Item {
            id: planColumn
            width: columnWidth
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0

            Rectangle{
                id: userPlanSelect
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 30

                Text {
                    text: qsTr("Plan list")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.pixelSize: 17
                    font.bold: true
                    width: 120
                    color:"#d9d9d9"
                }
            }

            ActionBar{
                id:planActionbar
                positionAction: false

                height: 30

                anchors.top: userPlanSelect.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                onDoAction: {
                    if(str == "edit"){
                        if(planListView.currentIndex != -1){
                            planListView.currentItem.inEdit = true;
                        }
                    }else if(str == "add"){
                        planListModel.append({"name":"NewPlan"});
                        selector.addPlan(planListView.currentIndex, "");
                        planListView.currentIndex = planListModel.count - 1;
                        stepListView.refreshStepListModel();
                        planListView.currentItem.inEdit = true;
                    }else if(str == "delete"){
                        planListModel.remove(planListView.currentIndex);
                        selector.removePlan(planListView.currentIndex);
                        stepListView.refreshStepListModel();
                    }
                }
            }

            ListModel{
                id:planListModel
            }


            ListView {
                id: planListView
                spacing: 4
                anchors.top: planActionbar.bottom
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                clip: true
                highlight: Rectangle{
                    height: 30
                    anchors.left: parent.left
                    anchors.right: parent.right

                    color: "#ffb902"
                    radius: 0
                }
                highlightFollowsCurrentItem: true
                currentIndex: 0
                interactive: false
                model: planListModel

                delegate: Item{
                    property bool inEdit: false
                    height: 30
                    anchors.left:parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    focus:true

                    TextInput{
                        id:inputArea
                        visible: inEdit

                        height: 30
                        font.italic: true
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 20

                        anchors.left:parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        focus: true
                        text:name

                        onAccepted: {
                            planListModel.setProperty(index, "name", text);
                            selector.setPlanName(index, text);
                            parent.inEdit = false;
                        }
                        onVisibleChanged: {
                            if(visible){
                                focus = true;
                                selectAll();
                                forceActiveFocus();
                            }
                        }

                        onFocusChanged: {
                            if(!focus){
                                planListModel.setProperty(index, "name", text);
                                selector.setPlanName(index, text);
                                parent.inEdit = false;
                            }
                        }
                    }

                    TextButton {
                        visible: !inEdit

                        height: 30
                        anchors.left:parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0

                        buttonradius: 0

                        textValue: name
                        startColor: "transparent"
                        stopColor: "transparent"
                        onClicked: {
                            console.debug(modelData+"clicked");
                            planListView.currentIndex = index;
                        }
                    }
                }
                onCurrentIndexChanged: {
                    stepListView.refreshStepListModel();

                }
                Component.onCompleted: {
                    refreshPlanListModel();
                    stepListView.refreshStepListModel();
                }

                function refreshPlanListModel(){
                    var list = selector.planListModel();
                    planListModel.clear();
                    for(var ind = 0; ind < list.length; ind++){
                        planListModel.append({"name":list[ind]});
                    }
                    currentIndex = 0;
                }
            }
        }


        Item {
            id: stepColumn
            width: columnWidth
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0

            Rectangle{
                id: stepList
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 30

                Text {
                    text: qsTr("Step list")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.pixelSize: 17
                    font.bold: true
                    width: 120
                    color:"#d9d9d9"
                }

            }

            ActionBar{
                id:stepActionBar

                height: 30

                anchors.top: stepList.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                onDoAction: {
                    if (str == "add"){
                        operationColumn.changeOperation = "add"
                        operationColumn.visible = true;
                    }else if(str == "edit"){
                        operationColumn.changeOperation = "edit";
                        operationColumn.visible = true;
                    }else if(str == "up"){
                        selector.moveStep(planListView.currentIndex, stepListView.currentIndex, stepListView.currentIndex-1);
                        stepListModel.move(stepListView.currentIndex, stepListView.currentIndex - 1, 1);
                    }else if(str == "down"){
                        selector.moveStep(planListView.currentIndex, stepListView.currentIndex, stepListView.currentIndex+1);
                        stepListModel.move(stepListView.currentIndex, stepListView.currentIndex + 1, 1);
                    }else if(str == "delete"){
                        selector.removeStep(planListView.currentIndex, stepListView.currentIndex);
                        stepListModel.remove(stepListView.currentIndex);
                        if(stepListView.count > 0){
                            if(stepListView.currentIndex > 0){
                                stepListView.currentIndex = stepListView.currentIndex -1;
                            }else {
                                selector.setSelectedStep(planListView.currentIndex, stepListView.currentIndex);
                                //paramList.model = selector.paramListModel();
                            }
                        }
                    }
                }
            }

            ListModel{
                id:stepListModel
            }

            DelegateModel{
                id:stepVisualModel

                model: stepListModel
                delegate:stepDelegate
            }

            ListView {
                id: stepListView

                function refreshStepListModel(){
                    var list = selector.stepListModel(planListView.currentIndex);
                    stepListModel.clear();
                    for(var ind = 0; ind < list.length; ind++){
                        stepListModel.append({"name":list[ind]});
                    }
                    currentIndex = 0;

                    selector.setSelectedStep(planListView.currentIndex, 0);
                    //paramList.model = selector.paramListModel();
                }

                spacing: 4
                anchors.top: stepActionBar.bottom
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                model: stepVisualModel

                clip: true
                highlight: Rectangle{
                    height: 30

                    color: "#5cc5ff"
                    radius: 0

                    Component.onCompleted: {
                        if(parent){
                            anchors.left = parent.left;
                            anchors.right = parent.right;
                        }
                    }
                }
                highlightFollowsCurrentItem: true
                currentIndex: 0
                interactive: true

                onCurrentIndexChanged: {
                    selector.setSelectedStep(planListView.currentIndex, currentIndex);

                    //operationList.currentIndex = selector.operationCurrentIndex();
                   // paramList.model = selector.paramListModel();
                    if(operationColumn.visible) operationColumn.visible = false;
                }
            }

            Component{
                id: stepDelegate

                MouseArea {
                    id: stepItem

                    property bool held: false

                    anchors { left: parent.left; right: parent.right }
                    height: stepContent.height

                    drag.target: held ? stepContent : undefined
                    drag.axis: Drag.YAxis

                    onPressAndHold: {
                        console.debug("holding");
                        parent.held = true;
                    }
                    onReleased: {
                        console.debug("release");
                        parent.height = false;
                    }

                    TextButton {
                        id: stepContent
                        height: 30
                        anchors.left:parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0

                        buttonradius: 0
                        textValue: (index+1) + ". " + name
                        startColor: "transparent"
                        stopColor: "transparent"

                        Drag.active: stepItem.held
                        Drag.source: stepItem
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2

                        states: State {
                            when: stepItem.held

                            ParentChange { target: stepContent; parent: stepListView }
                            AnchorChanges {
                                target: stepContent
                                anchors { horizontalCenter: undefined; verticalCenter: undefined }
                            }
                        }

                        onClicked: {
                            stepListView.currentIndex = index;
                        }
                    }

                    DropArea {
                        anchors { fill: parent; margins: 10 }

                        onEntered: {
                            console.debug("start pos "+drag.source.DelegateModel.itemsIndex+" new index "+stepItem.DelegateModel.itemsIndex);
                            stepVisualModel.items.move(drag.source.DelegateModel.itemsIndex,stepItem.DelegateModel.itemsIndex);
                        }
                    }
                }
            }
        }

        Item {
            property var  changeOperation;

            id: operationColumn
            width: columnWidth
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            visible: false

            changeOperation:"add"

            Rectangle{
                id: operationType
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 30

                Text {
                    text: qsTr("Operation type")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.pixelSize: 17
                    font.bold: true
                    width: 120
                    color:"#d9d9d9"
                }
            }


            ListView {
                id: operationList
                highlightRangeMode: ListView.NoHighlightRange
                highlightMoveDuration: 0
                snapMode: ListView.NoSnap
                spacing: 4
                anchors.top: operationType.bottom
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                clip: true
                highlight: Rectangle{
                    height: 30

                    color: "#5cc5ff"
                    radius: 0
                    Component.onCompleted: {
                        if(parent){
                            anchors.left = parent.left;
                            anchors.right = parent.right;
                        }
                    }
                }
                highlightFollowsCurrentItem: true
                currentIndex: -1
                interactive: false

                delegate: TextButton {
                    height: 30

                    anchors.left:parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    buttonradius: 0

                    textValue: modelData
                    startColor: "transparent"
                    stopColor: "transparent"
                    onClicked: {
                        console.debug(modelData+"clicked");
                        operationList.currentIndex = index;
                        operationColumn.visible = false;


                        if(operationColumn.changeOperation == "add"){
                            selector.addStep(planListView.currentIndex, stepListView.count, index);
                            stepListModel.append({"name":textValue});

                            selector.setSelectedOperation(planListView.currentIndex, stepListView.count - 1, index);
                            //paramList.model = selector.paramListModel();

                            stepListView.currentIndex = stepListView.count - 1;
                        }else if (operationColumn.changeOperation == "edit"){
                            selector.setSelectedOperation(planListView.currentIndex, stepListView.currentIndex, index);
                            stepListModel.setProperty(stepListView.currentIndex, "name", textValue);
                            //paramList.model = selector.paramListModel();
                        }
                    }
                }

                Component.onCompleted:
                {
                    model = selector.operationListModel();
                }
                onVisibleChanged: {
                    if((operationColumn.changeOperation == false) && (operationColumn.visible == true)){
                        currentIndex = selector.operationCurrentIndex();
                    }else {
                        currentIndex = -1;
                    }
                }
            }
        }

        Item {
            id: paramColumn
            width: columnWidth*2.5
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            visible: !operationColumn.visible

            Rectangle{
                id: operationParam
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 30

                Text {
                    text: qsTr("Operation param")
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 17
                    font.bold: true

                    color:"#d9d9d9"
                }
            }

            ListView {
                id: paramList
                anchors.leftMargin: 0
                clip:true
                spacing: 4
                anchors.top: operationParam.bottom
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                interactive: false
                model: selector.paramListModel

                delegate: Item {
                    height:30
                    anchors.left: parent.left
                    anchors.right: parent.right



                    enabled:getSwitchState()
                    function getSwitchState()
                    {
                        var obj = selector.getSwitch(modelData.SwitchValue);
                        if (obj)
                            return obj.BoolValue;
                        else
                            return true;
                    }

                    opacity: enabled? 1.0: 0.5

                    Text {
                        id: paramName
                        height:30
                        width:100
                        text: modelData.Display
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color:"#d9d9d9"
                        font.pixelSize: 17
                        font.bold: true
                    }

                    Component{
                        id: texteditComponent

                        Rectangle{
                            anchors.fill: parent
                            border.width: 2
                            border.color: "#ffffff"
                            radius: 4

                            TextInput{
                                id: textedit
                                property bool init: false
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                verticalAlignment: TextEdit.AlignVCenter
                                validator: getValidator()
                                focus:true
                                activeFocusOnTab: true
                                selectByMouse: true
                                //text: getText()

                                Component.onCompleted: {
                                    text = getText();
                                    init = true;
                                }
                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        selectAll();
                                    }else{
                                        deselect();
                                    }
                                }

                                function getText() {
                                    if(modelData.Type == "integer"){
                                        return modelData.IntegerValue.toString();
                                    }else if(modelData.Type == "float"){                                        
                                        return modelData.FloatValue.toFixed(1);
                                    }else{
                                        return modelData.StringValue;
                                    }
                                }

                                function getValidator(){
                                    if(modelData.Type == "integer"){
                                        return intValidator;
                                    }
                                    else if(modelData.Type == "float"){                                        
                                        return floatValidator;
                                    }
                                    return validator;
                                }


                                IntValidator{
                                    id:intValidator
                                    bottom: modelData.BottomValue
                                    top:modelData.TopValue
                                }

                                TextFieldDoubleValidator{
                                    id:floatValidator
                                    bottom:modelData.BottomValue
                                    top:modelData.TopValue
                                    decimals: 1
                                }

                                onTextChanged: {
                                    if(init == true){
                                        if(modelData.Type == "integer"){
                                            modelData.IntegerValue = Number(text);
                                        }
                                        else if(modelData.Type == "float"){
                                            modelData.FloatValue = Number(text);
                                        }
                                        else{
                                            modelData.StringValue = text;
                                        }

                                        selector.commitParam(planListView.currentIndex, stepListView.currentIndex, modelData.Name, text);
                                    }
                                }
                                onEnabledChanged: {
                                    if(enabled == false)
                                        text = "";
                                }

                            }
                        }
                    }
                    Component{
                        id:comboboxComponent

                        ComboBox{
                            id: combox
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            model: modelData.StringListValue
                            currentIndex: modelData.IntegerValue
                            focus:true
                            activeFocusOnTab: true

                            onCurrentIndexChanged: {
                                modelData.IntegerValue = currentIndex;

                                selector.commitParam(planListView.currentIndex, stepListView.currentIndex, modelData.Name, currentIndex);
                            }
                        }
                    }
                    Component{
                        id:checkboxComponent
                        CheckBox{
                            id: checkbox
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            focus:true
                            activeFocusOnTab: true
                            checked: modelData.BoolValue

                            onCheckedChanged: {
                                modelData.BoolValue = checked;

                                selector.commitParam(planListView.currentIndex, stepListView.currentIndex, modelData.Name, checked);
                            }
                        }
                    }

                    Loader{
                        id: paramInput
                        anchors.left: paramName.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: paramUnit.left
                        anchors.rightMargin: 3

                        height: 30


                        anchors.leftMargin: 10
                        sourceComponent:getcomponent(modelData.Type)


                        function getcomponent(typename, val){
                            if (typename == "integer" || typename == "string" || typename == "float"){
                                return texteditComponent;
                            }
                            else if(typename == "enum"){
                                return comboboxComponent;
                            }
                            else if(typename == "bool"){
                                return checkboxComponent;
                            }

                        }
                    }
                    Text {
                        id: paramUnit
                        height:30
                        width:(modelData.Unit.length > 0 )? modelData.Unit.width: 0
                        text: modelData.Unit
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        color:"#d9d9d9"
                        font.pixelSize: 17
                        font.bold: true
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                    }

                }
            }
        }
    }
}

