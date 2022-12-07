import QtQuick
import rpidisplay

Item {
    required property InfluxDBConnection influx_water
    opacity: 0.0
    id: root
    property int sinceDays: 0

    ConsumptionGraphView {
        id: consumptionGraphView

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

            // Cumulative consumption in the last 24 hours
            var queryText = "select last(amount_dl) as power from consumption where time >= '" + endOfDay.toJSON() + "' - " + (sinceDays+1) + "d and time < '" + endOfDay.toJSON() + "' - " + sinceDays + "d group by time(2m) order by time asc"
            var queryResult = influx_water.doQuery(queryText)

            if (queryResult[0]) {
                refreshLineGraph(queryResult)
                refreshBarGraph(endOfDay)
            }

            var titleDate = new Date()
            titleDate.setDate(titleDate.getDate() - sinceDays)
            chartView.title = "Veden kulutus " + titleDate.toLocaleDateString("fi_FI")
            chartView.focus = true
        }

        function refreshLineGraph(queryResult) {
            var firstValue = queryResult[0].data
            var maxValue = queryResult[queryResult.length - 1].data - firstValue
            maxValue = maxValue / 10

            // Sometimes water meter maximum value can go haywire because of bad data,
            // make sure the maximum value makes some sense
            if (maxValue > 2000 || maxValue < 0) {
                maxValue = 600
            }

            queryResult.forEach((point) => {
                            lineSeries.append(point.timestamp.getTime(), (point.data-firstValue)/10)
                        });

            yAxis.max = (maxValue + 50) - (maxValue + 50) % 50
        }

        function refreshBarGraph(endOfDay) {
            // Aggregated consumption per hour
            var queryText = "select difference(last(amount_dl))/10 as power from consumption where time >= '" + endOfDay.toJSON() + "' - " + (sinceDays+1) + "d and time < '" + endOfDay.toJSON() + "' - " + sinceDays + "d + 1s group by time(1h) order by time asc"
            var queryResult = influx_water.doQuery(queryText)

            if (queryResult[0]) {
                barSeries.append("litersPerHour", queryResult.map(point => point.data))
            }
        }
    }
}
