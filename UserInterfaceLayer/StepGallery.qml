import QtQuick 2.0
import Common 1.0
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

Item {
    property bool activeOnClick: false
    property bool showLabel: true
    property bool showIndex: false
    property bool showCombo: false
    property alias currentIndex: gridView.currentIndex
    signal typeChanged();
    signal itemSelected(int index);

    height: width*3/4

    clip:true

    id:root

    MouseArea{
        anchors.fill: parent
    }
    StatusViewWatcher{
        id:watcher
        onStatusChanged: {
            if(showCombo){
                return;
            }

            if(displayModel.count > 0 && jsobj.position > 0){
                if (gridView.currentIndex == jsobj.position - 1 ){
                    if( jsobj.ack == true && gridView.currentItem.gridType != "null" && showLabel){
                        gridView.currentItem.state = "used";
                    }
                }else{
                    gridView.currentIndex = jsobj.position - 1;
                }
            }
        }
        onWorkLocationTypeChanged:{
            typeChanged();
        }
    }
    onTypeChanged: {
        refreshModel();
    }

    ListModel {
        id:displayModel
    }

    function resetGridView(){
        displayModel.clear();
        refreshModel();
    }

    function setWorkPlaceType(gridIndex, typeVal){
        var listAll = watcher.getWorkLocationTypeList();
        var configIndex = listAll.current;
        if(listAll.config[configIndex].type[gridIndex].name != typeVal.type){
            listAll.config[configIndex].type[gridIndex] = typeVal;
            watcher.updateWorkPlace(listAll);
        }
    }

    function setIndexParam(gridIndex, type, param, value){
        var listAll = watcher.getWorkLocationTypeList();
        var configIndex = listAll.current;
        if(listAll.config[configIndex].type[gridIndex].name == type){
            listAll.config[configIndex].type[gridIndex][param] = parseInt(value);
            watcher.updateWorkPlace(listAll);
        }
    }

    function refreshModel(){

        var comboItem = watcher.getWorkPlaceConstraint();
        //.refresh listview
//        var tipsReadyImage =  "./image/2-1.png";
//        var tipsUsedImage = "./image/2-4.png";
//        var tubesReadyImage =  "./image/4-1.png";
//        var tubesUsedImage = "./image/4-4.png";

        var listAll = watcher.getWorkLocationTypeList();
        if(listAll.current < 0 || listAll.current >= listAll.config.length){
            return;
        }

        var listData = listAll.config[listAll.current].type;
        for(var index = 0; index < listData.length; index++){
//            if(listData[index]=="tips"){
//                displayModel.set(index, {"type":"tips", "readyImage":tipsReadyImage, "usedImage":tipsUsedImage});
//            }else if(listData[index]=="tubes"){
//                displayModel.set(index, {"type":"tubes", "readyImage":tubesReadyImage, "usedImage":tubesUsedImage});
//            }else if(listData[index]=="null"){
//                displayModel.set(index,{"type":"null", "readyImage":"", "usedImage":""});
//            }

            for (var item in comboItem){
                if(comboItem[item].type == listData[index].name){
                    displayModel.set(index, {
                                         "type":comboItem[item].type,
                                         "readyImage":comboItem[item].image.ready,
                                         "usedImage":comboItem[item].image.used});
                    break;
                }
            }
        }
    }
    Component.onCompleted: refreshModel()

    ListModel{
        id:comboboxModel
//        ListElement{name:qsTr("tips"); type:"tips"}
//        ListElement{name:qsTr("tubes"); type:"tubes"}
//        ListElement{name:qsTr("null"); type: "null"}

        Component.onCompleted: {
            var comboItem = watcher.getWorkPlaceConstraint();
            for(var index = 0; index < comboItem.length; index++){
                comboboxModel.append({"name":comboItem[index].display, "type":comboItem[index].type});
            }
        }
    }

    GridView {
        id: gridView
        antialiasing: true
        highlightMoveDuration: 200
        //highlightRangeMode: GridView.StrictlyEnforceRange
        interactive: false
        clip: true
        flow: GridView.FlowTopToBottom
        anchors.fill: parent
        currentIndex: -1
        highlight: Rectangle{
            width:200
            height:100
            radius: 3
            color:"#747474"
            border.width: 3
            border.color:"#99da73"
        }

        delegate: Rectangle {
            property int gridIndex:index
            property string gridType: type
            height: gridView.cellHeight * 9/10
            width: gridView.cellWidth * 9/10

            color:"#4c000000"
            radius: 8

            Image{
                id:itemImage
                fillMode: Image.PreserveAspectFit
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                source: readyImage
                anchors.centerIn:  parent
                smooth: true
                antialiasing: true
                visible: true

                Rectangle{
                    visible: showLabel||showIndex
                    id:textBack
                    color:"#92d456"

                    width:itemImage.width
                    height:itemImage.height/3

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    Text{
                        anchors.fill: parent
                        id:textlabel
                        color: "#e6eae9"
                        text:getText()
                        function getText(){
                            if(showLabel){
                                return (gridType == "null")?qsTr("Empty"):qsTr("Ready");
                            }else if(showIndex && gridIndex>=0){
                                return gridIndex+1;
                            }else{
                                return "";
                            }
                        }
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter

                        font.pixelSize: height>0?(height*4/5):10

                    }
                }
            }

            MouseArea{
                anchors.fill: parent
                enabled: activeOnClick
                onClicked: {
                    itemSelected(gridIndex);
                }
            }
            ColumnLayout{
                visible: showCombo
                anchors.fill: parent
                anchors.margins: 7
                spacing: 2
                clip: true

                ComboBox
                {
                    id: combox

                    anchors.left: parent.left
                    anchors.right: parent.right
                    height:35

                    //anchors.centerIn: parent
                    textRole: "name"
                    model:comboboxModel
                    currentIndex: {
                        var ind = -1;
                        for(var index = 0; index < comboboxModel.count; index++){
                            if(comboboxModel.get(index).type == gridType){
                                ind = index;
                                break;
                            }
                        }
                        return ind;
                    }
                    focus:true
                    activeFocusOnTab: true

                    onCurrentIndexChanged: {
                        if(currentIndex != -1){
                            var boardTypeVar = {
                                name:"null"
                            };

                            var newtype = comboboxModel.get(currentIndex).type;
                            boardTypeVar.name = newtype;

                            //watcher.setWorkLocationType(0,gridIndex, model.get(currentIndex).type);
                            var listAll = watcher.getWorkLocationTypeList();
                            var listData = listAll.config[listAll.current].type[gridIndex];
                            var constraint = watcher.getWorkPlaceConstraint();

                            for(var ind = 0; ind < constraint.length; ind++){
                                if(constraint[ind].type == newtype){
                                    var showVolume = constraint[ind].params.hasOwnProperty("volume");
                                    if(showVolume){
                                        if(listData.hasOwnProperty("volume")){
                                            editVolume.volumeVal = listData.volume;
                                            boardTypeVar["volume"] = listData.volume;
                                        }else{
                                            editVolume.volumeVal = constraint[ind].params.volume.default;
                                            boardTypeVar["volume"] = constraint[ind].params.volume.default;
                                        }
                                    }
                                    editVolume.visible = showVolume;
                                    break;
                                }
                            }

                            var configIndex = listAll.current;
                            if(listAll.config[configIndex].type[gridIndex].name != newtype){
                                listAll.config[configIndex].type[gridIndex] = boardTypeVar;
                                watcher.updateWorkPlace(listAll);
                            }
                        }
                    }
                }
                Rectangle{
                    id: editVolume
                    property alias volumeVal:volumeInput.text
                    visible:false
                    clip:true
                    anchors.left: parent.left
                    anchors.right: parent.right
                    color:"#e0e0e0"
                    height:35
                    Row{
                        anchors.fill: parent
                        anchors.centerIn: parent
                        Text{
                            id: volumeText
                            width: 40
                            height: parent.height
                            text: qsTr("Vol.")
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 17
                            color: "#373839"
                            font.bold: true
                        }
                        TextField{
                            id: volumeInput
                            focus: true
                            height:parent.height
                            width:65
                            placeholderText: qsTr("Max volume")
                            //horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 17
                            inputMethodHints: Qt.ImhDigitsOnly
                            selectByMouse:true

                            validator:IntValidator{
                                bottom: 0
                                top:10000
                            }
                            onEditingFinished: {
                                setIndexParam(gridIndex, "tipBox", "volume", text);
                                focus = false;
                            }
                        }
                        Text{
                            id: unitText
                            width: 15
                            height: parent.height
                            text: "μL"
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: 13
                            color: "#373839"
                            font.bold: true
                        }
                    }
                }


            }


            states:State{
                name:"used"
                PropertyChanges {
                    target: itemImage
                    source:usedImage
                }
                PropertyChanges {
                    target: textlabel
                    text: qsTr("Used")
                }
            }

        }
        model: displayModel

        cellWidth: gridView.width/4
        cellHeight: gridView.height/3
    }
}
