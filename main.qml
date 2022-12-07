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
        refreshDateAndTime()
    }

    function refreshElectricity() {
        var res = influx_electricity.doQuery("select power from consumption order by time desc limit 1")
        fpPower.text = "Sähkö: " + res[0].data.toFixed(0) + "W"
    }

    function refreshWater() {
        // Liters, last 10 minutes
        var res = influx_water.doQuery("select sum(power) as power from (select difference(first(amount_dl))/10 as power from consumption where time < now() and time >= now()-10m group by time(1m) order by time asc)")
        var foo = res[0] ? res[0].data.toFixed(1) : "--"
        fpWater.text = "Vesi: " + foo + " L/10min"
    }

    function refreshOutsideTemperature() {
        var res = influx_ruuvi.doQuery("select temperature as power from ruuvi_measurements where mac='CA:39:20:9F:92:AC' order by time desc limit 1")
        fpOutsideTemperature.text = "Ulkolämpötila: " + res[0].data.toFixed(1) + "℃"
    }

    function refreshInsideTemperature() {
        var res = influx_ruuvi.doQuery("select temperature as power from ruuvi_measurements where mac='EF:93:E1:2B:3E:DB' order by time desc limit 1")
        fpInsideTemperature.text = "Sisälämpötila: " + res[0].data.toFixed(1) + "℃"
    }

    function refreshDateAndTime() {
        var date = new Date()
        dateAndTime.text = date.toLocaleString("fi_FI", Locale.LongFormat)
    }


    Item {
        id: frontPage

        Image {
            id: image
            x: 0
            y: 0
            width: 800
            height: 480
            opacity: 0.5
            source: "img/background.jpg"
            fillMode: Image.PreserveAspectFit
        }

        Item {
            id: overlay
            x: 0
            y: 0
            width: 800
            height: 480

            Text {
                id: dateAndTime
                color: "#ffffff"
                text: qsTr("Text")
                anchors.top: parent.top
                font.pixelSize: 37
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 50
            }

            Grid {
                id: grid
                width: 650
                height: 300
                rows: 2
                columns: 2
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: 40
                anchors.horizontalCenter: parent.horizontalCenter

                Item {
                    id: electricity
                    width: 325
                    height: 150

                    Text {
                        id: fpPower
                        color: "#ffffff"
                        text: "Sähkö: 650W"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            powerGraphView.opacity = 1.0
                            frontPage.visible = false
                        }
                    }
                }

                Item {
                    id: insideTemperature
                    width: 325
                    height: 150

                    Text {
                        id: fpInsideTemperature
                        color: "#ffffff"
                        text: "Sisälämpötila 25℃"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            temperatureGraphView.opacity = 1.0
                            frontPage.visible = false
                        }
                    }
                }

                Item {
                    id: water
                    width: 325
                    height: 150

                    Text {
                        id: fpWater
                        color: "#ffffff"
                        text: "Vesi: 2L / 10min"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            waterGraphView.sinceDays = 0
                            waterGraphView.opacity = 1.0
                            frontPage.visible = false
                        }
                    }
                }

                Item {
                    id: outsideTemperature
                    width: 325
                    height: 150

                    Text {
                        id: fpOutsideTemperature
                        color: "#ffffff"
                        text: "Ulkolämpötila 25℃"
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 24
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            temperatureGraphView.opacity = 1.0
                            frontPage.visible = false
                        }
                    }
                }
            }
        }
    }
}
