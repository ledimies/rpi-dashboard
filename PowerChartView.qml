import QtQuick
import rpidisplay

Item {
    required property InfluxDBConnection influx_electricity
    opacity: 0.0
    id: root
    property int sinceDays: 0

    ConsumptionGraphView {
        id: consumptionGraphView

        function refresh(sinceDays) {
            lineSeries.clear()
            barSeries.clear()

            var queryText = "select mean(power) as power from consumption where time < now()-" + sinceDays*24 + "h and time >= now()-" + (sinceDays+1)*24 + "h group by time(2m) order by time asc"
            var queryResult = influx_electricity.doQuery(queryText)
            var maxValue = Math.max(...queryResult.map(point => point.data))

            queryResult.forEach((point) => {
                                    lineSeries.append(point.timestamp.getTime(), point.data)
                                });

            timeAxis.max = queryResult[queryResult.length - 1].timestamp
            timeAxis.min = queryResult[0].timestamp
            timeAxis.tickCount = 24
            yAxis.max = (maxValue + 500) - (maxValue + 500) % 500

            queryText = "select count(power) as power from consumption where time < now()-" + sinceDays*24 + "h and time >= now()-" + (sinceDays+1)*24 + "h group by time(1h) order by time asc"
            queryResult = influx_electricity.doQuery(queryText)

            barSeries.append("kWhPerHour", queryResult.map(point => point.data))
            barAxis.categories = queryResult.map(point => point.data)

            var titleDate = new Date()
            titleDate.setDate(titleDate.getDate() - sinceDays)
            chartView.title = "Sähkön kulutus " + titleDate.toLocaleDateString("fi_FI")
            chartView.focus = true
        }
    }
}
