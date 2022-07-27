import QtQuick
import rpidisplay
import QtCharts

Item {
    id: root
    required property InfluxDBConnection influx_ruuvi
    required property list<TemperatureSeries> series
    property int sinceDays: 0
    opacity: 0.0

    function createInitialSeries(series) {
        chartView.createSeries(ChartView.SeriesTypeLine, series.name, timeAxis, yAxis);
    }

    Component.onCompleted: {
        for (var i = 0; i < series.length; i++) {
            createInitialSeries(series[i])
        }
    }

    function refresh(sinceDays) {
        var maxValue = 0;
        var minValue = 0
        for (var i = 0; i < series.length; i++) {
            var updatedSeries = chartView.series(i)
            updatedSeries.clear()
            var mac = series[i].mac

            var queryText = "select mean(temperature) as power from ruuvi_measurements where mac='" + mac + "' and time < now()-" + sinceDays*24 + "h and time >= now()-" + (sinceDays+1)*24 + "h group by time(10m) order by time asc"
            var queryResult = influx_ruuvi.doQuery(queryText)
            maxValue = Math.max(...queryResult.map(point => point.data), maxValue)
            minValue = Math.min(...queryResult.map(point => point.data), minValue)

            queryResult.forEach((point) => {
                                    updatedSeries.append(point.timestamp.getTime(), point.data)
                                });

            // Set time axis based on first query
            if (i === 0) {
                timeAxis.max = queryResult[queryResult.length - 1].timestamp
                timeAxis.min = queryResult[0].timestamp
                timeAxis.tickCount = 24
            }
        }
        yAxis.max = (maxValue + 5) - (maxValue + 5) % 5
        yAxis.min = minValue

        var titleDate = new Date()
        titleDate.setDate(titleDate.getDate() - sinceDays)
        chartView.title = "Lämpötila " + titleDate.toLocaleDateString("fi_FI")
        chartView.focus = true
        console.log("series count: " + chartView.series(0).count);
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
