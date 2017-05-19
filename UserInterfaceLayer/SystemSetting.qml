import QtQuick 2.4
import QtQuick.Controls 1.4

Item {
    id:systemSettingPage
    MouseArea{
        anchors.fill: parent
    }

    Grid {
        id: grid
        spacing: 5

        anchors.fill:parent
        anchors.topMargin: 20
        anchors.leftMargin: 20
        anchors.rightMargin: 20

        Text {
            id: text1
            width: 220
            height: 30
            color: "#d9d9d9"
            text: qsTr("Machine Address")
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideNone
            font.pixelSize: 20
        }

        Rectangle{
            width: 200
            height: 30
            border.width: 2
            border.color: "#ffffff"
            radius: 4
            TextField {
                id: textInput
                anchors.fill: parent
                placeholderText: qsTr("IP Address")
                text: IPAddressObject.IpAddress
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20

                validator: RegExpValidator{regExp: /^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))$/}
                //inputMask: "000.000.000.000;_"
            }
        }

        Rectangle{
            width: 82
            height: 30
            border.width: 2
            border.color: "#ffffff"
            radius: 4
            TextField {
                id: textInput1
                anchors.fill: parent
                text: IPAddressObject.port
                placeholderText: qsTr("port")
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 20

                validator:IntValidator{
                    bottom: 0
                    top:65535
                }
            }
        }

        TextButton {
            id: textButton
            width: 65
            height: 30
            buttonradius: 3
            textValue: qsTr("Save")

            onClicked: {
                IPAddressObject.IpAddress = textInput.text;
                IPAddressObject.port = textInput1.text;

                textInput.focus = false;
                textInput1.focus = false;
            }
        }
    }


}
