import QtQuick 2.7
import QtQuick.Controls 2.1
import Common 1.0
import QtQml.Models 2.2

Item {
    property alias operationState: operationColumn.state
    signal positionSelected(int index);
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

    PlanSelector{
        id:selector
    }

    property var columnWidth;

    columnWidth: 120
    width: row.width
    Component.onCompleted: {
        planColumn.state = ""
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
                anchors.bottomMargin: 10

                ScrollBar.vertical: ScrollBar{}

                clip: true
                highlight: Rectangle{
                    height: 40
                    anchors.left: parent.left
                    anchors.right: parent.right

                    color: "#ffb902"
                    radius: 0
                }
                highlightFollowsCurrentItem: true
                currentIndex: 0
                interactive: true
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
            id: stepColumn
            width: columnWidth*1.4
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

                onHeightChanged: {
                    if(globalinput.active){
                        var itemHeight = 42;
                        var tempY = mapFromItem(stepListView.currentItem, 0, stepListView.currentItem.y).y;
                        if(tempY +itemHeight> height){
                            contentY  += (tempY - height + itemHeight);
                        }
                    }
                }

                function refreshStepListModel(){
                    var list = selector.stepListModel(planListView.currentIndex);
                    stepListModel.clear();
                    for(var ind = 0; ind < list.length; ind++){
                        stepListModel.append({"name":list[ind],"showStep":true});
                    }
                    if(stepListModel.count > 0){
                        currentIndex = 0;
                        selector.setSelectedStep(planListView.currentIndex, 0);
                        //paramList.model = selector.paramListModel();
                    }else{
                        currentIndex = -1;
                    }
                }
                
                //return visible status
                function toggleGroup(index){
                    var retVal = true;
                    for(var cur = index+1; cur < stepListModel.count; cur++){
                        if( stepListModel.get(cur).name.substring(0,2)=="分组"){
                            break;
                        }else{
                            var vi = stepListModel.get(cur).showStep;
                            stepListModel.setProperty(cur, "showStep", !vi);
                            retVal = !vi;
                        }
                    }
                    return retVal;
                }

                function expandAll(){
                    for(var cur = 0; cur < stepListModel.count; cur++){
                        if( stepListModel.get(cur).name.substring(0,2)!="分组"){
                            var vi = stepListModel.get(cur).showStep;
                            stepListModel.setProperty(cur, "showStep", true);
                        }
                    }
                }

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
                            property bool collapsed: false
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 5
                            radius: 4
                            width: height
                            color: collapseButton.pressed?"lightblue":"transparent"
                            border.color: "#e1e8e2"
                            border.width: 1
                            visible:(name.substring(0,2) == "分组")
                            clip:true
                            rotation: collapseContent.collapsed?0:-90

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
                                    if(name.substring(0,2) == "分组"){
                                        if (stepListView.toggleGroup(stepContent.DelegateModel.itemsIndex)){
                                            collapseContent.collapsed = false;
                                        }else{
                                            collapseContent.collapsed = true;
                                        }
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
                    width: columnWidth*2
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
                            selector.addStep(planListView.currentIndex, stepListView.count, index);
                            stepListModel.append({"name":textValue, "showStep":true});

                            //paramList.model = selector.paramListModel();

                            stepListView.currentIndex = stepListView.count - 1;
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

        Item {
            id: paramColumn
            width: columnWidth*2
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            //visible: !operationColumn.visible
            clip:true
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
                anchors.bottomMargin: 10
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
                    height:40
                    anchors.left: parent.left
                    anchors.right: parent.right



                    enabled:getSwitchState()
                    function getSwitchState()
                    {
                        var obj = selector.getSwitch(modelData.SwitchValue);
                        if (obj)
                            return obj.BoolValue;
                        else
                            return true;
                    }

                    opacity: enabled? 1.0: 0.5

                    Text {
                        id: paramName

                        height:parent.height
                        width:125

                        text: modelData.Display
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        color:"#d9d9d9"
                        font.pixelSize: 20
                        font.bold: true
                    }

                    Component{
                        id: texteditComponent

                        Rectangle{
                            anchors.fill: parent
                            border.width: 2
                            border.color: "#ffffff"
                            radius: 4

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

                                inputMethodHints: {
                                    if(modelData.Type == "integer"){
                                        return Qt.ImhDigitsOnly;
                                    }
                                    else if(modelData.Type == "float"){
                                        return Qt.ImhDigitsOnly;
                                    }
                                    return Qt.ImhNoAutoUppercase;

                                }

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
                                    var boardIndex = selector.getBoardTypeIndexByPosition(currentIndex);

                                    for(var ind = 0; ind < paramList.model.length; ind++){
                                        if(paramList.model[ind].Name == "boardType"){
                                            paramList.model[ind].IntegerValue = boardIndex;
                                            break;
                                        }
                                    }
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

                    Loader{
                        id: paramInput
                        anchors.left: paramName.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.right: paramUnit.left
                        anchors.rightMargin: 3
                        anchors.leftMargin: 4

                        height: parent.height

                        enabled: modelData.Name != "boardType"

                        sourceComponent:getcomponent(modelData.Type)


                        function getcomponent(typename, val){
                            if (typename == "integer" || typename == "string" || typename == "float"){
                                return texteditComponent;
                            }
                            else if(typename == "enum"){
                                return comboboxComponent;
                            }
                            else if(typename == "bool"){
                                return checkboxComponent;
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
    }
}

