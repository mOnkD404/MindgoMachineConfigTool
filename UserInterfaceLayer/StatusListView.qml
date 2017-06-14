import QtQuick 2.7
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

//    ScrollView{
//        anchors.fill: parent
//        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
//        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff

        ListView{
            id:statusList
            anchors.fill: parent
            spacing: 4
            clip:true
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
                height: 80
                Component{
                    id:controlCmd
                    Column {
                        id: column
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.topMargin: 3

                        //anchors { fill: parent; margins: 2 }

                        Text { text: 'Step: ' + sequence; color:"#d9d9d9"; visible: (sequence == 0xffff)?false:true; wrapMode:Text.Wrap }
                        Text { text: 'Tunning'; color:"#d9d9d9"; font.bold: true; visible: (sequence==0xffff)?true:false; wrapMode:Text.Wrap }
                        Text { text: operation; color:"#d9d9d9"; wrapMode:Text.Wrap }
                        Text { text: 'position: ' + position; color: "#d9d9d9"; wrapMode:Text.Wrap}
//                        Text {
//                            text: {
//                                if(send==true){
//                                    return 'Send: success';
//                                }else{
//                                    return 'Send: fail';
//                                }
//                            }
//                            color:"#d9d9d9";
//                            font.bold: true;
//                            wrapMode:Text.Wrap
//                        }
//                        Text {
//                            text: {
//                                if(ack == true){
//                                    return 'Ack: success';
//                                }else{
//                                    return 'Ack: waitting';
//                                }
//                            }
//                            color:"#d9d9d9";
//                            font.bold: true;
//                            wrapMode:Text.Wrap
//                        }
                        Text {
                            text: {
                                if(send==true){
                                    if(ack==false){
                                        return 'Result: watting';
                                    }else{
                                        if(ackResult==0){
                                            return 'Result: success';
                                        }else{
                                            return 'Result: fail code'+ackResult.toString();
                                        }
                                    }
                                }else{
                                    return 'Result: send fail';
                                }
                            }
                            color:"#d9d9d9";
                            font.bold: true;
                            wrapMode:Text.Wrap
                        }
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

                        Text { text: 'Step: ' + sequence; color:"#d9d9d9"; wrapMode:Text.Wrap }
                        Text { text: operation; color:"#d9d9d9"; wrapMode:Text.Wrap }
                        Text { text: 'Wait: ' + waitArray; color:"#d9d9d9"; font.bold: true; wrapMode:Text.Wrap }
                        Text { text: 'Waitting: ' + waitting; color:"#d9d9d9"; font.bold: true; wrapMode:Text.Wrap }
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

                        Text { text: 'Step: ' + sequence; color:"#d9d9d9"; wrapMode:Text.Wrap }
                        Text { text: operation; color:"#d9d9d9"; wrapMode:Text.Wrap }
                        Text { text: 'Count: ' + loopCount; color:"#d9d9d9"; font.bold: true; wrapMode:Text.Wrap }
                    }
                }
                Component{
                    id: loopEndCmd
                    Column {
                        id: column
                        anchors.fill: parent
                        anchors.leftMargin: 3
                        anchors.topMargin: 3

                        //anchors { fill: parent; margins: 2 }

                        Text { text: 'Step: ' + sequence; color:"#d9d9d9"; wrapMode:Text.Wrap }
                        Text { text: operation; color:"#d9d9d9"; wrapMode:Text.Wrap }
                        Text { text: 'Remain: ' + remainLoopCount; color:"#d9d9d9"; font.bold: true; wrapMode:Text.Wrap }
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
//    }
}
