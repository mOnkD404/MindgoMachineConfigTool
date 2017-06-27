import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Window 2.2

Item {
    visible: true
    width: 800
    height: 480
    antialiasing: true
    //scale: 0.5

    //title: qsTr("Mindgo automatic tool")

    MainScreen{
        id:mainscreen
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
    }
    Item{
        property bool active
        active:false
        id:globalinput
        visible:false
    }
}
