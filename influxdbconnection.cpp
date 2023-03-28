#include "influxdbconnection.h"

#include <InfluxDBFactory.h>
#include <iostream>

InfluxDBConnection::InfluxDBConnection(QObject *parent)
    : QObject{parent}
{
}

bool InfluxDBConnection::connected() const
{
    return m_connected;
}

void InfluxDBConnection::connect(const QString &url)
{
    if (m_connected == false) {
        std::cout << "Not connected, connecting" << std::endl;
        m_influxDBConnection = influxdb::InfluxDBFactory::Get(url.toStdString());
        m_connected = true;
        emit connectedChanged();
    }
}

QVariantList InfluxDBConnection::doQuery(const QString query)
{
    m_data.clear();
    auto data = m_influxDBConnection->query(query.toStdString());
    for (auto element : data) {
        InfluxDBData new_element;
        new_element.setData(QString::fromStdString(element.getFields()).remove(0,6).toDouble());
        long value_ms = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::time_point_cast<std::chrono::milliseconds>(element.getTimestamp()).time_since_epoch()).count();
        new_element.setTimestamp(QDateTime::fromMSecsSinceEpoch(value_ms));
        m_data.append(QVariant::fromValue(new_element));
    }
    return m_data;
}
