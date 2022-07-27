import QtQuick
import rpidisplay
import QtCharts

Window {
    id: mainWindow
    width: 800
    height: 480
    visible: true
    color: "black"
    title: qsTr("Home Dashboard")

    InfluxDBConnection {
        id: influx_electricity
    }

    InfluxDBConnection {
        id: influx_water
    }

    InfluxDBConnection {
        id: influx_ruuvi
    }

    PowerChartView {
        id: powerGraphView
        influx_electricity: influx_electricity
    }

    WaterChartView {
        id: waterGraphView
        influx_water: influx_water
    }

    TemperatureChartView {
        id: temperatureGraphView
        influx_ruuvi: influx_ruuvi
        series: [
            TemperatureSeries { name: "Ulkolämpötila"; mac: "CA:39:20:9F:92:AC" },
            TemperatureSeries { name: "Sisälämpötila"; mac: "EF:93:E1:2B:3E:DB" }
        ]
    }

    Component.onCompleted: {
        influx_electricity.connect(powerURL)
        influx_water.connect(waterURL)
        influx_ruuvi.connect(ruuviURL)
    }

    Timer {
        id: mainWindowTimer
        interval: 500
        triggeredOnStart: true
        running: frontPage.visible
        repeat: true
        onTriggered: {
            refreshAll()
        }
    }

    function refreshAll() {
        refreshElectricity()
        refreshWater()
        refreshOutsideTemperature()
        refreshInsideTemperature()
    }

    function refreshElectricity() {
        var res = influx_electricity.doQuery("select power from consumption order by time desc limit 1")
        fpPower.text = res[0].data.toFixed(0)
    }

    function refreshWater() {
        // Liters, last 10 minutes
        var res = influx_water.doQuery("select sum(power) as power from (select difference(first(amount_dl))/10 as power from consumption where time < now() and time >= now()-10m group by time(1m) order by time asc)")
        fpWater.text = res[0].data.toFixed(1)
    }

    function refreshOutsideTemperature() {
        var res = influx_ruuvi.doQuery("select temperature as power from ruuvi_measurements where mac='CA:39:20:9F:92:AC' order by time desc limit 1")
        fpOutsideTemperature.text = res[0].data.toFixed(1)
    }

    function refreshInsideTemperature() {
        var res = influx_ruuvi.doQuery("select temperature as power from ruuvi_measurements where mac='EF:93:E1:2B:3E:DB' order by time desc limit 1")
        fpInsideTemperature.text = res[0].data.toFixed(1)
    }

    Grid {
        id: frontPage
        x: 0
        y: 0
        width: 800
        height: 480
        rows: 2
        columns: 4

        Rectangle {
            id: electricity
            width: 200
            height: 240
            color: "#ffffff"

            Text {
                id: fpPower
                text: influx_electricity.connected
//                font.pointSize: 40

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        powerGraphView.opacity = 1.0
                        frontPage.visible = false
                    }
                }
            }
        }

        Rectangle {
            id: water
            width: 200
            height: 240
            color: "#ffffff"

            Text {
                id: fpWater
                text: influx_electricity.connected
//                font.pointSize: 40

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        waterGraphView.opacity = 1.0
                        frontPage.visible = false
                    }
                }
            }
        }

        Rectangle {
            id: outsideTemperature
            width: 200
            height: 240
            color: "#ffffff"

            Text {
                id: fpOutsideTemperature
                text: influx_electricity.connected
//                font.pointSize: 40

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        temperatureGraphView.opacity = 1.0
                        frontPage.visible = false
                    }
                }
            }
        }

        Rectangle {
            id: insideTemperature
            width: 200
            height: 240
            color: "#ffffff"

            Text {
                id: fpInsideTemperature
                text: influx_electricity.connected
//                font.pointSize: 40

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        temperatureGraphView.opacity = 1.0
                        frontPage.visible = false
                    }
                }
            }
        }

        Rectangle {
            id: rectangle4
            width: 200
            height: 240
            color: "#ffffff"
        }

        Rectangle {
            id: rectangle5
            width: 200
            height: 240
            color: "#ffffff"
        }

        Rectangle {
            id: rectangle6
            width: 200
            height: 240
            color: "#ffffff"
        }

        Rectangle {
            id: rectangle7
            width: 200
            height: 240
            color: "#ffffff"
        }
    }
}
