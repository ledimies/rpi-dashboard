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

            // Cumulative consumption in the last 24 hours
            var queryText = "select last(amount_dl) as power from consumption where time < now()-" + sinceDays*24 + "h and time >= now()-" + (sinceDays+1)*24 + "h group by time(1m) order by time asc"
            var queryResult = influx_water.doQuery(queryText)
            var firstValue = queryResult[0].data
            var maxValue = queryResult[queryResult.length - 1].data - firstValue
            maxValue = maxValue / 10

            // Sometimes water meter maximum value can go haywire because of bad data,
            // make sure the maximum value makes some sense
            if (maxValue > 2000 || maxValue < 0) {
                maxValue = 2000
            }

            queryResult.forEach((point) => {
                            lineSeries.append(point.timestamp.getTime(), (point.data-firstValue)/10)
                        });

            timeAxis.max = queryResult[queryResult.length - 1].timestamp
            timeAxis.min = queryResult[0].timestamp
            timeAxis.tickCount = 24
            yAxis.max = (maxValue + 50) - (maxValue + 50) % 50

            // Aggregated consumption per hour
            queryText = "select difference(last(amount_dl))/10 as power from consumption where time < now()-" + sinceDays*24 + "h and time >= now()-" + (sinceDays+1)*24 + "h group by time(1h) order by time asc"
            queryResult = influx_water.doQuery(queryText)

            barSeries.append("litersPerHour", queryResult.map(point => point.data))
            barAxis.categories = queryResult.map(point => point.data)

            var titleDate = new Date()
            titleDate.setDate(titleDate.getDate() - sinceDays)
            chartView.title = "Veden kulutus " + titleDate.toLocaleDateString("fi_FI")
            chartView.focus = true
        }
    }
}
