import QtQuick 2.7
import Common 1.0
import QtQuick.Controls 2.1

Item {
    property string checkingState: "checking"
    property int errorStep: -1
    signal okClicked(int planIndex, int stepIndex);

    function updatePlanList(){
        plancomboBox.model = selector.planListModel()

    }

    PlanSelector{
        id:selector

        onPlanCheckStatusChanged: {
            progressBar.setValue(jsObj.progress);
            if(jsObj.end == true){
                if(jsObj.allow){
                    checkingState = "ready";
                }else{
                    checkingState = "invalid";
                }
            }else{
                checkingState = "checking";
            }

            errorStep =  jsObj.errorStep;
        }
    }
    WorkLocationManager{
        id: workLocationMgr
    }

    id:root
    anchors.fill: parent

    onVisibleChanged: {
        if(visible){
            state = "";
        }else{
            selector.stopCheckPlan();
        }
    }

    Rectangle{
        anchors.fill: parent
        color:"#99000000"

        MouseArea{
            anchors.fill: parent
        }
    }

    Rectangle{
        id: rectangle1
        width: 400
        height: 350
        color: "#818382"
        radius: 0
        border.width: 0
        anchors.centerIn: parent

        Rectangle {
            id: rectangle
            height: 60
            color: "#25ba5e"
            radius: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 0

            Text {
                id: text1
                text: qsTr("Confirm")
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                anchors.bottomMargin: 0
                anchors.fill: parent
                font.pixelSize: 35
                color:"#b5b7b6"
            }
        }

        Text {
            id: text4
            width: 130
            height: 35
            text: qsTr("Test")
            anchors.top: parent.top
            anchors.topMargin: 75
            anchors.left: parent.left
            anchors.leftMargin: 21
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 25
            color: "#b5b7b6"
        }

        ComboBox {
            id: plancomboBox
            width: 200
            height: 35
            anchors.left: text4.right
            anchors.leftMargin: 10
            anchors.top:parent.top
            anchors.topMargin: 75
            font.pixelSize: 25

            //model: selector.planListModel()
            currentIndex: 0
            focus:true
            activeFocusOnTab: true

            onVisibleChanged: {
                if(visible){
                    model = selector.planListModel();
                    if(currentIndex >=0){
                        selector.startCheckPlan(plancomboBox.currentIndex);
                    }
                }
            }
            onCurrentIndexChanged: {
                stepcomboBox.model = selector.planSelectStepListModel(plancomboBox.currentIndex);
                selector.startCheckPlan(plancomboBox.currentIndex);
                boardcomboBox.refreshModel();
            }
        }

        Text{
            id: text5
            width: 130
            height: 35
            text: qsTr("Start Step")
            anchors.top: text4.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 21
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 25
            color: "#b5b7b6"
        }

        ComboBox {
            id: stepcomboBox
            width: 200
            height: 35
            anchors.left: text5.right
            anchors.leftMargin: 10
            anchors.top:plancomboBox.bottom
            anchors.topMargin: 10
            font.pixelSize: 25

            //model: selector.planSelectStepListModel(plancomboBox.currentIndex)
            currentIndex: 0
            focus:true
            activeFocusOnTab: true

            onVisibleChanged: {
                if(visible){
                    model = selector.planSelectStepListModel(plancomboBox.currentIndex)
                }
            }
        }

        Text{
            id: text6
            width: 130
            height: 35
            text: qsTr("Board config")
            anchors.top: text5.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 21
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 25
            color: "#b5b7b6"
        }
        ComboBox {
            id: boardcomboBox
            width: 200
            height: 35
            anchors.left: text6.right
            anchors.leftMargin: 10
            anchors.top: stepcomboBox.bottom
            anchors.topMargin: 10
            font.pixelSize: 25
            enabled: false

            model: ListModel{
                id: boardcomboBoxModel
            }
            currentIndex: 0
            focus:true
            activeFocusOnTab: true

            function refreshModel(){
                var listAll = workLocationMgr.getWorkLocationTypeList();

                boardcomboBoxModel.clear();
                for(var item in listAll.config){
                    boardcomboBoxModel.append({"key":listAll.config[item].name});
                }

                currentIndex = selector.boardConfigIndex(plancomboBox.currentIndex);
            }

            onVisibleChanged: {
                if(visible){
                    refreshModel();
                }
            }
        }

        Text{
            id: checkText
            height: 35
            text: {
                if(checkingState == "checking"){
                    return qsTr("Checking plan...");
                }else if(checkingState == "ready"){
                    return qsTr("Ready");
                }else if(checkingState == "invalid"){
                    return qsTr("Invalid step ") + errorStep;
                }
            }
            anchors.bottom: progressBar.top
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 25
            color: "#b5b7b6"
        }

        Progressbar{
            id:progressBar
            anchors.bottom:textButton.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 2

            maximumValue : 100
            minimumValue : 0
            //indeterminate: true

            value:0
            function setValue(prog){
                value = prog;
            }
            onValueChanged:{
                //console.debug(value);
            }

        }

        TextButton {
            id: textButton
            y: 234
            width: 199
            height: 60
            textColor: "#7d7f7c"
            stopColor: "#e6eae9"
            startColor: "#e6eae9"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            buttonradius: 0
            fontPixelSize: 30

            textValue: qsTr("Cancel")

            onClicked: {
                root.visible = false;
            }
        }

        TextButton {
            id: textButton1
            x: 201
            y: 200
            width: 199
            height: 60
            textColor: "#7d7f7c"
            stopColor: "#e6eae9"
            startColor: "#e6eae9"
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            buttonradius: 0
            fontPixelSize: 30
            enabled: checkingState == "ready"

            textValue: qsTr("Start")
            onClicked: {
                var listAll = workLocationMgr.getWorkLocationTypeList();
                if(listAll.current != boardcomboBox.currentIndex){
                    listAll.current = boardcomboBox.currentIndex;
                    workLocationMgr.updateWorkPlace(listAll);
                }

                var itemStr = stepcomboBox.currentText.split('.');

                okClicked(plancomboBox.currentIndex, parseInt(itemStr[0])-1);
                root.visible = false;
            }
        }

    }

}
