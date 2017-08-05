import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQml.Models 2.2
import Common 1.0

Rectangle {
    property string type:"export"
    signal accepted(string fileUrl);
    signal rejected();

    id:root
    //modal: true
    focus: true
    //closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    width: subPageRect.width
    height: subPageRect.height

    color: "#414141"

    FileViewModel{
        id:modelProvider
        dirOnly:type=="export"
    }
    onVisibleChanged: {
        if(visible){
            tree.selection.setCurrentIndex(-1, ItemSelectionModel.Clear);
        }
    }

    Item{
        anchors.fill: parent
        Row{
            id: layout
            anchors.fill: parent
            anchors.margins: 10

            spacing: 10


            TreeView{
                id:tree
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 600
                clip: true

                selection:ItemSelectionModel{
                    id:selectionModel
                }

                style: TreeViewStyle{
                    textColor:"white"
                    highlightedTextColor: "white"
                    backgroundColor: "#ac58595b"
                    alternateBackgroundColor: "#9c58595b"
                    activateItemOnSingleClick: true

                    branchDelegate: Item{
                        height:45
                        width: 20
                        clip:true
                        rotation:styleData.isExpanded?90:0

                        Behavior on rotation{
                            PropertyAnimation{
                                duration: 100
                            }
                        }

                        Text{
                            anchors.fill: parent
                            anchors.margins: 8
                            text:">"
                            color:"#e1e8e2"
                            font.pixelSize: 17
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                headerDelegate: Rectangle{
                    color:"#545454"
                    height: 50

                    Text {
                        text: styleData.value
                        color:"#d9d9d9"
                        verticalAlignment: Text.AlignVCenter
                        anchors.leftMargin: 5
                        anchors.fill: parent
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                itemDelegate: Item{
                    height:45
                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        color: styleData.textColor
                        elide: styleData.elideMode
                        text: styleData.value
                        font.pixelSize: 17
                    }
//                    MouseArea{
//                        anchors.fill: parent

//                        onClicked: {
//                            console.debug(styleData.index);
//                            if(styleData.hasChildren){
//                                if(styleData.isExpanded){
//                                    tree.collapse(styleData.index);
//                                }else{
//                                    tree.expand(styleData.index);
//                                }
//                            }
//                            tree.selection.setCurrentIndex(styleData.index, ItemSelectionModel.ClearAndSelect);
//                        }
//                    }
                }
                rowDelegate: Rectangle{
                    height:45
                    color:getColor()

                    function getColor(){
                        if(styleData.selected){
                            return "#5cc5ff";
                        }else if (styleData.alternate){
                            return "#00000000";
                        }else{
                            return "#1c000000";
                        }
                    }
                }
                TableViewColumn {
                    title: qsTr("File name")
                    role: "fileName"
                    width: 300
                }

                Component.onCompleted: {
                    model = modelProvider.fileSystemModel();
                    selectionModel.model = modelProvider.fileSystemModel();
                    rootIndex = modelProvider.rootIndex();
                }
                onActivated: {
                    if(modelProvider.fileSystemModel().hasChildren(index)){
                        if(tree.isExpanded(index)){
                            tree.collapse(index);
                        }else{
                            tree.expand(index);
                        }
                    }
                    tree.selection.setCurrentIndex(index, ItemSelectionModel.ClearAndSelect);
                }
            }
            Column{
                spacing: 10

                TextButton {
                    width: 130
                    height: 60
                    buttonradius: 3
                    borderColor: "#4c5cc5ff"
                    textValue: qsTr("Confirm")
                    fontPixelSize: 20
                    enabled: tree.selection.currentIndex.row>=0

                    onClicked: {
                        if(tree.selection.currentIndex.row >= 0){
                            accepted(modelProvider.fullFileName(tree.selection.currentIndex));
                        }
                    }
                }
                TextButton{
                    textValue: qsTr("Cancel")
                    width: 130
                    height: 60
                    buttonradius: 3
                    borderColor: "#4c5cc5ff"
                    fontPixelSize: 20

                    onClicked: {
                        rejected();
                    }
                }
            }
        }
    }
}
