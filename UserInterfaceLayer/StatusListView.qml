﻿import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import "functions.js" as Script

Item {
    property bool running: false
    id:root
    function clearModel(){
        displayModel.clear();
        statusList.currentIndex = -1;
    }

    StatusViewWatcher{
        id:watcher
        onStatusChanged: {
            if(displayModel.count > 0 && (jsobj.newOperationItem == false) &&
                    (jsobj.operation == displayModel.get(displayModel.count-1).operation ) &&
                    (jsobj.sequence == displayModel.get(displayModel.count-1).sequence))
            {
                displayModel.set(displayModel.count-1, jsobj);
            }
            else
            {
                displayModel.append(jsobj);
            }
            statusList.currentIndex = displayModel.count - 1;

            if(jsobj.hasOwnProperty("running")){
                running = jsobj.running;
            }
        }
    }

    width: 220
    Rectangle{
        visible: false
        anchors.fill: parent
        radius:8
        color: "#3c747474"
    }

    ListModel{
        id:displayModel
        dynamicRoles:true
    }

    ListView{
        id:statusList
        anchors.fill: parent
        anchors.margins: 5
        spacing: 4
        model:displayModel
        highlight: Rectangle{
            height: 85
            color: "#995cc5ff"
            radius: 5
        }
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 1000
        ScrollBar.vertical: ScrollBar{}
        clip:true

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


                    Text { text: 'Step: ' + sequence; color:"#d9d9d9"; visible: (sequence == 0xffff)?false:true; font.pixelSize: 15 }
                    Text { text: 'Tunning'; color:"#d9d9d9"; font.bold: true; visible: (sequence==0xffff)?true:false; font.pixelSize: 15 }
                    Text { text: operation; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: 'position: ' + position; color: "#d9d9d9"; font.pixelSize: 15}
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
                    //                            font.pixelSize: 15
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
                    //                            font.pixelSize: 15
                    //                        }
                    Text {
                        text: {
                            if(send==true){
                                if(ack==false){
                                    return 'Watting';
                                }else{
                                    if(ackResult==0){
                                        return 'Success';
                                    }else{
                                        return 'Fail: '+ Script.decodeError(ackResult.toString());
                                    }
                                }
                            }else{
                                return 'Send fail';
                            }
                        }
                        color:"#d9d9d9";
                        font.bold: true;
                        font.pixelSize: 15
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


                    Text { text: 'Step: ' + sequence; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: operation; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: 'Wait: ' + waitArray; color:"#d9d9d9"; font.bold: true; font.pixelSize: 15 }
                    Text { text: 'Waitting: ' + waitting; color:"#d9d9d9"; font.bold: true; font.pixelSize: 15 }

                }
            }
            Component{
                id:waittingPermanentCmd
                Column {
                    id: column
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.topMargin: 3

                    //anchors { fill: parent; margins: 2 }


                    Text { text: 'Step: ' + sequence; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: operation; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: 'Wait: Permanent' ; color:"#d9d9d9"; font.bold: true; font.pixelSize: 15 }

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

                    Text { text: 'Step: ' + sequence; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: operation; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: 'Count: ' + loopCount; color:"#d9d9d9"; font.bold: true; font.pixelSize: 15 }

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


                    Text { text: 'Step: ' + sequence; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: operation; color:"#d9d9d9"; font.pixelSize: 15 }
                    Text { text: 'Remain: ' + remainLoopCount; color:"#d9d9d9"; font.bold: true; font.pixelSize: 15 }

                }
            }
            Loader{
                anchors.fill: parent

                sourceComponent: getSource()

                function getSource(){
                    if(!logicalCommand){
                        return controlCmd;
                    }else if (operation == "WaitArray" ){
                        if(waitPermanent){
                            return waittingPermanentCmd;
                        }else{
                            return wattingArrayCmd;
                        }
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
