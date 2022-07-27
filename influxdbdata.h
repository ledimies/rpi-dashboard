#ifndef INFLUXDBDATA_H
#define INFLUXDBDATA_H

#include <QDateTime>
#include <QObject>
#include <QtQml/qqml.h>

class InfluxDBData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double data READ data CONSTANT)
    Q_PROPERTY(QDateTime timestamp READ timestamp CONSTANT)
    QML_ELEMENT
public:
    explicit InfluxDBData(QObject *parent = nullptr);

    double data() const;
    void setData(const double);

    QDateTime timestamp() const;
    void setTimestamp(const QDateTime &);

private:
    double m_data;
    QDateTime m_timestamp;
};

#endif // INFLUXDBDATA_H
