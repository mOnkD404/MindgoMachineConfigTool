import QtQuick 2.7
import QtQuick.Controls 2.1

Item{
    property color startColor;
    property color stopColor;
    property color borderColor;
    property var textValue;
    property color textColor;
    property var buttonradius;
    property var textHorizontalAlignment : textItem.horizontalAlignment;

    property int fontPixelSize;
    property bool holding;


    signal clicked;
    signal pressed;
    signal released;

    //drag
    holding:false

    id:textbutton
    width: parent.width
    height: 100

    textColor:"#e1e8e2"
    startColor: "#5cc5ff"
    stopColor: "#5cc5ff"
    borderColor: "transparent"
    buttonradius: 8


    Rectangle{
        id:promptLabel
        height: buttonRect.height
        anchors.right: buttonRect.left
        anchors.margins: 2
        visible: false
        property alias text: promptText.text

        color: "#cc414141"
        radius: 3
        border.width: 2
        border.color: "#acdfdfdf"
        clip:true

        Text{
            id:promptText
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter

            text:textValue
            color:textColor

            font.pixelSize: fontPixelSize
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            styleColor: "#3a3a3a"
            style: Text.Raised
        }

        states:[
            State{
                name:"showOnce"
                PropertyChanges {
                    target: promptLabel
                    visible: true
                }
                PropertyChanges {
                    target: animatePrompt
                    running: true
                }
            }

        ]
    }

    function showPrompt(prompt){
        promptLabel.text = prompt;
        promptLabel.state = "showOnce";
    }

    SequentialAnimation{
        id: animatePrompt
        running: false
        alwaysRunToEnd: true

        PropertyAnimation{
            target:promptLabel
            property: "width"
            to: buttonRect.width*1.5
            duration: 100
        }

        PauseAnimation {
            duration: 1000
        }
        PropertyAnimation{
            target:promptLabel
            property: "width"
            to: 0
            duration: 100
        }

        onStopped: {
            promptLabel.state = "";
        }
    }

    Rectangle{
        id:buttonRect
        anchors.fill: parent
        clip:true

        opacity: enabled?1:0.3
        //color: mouseButton.pressed?"lightgreen":"lightgray"
        radius: buttonradius
        gradient: getGradient()

        Gradient {
            id:normalGradient
            GradientStop { position: 0.0; color: startColor }
            GradientStop { position: 1.0; color: stopColor }
        }

        Gradient {
            id:pressGradient
            GradientStop { position: 0.0; color: "lightblue" }
            GradientStop { position: 1.0; color: "lightblue" }
        }

        function getGradient(){
            if (mouseButton.pressed)
                return pressGradient;
            else
                return normalGradient;
        }
        border.color: borderColor
        border.width: 2

        Text{
            id:textItem
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter

            text:textValue
            color:textColor

            font.pixelSize: fontPixelSize
            font.bold: true
            verticalAlignment: Text.AlignVCenter
            styleColor: "#3a3a3a"
            style: Text.Raised

        }


        MouseArea{
            id:mouseButton
            anchors.fill: parent
            property int pressAndHoldDuration: 500

            onClicked: {
                textbutton.clicked();
            }
            onPressed:{
                mouse.acccepted = true;
                textbutton.pressed();
                pressAndHoldTimer.start();
            }
            onReleased: {
                textbutton.released();
                pressAndHoldTimer.stop();
                textbutton.holding = false;
            }

            Timer {
                id:  pressAndHoldTimer
                interval: parent.pressAndHoldDuration
                running: false
                repeat: false
                onTriggered: {
                    textbutton.holding = true;
                }
            }
        }
    }
}

