import QtQuick 2.5
import QtQuick.Controls 1.4
import Common 1.0

Item {
    property string name

    OperationParamSelector{
        id:selector
    }
    function commitData(index){
        selector.onCompleteSingleOperation(index);
    }


    Row {
        id: row
        anchors.topMargin: 10
        spacing: 10
        anchors.fill: parent

        Item {
            id: column
            width: 150
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0

            Text {
                id: operationType
                text: qsTr("Operation type")
                horizontalAlignment: Text.AlignHCenter
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                font.pixelSize: 17
                width: 120
            }

            ListView {
                id: operationList
                anchors.leftMargin: 20
                spacing: 4
                anchors.top: operationType.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                clip: true
                highlight: Rectangle{
                    height: 25
                    width: 100
                    color: "lightblue"
                    radius: 3
                }
                highlightFollowsCurrentItem: true
                currentIndex: 0
                interactive: false

                delegate: TextButton {
                    height: 25
                    width:100
                    text: modelData
                    backColor: "transparent"
                    onClicked: {
                        console.debug(modelData+"clicked");
                        operationList.currentIndex = index;
                    }
                }
                onCurrentIndexChanged: {
                    selector.setSelectedOperation(currentIndex);
                    paramList.model = selector.paramModel();
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
            width: row.width/2
            anchors.bottom: parent.bottom
            anchors.top: parent.top

            Text {
                id: operationParam
                text: qsTr("Operation param")
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 10
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                font.pixelSize: 17
            }

            ListView {
                id: paramList
                anchors.leftMargin: 0
                clip:true
                spacing: 4
                anchors.top: operationParam.bottom
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                interactive: false

                Component.onCompleted: {
                    model = selector.paramModel();
                }

                delegate: Item {
                    height:25
                    width:260


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
                        height:25
                        width:100
                        text: modelData.Display
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    Component{
                        id: texteditComponent

                        Rectangle{
                            anchors.fill: parent
                            border.width: 2
                            border.color: "steelblue"
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

                        height: 25
                        width: 100

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

