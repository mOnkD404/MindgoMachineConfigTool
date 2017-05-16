import QtQuick 2.5
import QtQuick.Controls 1.4
import Common 1.0

Item {
    id: root

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


            ListView {
                id: planListView
                spacing: 4
                anchors.top: userPlanSelect.bottom
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
                        planListView.currentIndex = index;
                    }
                }
                onCurrentIndexChanged: {
                    selector.setSelectedPlan(currentIndex);
                    stepListView.model = selector.stepListModel();
                }

                Component.onCompleted:
                {
                    model = selector.planListModel();
                    selector.setSelectedPlan(currentIndex);
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
                    width: 85
                    color:"#d9d9d9"
                }

                TextButton{
                    id:addStepButton
                    width: 30
                    anchors.top: parent.top
                    anchors.topMargin: 4
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    textValue: "+"

                    onClicked: {
                        operationColumn.visible = true;
                    }
                }
            }


            ListView {
                id: stepListView
                spacing: 4
                anchors.top: stepList.bottom
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

                    color: "#5cc5ff"
                    radius: 0
                }
                highlightFollowsCurrentItem: true
                currentIndex: 0
                interactive: true

                delegate: TextButton {
                    height: 30

                    anchors.left:parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    textHorizontalAlignment: Text.AlignLeft

                    buttonradius: 0

                    textValue: (index+1)+". "+modelData
                    startColor: "transparent"
                    stopColor: "transparent"
                    onClicked: {
                        console.debug(modelData+"clicked");
                        stepListView.currentIndex = index;
                    }
                }
                onCurrentIndexChanged: {
                    selector.setSelectedStep(planListView.currentIndex, currentIndex);

                    //operationList.currentIndex = selector.operationCurrentIndex();
                    paramList.model = selector.paramListModel();
                }
            }
        }

        Item {
            property bool  addOperation;

            id: operationColumn
            width: columnWidth
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            visible: false

            addOperation:true

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
                    anchors.left: parent.left
                    anchors.right: parent.right

                    color: "#5cc5ff"
                    radius: 0
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


                        var oldIndex = stepListView.currentIndex;
                        if(operationColumn.addOperation){
                            selector.addStep(planListView.currentIndex, stepListView.currentIndex, index);
                            stepListView.model = selector.stepListModel();
                            stepListView.currentIndex = oldIndex;
                        }else {
                            selector.setSelectedOperation(stepListView.currentIndex, index);
                            stepListView.model = selector.stepListModel();
                            stepListView.currentIndex = oldIndex;
                        }
                    }
                }

                Component.onCompleted:
                {
                    model = selector.operationListModel();
                }
                onVisibleChanged: {
                    if(operationColumn.visible == true){
                        currentIndex = selector.operationCurrentIndex();
                    }
                }
            }
        }

        Item {
            id: paramColumn
            width: columnWidth*2
            anchors.bottom: parent.bottom
            anchors.top: parent.top

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
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                verticalAlignment: TextEdit.AlignVCenter
                                text:modelData.StringValue
                                validator: getValidator()
                                focus:true
                                activeFocusOnTab: true

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
                                    bottom: 0
                                    top:1000000000
                                }

                                DoubleValidator{
                                    id:floatValidator
                                    bottom:0.0
                                    top:1000000000.0
                                }

                                onTextChanged: {
                                    if(modelData.Type == "integer"){
                                        modelData.IntegerValue = Number(text);
                                    }
                                    else if(modelData.Type == "float"){
                                        modelData.FloatValue = Number(text);
                                    }
                                    else{
                                        modelData.StringValue = text;
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

                        ComboBox
                        {
                            id: combox
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            model: modelData.StringListValue
                            currentIndex: modelData.IntegerValue
                            focus:true
                            activeFocusOnTab: true

                            onCurrentIndexChanged: {
                                modelData.IntegerValue = currentIndex;
                            }

                        }
                    }
                    Component{
                        id:checkboxComponent
                        CheckBox{
                            id: checkbox
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            checked: modelData.BoolValue
                            focus:true
                            activeFocusOnTab: true

                            onCheckedChanged: {
                                modelData.BoolValue = checked;
                            }
                        }
                    }

                    Loader{

                        anchors.left: paramName.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right

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


                }
            }
        }
    }
}

