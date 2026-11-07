#pragma once
#include "resident_protocol.hpp"
#include <QJsonObject>
#include <QString>
#include <memory>
namespace tlbb {
class ResidentChannel {
public:
    ResidentChannel();~ResidentChannel();
    bool open(quint32,const QString &created,const QString &root,QString &error);
    bool start(const QByteArray &source,const QJsonObject &config,QJsonObject &state,QString &error);
    bool command(resident::Command,QJsonObject &state,QString &error);
private:struct Impl;std::unique_ptr<Impl> p_;bool exchange(resident::Command,QJsonObject&,QString&);
};
QByteArray prepareResidentScript(const QString &legacyDirectory,const QString &entry,const QJsonObject &config,QString &error);
}
