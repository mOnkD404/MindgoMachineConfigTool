import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import QtQuick.VirtualKeyboard 2.1

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
    InputPanel{
        id: globalinput
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        //anchors.bottom: parent.bottom
        //visible: Qt.inputMethod.visible
        y:active?parent.height - height:parent.height
        Behavior on y{
            PropertyAnimation{duration:200}
        }
    }
}
