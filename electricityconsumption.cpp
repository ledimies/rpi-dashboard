#include "electricityconsumption.h"

#include <InfluxDBFactory.h>

ElectricityConsumption::ElectricityConsumption(QObject *parent)
    : QObject{parent}
{
    m_influxDBConnection = influxdb::InfluxDBFactory::Get("http://qt-sahko:testi@192.168.1.2:8086/?db=sahko");
}
