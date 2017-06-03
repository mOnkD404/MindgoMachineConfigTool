﻿import QtQuick 2.7
import QtQuick.Controls 1.4
import Common 1.0

Item {
    function clearModel(){
        displayModel.clear();
        statusList.currentIndex = -1;
    }

    StatusViewWatcher{
        id:watcher
        onStatusChanged: {
            if(displayModel.count > 0 && (jsobj["newOperationItem"] == false) &&
                    (jsobj["operation"] == displayModel.get(displayModel.count-1).operation ) &&
                    (jsobj["sequence"] == displayModel.get(displayModel.count-1).sequence))
            {
                displayModel.set(displayModel.count-1, jsobj);
            }
            else
            {
                displayModel.append(jsobj);
            }

            statusList.currentIndex = displayModel.count - 1;
        }
    }

    width: 220

    ListModel{
        id:displayModel
        dynamicRoles:true
    }

    ScrollView{
        anchors.fill: parent

        ListView{
            id:statusList
            anchors.fill: parent
            spacing: 4
            model:displayModel
            highlight: Rectangle{
                height: 85
                color: "#995cc5ff"
                radius: 5
            }
            highlightFollowsCurrentItem: true
            highlightMoveDuration: 1000

            delegate: Rectangle{
                anchors.left: parent.left
                anchors.right: parent.right
                radius:5
                border.width: 2
                border.color:"#747474"
                color:"transparent"
                height: 100
                Component{
                    id:controlCmd
                    Column {
                        id: column
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 3

                        //anchors { fill: parent; margins: 2 }

                        Text { text: 'Operation: ' + operation; color:"#d9d9d9" }
                        Text { text: 'position: ' + position; color: "#d9d9d9"}
                        Text { text: 'Sequence number: ' + sequence; color:"#d9d9d9" }
                        Text { text: 'Send: ' + send.toString(); color:"#d9d9d9"; font.bold: true }
                        Text { text: 'Ack: ' + ack.toString(); color:"#d9d9d9"; font.bold: true }
                        Text { text: 'Ack result: ' + ackResult; color:"#d9d9d9"; font.bold: true }
                    }
                }
                Component{
                    id:wattingArrayCmd
                    Column {
                        id: column
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 3

                        //anchors { fill: parent; margins: 2 }

                        Text { text: 'Operation: ' + operation; color:"#d9d9d9" }
                        Text { text: 'Sequence number: ' + sequence; color:"#d9d9d9" }
                        Text { text: 'Wait array: ' + waitArray; color:"#d9d9d9"; font.bold: true }
                        Text { text: 'Waitting: ' + waitting; color:"#d9d9d9"; font.bold: true }
                    }
                }
                Component{
                    id: loopStartCmd
                    Column {
                        id: column
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 3

                        //anchors { fill: parent; margins: 2 }

                        Text { text: 'Operation: ' + operation; color:"#d9d9d9" }
                        Text { text: 'Sequence number: ' + sequence; color:"#d9d9d9" }
                        Text { text: 'Loop Count: ' + loopCount; color:"#d9d9d9"; font.bold: true }
                    }
                }
                Component{
                    id: loopEndCmd
                    Column {
                        id: column
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 3

                        //anchors { fill: parent; margins: 2 }

                        Text { text: 'Operation: ' + operation; color:"#d9d9d9" }
                        Text { text: 'Sequence number: ' + sequence; color:"#d9d9d9" }
                        Text { text: 'Remain loop count: ' + remainLoopCount; color:"#d9d9d9"; font.bold: true }
                    }
                }
                Loader{
                    anchors.fill: parent

                    sourceComponent: getSource()

                    function getSource(){
                        if(!logicalCommand){
                            return controlCmd;
                        }else if (operation == "WaitArray"){
                            return wattingArrayCmd;
                        }else if (operation == "Loop"){
                            return loopStartCmd;
                        }else if (operation == "EndLoop"){
                            return loopEndCmd;
                        }
                    }
                }
            }
        }
    }
}
