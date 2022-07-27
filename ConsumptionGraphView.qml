import QtQuick
import QtCharts

Rectangle {
    id: consumptionGraphView
    color: mainWindow.color
    width: mainWindow.width
    height: mainWindow.height
    opacity: parent.opacity
    visible: opacity != 0

    property alias chartView: chartView
    property alias lineSeries: lineSeries
    property alias barSeries: barSeries
    property alias timeAxis: timeAxis
    property alias barAxis: barAxis
    property alias yAxis: yAxis

    onVisibleChanged: {
        if (visible) {
            refresh(0)
        }
    }

    ChartView {
        id: chartView
        title: "Veden kulutus"
        anchors.fill: parent
        antialiasing: true
        theme: ChartView.ChartThemeDark
        legend.visible: false

        BarSeries {
            id: barSeries
            axisX: barAxis
            axisY: yAxis
        }

        LineSeries {
            id: lineSeries
            axisX: timeAxis
            axisY: yAxis

        }

        ValuesAxis {
            id: yAxis
            min: 0
            max: 10000
            tickCount: 11
            minorTickCount: 1

        }

        BarCategoryAxis {
            id: barAxis
            gridVisible: false
            lineVisible: false
            labelsVisible: false
            titleVisible: false

        }

        DateTimeAxis {
            id: timeAxis
            format: "hh:mm"
            labelsAngle: 45
            truncateLabels: false
            minorGridVisible: true
        }

        MouseArea {
            anchors.fill: parent

            onDoubleClicked: {
                refresh()
            }

            onClicked: {
                root.opacity = 0.0
                frontPage.visible = true
            }
        }

        Keys.onLeftPressed: {
            sinceDays = sinceDays + 1
            refresh(sinceDays)
        }

        Keys.onRightPressed: {
            if (sinceDays > 0) {
                sinceDays = sinceDays - 1
            }
            refresh(sinceDays)
        }
    }
}
