import QtQuick 2.0
import Common 1.0
import QtQuick.Controls 2.1

Item {
    property bool activeOnClick: false
    property bool showLabel: true
    property bool showIndex: false
    property bool showCombo: false
    property alias currentIndex: gridView.currentIndex
    signal typeChanged();
    signal itemSelected(int index);

    height: width*3/4

    MouseArea{
        anchors.fill: parent
    }
    StatusViewWatcher{
        id:watcher
        onStatusChanged: {
            if(displayModel.count > 0 && jsobj["position"] > 0){
                if (gridView.currentIndex == jsobj["position"] - 1 ){
                    if( jsobj["ack"] == true && gridView.currentItem.gridType != "null" && showLabel){
                        gridView.currentItem.state = "used";
                    }
                }else{
                    gridView.currentIndex = jsobj["position"] - 1;
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

    function refreshModel(){
        var tipsReadyImage =  "./image/2-1.png";
        var tipsUsedImage = "./image/2-4.png";
        var tubesReadyImage =  "./image/4-1.png";
        var tubesUsedImage = "./image/4-4.png";

        var listData = watcher.getWorkLocationTypeList();
        for(var index = 0; index < listData.length; index++){
            if(listData[index]=="tips"){
                displayModel.set(index, {"type":"tips", "readyImage":tipsReadyImage, "usedImage":tipsUsedImage});
            }else if(listData[index]=="tubes"){
                displayModel.set(index, {"type":"tubes", "readyImage":tubesReadyImage, "usedImage":tubesUsedImage});
            }else if(listData[index]=="null"){
                displayModel.set(index,{"type":"null", "readyImage":"", "usedImage":""});
            }
        }
    }
    Component.onCompleted: refreshModel()

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
            height: gridView.cellHeight * 4/5
            width: gridView.cellWidth * 7/8

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
            ComboBox
            {
                visible: showCombo
                id: combox

                width: itemImage.width-4
                height:itemImage.height/2

                anchors.centerIn: parent
                textRole: "name"
                model: ListModel{
                    id:comboboxModel
                    ListElement{name:qsTr("tips"); type:"tips"}
                    ListElement{name:qsTr("tubes"); type:"tubes"}
                    ListElement{name:qsTr("null"); type: "null"}
                }
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
                    watcher.setWorkLocationType(gridIndex, model.get(currentIndex).type);
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
