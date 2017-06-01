import QtQuick 2.7
import QtQuick.Controls 1.4

Item {
    id:systemSettingPage
    property string versionVal: "1.2"

    //    MouseArea{
    //        anchors.fill: parent
    //    }

    Rectangle{
        anchors.fill: parent
        anchors.margins: 10
        color:"#58595a"
        MouseArea{
            anchors.fill: parent
        }
        Column {
            id: column
            spacing: 5

            anchors.fill:parent
            anchors.topMargin: 20
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            Text {
                id: text3
                text: qsTr("Version "+versionVal)

                width: 220
                height: 30
                color: "#d9d9d9"
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideNone
                font.pixelSize: 20
            }

            Row{
                spacing: 5

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
            }

            Row{
                spacing: 5

                Text {
                    id: text2
                    width: 220
                    height: 30
                    text: qsTr("Max ack waiting time")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: 20
                    color: "#d9d9d9"
                    font.bold: true
                }


                Rectangle{
                    width: 200
                    height: 30
                    border.width: 2
                    border.color: "#ffffff"
                    radius: 4
                    TextField {
                        id: textInput2
                        anchors.fill: parent
                        text: IPAddressObject.maxReceiveTime
                        placeholderText: qsTr("Wait time")
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 20

                        validator:IntValidator{
                            bottom: 0
                            top:65535
                        }
                    }
                }
            }

            StepGallery{
                height: 480
                width: 1000

                activeOnClick: true
            }



        }
        TextButton {
            id: textButton
            width: 130
            height: 60
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            buttonradius: 0
            textValue: qsTr("Save")

            onClicked: {
                IPAddressObject.IpAddress = textInput.text;
                IPAddressObject.port = textInput1.text;
                IPAddressObject.maxReceiveTime = textInput2.text;
                IPAddressObject.onMachineConfigChanged();

                textInput.focus = false;
                textInput1.focus = false;
                textInput2.focus = false;
            }
        }

    }
}
