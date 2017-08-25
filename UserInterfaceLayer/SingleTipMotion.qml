import QtQuick 2.7
import QtQuick.Controls 1.4

Item {
    property string modelStr;
    property alias intvalidator: intValidator
    signal setModelStr(string str);

    id: root
    onModelStrChanged: {
        refreshModel();
    }

    function refreshModel(){
        parseStringToModel();
    }

    function parseStringToModel(){
        motionModel.clear();
        var splitStr = modelStr.split('\n');
        for(var index = 0; index < splitStr.length; index++){
            if(splitStr[index].length > 0)
            {
                if (splitStr[index].charAt(splitStr[index].length-1) == '\r')
                {
                   splitStr[index] = splitStr[index].slice(0, splitStr[index].length-1);
                }
            }

            var jsobj = {
               suctionIndex:"",
               dispenseIndex:"",
               volume:""
            };

            var subSplitStr = splitStr[index].split(',');
            if(subSplitStr.length == 3){
                jsobj.suctionIndex =  subSplitStr[0];
                jsobj.dispenseIndex =  subSplitStr[1];
                jsobj.volume =  subSplitStr[2];
                motionModel.append(jsobj);
            }
        }
    }
    function parseModelToString(){
        var tempStr="";
        for(var index = 0; index < motionModel.count; index++){
            tempStr+=motionModel.get(index).suctionIndex;
            tempStr+=',';
            tempStr+=motionModel.get(index).dispenseIndex;
            tempStr+=',';
            tempStr+=motionModel.get(index).volume;
            tempStr+="\r\n";
        }
        setModelStr(tempStr);
    }
    function setModel(row, column, text){
        var item = motionModel.get(row);
        switch(column){
        case 0:
            item.suctionIndex = text;
            break;
        case 1:
            item.dispenseIndex = text;
            break;
        case 2:
            item.volume = text;
            break;
        default:
            break;
        }
        var tempStr="";
        for(var index = 0; index < motionModel.count; index++){
            if(row == index ){
                tempStr+=item.suctionIndex;
                tempStr+=',';
                tempStr+=item.dispenseIndex;
                tempStr+=',';
                tempStr+=item.volume;
            }else{
                tempStr+=motionModel.get(index).suctionIndex;
                tempStr+=',';
                tempStr+=motionModel.get(index).dispenseIndex;
                tempStr+=',';
                tempStr+=motionModel.get(index).volume;
            }
            tempStr+="\r\n";
        }
        setModelStr(tempStr);
    }

    property var modelObj;

    ListModel {
        id: motionModel
    }

    IntValidator{
        id:intValidator
    }
    Component.onCompleted: {
        refreshModel();
    }

    TableView {
        anchors.fill: parent
        TableViewColumn {
            role: "suctionIndex"
            title: qsTr("Sunction Tip Index")
            width: parent.width/3-2
        }
        TableViewColumn {
            role: "dispenseIndex"
            title: qsTr("Dispense Tip Index")
            width: parent.width/3-2
        }
        TableViewColumn {
            role: "volume"
            title: qsTr("Volume")
            width: parent.width/3-2
        }
        model: motionModel
        itemDelegate: Item{
            TextInput{
                id: textedit
                anchors.fill: parent
                anchors.leftMargin: 2
                verticalAlignment: TextEdit.AlignVCenter
                text: styleData.value
                validator: intValidator

                focus:true
                activeFocusOnTab: true

                onActiveFocusChanged: {
                    if(activeFocus){
                        selectAll();
                    }else{
                        deselect();
                    }
                }
                onTextChanged: {
                    setModel(styleData.row, styleData.column, text);
                }
                onEditingFinished: {

                }
                onAccepted: {
                    root.forceActiveFocus();
                }
            }
        }
    }
}
