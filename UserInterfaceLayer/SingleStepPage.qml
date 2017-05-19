import QtQuick 2.4

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
            height: 50

            Text{
                text:qsTr("Single step operation")
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pointSize: 19
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 30
                color:"#d9d9d9"
            }

            TextButton{
                width: 100
                height: 45
                textValue: qsTr("Execute")
                anchors.right: parent.right
                anchors.rightMargin: 0
                buttonradius: 0
                onClicked: {
                    singleStepOperation.commitData();
                    console.debug("Execute single step operation.");
                }
            }
        }

        OperationList{
            id:singleStepOperation

            anchors.top: row.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottom: parent.bottom

            operationGroupType: "NormalOperation"
        }

        StatusListView{
            anchors.top: row.bottom
            anchors.topMargin: 10
            anchors.left: singleStepOperation.right
            anchors.leftMargin: 10

            height: 400
        }
    }

}
