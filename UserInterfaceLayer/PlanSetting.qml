﻿import QtQuick 2.7

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
                width: height*2
                height: parent.height
                textValue: qsTr("Save")
                anchors.right: parent.right
                anchors.rightMargin: 0
                fontPixelSize: 20
                buttonradius: 0
                onClicked: {
                    planList.savePlan();
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
        }

        StepGallery{
            //height: 480
            //width: 1000
            id:planStepGallery
            anchors.top: row.bottom
            anchors.left: planList.right
            //x:planList.x + planList.width
            anchors.right: parent.right
            //anchors.bottom: parent.bottom

            anchors.topMargin: 20
            anchors.leftMargin: 7

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
