﻿import QtQuick 2.7
import Common 1.0

Item {
    property bool showHeader: false
    id:planSettingPage
    anchors.fill: parent

    Rectangle{
        anchors.fill: parent
        anchors.margins: 10
        color:"#58595a"
        MouseArea{
            anchors.fill: parent
        }

        Item{
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            height: 45


            Text{
                text:qsTr("Plan setting")
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 30
                color:"#d9d9d9"
                visible: showHeader
            }

            TextButton{
                width: 130
                height: 60
                textValue: qsTr("Save")
                anchors.right: parent.right
                anchors.rightMargin: 0
                fontPixelSize: 20
                buttonradius: 3
                borderColor: "#4c5cc5ff"
                onClicked: {
                    forceActiveFocus();
                    var result = planList.savePlan()?qsTr("save succeed"):qsTr("save failed");
                    showPrompt(result);
                }
            }
        }

        PlanList{
            id:planList

            anchors.margins: 4
            anchors.top: showHeader?row.bottom:parent.top
            anchors.left: parent.left
            //anchors.right: parent.right
            //anchors.bottom: parent.bottom


            //width: parent.width/3*2


            onPositionSelected: {
                planStepGallery.currentIndex = index;
            }
            height:globalinput.active?parent.height-globalinput.height:parent.height;

            Behavior on height{
                PropertyAnimation { duration:200}
            }

            onBoardIndexSelected: {
                planStepGallery.boardIndex = index;
            }
        }

        StatusViewWatcher{
            id:watcher
        }
        function refreshModel(){
            var listAll = watcher.getWorkLocationTypeList();

            configListModel.clear();
            for(var item in listAll.config){
                configListModel.append({"name":listAll.config[item].name});
            }

            configListView.currentIndex = listAll.current;

        }
        function selectConfig(currentIndex){
            var listAll = watcher.getWorkLocationTypeList();

            listAll.current = currentIndex;
            watcher.updateWorkPlace(listAll);
        }

        StepGallery{
            //height: 480
            //width: 1000
            id:planStepGallery
            anchors.top: row.bottom
            anchors.left: planList.right
            //x:planList.x + planList.width
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.topMargin: 35
            anchors.leftMargin: 20

            visible: (planList.operationState != "expandOperation")

            activeOnClick: true
            showLabel: false
            showIndex: true

            onItemSelected: {
                planList.setPosition(index);
            }
        }
    }
}
