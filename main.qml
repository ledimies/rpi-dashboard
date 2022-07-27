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
    }

    function refreshElectricity() {
        var res = influx_electricity.doQuery("select power from consumption order by time desc limit 1")
        fp_power.text = res[0].data.toFixed(0)
    }

    function refreshWater() {
        // Litraa / viimeisimmät 10 minuuttia
        var res = influx_water.doQuery("select sum(power) as power from (select difference(first(amount_dl))/10 as power from consumption where time < now() and time >= now()-10m group by time(1m) order by time asc)")
        fp_water.text = res[0].data.toFixed(1)
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
                id: fp_power
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
                id: fp_water
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
            id: rectangle2
            width: 200
            height: 240
            color: "#ffffff"
        }

        Rectangle {
            id: rectangle3
            width: 200
            height: 240
            color: "#ffffff"
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
