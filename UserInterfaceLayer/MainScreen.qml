import QtQuick 2.7
import Common 1.0

Item {
    anchors.fill: parent

    PlanController{
        id:controller

        onTaskStateChanged: {
            actionBarID.state = actionBarID.newState;
        }
    }

    Rectangle{

        height: parent.height/8
        color: "#1f1f1f"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top

        border.color: "#ffffff"
        border.width: 0

        id: mainScreenHeader
        Text {
            id: title
            width: 400
            color: "#fdfdfd"
            text: qsTr("Automatic moving fluid tool")
            renderType: Text.NativeRendering
            font.weight: Font.ExtraBold
            style: Text.Normal
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 30
            font.bold: true
            antialiasing: true
        }

        Text {
            id: timeBar
            width: 250
            color: "#fdfdfd"
            text: qsTr("00-00-00")
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 20
            font.bold: true
        }


        Timer{
            running: true
            triggeredOnStart: true
            repeat: true


            function currentTime(){
                return Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss");
            }

            onTriggered: {
                timeBar.text = currentTime();
            }
        }
    }


    Rectangle {
        id: row
        color: "#414141"
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top:mainScreenHeader.bottom
        anchors.bottom: parent.bottom

        Rectangle {
            id: mainVDewID
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.right: actionBarID.left

            color:"#58595a"

            radius: 8
            anchors.rightMargin: 10
            anchors.leftMargin: 10

            StepGallery{
                id:stepGallery
                visible: true
                anchors.top:mainVDewID.top
                anchors.left: mainVDewID.left
                anchors.bottom: mainVDewID.bottom
                anchors.right: statusList.left
                onTypeChanged: {
                    resetGridView();
                }
            }


            StatusListView{
                id:statusList
                visible: true
                anchors.top:mainVDewID.top
                anchors.topMargin: 3
                anchors.right: mainVDewID.right
                anchors.rightMargin: 3
                anchors.bottom: mainVDewID.bottom
                anchors.bottomMargin: 3
                width:parent.width/5
            }
        }

        Column {
            property string newState: ""

            id: actionBarID
            width: parent.width/5
            height: parent.height
            anchors.top: parent.top
            anchors.topMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.bottom: parent.bottom
            spacing: 20

            TextButton{
                id:singleStepButton
                height: 50
                fontPixelSize: 25
                textValue: qsTr("Single step")
                startColor:"#a9aaac"
                stopColor:"#6e6d71"
                borderColor:"#cecece"

                onClicked: subPage.subPageUrl = Qt.resolvedUrl("SingleStepPage.qml")
            }

            TextButton{
                id:systemSettingButton
                height: 50
                fontPixelSize: 25
                textValue: qsTr("System settings")
                startColor:"#a9aaac"
                stopColor:"#6e6d71"
                borderColor:"#cecece"

                onClicked: subPage.subPageUrl = Qt.resolvedUrl("SystemSetting.qml")
            }

            TextButton{
                id:planSettingButton
                height: 50
                fontPixelSize: 25
                textValue: qsTr("Plan settings")
                startColor:"#a9aaac"
                stopColor:"#6e6d71"
                borderColor:"#cecece"
                enabled: isAdministratorAccount

                onClicked: subPage.subPageUrl = Qt.resolvedUrl("PlanSetting.qml")
            }

            TextButton{
                id:startButton
                textValue: qsTr("Start test")
                height: 65
                fontPixelSize: 25
                startColor:"#cffe9e"
                stopColor:"#92d456"
                borderColor:"#99da73"

                onClicked: {
                    startPage.visible = true;
                    actionBarID.newState = "start";

                    statusList.clearModel();
                    stepGallery.resetGridView();
                }
            }
            TextButton{
                id:stopButton
                textValue: qsTr("Stop test")
                height: 65
                fontPixelSize: 25
                startColor:"#cffe9e"
                stopColor:"#92d456"
                borderColor:"#99da73"
                visible:false

                onClicked: {
                    controller.stopPlan();
                    if(actionBarID.state == "start"){
                        actionBarID.newState = "";
                    }else if(actionBarID.state == "pause"){
                        //already stopped
                        actionBarID.state = "";
                    }
                }
            }
            TextButton{
                id:pauseButton
                textValue: qsTr("Pause test")
                height: 65
                fontPixelSize: 25
                startColor:"#cffe9e"
                stopColor:"#92d456"
                borderColor:"#99da73"
                visible:false

                onClicked: {
                    controller.stopPlan();
                    actionBarID.newState = "pause";
                }
            }
            TextButton{
                id:resumeButton
                textValue: qsTr("Resume test")
                height: 65
                fontPixelSize: 25
                startColor:"#a9aaac"
                stopColor:"#6e6d71"
                borderColor:"#99da73"
                visible:false

                onClicked: {
                    controller.resumePlan();
                    actionBarID.newState = "start";
                }
            }


            states:[
                State{
                    name:"start"
                    PropertyChanges {
                        target: actionBarID
                        newState: ""
                    }
                    PropertyChanges {
                        target: startButton
                        visible: false
                    }
                    PropertyChanges {
                        target: stopButton
                        visible: true
                    }
                    PropertyChanges {
                        target: pauseButton
                        visible: true
                    }
                    PropertyChanges {
                        target: resumeButton
                        visible: false
                    }
                    PropertyChanges {
                        target: singleStepButton
                        enabled:false
                    }
                    PropertyChanges {
                        target: planSettingButton
                        enabled:false
                    }
                    PropertyChanges {
                        target: systemSettingButton
                        enabled:false
                    }
                },
                State{
                    name:"pause"
                    PropertyChanges {
                        target: startButton
                        visible: false
                    }
                    PropertyChanges {
                        target: stopButton
                        visible: true
                    }
                    PropertyChanges {
                        target: pauseButton
                        visible: false
                    }
                    PropertyChanges {
                        target: resumeButton
                        visible: true
                    }
                    PropertyChanges {
                        target: singleStepButton
                        enabled:true
                    }
                    PropertyChanges {
                        target: planSettingButton
                        enabled:false
                    }
                    PropertyChanges {
                        target: systemSettingButton
                        enabled:false
                    }
                }
            ]

        }
    }

    Rectangle{
        property url subPageUrl
        //onSubPageUrlChanged: visible = (subPageUrl == ''?false:true);

        id:subPage
        anchors.fill: parent
        color:"transparent"

        visible: subPageUrl == ''?false:true

        Rectangle{
            id:subPageheader
            height: parent.height/8
            width: 400
            color: "#1f1f1f"
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top

            border.color: mainScreenHeader.color
            border.width: 0


            TextButton{
                id: backButton
                textValue:qsTr("< Back")
                height:parent.height - 20
                width:100
                fontPixelSize: 20
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 10

                startColor: "#1f1f1f"
                stopColor: "#1f1f1f"

                onClicked:subPage.subPageUrl = ""
            }
        }


        Rectangle{
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top:subPageheader.bottom
            color: "#414141"

            Loader{
                id:subLoader
                focus: true
                source: subPage.subPageUrl


                anchors.fill: parent
            }

        }
    }

    StartPage{
        id:startPage
        anchors.fill: parent
        visible: false

        onVisibleChanged: {
            if(visible == true){
                updatePlanList();
            }
        }

        onOkClicked: {
            //statusList.visible = true;
            controller.startPlan(index, 0);
        }
    }
}
