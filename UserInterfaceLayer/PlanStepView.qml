﻿import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import "functions.js" as Script

Item {
    id:root
    function clearModel(){
        displayModel.clear();
        statusList.currentIndex = -1;
    }
    function startPlan(planIndex, stepIndex){
        displayModel.clear();
        var model = planSelector.stepListModel(planIndex);
        for(var index = 0; index < model.length; index++){
            displayModel.append({
                                    "operation":model[index],
                                    "sequence":index+1,
                                    "send":false,
                                    "ack":false,
                                    "ackResult":0,
                                    "logicalCommand":Script.isLogicalCommand(model[index]),
                                    "waitArray":0,
                                    "waitting":0,
                                    "waitPermanent":false,
                                    "loopCount":0,
                                    "remainLoopCount":0,
                                    "position":-1
                                });
        }
    }

    StatusViewWatcher{
        id:watcher
        onStatusChanged: {
                if(displayModel.count > 0 && jsobj.sequence >0 && jsobj.sequence <= displayModel.count)
                {
                    displayModel.setProperty(jsobj.sequence-1, "send", jsobj.send);
                    displayModel.setProperty(jsobj.sequence-1, "ack", jsobj.ack);
                    displayModel.setProperty(jsobj.sequence-1, "ackResult", jsobj.ackResult);
                    displayModel.setProperty(jsobj.sequence-1, "waitArray", jsobj.waitArray);
                    displayModel.setProperty(jsobj.sequence-1, "waitting", jsobj.waitting);
                    displayModel.setProperty(jsobj.sequence-1, "waitPermanent", jsobj.waitPermanent);
                    displayModel.setProperty(jsobj.sequence-1, "loopCount", jsobj.loopCount);
                    displayModel.setProperty(jsobj.sequence-1, "remainLoopCount", jsobj.remainLoopCount);
                    displayModel.setProperty(jsobj.sequence-1, "position", jsobj.position);
                    statusList.currentIndex = jsobj.sequence - 1;
                }

            }

    }

    PlanController{
        id: planController
    }

    PlanSelector{
        id: planSelector
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

        delegate: Item{
            anchors.left: parent.left
            anchors.right: parent.right

            Rectangle{
                id:delegateRect
                anchors.fill: parent
                radius:5
                border.width: 3
                border.color:"#747474"
                color:"transparent"
                opacity: 0.6
            }

            height: 80


            Component{
                id:controlCmd
                Column {
                    id: column
                    anchors.fill: parent
                    anchors.leftMargin: 5
                    anchors.topMargin: 3

                    //anchors { fill: parent; margins: 2 }

                    Text { text: sequence + '.' + operation; color:"#d9d9d9"; visible: (sequence == 0xffff)?false:true; font.pixelSize: 17 }
                    Text { text: qsTr('position: ') + position; color: "#d9d9d9"; font.pixelSize: 17; visible: (position != -1)}
                    Text {
                        text: {
                            if(send==true){
                                if(ack==false){
                                    return qsTr('Watting');
                                }else{
                                    if(ackResult==0){
                                        delegateRect.border.color = "lightgreen";
                                        return qsTr('Success');
                                    }else{
                                        delegateRect.border.color = "steelred";
                                        return qsTr('Fail: ')+ Script.decodeError(ackResult.toString());
                                    }
                                }
                            }else{
                                return '';
                            }
                        }
                        color:"#d9d9d9";
                        font.bold: true;
                        font.pixelSize: 17
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


                    Text { text: sequence + '.' + operation; color:"#d9d9d9"; font.pixelSize: 17 }
                    Text { text: qsTr('Wait: ') + waitArray; color:"#d9d9d9"; font.bold: true; font.pixelSize: 17 }
                    Text { text: qsTr('Waitting: ') + waitting; color:"#d9d9d9"; font.bold: true; font.pixelSize: 17

                        onTextChanged: {
                            if((waitArray > 0)&&(waitArray == waitting)){
                                delegateRect.border.color = "lightgreen";
                            }
                        }
                    }
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


                    Text { text: sequence+'.'+operation; color:"#d9d9d9"; font.pixelSize: 17 }
                    Text { text: qsTr('Wait: Permanent') ; color:"#d9d9d9"; font.bold: true; font.pixelSize: 17 }
                    Component.onCompleted: {
                        if((sequence == statusList.currentIndex + 1)){
                            delegateRect.border.color = "lightgreen";
                        }
                    }
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

                    Text { text:  sequence+'.'+operation; color:"#d9d9d9"; font.pixelSize: 17 }
                    Text { text: qsTr('Count: ') + loopCount; color:"#d9d9d9"; font.bold: true; font.pixelSize: 17 }

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


                    Text { text: sequence+'.'+operation; color:"#d9d9d9"; font.pixelSize: 17 }
                    Text { text: qsTr('Remain: ') + remainLoopCount; color:"#d9d9d9"; font.bold: true; font.pixelSize: 17 }

                }
            }
            Loader{
                anchors.fill: parent

                sourceComponent: getSource()

                function getSource(){
                    console.debug(operation);
                    if(!logicalCommand){
                        return controlCmd;
                    }else if (operation == "等待时间" ){
                        if(waitPermanent){
                            return waittingPermanentCmd;
                        }else{
                            return wattingArrayCmd;
                        }
                    }else if (operation == "循环"){
                        return loopStartCmd;
                    }else if (operation == "循环结束"){
                        return loopEndCmd;
                    }
                }
            }
        }
    }

}
