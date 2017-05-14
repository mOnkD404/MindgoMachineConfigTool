import QtQuick 2.0
import QtQuick.Controls 2.1

Button{
    property color backColor;
    id:textbutton
    width: parent.width
    height: 100
    backColor: "lightgray"
    font.bold: true

    background: Rectangle{
        opacity: enabled?1:0.3
        color: textbutton.down?"lightgreen":backColor
        radius: 8
    }

}

