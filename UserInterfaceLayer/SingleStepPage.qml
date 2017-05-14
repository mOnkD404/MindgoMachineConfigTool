import QtQuick 2.4

Item {
    id:singleStepPage
    anchors.fill: parent

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
            anchors.horizontalCenter: parent.horizontalCenter
        }

        TextButton{
            width: 100
            height: 45
            text: qsTr("Execute")
            anchors.right: parent.right
            anchors.rightMargin: 0
            onClicked: {
                singleStepOperation.commitData(0);
                console.debug("Execute single step operation.");
            }
        }
    }

    OperationList{
        id:singleStepOperation

        anchors.top: row.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        name: "SingleStepPage"
    }

}
