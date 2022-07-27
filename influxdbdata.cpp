#include "influxdbdata.h"

InfluxDBData::InfluxDBData(QObject *parent)
    : QObject{parent}
{

}

double InfluxDBData::data() const
{
    return m_data;
}

void InfluxDBData::setData(const double data)
{
    m_data = data;
}

QDateTime InfluxDBData::timestamp() const
{
    return m_timestamp;
}

void InfluxDBData::setTimestamp(const QDateTime &timestamp)
{
    m_timestamp = timestamp;
}
