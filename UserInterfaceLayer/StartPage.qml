import QtQuick 2.7
import Common 1.0
import QtQuick.Controls 2.1

Item {
    signal okClicked(int index);

    function updatePlanList(){
        plancomboBox.model = selector.planListModel()

    }

    PlanSelector{
        id:selector
    }


    id:root
    anchors.fill: parent
    Rectangle{
        anchors.fill: parent
        color:"#99000000"
    }

    Rectangle{
        id: rectangle1
        width: 400
        height: 300
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
                font.pixelSize: 30
                color:"#b5b7b6"
            }
        }

        Text {
            id: text4
            width: 130
            height: 25
            text: qsTr("Test")
            anchors.top: parent.top
            anchors.topMargin: 75
            anchors.left: parent.left
            anchors.leftMargin: 21
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 16
            color: "#b5b7b6"
        }

        ComboBox {
            id: plancomboBox
            width: 150
            height: 30
            anchors.left: text4.right
            anchors.leftMargin: 10
            anchors.top:parent.top
            anchors.topMargin: 75

            model: selector.planListModel()
            currentIndex: 0
            focus:true
            activeFocusOnTab: true
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

            textValue: qsTr("Start")
            onClicked: {
                okClicked(plancomboBox.currentIndex);
                root.visible = false;
            }
        }

    }
}
