﻿import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import QtQuick.Dialogs 1.2

Item {
    property string operationGroupType
    signal positionSelected(int index);

    function setPosition(index){
        for(var ind = 0; ind < paramList.model.length; ind++){
            if(paramList.model[ind].Name == "position"){
                paramList.model[ind].IntegerValue = index;
                break;
            }
        }
    }

    Component.onCompleted: {
        selector.init(operationGroupType);
    }
    OperationParamSelector{
        id:selector
    }
    function commitData(){
        selector.onCompleteSingleOperation();
    }

    property int columnWidth

    columnWidth: 150
    width: column.width+column1.width+10



    Row {
        id: row
        anchors.topMargin: 10
        spacing: 10
        anchors.fill: parent

        Item {
            id: column
            width: 200
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0

            Rectangle{
                anchors.fill: parent
                anchors.bottomMargin: 8
                radius:8
                color: "#3c747474"
            }

            Rectangle{
                id: operationType
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 40

                Text {
                    text: qsTr("Operation type")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.pixelSize: 20
                    font.bold: true
                    width: 120
                    color:"#d9d9d9"
                }
            }


            ListView {
                id: operationList
                spacing: 1
                anchors.top: operationType.bottom
                anchors.topMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                clip: true
                highlight: Rectangle{
                    height: 40
                    anchors.left: parent.left
                    anchors.right: parent.right

                    color: "#5cc5ff"
                    radius: 0
                }
                highlightFollowsCurrentItem: true
                highlightMoveDuration: 150
                currentIndex: 0
                interactive: false

                delegate: TextButton {
                    height: 40

                    anchors.left:parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    buttonradius: 0
                    fontPixelSize: 20

                    textValue: modelData
                    startColor: "transparent"
                    stopColor: "transparent"
                    onClicked: {
                        positionSelected(-1);
                        operationList.currentIndex = index;
                    }
                }
                onCurrentIndexChanged: {
                    selector.setSelectedOperation(currentIndex);
                    //paramList.model = selector.paramModel();
                }

                Component.onCompleted:
                {
                    model = selector.operationModel();
                    selector.setSelectedOperation(currentIndex);
                }
            }
        }

        Item {
            id: column1

            width: columnWidth*2.3

            anchors.bottom: parent.bottom
            anchors.top: parent.top

            Rectangle{
                anchors.fill: parent
                anchors.bottomMargin: 8
                radius:8
                color: "#3c747474"
            }

            Rectangle{
                id: operationParam
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 40

                Text {
                    text: qsTr("Operation param")
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 20
                    font.bold: true
                    color:"#d9d9d9"
                }
            }

            ListView {
                id: paramList
                anchors.leftMargin: 5
                clip:true
                spacing: 2
                anchors.top: operationParam.bottom
                anchors.topMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                interactive: true

                ScrollBar.vertical: ScrollBar{}
                //highlightRangeMode: ListView.StrictlyEnforceRange
                highlightFollowsCurrentItem: true
                highlight: Item{

                }



                model : selector.paramModel




                delegate: Item {
                    property int paramIndex: index
                    height:{
                        if(modelData.Display == "操作流程"){
                            return 200;
                        }else{
                            return 35;
                        }
                    }
                    anchors.left: parent.left
                    anchors.right: parent.right

                    enabled:getSwitchState()
                    function getSwitchState()
                    {
                        var revert = modelData.RevertSwitch;
                        var obj = selector.getSwitch(modelData.SwitchValue);
                        if (obj)
                            return revert? (!obj.BoolValue) : (obj.BoolValue);
                        else
                            return true;
                    }

                    opacity: enabled? 1.0: 0.5

                    Text {
                        id: paramName
                        height:30
                        width:120
                        text: modelData.Display
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color:"#d9d9d9"
                        font.pixelSize: 17
                        font.bold: true
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

                    Component{
                        id: texteditComponent

                        Rectangle{
                            anchors.fill: parent
                            border.width: 2
                            border.color: "#ffffff"
                            radius: 0

                            TextInput{
                                id: textedit
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                verticalAlignment: TextEdit.AlignVCenter
                                text:modelData.StringValue
                                validator: getValidator()
                                focus:true
                                activeFocusOnTab: true

                                onActiveFocusChanged: {
                                    if(activeFocus){
                                        selectAll();
                                        if(paramList.currentIndex != paramIndex){
                                            paramList.currentIndex = paramIndex;
                                            forceActiveFocus();
                                        }
                                    }else{
                                        deselect();
                                        if(modelData.Type == "integer"){
                                            var value = Number(text);
                                            if(value > intValidator.top){
                                                value = intValidator.top;
                                            }else if(value < intValidator.bottom){
                                                value = intValidator.bottom;
                                            }
                                            text = value.toString();
                                            modelData.IntegerValue = Number(text);
                                        }
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
                                if (modelData.Name == "position"){
                                    positionSelected(currentIndex);

                                    var boardIndex = selector.getBoardTypeIndexByPosition(currentIndex);

                                    for(var ind = 0; ind < paramList.model.length; ind++){
                                        if(paramList.model[ind].Name == "boardType"){
                                            paramList.model[ind].IntegerValue = boardIndex;
                                            break;
                                        }
                                    }
                                }
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
                    Component{
                        id:tipMotionComponent
                        Item{
                            anchors.fill: parent
                            TextButton{
                                id:importMotion
                                height:30
                                width:100
                                textValue: qsTr("import")
                                buttonradius: 0
                                borderColor: "#4c5cc5ff"

                                anchors.top: parent.top
                                anchors.right: parent.right

                                visible: (modelData.Display=="操作流程")

                                onClicked: {
                                    forceActiveFocus();
                                    fileDialogImport.visible = true;
                                }

                            }
                            SingleTipMotion{
                                id: singleTipMotion
                                anchors.top: importMotion.bottom
                                anchors.left: parent.left
                                anchors.bottom: parent.bottom
                                anchors.right: parent.right

                                intvalidator.bottom:  intValidator.bottom
                                intvalidator.top: intValidator.top

                                modelStr: modelData.StringValue

                                focus:true

                                onSetModelStr: {
                                    modelData.StringValue = str;
                                }
                                FileDialog {
                                    id: fileDialogImport
                                    title: qsTr("Select file")
                                    folder: shortcuts.documents
                                    visible: false
                                    selectMultiple:false
                                    selectExisting:true
                                    nameFilters: [ "CSV files (*.csv)" ]
                                    //fileMode: FileDialog.OpenFile
                                    onAccepted: {
                                        singleTipMotion.modelStr = configFileConverter.readConfigFIle(fileUrl);

                                        visible = false;
                                    }
                                    onRejected: {
                                        visible = false;
                                    }
                                }
                            }
                        }
                    }

                    Loader{
                        id:paramInput
                        anchors.left: paramName.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: paramUnit.left
                        anchors.rightMargin: 3

                        height: 30

                        enabled: modelData.Name != "boardType"


                        anchors.leftMargin: 10
                        sourceComponent:getcomponent(modelData.Type, modelData.Display)

                        function getcomponent(typename, strVal){
                            if (typename == "integer" || typename == "float"){
                                return texteditComponent;
                            }else if(typename == "enum"){
                                return comboboxComponent;
                            }else if(typename == "bool"){
                                return checkboxComponent;
                            }else if(typename == "string"){
                                 if(strVal == "操作流程"){
                                     return tipMotionComponent;
                                 }else{
                                     return texteditComponent;
                                 }
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
                        style: Text.Raised
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                    }

                }
            }
        }
    }
}

