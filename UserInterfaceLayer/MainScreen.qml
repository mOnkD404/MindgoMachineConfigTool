import QtQuick 2.4

Item {

    anchors.rightMargin: 10
    anchors.leftMargin: 10
    anchors.bottomMargin: 10
    anchors.topMargin: 10
    anchors.fill: parent

    Column {
        id: column
        spacing: 12
        anchors.fill: parent

        Rectangle{

            height: 100
            color: "#ffffff"
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            radius: 8
            border.color: "#ffffff"
            border.width: 0

            id: mainScreenHeader
            Text {
                id: title
                width: 400
                text: qsTr("Automatic moving fluid tool")
                renderType: Text.NativeRendering
                font.weight: Font.ExtraBold
                style: Text.Normal
                anchors.verticalCenter: parent.verticalCenter
                textFormat: Text.PlainText
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 28
                font.bold: true
            }

            Text {
                id: timeBar
                width: 150
                text: qsTr("00-00-00")
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 12
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
            height: 350
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Item {
                id: mainVDewID
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                width: 400
            }
            
            Column {
                id: actionBarID
                width: 150
                height: 620
                anchors.right: parent.right
                anchors.rightMargin: 20
                spacing: 3

                TextButton{
                    id:button1
                    height: 80
                    text: qsTr("Single step")

                    onClicked: subPage.subPageUrl = Qt.resolvedUrl("SingleStepPage.qml");
                }

                TextButton{
                    id:button2
                    height: 80
                    text: qsTr("System settings")

                    onClicked: subPage.subPageUrl = Qt.resolvedUrl("SystemSdtting.qml")
                }

                TextButton{
                    id:button3
                    height: 80
                    text: qsTr("Plan settings")

                    onClicked: subPage.subPageUrl = Qt.resolvedUrl("PlanSetting.qml")
                }

                TextButton{
                    id:button4
                    text: qsTr("Start test")
                    height: 100
                    font.pixelSize: 20
                    backColor:"darkgreen"

                    onClicked: console.debug("start")
                }


            }
        }
    }

    Rectangle{
        property url subPageUrl
        //onSubPageUrlChanged: visible = (subPageUrl == ''?false:true);

        id:subPage
        anchors.fill:parent
        visible: subPageUrl == ''?false:true

        TextButton{
            id: backButton
            text:qsTr("< Back")
            height:45
            width:100
            anchors.left: parent.left
            anchors.top: parent.top

            onClicked:subPage.subPageUrl = ""
        }

        Loader{
            id:subLoader
            focus: true
            source: subPage.subPageUrl

            anchors.fill: parent
        }

    }
}
