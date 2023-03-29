import QtQuick
import rpidisplay

Item {
    required property InfluxDBConnection influx_electricity
    opacity: 0.0
    id: root
    property int sinceDays: 0
    property InfluxDBQuery powerLineChartQuery: null
    property InfluxDBQuery powerBarChartQuery: null

    ConsumptionGraphView {
        id: consumptionGraphView

        Component.onCompleted: {
            powerLineChartQuery = influx_electricity.getNewQuery()
            powerLineChartQuery.onQueryFinished.connect(onPowerLineChartQueryFinished)
            powerBarChartQuery = influx_electricity.getNewQuery()
            powerBarChartQuery.onQueryFinished.connect(onPowerBarChartQueryFinished)
        }

        function onPowerLineChartQueryFinished(queryResult) {
            var maxValue = Math.max(...queryResult.map(point => point.data))

            queryResult.forEach((point) => {
                                    lineSeries.append(point.timestamp.getTime(), point.data)
                                });

            yAxis.max = (maxValue + 500) - (maxValue + 500) % 500
        }

        function onPowerBarChartQueryFinished(queryResult) {
            barSeries.append("kWhPerHour", queryResult.map(point => point.data))
        }

        function refresh(sinceDays) {
            lineSeries.clear()
            barSeries.clear()
            barAxis.categories = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]

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

            var queryText = "select mean(power) as power from consumption where time >= '" + endOfDay.toJSON() + "' - " + (sinceDays+1) + "d and time < '" + endOfDay.toJSON() + "' - " + sinceDays + "d group by time(2m) order by time asc"
            powerLineChartQuery.setQuery(queryText)
            powerLineChartQuery.queueQuery()

            queryText = "select count(power) as power from consumption where time >= '" + endOfDay.toJSON() + "' - " + (sinceDays+1) + "d and time < '" + endOfDay.toJSON() + "' - " + sinceDays + "d group by time(1h) order by time asc"
            powerBarChartQuery.setQuery(queryText)
            powerBarChartQuery.queueQuery()

            var titleDate = new Date()
            titleDate.setDate(titleDate.getDate() - sinceDays)
            chartView.title = "Sähkön kulutus " + titleDate.toLocaleDateString("fi_FI")
            chartView.focus = true
        }
    }
}
