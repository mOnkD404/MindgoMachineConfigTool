import QtQuick 2.7
import QtQuick.VirtualKeyboard 2.1

Item {
    id:singleStepPage
    anchors.fill: parent

    Rectangle{
        anchors.fill: parent
        anchors.margins: 10
        color:"#58595b"
        MouseArea{
            anchors.fill: parent
        }

        Item{
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 40

            Text{
                text:qsTr("Single step operation")
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 30
                color:"#d9d9d9"
            }

            TextButton{
                id: execButton
                width: height*2
                height: parent.height
                textValue: qsTr("Execute")
                anchors.right: parent.right
                anchors.rightMargin: 0
                buttonradius: 0
                fontPixelSize: 20
                onClicked: {
                    singleStepOperation.commitData();
                    console.debug("Execute single step operation.");
                }
            }
        }

        OperationList{
            id:singleStepOperation

            columnWidth: 160
            anchors.top: row.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottom: parent.bottom

            operationGroupType: "NormalOperation"

            onPositionSelected: {
                stepGallery.currentIndex = index;
            }
        }

        StatusListView{
            id: singleStepStatus
            anchors.top: row.bottom
            anchors.topMargin: 5
            anchors.left: singleStepOperation.right
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            height:85

        }
        StepGallery{
            //height: 480
            //width: 1000
            id:stepGallery

            anchors.top: singleStepStatus.bottom
            anchors.left: singleStepOperation.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.margins: 10

            activeOnClick: true
            showLabel: false
            showIndex: true

            onItemSelected: {
                singleStepOperation.setPosition(index);
            }
        }

        InputPanel{
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 500
            height:500
            visible: Qt.inputMethod.visible
            //x: Qt.inputMethod.visible?parent.width - InputPanel.width: parent.width;
        }
    }

}
