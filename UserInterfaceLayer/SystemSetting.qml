import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import QtQuick.Dialogs 1.2
//import Qt.labs.platform 1.0

Item {
    id:systemSettingPage
    property string versionVal: "1.6.1"

    //    MouseArea{
    //        anchors.fill: parent
    //    }

    Rectangle{
        anchors.fill: parent
        anchors.margins: 10
        color:"#58595a"
        MouseArea{
            anchors.fill: parent
            onClicked: {
                systemSettingPage.forceActiveFocus();
            }
        }

        Flickable{
            //anchors.top: parent.top
            //anchors.bottom: parent.bottom
            id:scrollableView
            anchors.left: parent.left
            anchors.right: textButton.left

            ScrollBar.vertical: ScrollBar{}

            clip:true

            height: globalinput.active?parent.height -globalinput.height:parent.height-10;
            Behavior on height{
                PropertyAnimation { duration:200}
            }
            onHeightChanged: {
                if(globalinput.active){
                    var itemHeight = 40;
                    var tempY = mapFromItem(stepGallery, 0, stepGallery.activeY).y;
                    if(tempY +itemHeight> height){
                        contentY  += (tempY - height + itemHeight);
                    }
                }
            }

            contentHeight: column.height

            Column {
                id: column
                spacing: 2

                width: parent.width


               // anchors.top:parent.top
                //anchors.left: parent.left
                //anchors.right: parent.right
               // anchors.topMargin: 0
                //anchors.leftMargin: 10
                //anchors.rightMargin: 10

                Text {
                    id: text3
                    text: qsTr("Version "+versionVal)

                    width: 220
                    height: 22
                    color: "#d9d9d9"
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideNone
                    font.pixelSize: 17
                }

                Row{
                    spacing: 5

                    Text {
                        id: text1
                        width: 220
                        height: 35
                        color: "#d9d9d9"
                        text: qsTr("Machine Address")
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideNone
                        font.pixelSize: 17
                    }

                    Rectangle{
                        width: 200
                        height: 35
                        border.width: 2
                        border.color: "#ffffff"
                        radius: 4
                        TextField {
                            id: textInput
                            anchors.fill: parent
                            placeholderText: qsTr("IP Address")
                            text: IPAddressObject.IpAddress
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 17
                            inputMethodHints: Qt.ImhDigitsOnly

                            validator: RegExpValidator{regExp: /^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))$/}
                            //inputMask: "000.000.000.000;_"
                        }
                    }


                    Text {
                        id: text4
                        text: ":"
                        width: 5
                        height: 35
                        color: "#d9d9d9"
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideNone
                        font.pixelSize: 17
                    }
                    Rectangle{
                        width: 82
                        height: 35
                        border.width: 2
                        border.color: "#ffffff"
                        radius: 4
                        TextField {
                            id: textInput1
                            anchors.fill: parent
                            text: IPAddressObject.port
                            placeholderText: qsTr("port")
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 17
                            inputMethodHints: Qt.ImhDigitsOnly

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
                        height: 35
                        text: qsTr("Max ack waiting time")
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 17
                        color: "#d9d9d9"
                        font.bold: true
                    }


                    Rectangle{
                        width: 200
                        height: 35
                        border.width: 2
                        border.color: "#ffffff"
                        radius: 4
                        TextField {
                            id: textInput2
                            anchors.fill: parent
                            text: IPAddressObject.maxReceiveTime
                            placeholderText: qsTr("Wait time")
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 17
                            inputMethodHints: Qt.ImhDigitsOnly

                            validator:IntValidator{
                                bottom: 0
                                top:65535
                            }
                        }
                    }
                }

                Row{
                    spacing: 5
                    Item{
                        id:configColumn
                        //anchors.top: parent.top
                        //anchors.left: parent.left
                        //anchors.bottom: parent.bottom
                        //anchors.leftMargin: 20

                        width: 130
                        height: 400

                        StatusViewWatcher{
                            id:watcher
                        }

                        function addConfig(newname){
                            var listAll = watcher.getWorkLocationTypeList();

                            var defaultVal = listAll.default;
                            defaultVal.name = newname;

                            listAll.config.push(defaultVal);
                            watcher.updateWorkPlace(listAll);
                        }

                        function removeConfig(index){
                            var listAll = watcher.getWorkLocationTypeList();

                            if ( index >= 0 && index < listAll.config.length){
                                listAll.config.splice(index, 1);
                                watcher.updateWorkPlace(listAll);
                            }
                        }

                        function setConfigName(index, newname){
                            var listAll = watcher.getWorkLocationTypeList();

                            if ( index >= 0 && index < listAll.config.length){
                                if(listAll.config[index].name != newname){
                                    listAll.config[index].name = newname;
                                    watcher.updateWorkPlace(listAll);
                                }
                            }
                        }

                        function selectConfig(currentIndex){
                            var listAll = watcher.getWorkLocationTypeList();

                            listAll.current = currentIndex;
                            watcher.updateWorkPlace(listAll);
                        }

                        Text {
                            id: text5
                            //width: 220
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 25
                            text: qsTr("Work place configuration")
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            font.pixelSize: 17
                            color: "#d9d9d9"
                            font.bold: true
                        }

                        ActionBar{
                            id:configActionbar
                            positionAction: false

                            height: 27

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: text5.bottom
                            anchors.margins: 2
                            disableDelete:configListModel.count == 1
                            onDoAction: {
                                if(str == "edit"){
                                    if(configListView.currentIndex != -1){
                                        configListView.currentItem.inEdit = true;
                                    }
                                }else if(str == "add"){
                                    configListModel.append({"name":"NewConfig"});
                                    configColumn.addConfig("");
                                    configListView.currentIndex = configListModel.count - 1;
                                    configListView.currentItem.inEdit = true;
                                }else if(str == "delete"){
                                    if(configListModel.count > 1){
                                        configListModel.remove(configListView.currentIndex);
                                        configColumn.removeConfig(configListView.currentIndex);
                                    }
                                }
                            }
                        }

                        ListModel{
                            id:configListModel
                        }


                        ListView {
                            id: configListView
                            spacing: 0
                            anchors.top: configActionbar.bottom
                            anchors.topMargin: 4
                            anchors.right: parent.right
                            anchors.rightMargin: 4
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8

                            clip: true
                            highlight: Rectangle{
                                height: 40
                                anchors.left: parent.left
                                anchors.right: parent.right

                                color: "#ffb902"
                                radius: 0
                            }
                            highlightFollowsCurrentItem: true
                            //highlightMoveDuration: 200
                            currentIndex: 0
                            interactive: true
                            model: configListModel

                            ScrollBar.vertical: ScrollBar{}

                            delegate: Item{
                                property bool inEdit: false
                                height: 40
                                anchors.left:parent.left
                                anchors.leftMargin: 0
                                anchors.right: parent.right
                                anchors.rightMargin: 0
                                focus:true

                                TextInput{
                                    id:inputArea
                                    visible: inEdit
                                    selectByMouse: true

                                    height: 40
                                    font.italic: true
                                    verticalAlignment: Text.AlignVCenter
                                    font.pointSize: 22

                                    anchors.left:parent.left
                                    anchors.leftMargin: 0
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0
                                    focus: true
                                    text:name

                                    onAccepted: {
                                        configListModel.setProperty(index, "name", text);
                                        configColumn.setConfigName(index, text);
                                        parent.inEdit = false;
                                    }
                                    onVisibleChanged: {
                                        if(visible){
                                            focus = true;
                                            selectAll();
                                            forceActiveFocus();
                                        }
                                    }

                                    onFocusChanged: {
                                        if(!focus){
                                            configListModel.setProperty(index, "name", text);
                                            configColumn.setConfigName(index, text);
                                            parent.inEdit = false;
                                        }
                                    }
                                }

                                TextButton {
                                    visible: !inEdit

                                    height: 40
                                    anchors.left:parent.left
                                    anchors.leftMargin: 0
                                    anchors.right: parent.right
                                    anchors.rightMargin: 0

                                    fontPixelSize: 20


                                    buttonradius: 0

                                    textValue: name
                                    startColor: "#4c000000"
                                    stopColor: "#2c000000"
                                    onClicked: {
                                        configListView.currentIndex = index;
                                    }
                                }
                            }
                            onCurrentIndexChanged: {
                                configColumn.selectConfig(currentIndex);
                            }
                            Component.onCompleted: {
                                refreshModel();
                            }
                            function refreshModel(){
                                var listAll = watcher.getWorkLocationTypeList();

                                configListModel.clear();
                                for(var item in listAll.config){
                                    configListModel.append({"name":listAll.config[item].name});
                                }

                                configListView.currentIndex = listAll.current;

                            }
                        }

                    }

                    StepGallery{
                        id:stepGallery
                        //anchors.right: textButton.left
                        //anchors.left: configColumn.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 10
                        anchors.leftMargin: 10
                        width: 500
                        height: 250

                        showLabel: false
                        showCombo: true

                        visible:configListModel.count>0
                    }

                }
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
            buttonradius: 3
            borderColor: "#4c5cc5ff"
            textValue: qsTr("Save config")
            fontPixelSize: 20

            onClicked: {
                IPAddressObject.IpAddress = textInput.text;
                IPAddressObject.port = textInput1.text;
                IPAddressObject.maxReceiveTime = textInput2.text;
                var result = IPAddressObject.onMachineConfigChanged()?qsTr("save succeed"):qsTr("save failed");
                textButton.showPrompt(result);

                forceActiveFocus();
            }
        }
        TextButton {
            id: textButton2
            width: 130
            height: 60
            anchors.top: textButton.bottom
            anchors.topMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 0
            buttonradius: 3
            borderColor: "#4c5cc5ff"
            textValue: qsTr("Export config")
            fontPixelSize: 20

            onClicked: {
                //fileDialogExport.visible = true;
                fileViewExport.open();
                forceActiveFocus();
            }
        }
        TextButton {
            id: textButton3
            width: 130
            height: 60
            anchors.top: textButton2.bottom
            anchors.topMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 0
            buttonradius: 3
            borderColor: "#4c5cc5ff"
            textValue: qsTr("Import config")
            fontPixelSize: 20

            onClicked: {
                //fileDialogImport.visible = true;
                fileViewImport.open();
                forceActiveFocus();
            }
        }
    }

    FileView{
        id:fileViewExport

        type:"export"

        onAccepted: {
            var exportFileName = fileUrl + '/MindGoConfigExport_'+Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh_mm_ss")+'.csv';
            var result = configFileConverter.exportConfigFile(exportFileName.toLocaleString())?qsTr("export succeed"):qsTr("export failed");

            textButton2.showPrompt(result);
        }
    }
    FileView{
        id:fileViewImport
        type:"import"
        onAccepted: {
            if(configFileConverter.importConfigFile(fileUrl)){
                configListView.refreshModel();
                textButton3.showPrompt(qsTr("import succeed"));
            }else {
                textButton3.showPrompt(qsTr("import failed"));
            }
        }
    }

}
