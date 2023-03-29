import QtQuick
import rpidisplay
import QtCharts

Item {
    id: root
    required property InfluxDBConnection influx_ruuvi
    required property list<TemperatureSeries> series
    property int sinceDays: 0
    opacity: 0.0
//    property var queryArray: []
    property list<InfluxDBQuery> queries
    property int minValue: 0
    property int maxValue: 0
    property double maxSeriesValue: 0
    property double minSeriesValue: 0

    function createInitialSeries(series) {
        chartView.createSeries(ChartView.SeriesTypeLine, series.name, timeAxis, yAxis);
    }

    function createSeriesQuery(index) {
        var seriesQuery = influx_ruuvi.getNewQuery()

        var onQueryFinished = function(queryResult) {
            onSeriesQueryFinished(queryResult, index, series.length)
        }

        seriesQuery.onQueryFinished.connect(onQueryFinished);
        queries.push(seriesQuery)
    }

    Component.onCompleted: {
        for (var i = 0; i < series.length; i++) {
            createInitialSeries(series[i])
            createSeriesQuery(i)
        }
    }

    function onSeriesQueryFinished(queryResult, seriesNum, seriesLength) {
        var updatedSeries = chartView.series(seriesNum)
        queryResult.forEach((point) => {
                                updatedSeries.append(point.timestamp.getTime(), point.data)
                            });

        maxSeriesValue = Math.max(...queryResult.map(point => point.data), maxSeriesValue)
        minSeriesValue = Math.min(...queryResult.map(point => point.data), minSeriesValue)
        console.log("Series num: " + seriesNum + " MAX: " + maxSeriesValue + " MIN: " + minSeriesValue)
//        maxValue = maxValue + 5
//        minValue = minValue - 5
//        maxValue = (maxValue + 5) - (maxValue + 5) % 5
//        minValue = (minValue - 5) + (minValue - 5) % 5
        //        yAxis.min = minValue

        if (seriesNum >= series.length - 1) {
            minValue = minSeriesValue - 2
            maxValue = maxSeriesValue + 2
        }
    }

    function refresh(sinceDays) {
        maxSeriesValue = 0
        minSeriesValue = 0

        var endOfDay = new Date()
        endOfDay.setHours(0,0,0,0)
        endOfDay.setDate(endOfDay.getDate() + 1)

        var startTime = new Date(endOfDay)
        var endTime = new Date(endOfDay)
        startTime.setDate(endOfDay.getDate() - (sinceDays+1))
        endTime.setDate(endOfDay.getDate() - (sinceDays))

        timeAxis.max = endTime
        timeAxis.min = startTime
        timeAxis.tickCount = 25

        for (var i = 0; i < series.length; i++) {
            var updatedSeries = chartView.series(i)
            updatedSeries.clear()
            var mac = series[i].mac

            var queryText = "select mean(temperature) as power from ruuvi_measurements where mac='" + mac + "' and time >= '" + endOfDay.toJSON() + "' - " + (sinceDays+1) + "d and time < '" + endOfDay.toJSON() + "' - " + sinceDays + "d group by time(10m) order by time asc"
            queries[i].setQuery(queryText)
            queries[i].queueQuery()
        }

        var titleDate = new Date()
        titleDate.setDate(titleDate.getDate() - sinceDays)
        chartView.title = "Lämpötila " + titleDate.toLocaleDateString("fi_FI")
        chartView.focus = true
    }

    Rectangle {
        id: temperatureGraphView
        color: mainWindow.color
        width: mainWindow.width
        height: mainWindow.height
        opacity: parent.opacity
        visible: opacity != 0

        onVisibleChanged: {
            if (visible) {
                refresh(0)
            }
        }

        ChartView {
            id: chartView
            title: "Lämpötila"
            anchors.fill: parent
            antialiasing: true
            theme: ChartView.ChartThemeDark
            legend.visible: true

            ValuesAxis {
                id: yAxis
                min: minValue
                max: maxValue
                tickCount: 11
                minorTickCount: 1

            }

            DateTimeAxis {
                id: timeAxis
                format: "hh:mm"
                labelsAngle: 45
                truncateLabels: false
                minorGridVisible: true
            }

            MouseArea {
                id: mouseArealeft
                width: 266
                height: 480
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 0
                anchors.leftMargin: 0

                onClicked: {
                    sinceDays = sinceDays + 1
                    refresh(sinceDays)
                }
            }

            MouseArea {
                id: mouseAreaMiddle
                width: 268
                height: 480
                anchors.left: mouseArealeft.right
                anchors.top: mouseArealeft.top
                anchors.topMargin: 0
                anchors.leftMargin: 0

                onClicked: {
                    root.opacity = 0.0
                    frontPage.visible = true
                }
            }

            MouseArea {
                id: mouseAreaRight
                width: 266
                height: 480
                anchors.left: mouseAreaMiddle.right
                anchors.top: mouseAreaMiddle.top
                anchors.topMargin: 0
                anchors.leftMargin: 0

                onClicked: {
                    if (sinceDays > 0) {
                        sinceDays = sinceDays - 1
                    }
                    refresh(sinceDays)
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
}
