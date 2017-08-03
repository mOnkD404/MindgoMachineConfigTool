import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQml.Models 2.2

Item {
    TreeView{
        id:tree
        anchors.fill: parent
        TableViewColumn {
            title: "Name"
            role: "fileName"
            width: 300
        }
        model: configFileConverter.fileSystemModel()

        Component.onCompleted: {
            rootIndex = configFileConverter.rootIndex();
        }
    }

}
