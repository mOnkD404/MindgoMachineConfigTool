import QtQuick 2.0
import Common 1.0

Item {
    StatusViewWatcher{
        id:watcher
        onStatusChanged: {
            if(displayModel.count > 0 && jsobj["position"] > 0){
                console.debug("position"+jsobj["position"]);
                console.debug("current "+jsobj["position"]);
                if (gridView.currentIndex == jsobj["position"] - 1 ){
                    if( jsobj["ack"] == true){
                        gridView.currentItem.state = "used";
                    }
                }else{
                    gridView.currentIndex = jsobj["position"] - 1;
                }
            }
        }
    }

    ListModel {
        id:displayModel
    }

    function refreshModel(){
        displayModel.clear();

        var tipsReadyImage =  "./image/2-1.png";
        var tipsUsedImage = "./image/2-4.png";
        var tubesReadyImage =  "./image/4-1.png";
        var tubesUsedImage = "./image/4-4.png";

        var listData = watcher.getWorkLocationTypeList();
        console.debug(listData);
        for(var index = 0; index < listData.length; index++){
            if(listData[index]=="tips"){
                displayModel.append({"type":"tips", "readyImage":tipsReadyImage, "usedImage":tipsUsedImage});
            }else if(listData[index]=="tubes"){
                displayModel.append({"type":"tubes", "readyImage":tubesReadyImage, "usedImage":tubesUsedImage});
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
            height: 180
            width:240
            color:"transparent"
            Image{
                id:itemImage
                height:154
                width:222
                source: readyImage
                anchors.centerIn:  parent
                smooth: true
                antialiasing: true
                visible: true
            }
            Rectangle{
                id:textBack
                color:"#92d456"
                width:222
                height:40
                anchors.centerIn: parent
                Text{
                    anchors.fill: parent
                    id:textlabel
                    color: "#e6eae9"
                    text:qsTr("Ready")
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 16
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
