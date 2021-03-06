﻿import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import QtQml.Models 2.2
import QtQuick.Dialogs 1.2
import "functions.js" as Script

Item {
    property alias operationState: operationColumn.state
    signal positionSelected(int index);
    signal boardIndexSelected(int index);

    id: root
    clip:true
    function savePlan(){
        return selector.onSave();
    }

    function setPosition(index){
        for(var ind = 0; ind < paramList.model.length; ind++){
            if(paramList.model[ind].Name == "position"){
                paramList.model[ind].IntegerValue = index;
                break;
            }
        }
    }

    function refreshBoardType(index){
        var boardIndex = selector.getPlanBoardTypeIndexByPosition(planListView.currentIndex, index);

        for(var ind = 0; ind < paramList.model.length; ind++){
            if(paramList.model[ind].Name == "boardType"){
                paramList.model[ind].IntegerValue = boardIndex;
                break;
            }
        }
    }
    function forceRefreshBoardType(){
        for(var ind = 0; ind < paramList.model.length; ind++){
            if(paramList.model[ind].Name == "position"){
                var pos = paramList.model[ind].IntegerValue;
                refreshBoardType(pos);
                break;
            }
        }
    }

    PlanSelector{
        id:selector
    }

    property var columnWidth;

    columnWidth: 165
    width: row.width
    Component.onCompleted: {
        planColumn.state = "expandPlan"
    }


    Row {
        id: row
        spacing: 10
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left

        Item {
            id: planColumn
            width: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            clip: true


            Behavior on width{
                PropertyAnimation{
                    easing.type: Easing.InOutSine
                    duration:200
                }
            }
            states:State{
                name:"expandPlan"
                PropertyChanges {
                    target: planColumn
                    width: columnWidth
                }
            }

            Rectangle{
                anchors.fill: parent
                anchors.bottomMargin: 8
                radius:8
                color: "#3c747474"
            }

            Rectangle{
                id: userPlanSelect
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 40

                Text {
                    text: qsTr("Plan list")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    //anchors.fill: parent
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: hideButton.left
                    font.pixelSize: 20
                    font.bold: true
                    width: 120
                    color:"#d9d9d9"
                }

                TextButton{
                    id: hideButton
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 3
                    width: height
                    buttonradius: 0

                    textValue:"<"

                    onClicked: {
                        planColumn.state = "";
                    }
                }
            }

            ActionBar{
                id:planActionbar
                positionAction: false

                height: 27

                anchors.top: userPlanSelect.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4

                disableDelete: planListModel.count == 1

                onDoAction: {
                    if(str == "edit"){
                        if(planListView.currentIndex != -1){
                            planListView.currentItem.inEdit = true;
                        }
                    }else if(str == "add"){
                        planListModel.append({"name":"NewPlan"});
                        selector.addPlan("");
                        planListView.currentIndex = planListModel.count - 1;
                        stepListView.refreshStepListModel();
                        planListView.currentItem.inEdit = true;
                    }else if(str == "delete"){
                        planListModel.remove(planListView.currentIndex);
                        selector.removePlan(planListView.currentIndex);
                        stepListView.refreshStepListModel();
                    }
                }
            }

            ListModel{
                id:planListModel
            }


            ListView {
                id: planListView
                spacing: 4
                anchors.top: planActionbar.bottom
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
                highlightMoveDuration: 200
                currentIndex: 0
                interactive: true
                ScrollBar.vertical: ScrollBar{}
                model: planListModel

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
                            planListModel.setProperty(index, "name", text);
                            selector.setPlanName(index, text);
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
                                planListModel.setProperty(index, "name", text);
                                selector.setPlanName(index, text);
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
                        startColor: "transparent"
                        stopColor: "transparent"
                        onClicked: {
                            console.debug(modelData+"clicked");
                            planListView.currentIndex = index;
                        }
                    }
                }
                onCurrentIndexChanged: {
                    stepListView.refreshStepListModel();

                    boardtypeCombobox.currentIndex = selector.boardConfigIndex(planListView.currentIndex);

                }
                Component.onCompleted: {
                    //                    refreshPlanListModel();
                    //                    stepListView.refreshStepListModel();
                }
                onVisibleChanged: {
                    if(visible){
                        refreshPlanListModel();
                        stepListView.refreshStepListModel()

                    }
                }

                function refreshPlanListModel(){
                    var list = selector.planListModel();
                    planListModel.clear();
                    for(var ind = 0; ind < list.length; ind++){
                        planListModel.append({"name":list[ind]});
                    }
                    currentIndex = 0;
                }
            }
        }


        Item {
            property string copyString;
            id: stepColumn
            width: columnWidth*1.3
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0

            Rectangle{
                anchors.fill: parent
                anchors.bottomMargin: 8
                radius:8
                color: "#3c747474"
            }

            Rectangle{
                id: stepList
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 40

                TextButton{
                    id: expandButton
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: 3
                    width: height
                    buttonradius: 0

                    textValue:">"
                    visible:(planColumn.state=="")

                    onClicked: {
                        planColumn.state = "expandPlan";
                    }
                }

                Text {
                    text: qsTr("Step list")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    //anchors.fill: parent
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.left: expandButton.visible?expandButton.right:parent.left
                    font.pixelSize: 20
                    font.bold: true
                    //width: 120
                    color:"#d9d9d9"
                }
            }

            ActionBar{
                id:stepActionBar

                height: 27

                //positionAction: false
                anchors.top: stepList.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 4

                disablePaste: (stepColumn.copyString.length == 0 )

                onDoAction: {
                    stepListView.expandAll();
                    if (str == "add"){
                        operationColumn.changeOperation = "add"
                        operationColumn.state = "expandOperation";
                    }else if(str == "edit"){
                        operationColumn.changeOperation = "edit";
                        operationColumn.state = "expandOperation";
                    }else if(str == "up"){
                        selector.moveStep(planListView.currentIndex, stepListView.currentIndex, stepListView.currentIndex-1);
                        stepListModel.move(stepListView.currentIndex, stepListView.currentIndex - 1, 1);
                    }else if(str == "down"){
                        selector.moveStep(planListView.currentIndex, stepListView.currentIndex, stepListView.currentIndex+1);
                        stepListModel.move(stepListView.currentIndex, stepListView.currentIndex + 1, 1);
                    }else if(str == "delete"){
                        selector.removeStep(planListView.currentIndex, stepListView.currentIndex);
                        stepListModel.remove(stepListView.currentIndex);
                        if(stepListView.count > 0){
                            if(stepListView.currentIndex > 0){
                                stepListView.currentIndex = stepListView.currentIndex -1;
                            }else {
                                selector.setSelectedStep(planListView.currentIndex, stepListView.currentIndex);
                                //paramList.model = selector.paramListModel();
                            }
                        }
                    }else if(str == "copy"){
                        stepColumn.copyString = stepListModel.get(stepListView.currentIndex).name;
                        selector.copyStep(planListView.currentIndex, stepListView.currentIndex);
                    }else if(str == "paste"){
                        if(stepColumn.copyString.length > 0){
                            selector.pasteStep(planListView.currentIndex, stepListView.currentIndex+1);
                            //var textValue = selector.copyStep(planListView.currentIndex, stepColumn.copyIndex, stepListView.currentIndex+1);
                            stepListModel.insert(stepListView.currentIndex+1, {"name":stepColumn.copyString, "showStep":true, "collapse":false});

                            stepListView.currentIndex = stepListView.currentIndex + 1;
                        }
                        stepColumn.copyString = "";
                    }
                }
            }

            ListModel{
                id:stepListModel
            }

            //            DelegateModel{
            //                id:stepVisualModel

            //                model: stepListModel
            //                delegate:stepDelegate
            //            }

            ListView {
                id: stepListView

                property int scrollingDirection:0
                signal scrollOver(int direction);

                //                Behavior on contentY{
                //                    NumberAnimation{duration:100}
                //                }

                ScrollBar.vertical: ScrollBar{}
                moveDisplaced: Transition {
                    NumberAnimation { duration: 200; properties: "x,y"; easing.type: Easing.InOutCubic }
                }

                function refreshStepListModel(){
                    positionSelected(-1);
                    var list = selector.stepListModel(planListView.currentIndex);
                    stepListModel.clear();
                    for(var ind = 0; ind < list.length; ind++){
                        stepListModel.append({"name":list[ind],"showStep":true, "collapse":false});
                    }
                    if(stepListModel.count > 0){
                        currentIndex = 0;
                        selector.setSelectedStep(planListView.currentIndex, 0);
                        //paramList.model = selector.paramListModel();
                    }else{
                        currentIndex = -1;
                    }
                }
                
                function toggleGroup(index){
                    if(!Script.isGroupBegin(stepListModel.get(index).name)){
                        return;
                    }

                    var collapsed = !stepListModel.get(index).collapse;
                    stepListModel.setProperty(index, "collapse", collapsed);

                    var stackIndex = 0;
                    for(var cur = index+1; cur < stepListModel.count; cur++){

                        stepListModel.setProperty(cur, "collapse", collapsed);
                        stepListModel.setProperty(cur, "showStep", !collapsed);

                        if(Script.isGroupBegin(stepListModel.get(cur).name)){
                            stackIndex++;
                        }else if(Script.isGroupEnd(stepListModel.get(cur).name)){
                            if(stackIndex >0){
                                stackIndex--;
                            }else{
                                break;
                            }
                        }
                    }
                }

                function expandAll(){
                    for(var cur = 0; cur < stepListModel.count; cur++){
                        stepListModel.setProperty(cur, "showStep", true);
                        stepListModel.setProperty(cur, "collapse", false);
                    }
                }

                cacheBuffer: 1000
                spacing: 0
                anchors.top: stepActionBar.bottom
                anchors.topMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                model: stepListModel
                delegate: stepDelegate
                highlightMoveDuration:100
                //highlightRangeMode: ListView.ApplyRange
                snapMode: ListView.SnapToItem

                clip: true
                highlight: Rectangle{
                    height: 40

                    color: "#5cc5ff"
                    radius: 0

                    Component.onCompleted: {
                        if(parent){
                            anchors.left = parent.left;
                            anchors.right = parent.right;
                        }
                    }
                }
                highlightFollowsCurrentItem: true
                currentIndex: 0
                interactive: true

                onCurrentIndexChanged: {
                    positionSelected(-1);
                    selector.setSelectedStep(planListView.currentIndex, currentIndex);
                    if(operationColumn.state == "expandOperation") operationColumn.state = "";
                }
                SmoothedAnimation {
                    id: upAnimation
                    target: stepListView
                    property: "contentY"
                    to: 0
                    running: false
                    //duration: 200
                    onStopped: {
                        stepListView.scrollOver(-1);
                    }
                }
                SmoothedAnimation {
                    id: downAnimation
                    target: stepListView
                    property: "contentY"
                    to: stepListView.contentHeight - stepListView.height
                    running: false
                    //duration: 200
                    onStopped: {
                        stepListView.scrollOver(1);
                    }
                }
            }

            Component{
                id: stepDelegate
                MouseArea{
                    id:stepContent
                    onClicked: {
                        stepListView.currentIndex = index;
                    }

                    property bool holding;
                    property int itemStepLength: height+stepListView.spacing

                    //drag
                    holding:false

                    width: parent.width
                    height: showStep?40:0

                    property bool collapsed: collapse

                    onCollapsedChanged: {
                        collapseContent.rotation = collapsed?0:-90;
                    }

                    Behavior on height {
                        PropertyAnimation{
                            easing.type: Easing.InOutSine
                            duration:200
                        }
                    }

                    anchors.left:parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    clip:true


                    Rectangle{
                        id:content

                        signal stepScrollOver(int dir);


                        width: stepContent.width
                        height: 40
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            verticalCenter: parent.verticalCenter
                        }

                        opacity: enabled?1:0.3
                        clip:true
                        color: stepContent.pressed?"lightblue":"transparent";


                        border.color: "transparent"
                        border.width: 2

                        Text{
                            id:textItem
                            anchors.fill: parent
                            anchors.leftMargin: 18
                            horizontalAlignment: Text.AlignLeft//Text.AlignHCenter

                            text:(index+1) + ". " + name
                            color:"#e1e8e2"

                            font.pixelSize: 20
                            font.bold: true
                            verticalAlignment: Text.AlignVCenter
                            styleColor: "#3a3a3a"
                            style: Text.Raised

                        }

                        Rectangle{
                            id:collapseContent
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 5
                            radius: 4
                            width: height
                            color: collapseButton.pressed?"lightblue":"transparent"
                            border.color: "#e1e8e2"
                            border.width: 1
                            visible:Script.isGroupBegin(name)
                            clip:true
                            rotation: -90


                            Behavior on rotation{
                                PropertyAnimation{
                                    duration: 100
                                }
                            }

                            Text{
                                anchors.fill: parent
                                anchors.margins: 4
                                text:"<"
                                color:"#e1e8e2"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter

                            }

                            MouseArea{
                                id: collapseButton
                                anchors.fill: parent

                                onClicked: {
                                    stepContent.clicked(mouse);
                                    if(Script.isGroupBegin(name)){
                                        stepListView.toggleGroup(stepContent.DelegateModel.itemsIndex);

                                    }

                                }
                            }
                        }

                        Drag.active: stepContent.holding
                        Drag.source: stepContent
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2
                        Drag.keys: "reorder"

                        states: State {
                            when: stepContent.holding

                            ParentChange { target: content; parent: stepListView }
                            AnchorChanges {
                                target: content
                                anchors { horizontalCenter: undefined; verticalCenter: undefined }
                            }
                            PropertyChanges {
                                target: content
                                scale: 0.9
                                color: "#4cffffff"
                                radius: 4
                                border.color: "#60ffffff"
                                border.width: 3
                            }
                            PropertyChanges {
                                target: stepListView
                                //currentIndex: -1
                                scrollingDirection:{
                                    //console.debug("x:"+content.x+" y:"+content.y+" width:"+content.width+" height:"+content.height);
                                    var top = content.y;
                                    var bottom = content.y+content.height;
                                    var movePercent = 0.1;
                                    if((top < content.height*movePercent && stepListView.contentY > 0)){
                                        return -1;
                                    }else if((bottom > (stepListView.height - content.height*movePercent) && stepListView.contentY < stepListView.contentHeight - stepListView.height)){
                                        return 1;
                                    }else{
                                        return 0;
                                    }
                                }
                                onCurrentIndexChanged:undefined
                                onScrollOver:{
                                    content.stepScrollOver(direction);
                                }
                                currentIndex: stepContent.DelegateModel.itemsIndex
                            }
                            PropertyChanges {
                                target: content
                                onStepScrollOver: {
                                    //console.debug("scroll over "+dir);
                                    onEdgeScroll(dir);
                                }
                            }
                            PropertyChanges {
                                target: scrollTimer
                                running: (stepListView.scrollingDirection != 0)
                            }
                        }
                        function onEdgeScroll(direction){
                            console.debug("edge scroll "+direction);
                            if(direction == 1 && (stepContent.DelegateModel.itemsIndex < stepListModel.count - 1)){
                                console.debug("move index "+stepContent.DelegateModel.itemsIndex+" to "+(stepContent.DelegateModel.itemsIndex+1));
                                selector.moveStep(planListView.currentIndex, stepContent.DelegateModel.itemsIndex , stepContent.DelegateModel.itemsIndex + 1);
                                stepListModel.move( stepContent.DelegateModel.itemsIndex,stepContent.DelegateModel.itemsIndex+1 ,1);
                            }else if(direction == -1 && (stepContent.DelegateModel.itemsIndex > 0)){
                                selector.moveStep(planListView.currentIndex, stepContent.DelegateModel.itemsIndex - 1 , stepContent.DelegateModel.itemsIndex);
                                console.debug("move index "+stepContent.DelegateModel.itemsIndex+" to "+(stepContent.DelegateModel.itemsIndex-1));
                                stepListModel.move(stepContent.DelegateModel.itemsIndex, stepContent.DelegateModel.itemsIndex-1,1);
                            }
                        }


                        Timer {
                            id:  scrollTimer
                            interval: 300
                            running: false
                            repeat: true
                            onTriggered: {
                                //console.debug("content y "+stepListView.contentY);
                                //console.debug("content height "+stepListView.contentHeight);
                                if(stepListView.scrollingDirection == -1){
                                    if(stepListView.contentY - itemStepLength >= 0){
                                        //parent.onEdgeScroll(-1);
                                        upAnimation.to = stepListView.contentY - itemStepLength;
                                        upAnimation.start();
                                    }else if (stepListView.contentY > 0){
                                        //parent.onEdgeScroll(-1);
                                        upAnimation.to = 0;
                                        upAnimation.start();
                                    }else{
                                        //nothing
                                    }
                                }else if(stepListView.scrollingDirection == 1){
                                    if(stepListView.contentY + itemStepLength <= stepListView.contentHeight - stepListView.height){
                                        //parent.onEdgeScroll(1);
                                        downAnimation.to = stepListView.contentY + itemStepLength;
                                        downAnimation.start();
                                    }else if (stepListView.contentY < stepListView.contentHeight - stepListView.height){
                                        //parent.onEdgeScroll(1);
                                        downAnimation.to = stepListView.contentHeight - stepListView.height;
                                        downAnimation.start();
                                    }else{
                                        //nothing
                                    }
                                }
                            }
                        }
                    }

                    onReleased: {
                        if(holding){
                            holding = false;
                            stepListView.highlightMoveDuration = 0;
                            stepListView.currentIndex = stepContent.DelegateModel.itemsIndex;
                            stepListView.highlightMoveDuration = 200;
                        }else{
                        }
                    }

                    onPressAndHold: {
                        stepListView.currentIndex = -1;
                        holding = true;
                        stepListView.expandAll();
                    }
                    drag.target: holding ? content : undefined
                    drag.axis: Drag.YAxis

                    DropArea {
                        id: dropDelegate
                        anchors { fill: parent; margins: 2 }
                        keys: ["reorder","add"]

                        onEntered: {
                            console.debug("drag enter "+drag.keys);
                            if(drag.keys == "reorder"){
                                if(stepListView.scrollingDirection == 0){
                                    if(drag.source.DelegateModel.itemsIndex != stepContent.DelegateModel.itemsIndex){
                                        console.debug("drag index "+drag.source.DelegateModel.itemsIndex+" drop index "+stepContent.DelegateModel.itemsIndex);
                                        selector.moveStep(planListView.currentIndex, drag.source.DelegateModel.itemsIndex, stepContent.DelegateModel.itemsIndex);
                                        stepListModel.move(drag.source.DelegateModel.itemsIndex, stepContent.DelegateModel.itemsIndex, 1);
                                        //stepVisualModel.items.move(drag.source.DelegateModel.itemsIndex,stepContent.DelegateModel.itemsIndex);
                                        //judgeListScroll(drag.x, drag.y);
                                    }
                                }
                            }else if(drag.keys == "add"){

                            }
                        }
                        //                        onPositionChanged: {
                        //                            judgeListScroll(drag.x, drag.y);
                        //                        }
                        //                        function judgeListScroll(x, y){
                        //                            console.debug(stepListView.mapFromItem(dropDelegate, x, y));
                        //                            if(stepListView.mapFromItem(dropDelegate, x, y).y >= stepListView.height - dropDelegate.height/2){
                        //                                console.debug("should scroll down");
                        //                                stepListView.flick(0,-200);
                        //                            }else if(stepListView.mapFromItem(dropDelegate, x, y).y <= dropDelegate.height/2){
                        //                                console.debug("shold scroll up");
                        //                                stepListView.flick(0,200);
                        //                            }
                        //                        }
                    }
                }
            }

        }

        Item {
            property var  changeOperation;

            id: operationColumn
            width: 0
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            clip:true
            //visible: false

            changeOperation:"add"

            states:State{
                name:"expandOperation"
                PropertyChanges{
                    target: operationColumn
                    width: columnWidth*1.5
                }
                PropertyChanges {
                    target: paramColumn
                    width: 0
                }
            }

            Behavior on width{
                PropertyAnimation{
                    duration: 200
                }
            }
            Rectangle{
                anchors.fill: parent
                anchors.bottomMargin: 8
                radius:8
                color: "#3c747474"
            }

            Rectangle{
                id: operationType
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.top: parent.top
                color:"#747474"
                height: 40

                Text {
                    text: qsTr("Operation type")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.pixelSize: 20
                    font.bold: true
                    width: 120
                    color:"#d9d9d9"
                }
            }


            ListView {
                id: operationList
                highlightRangeMode: ListView.NoHighlightRange
                highlightMoveDuration: 0
                snapMode: ListView.NoSnap
                spacing: 4
                anchors.top: operationType.bottom
                anchors.topMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10

                ScrollBar.vertical: ScrollBar{}

                clip: true
                highlight: Rectangle{
                    height: 40

                    color: "#5cc5ff"
                    radius: 0
                    Component.onCompleted: {
                        if(parent){
                            anchors.left = parent.left;
                            anchors.right = parent.right;
                        }
                    }
                }
                highlightFollowsCurrentItem: false
                currentIndex: -1
                interactive: true

                delegate: TextButton {
                    height: 40

                    anchors.left:parent.left
                    anchors.leftMargin: 0
                    anchors.right: parent.right
                    anchors.rightMargin: 0

                    fontPixelSize:20


                    buttonradius: 0

                    textValue: modelData
                    startColor: "transparent"
                    stopColor: "transparent"
                    onClicked: {
                        console.debug(modelData+"clicked");
                        //operationList.currentIndex = index;
                        operationColumn.state = "";


                        if(operationColumn.changeOperation == "add"){
                            selector.addStep(planListView.currentIndex, stepListView.currentIndex+1, index);
                            stepListModel.insert(stepListView.currentIndex+1, {"name":textValue, "showStep":true, "collapse":false});
                            //stepListModel.append({"name":textValue, "showStep":true});

                            //paramList.model = selector.paramListModel();

                            stepListView.currentIndex = stepListView.currentIndex + 1;
                        }else if (operationColumn.changeOperation == "edit"){
                            selector.setSelectedOperation(planListView.currentIndex, stepListView.currentIndex, index);
                            stepListModel.setProperty(stepListView.currentIndex, "name", textValue);
                            //paramList.model = selector.paramListModel();
                        }
                    }
                }

                Component.onCompleted:
                {
                    model = selector.operationListModel();
                    currentIndex = -1;
                }
                onStateChanged: {
                    //                    if((operationColumn.changeOperation == "edit") && (operationColumn.state == "expandOperation")){
                    //                        currentIndex = selector.operationCurrentIndex();
                    //                    }else {
                    //                        currentIndex = -1;
                    //                    }
                }
            }
        }

        Item{
            width: columnWidth*2.5
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Item {
                id: paramColumn
                //width: columnWidth*2.5
                anchors.bottom: boardColumn.top
                anchors.bottomMargin: 10
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                //height: 500
                //visible: !operationColumn.visible
                clip:true
                Behavior on width{
                    PropertyAnimation{
                        duration: 200
                    }
                }

                Rectangle{
                    anchors.fill: parent
                    anchors.bottomMargin: 0
                    radius:8
                    color: "#3c747474"
                }

                Rectangle{
                    id: operationParam
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.top: parent.top
                    color:"#747474"
                    height: 40

                    Text {
                        text: qsTr("Operation param")
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 20
                        font.bold: true

                        color:"#d9d9d9"
                    }
                }

                ListView {
                    id: paramList
                    clip:true
                    spacing: 2
                    anchors.top: operationParam.bottom
                    anchors.topMargin: 4
                    anchors.right: parent.right
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    interactive: true
                    model: selector.paramListModel
                    //highlightRangeMode: ListView.StrictlyEnforceRange
                    highlight: Item{}
                    highlightFollowsCurrentItem:true
                    ScrollBar.vertical: ScrollBar{}

                    delegate: Item {
                        property int paramIndex: index
                        height:{
                            if(modelData.Display == "操作流程"){
                                return 200;
                            }else{
                                return 40;
                            }
                        }
                        anchors.left: parent.left
                        anchors.right: parent.right



                        enabled:getSwitchState()
                        function getSwitchState()
                        {
                            var revert = modelData.RevertSwitch;
                            var obj = selector.getSwitch(modelData.SwitchValue);
                            if (obj)
                                return revert? (!obj.BoolValue) : (obj.BoolValue);
                            else
                                return true;
                        }

                        opacity: enabled? 1.0: 0.5

                        Text {
                            id: paramName

                            height:40
                            width:120

                            text: modelData.Display
                            horizontalAlignment: Text.AlignRight
                            verticalAlignment: Text.AlignVCenter
                            color:"#d9d9d9"
                            font.pixelSize: 17
                            font.bold: true
                        }
                        IntValidator{
                            id:intValidator
                            bottom: modelData.BottomValue
                            top:modelData.TopValue
                        }

                        TextFieldDoubleValidator{
                            id:floatValidator
                            bottom:modelData.BottomValue
                            top:modelData.TopValue
                            decimals: 1
                        }

                        Component{
                            id: texteditComponent

                            Rectangle{
                                anchors.fill: parent
                                border.width: 2
                                border.color: "#ffffff"
                                radius: 0

                                TextInput{
                                    id: textedit
                                    property bool init: false
                                    anchors.fill: parent
                                    anchors.leftMargin: 2
                                    verticalAlignment: TextEdit.AlignVCenter
                                    validator: getValidator()
                                    focus:true
                                    activeFocusOnTab: true
                                    selectByMouse: true
                                    //text: getText()

                                    Component.onCompleted: {
                                        text = getText();
                                        init = true;
                                    }
                                    onActiveFocusChanged: {
                                        if(activeFocus){
                                            selectAll();
                                            if(paramList.currentIndex != paramIndex){
                                                paramList.currentIndex = paramIndex;
                                                forceActiveFocus();
                                            }
                                        }else{
                                            deselect();
                                            if(modelData.Type == "integer"){
                                                var value = Number(text);
                                                if(value > intValidator.top){
                                                    value = intValidator.top;
                                                }else if(value < intValidator.bottom){
                                                    value = intValidator.bottom;
                                                }
                                                text = value.toString();
                                                modelData.IntegerValue = Number(text);
                                            }
                                        }
                                    }

                                    function getText() {
                                        if(modelData.Type == "integer"){
                                            return modelData.IntegerValue.toString();
                                        }else if(modelData.Type == "float"){
                                            return modelData.FloatValue.toFixed(1);
                                        }else{
                                            return modelData.StringValue;
                                        }
                                    }

                                    function getValidator(){
                                        if(modelData.Type == "integer"){

                                            return intValidator;
                                        }
                                        else if(modelData.Type == "float"){
                                            return floatValidator;
                                        }
                                        return validator;
                                    }

                                    onTextChanged: {
                                        if(init == true){
                                            if(modelData.Type == "integer"){
                                                modelData.IntegerValue = Number(text);
                                            }
                                            else if(modelData.Type == "float"){
                                                modelData.FloatValue = Number(text);
                                            }
                                            else{
                                                modelData.StringValue = text;
                                            }

                                            selector.commitParam(planListView.currentIndex, stepListView.currentIndex, modelData.Name, text);

                                            if(modelData.Name=="GroupName"){
                                                var list = selector.stepListModel(planListView.currentIndex);
                                                stepListModel.setProperty(stepListView.currentIndex, "name", list[stepListView.currentIndex]);
                                            }
                                        }
                                    }

                                    onEnabledChanged: {
                                        if(enabled == false)
                                            text = "";
                                    }

                                }
                            }
                        }
                        Component{
                            id:comboboxComponent

                            ComboBox{
                                id: combox
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter
                                model: modelData.StringListValue
                                currentIndex: modelData.IntegerValue
                                focus:true
                                activeFocusOnTab: true

                                onCurrentIndexChanged: {
                                    modelData.IntegerValue = currentIndex;

                                    selector.commitParam(planListView.currentIndex, stepListView.currentIndex, modelData.Name, currentIndex);

                                    if (modelData.Name == "position"){
                                        positionSelected(currentIndex);
                                        refreshBoardType(currentIndex);

                                    }
                                }
                            }
                        }
                        Component{
                            id:checkboxComponent
                            CheckBox{
                                id: checkbox
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter
                                focus:true
                                activeFocusOnTab: true
                                checked: modelData.BoolValue

                                onCheckedChanged: {
                                    modelData.BoolValue = checked;

                                    selector.commitParam(planListView.currentIndex, stepListView.currentIndex, modelData.Name, checked);
                                }
                            }
                        }
                        Component{
                            id:tipMotionComponent
                            Item{
                                anchors.fill: parent
                                TextButton{
                                    id:importMotion
                                    height:30
                                    width:100
                                    textValue: qsTr("import")
                                    buttonradius: 0
                                    borderColor: "#4c5cc5ff"

                                    anchors.top: parent.top
                                    anchors.right: parent.right

                                    visible: (modelData.Display=="操作流程")

                                    onClicked: {
                                        forceActiveFocus();
                                        fileDialogImport.visible = true;

                                    }
                                }
                                SingleTipMotion{                                    
                                    id: singleTipMotion

                                    anchors.top: importMotion.bottom
                                    anchors.left: parent.left
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right

                                    intvalidator.bottom:  intValidator.bottom
                                    intvalidator.top: intValidator.top

                                    modelStr: modelData.StringValue

                                    focus:true


                                    onSetModelStr: {
                                        selector.commitParam(planListView.currentIndex, stepListView.currentIndex, modelData.Name, str);
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
                                            console.debug(singleTipMotion.modelStr);
                                            singleTipMotion.modelStr = configFileConverter.readConfigFIle(fileUrl);
                                            singleTipMotion.refreshModel();
                                            console.debug(singleTipMotion.modelStr);
                                            visible = false;
                                        }
                                        onRejected: {
                                            visible = false;
                                        }
                                    }
                                }
                            }
                        }

                        Loader{
                            id: paramInput
                            anchors.left: paramName.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: paramUnit.left
                            anchors.rightMargin: 7
                            anchors.leftMargin: 4

                            height: parent.height

                            enabled: modelData.Name != "boardType"

                            sourceComponent:getcomponent(modelData.Type, modelData.Display)


                            function getcomponent(typename, strVal){
                                if (typename == "integer" || typename == "float"){
                                    return texteditComponent;
                                }
                                else if(typename == "enum"){
                                    return comboboxComponent;
                                }
                                else if(typename == "bool"){
                                    return checkboxComponent;
                                }
                                else if(typename == "string" ){
                                    if(strVal == "操作流程"){
                                        return tipMotionComponent;
                                    }else{
                                        return texteditComponent;
                                    }
                                }

                            }
                        }
                        Text {
                            id: paramUnit
                            height:30
                            width:(modelData.Unit.length > 0 )? modelData.Unit.width: 0
                            text: modelData.Unit
                            horizontalAlignment: Text.AlignLeft
                            verticalAlignment: Text.AlignVCenter
                            color:"#d9d9d9"
                            font.pixelSize: 20
                            font.bold: true
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }

                    }
                }
            }

            Item {
                id: boardColumn
                width: columnWidth*1.2
                height: 120

                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle{
                    anchors.fill: parent
                    anchors.bottomMargin: 8
                    radius:8
                    color: "#3c747474"
                }

                Rectangle{
                    id: boardConfig
                    anchors.right: parent.right
                    anchors.rightMargin: 0
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.top: parent.top
                    color:"#747474"
                    height: 40

                    Text {
                        text: qsTr("Board Config")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        //anchors.fill: parent
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.left: expandButton.visible?expandButton.right:parent.left
                        font.pixelSize: 20
                        font.bold: true
                        //width: 120
                        color:"#d9d9d9"
                    }
                }
                Item {
                    height:40
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: boardConfig.bottom
                    anchors.topMargin: 5
                    //anchors.bottom: parent.bottom


                    opacity: enabled? 1.0: 0.5

                    Text {
                        id:boardName
                        height:parent.height
                        width:135

                        text: qsTr("Board Config")
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color:"#d9d9d9"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    ListModel{
                        id:boardconfigListModel
                    }
                    WorkLocationManager{
                        id:workLocationMgr
                    }

                    ComboBox{
                        id: boardtypeCombobox
                        property bool init: false
                        anchors.left: boardName.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.rightMargin: 3
                        anchors.leftMargin: 4

                        height: parent.height

                        model: boardconfigListModel
                        focus:true
                        activeFocusOnTab: true

                        onCurrentIndexChanged: {
                            if(init){
                                selector.setBoardConfigIndex(planListView.currentIndex, currentIndex);
                                boardIndexSelected(currentIndex);
                                forceRefreshBoardType();
                            }
                        }

                        function refreshModel(){
                            var listAll = workLocationMgr.getWorkLocationTypeList();

                            boardconfigListModel.clear();
                            for(var item in listAll.config){
                                boardconfigListModel.append({"key":listAll.config[item].name});
                            }
                        }
                        onVisibleChanged: {
                            if(visible){
                                refreshModel();
                                currentIndex = selector.boardConfigIndex(planListView.currentIndex);
                                init = true;
                                boardIndexSelected(currentIndex);

                                forceRefreshBoardType();
                            }else{
                                init = false;
                            }
                        }
                    }
                }
            }
        }
    }
}

