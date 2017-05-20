import QtQuick 2.4

Item {
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
            height: 50

            Text{
                text:qsTr("Plan setting")
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
                textValue: qsTr("Save")
                anchors.right: parent.right
                anchors.rightMargin: 0
                buttonradius: 0
                onClicked: {
                    planList.savePlan();
                }
            }
        }

        PlanList{
            id:planList

            anchors.top: row.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
    }
}
