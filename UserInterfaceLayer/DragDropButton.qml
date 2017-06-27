import QtQuick 2.7
import QtQuick.Controls 2.1

MouseArea{
    property color startColor;
    property color stopColor;
    property color borderColor;
    property var textValue;
    property color textColor;
    property var buttonradius;
    property var textHorizontalAlignment : textItem.horizontalAlignment;
    property int fontPixelSize;
    property bool holding;

    property int pressAndHoldDuration;

    signal dragEntered(var drag);

    //drag
    holding:false
    //pressAndHoldDuration: 500

    id:textbutton
    width: parent.width
    height: 100

    fontPixelSize: 20

    textColor:"#e1e8e2"
    startColor: "#5cc5ff"
    stopColor: "#5cc5ff"
    borderColor: "transparent"
    buttonradius: 8




    Rectangle{
        id:content
        anchors.fill: parent

        opacity: enabled?1:0.3
        //color: mouseButton.pressed?"lightgreen":"lightgray"
        radius: buttonradius
        gradient: textbutton.pressed?pressGradient:normalGradient;

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

        Drag.active: textbutton.holding
        Drag.source: textbutton
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        states: State {
            when: textbutton.holding

            ParentChange { target: content; parent: textbutton.parent }
            AnchorChanges {
                target: content
                anchors { horizontalCenter: undefined; verticalCenter: undefined }
            }
        }
    }

    onReleased: {
        holding = false;
    }

    onPressAndHold: holding = true

    drag.target: holding ? content : undefined
    drag.axis: Drag.YAxis

    DropArea {
        anchors { fill: parent; margins: 10 }

        onEntered: {
            textbutton.dragEntered(drag);
        }
    }
}

