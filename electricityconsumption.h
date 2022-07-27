#ifndef ELECTRICITYCONSUMPTION_H
#define ELECTRICITYCONSUMPTION_H

#include <QObject>
#include <InfluxDB.h>

class ElectricityConsumption : public QObject
{
    Q_OBJECT
public:
    explicit ElectricityConsumption(QObject *parent = nullptr);

signals:

private:
    std::unique_ptr<influxdb::InfluxDB> m_influxDBConnection;
};

#endif // ELECTRICITYCONSUMPTION_H
