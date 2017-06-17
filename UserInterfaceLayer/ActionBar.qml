import QtQuick 2.7
import QtGraphicalEffects 1.0

Item {
    property var positionAction;
    signal doAction(var str);

    positionAction: true

    ListModel{
        id: actionBarModel
        ListElement{
            name:"delete"
            icon:"./image/garbage.png"
            colorVal:"#da3430"
        }
        ListElement{
            name:"up"
            icon:"./image/up.png"
            colorVal:"#31d7a6"
        }
        ListElement{
            name:"down"
            icon:"./image/down.png"
            colorVal:"#31d7a6"
        }
        ListElement{
            name:"edit"
            icon:"./image/edit.png"
            colorVal:"#36b278"
        }
        ListElement{
            name:"add"
            icon:"./image/add.png"
            colorVal:"#da3430"
        }
    }
    ListModel{
        id: actionBarModelWithOutPositionAction
        ListElement{
            name:"delete"
            icon:"./image/garbage.png"
            colorVal:"#da3430"
        }

        ListElement{
            name:"edit"
            icon:"./image/edit.png"
            colorVal:"#36b278"
        }
        ListElement{
            name:"add"
            icon:"./image/add.png"
            colorVal:"#da3430"
        }
    }

    Component{
        id: iconArea

        Rectangle{

            width: 25
            height: 25

            color:mouse.pressed?"lightblue":colorVal

            Image{
                source: icon
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.leftMargin: 3
                anchors.rightMargin: 3
                anchors.bottomMargin: 3
                smooth: true
                antialiasing: true
                visible: true
            }

            MouseArea{
                id: mouse
                anchors.fill: parent

                onClicked: {
                    doAction(name);
                }
            }
        }
    }

    ListView{
        anchors.rightMargin: 5
        anchors.leftMargin: 5
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        anchors.fill: parent
        highlightMoveDuration: 5
        highlightRangeMode: ListView.StrictlyEnforceRange
        spacing: 4
        interactive: false
        clip: false
        contentWidth: 25
        contentHeight: 25
        orientation: Qt.Horizontal
        layoutDirection: Qt.LeftToRight
        delegate: iconArea
        model:positionAction?actionBarModel:actionBarModelWithOutPositionAction
    }

}
