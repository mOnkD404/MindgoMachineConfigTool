import QtQuick 2.4

Item {
    anchors.fill: parent
    Rectangle{

        height: 70
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
            font.pixelSize: 28
            font.bold: true
        }

        Text {
            id: timeBar
            width: 200
            color: "#fdfdfd"
            text: qsTr("00-00-00")
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 18
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
        }

        Column {
            id: actionBarID
            width: 150
            height: 620
            anchors.top: parent.top
            anchors.topMargin: 14
            anchors.right: parent.right
            anchors.rightMargin: 20
            spacing: 20

            TextButton{
                id:button1
                height: 52.7
                textValue: qsTr("Single step")
                startColor:"#a9aaac"
                stopColor:"#6e6d71"
                borderColor:"#cecece"

                onClicked: subPage.subPageUrl = Qt.resolvedUrl("SingleStepPage.qml");
            }

            TextButton{
                id:button2
                height: 55
                textValue: qsTr("System settings")
                startColor:"#a9aaac"
                stopColor:"#6e6d71"
                borderColor:"#cecece"

                onClicked: subPage.subPageUrl = Qt.resolvedUrl("SystemSdtting.qml")
            }

            TextButton{
                id:button3
                height: 55
                textValue: qsTr("Plan settings")
                startColor:"#a9aaac"
                stopColor:"#6e6d71"
                borderColor:"#cecece"

                onClicked: subPage.subPageUrl = Qt.resolvedUrl("PlanSetting.qml")
            }

            TextButton{
                id:button4
                textValue: qsTr("Start test")
                height: 80
                startColor:"#cffe9e"
                stopColor:"#92d456"
                borderColor:"#99da73"

                onClicked: console.debug("start")
            }


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
            height: 70
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
                height:45
                width:100
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
}
