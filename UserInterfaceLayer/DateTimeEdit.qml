import QtQuick 2.8
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls 2.1

Rectangle {
    id:root

    function date(){
        var date ;
        date = calendar.selectedDate;
        date.setHours(hoursTumbler.currentIndex);
        date.setMinutes(minutesTumbler.currentIndex);
        date.setSeconds(0);
        return date;
    }


    onVisibleChanged: {
        var date = new Date();
        hoursTumbler.currentIndex = parseInt(date.getHours());
        minutesTumbler.currentIndex = parseInt(date.getMinutes());

        calendar.selectedDate = date;
    }




    function formatText(count, modelData) {
        var data = modelData;
        return data.toString().length < 2 ? "0" + data : data;
    }

    FontMetrics {
        id: fontMetrics
    }

    Component {
        id: delegateComponent

        Label {
            text: formatText(Tumbler.tumbler.count, modelData)
            opacity: 1.0 - Math.abs(Tumbler.displacement) / (Tumbler.tumbler.visibleItemCount / 2)
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: fontMetrics.font.pixelSize * 1.25
            height: Tumbler.height/Tumbler.visibleItemCount
        }
    }

    Calendar{
        id: calendar
        width: 300
        height: 300

        selectedDate:{
            return new Date();
        }

        anchors.left: parent.left
    }

    Frame {
        id: frame
        padding: 0
        height:300

        anchors.left: calendar.right
        anchors.right: parent.right


        //         Column{
        //             anchors.fill: parent
        //             Frame{
        //                 height: 40
        //                 width: 150
        //                 anchors.margins: 3
        //                 padding: 0
        //                 clip:true

        //                 RowLayout{
        //                     Label{
        //                         text: qsTr("Hours")
        //                         horizontalAlignment: Text.AlignHCenter
        //                         verticalAlignment: Text.AlignVCenter
        //                         font.pixelSize: 20
        //                         width: hoursTumbler.width
        //                     }
        //                     Label{
        //                         text: qsTr("Minutes")
        //                         horizontalAlignment: Text.AlignHCenter
        //                         verticalAlignment: Text.AlignVCenter
        //                         font.pixelSize: 20
        //                         width: minutesTumbler.width
        //                     }
        //                 }
        //             }

        Item{
            id: timeBar
            height: frame.height
            width:frame.width

            Row {
                id: timeRow

                Tumbler {
                    id: hoursTumbler
                    model: 24
                    delegate: delegateComponent
                    visibleItemCount: 7
                    width:frame.width/2
                    height: frame.height
                }

                Tumbler {
                    id: minutesTumbler
                    model: 60
                    delegate: delegateComponent
                    visibleItemCount: 7
                    width:frame.width/2
                    height: frame.height
                }
            }

            Rectangle{
                width: timeBar.width
                height: 40

                color:"#4c5cc5ff"

                anchors.centerIn: timeBar

                Row{
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    Label{
                        text: qsTr("Hours")
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 20
                        width: hoursTumbler.width
                        height: parent.height
                    }
                    Label{
                        text: qsTr("Minutes")
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 20
                        width: minutesTumbler.width
                        height: parent.height
                    }
                }
            }
        }
    }
}


