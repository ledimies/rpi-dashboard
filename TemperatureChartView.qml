import QtQuick
import rpidisplay
import QtCharts

Item {
    required property InfluxDBConnection influx_ruuvi
    opacity: 0.0
    id: root
    property int sinceDays: 0

    function refresh(sinceDays) {
        lineSeriesOutside.clear()
        lineSeriesInside.clear()

        // Outside temperature
        var queryText = "select mean(temperature) as power from ruuvi_measurements where mac='CA:39:20:9F:92:AC' and time < now()-" + sinceDays*24 + "h and time >= now()-" + (sinceDays+1)*24 + "h group by time(10m) order by time asc"
        var queryResult = influx_ruuvi.doQuery(queryText)
        var maxOutsideValue = Math.max(...queryResult.map(point => point.data))
        var minOutsideValue = Math.min(...queryResult.map(point => point.data))

        queryResult.forEach((point) => {
                                lineSeriesOutside.append(point.timestamp.getTime(), point.data)
                            });

        // Inside temperature
        queryText = "select mean(temperature) as power from ruuvi_measurements where mac='EF:93:E1:2B:3E:DB' and time < now()-" + sinceDays*24 + "h and time >= now()-" + (sinceDays+1)*24 + "h group by time(10m) order by time asc"
        queryResult = influx_ruuvi.doQuery(queryText)
        var maxInsideValue = Math.max(...queryResult.map(point => point.data))
        var minInsideValue = Math.min(...queryResult.map(point => point.data))

        queryResult.forEach((point) => {
                                lineSeriesInside.append(point.timestamp.getTime(), point.data)
                            });

        timeAxis.max = queryResult[queryResult.length - 1].timestamp
        timeAxis.min = queryResult[0].timestamp
        timeAxis.tickCount = 24
        var maxValue = Math.max(maxOutsideValue, maxInsideValue)
        var minValue = Math.min(maxOutsideValue, maxInsideValue, 0)
        yAxis.max = (maxValue + 5) - (maxValue + 5) % 5
        yAxis.min = minValue

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

            LineSeries {
                id: lineSeriesOutside
                axisX: timeAxis
                axisY: yAxis
                name: "Ulkolämpötila"
            }

            LineSeries {
                id: lineSeriesInside
                axisX: timeAxis
                axisY: yAxis
                name: "Sisälämpötila"
            }

            ValuesAxis {
                id: yAxis
                min: 0
                max: 10000
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
                anchors.fill: parent

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
}
