#ifndef INFLUXDBCONNECTION_H
#define INFLUXDBCONNECTION_H

#include <QObject>
#include <QtQml/qqml.h>
#include <influxdbdata.h>
#include <InfluxDB.h>

class InfluxDBConnection : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    QML_ELEMENT
public:
    explicit InfluxDBConnection(QObject *parent = nullptr);

    bool connected() const;

    Q_INVOKABLE void connect(const QString &name);
    Q_INVOKABLE QVariantList doQuery(const QString query);

signals:
    void connectedChanged();

private:
    QVariantList m_data;
    bool m_connected = false;
    std::unique_ptr<influxdb::InfluxDB> m_influxDBConnection;
};

#endif // INFLUXDBCONNECTION_H
