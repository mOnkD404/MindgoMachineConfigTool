import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import QtQuick.Dialogs 1.2
//import Qt.labs.platform 1.0

Item {
    id:systemSettingPage
    property string versionVal: "1.6.5"

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

            anchors.top:parent.top
            anchors.left: parent.left
            anchors.right: parent.right
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
                    id: text6
                    width: 220
                    height: 30
                    text: qsTr("License number")
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
                        id: textInput6
                        anchors.fill: parent
                        text: machineConfigObject.licenseNumber
                        placeholderText: qsTr("license")
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 17
                        inputMethodHints: Qt.ImhDigitsOnly
                        selectByMouse:true
                        validator: RegExpValidator{regExp: /^([0-9]{4}-){3}([0-9]{4})$/}
                        //inputMask: "0000.0000.0000.0000;_"
                    }
                }
            }

            Row{
                spacing: 5
                visible: administratorChecker.bAdministrator

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
                        text: machineConfigObject.IpAddress
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 17
                        inputMethodHints: Qt.ImhDigitsOnly

                        selectByMouse:true

                        validator: RegExpValidator{regExp: /^(([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))\.){3}([01]?[0-9]?[0-9]|2([0-4][0-9]|5[0-5]))$/}
                        //inputMask: "000.000.000.000;_"
                    }
                }


                Text {
                    id: text4
                    text: ":"
                    width: 5
                    height: 30
                    color: "#d9d9d9"
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideNone
                    font.pixelSize: 20
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
                        text: machineConfigObject.port
                        placeholderText: qsTr("port")
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 17
                        inputMethodHints: Qt.ImhDigitsOnly
                        selectByMouse:true

                        validator:IntValidator{
                            bottom: 0
                            top:65535
                        }
                    }
                }
            }

            Row{
                spacing: 5
                visible: administratorChecker.bAdministrator

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
                        text: machineConfigObject.maxReceiveTime
                        placeholderText: qsTr("Wait time")
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 17
                        inputMethodHints: Qt.ImhDigitsOnly
                        selectByMouse:true

                        validator:IntValidator{
                            bottom: 0
                            top:65535
                        }
                    }
                }
            }

            Row{
                spacing: 5
                visible: administratorChecker.bAdministrator

                Text {
                    id: text5
                    width: 220
                    height: 35
                    text: qsTr("Work place configuration")
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignLeft
                    font.pixelSize: 20
                    color: "#d9d9d9"
                    font.bold: true
                }

//                ComboBox{
//                    width: 200
//                    height: 35

//                    textRole: "name"

//                    StatusViewWatcher{
//                        id:watcher
//                    }

//                    model:ListModel{
//                        id:comboModel
//                    }

//                    Component.onCompleted: {
//                        var listAll = watcher.getWorkLocationTypeList();

//                        comboModel.clear();
//                        for(var item in listAll.config){
//                            comboModel.append({"name":listAll.config[item].name});
//                        }

//                        currentIndex = listAll.current;
//                    }

//                    onCurrentIndexChanged: {
//                        var listAll = watcher.getWorkLocationTypeList();

//                        listAll.current = currentIndex;
//                        watcher.updateWorkPlace(listAll);
//                    }
//                }
//                ActionBar{
//                    positionAction: false

//                    height: 33
//                    width: 110

//                    onDoAction: {
//                        if(str == "edit"){

//                        }else if(str == "add"){

//                        }else if(str == "delete"){

//                        }
//                    }
//                }
//                Rectangle{
//                    height:35
//                    width:250
//                    clip:true
//                    color: "#4c000000"

//                    Row{
//                        anchors.fill: parent
//                        anchors.margins: 2
//                        spacing: 3
//                        TextField{
//                            height:31
//                            width:120
//                        }
//                        TextButton{
//                            height:31
//                            width:60
//                            buttonradius: 0
//                            textValue: qsTr('OK')
//                        }
//                        TextButton{
//                            height:31
//                            width:60
//                            buttonradius: 0
//                            textValue: qsTr('Cancel')
//                        }
//                    }
//                }
            }
        }
        Item{
            id:configColumn
            anchors.top: column.bottom
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 20
            visible: administratorChecker.bAdministrator

            width: 220

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

            ActionBar{
                id:configActionbar
                positionAction: false

                height: 27

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4
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
            //anchors.right: parent.right
            anchors.left: configColumn.right
            anchors.top: column.bottom
            //anchors.bottom: parent.bottom
            anchors.topMargin: 10
            anchors.leftMargin: 10
            width: 650
            height: 400

            showLabel: false
            showCombo: true

            visible:configListModel.count>0 && administratorChecker.bAdministrator
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
                forceActiveFocus();
                machineConfigObject.IpAddress = textInput.text;
                machineConfigObject.port = textInput1.text;
                machineConfigObject.maxReceiveTime = textInput2.text;
                machineConfigObject.licenseNumber = textInput6.text;
                var result = machineConfigObject.onMachineConfigChanged()?qsTr("save succeed"):qsTr("save failed");
                textButton.showPrompt(result);

                textInput.focus = false;
                textInput1.focus = false;
                textInput2.focus = false;
            }
        }
        TextButton {
            id: textButton2
            width: 130
            height: administratorChecker.bAdministrator?60:0
            anchors.top: textButton.bottom
            anchors.topMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 0
            buttonradius: 3
            borderColor: "#4c5cc5ff"
            textValue: qsTr("Export config")
            fontPixelSize: 20

            onClicked: {
                forceActiveFocus();
                fileDialogExport.visible = true;
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
                forceActiveFocus();
                fileDialogImport.visible = true;
            }
        }
    }


    FileDialog {
        id: fileDialogExport
        title: qsTr("Save file")
        folder: shortcuts.documents
        visible: false
        selectMultiple:false
        selectExisting:false
        //fileMode: FileDialog.SaveFile
        nameFilters: [ "CSV files (*.csv)" ]
        onAccepted: {
            var result = configFileConverter.exportConfigFile(fileUrl)?qsTr("export succeed"):qsTr("export failed");
            textButton2.showPrompt(result);
            visible = false;
        }
        onRejected: {
            visible = false;
        }
    }
    FileDialog {
        id: fileDialogImport
        title: qsTr("Select file")
        folder: shortcuts.documents
        visible: false
        selectMultiple:false
        selectExisting:true
        nameFilters: [ "CSV files (*.csv)" ]
        //fileMode: FileDialog.OpenFile
        onAccepted: {
            if(configFileConverter.importConfigFile(fileUrl)){
                configListView.refreshModel();
                textButton3.showPrompt(qsTr("import succeed"));
            }else {
                textButton3.showPrompt(qsTr("import failed"));
            }

            visible = false;
        }
        onRejected: {
            visible = false;
        }
    }
}
