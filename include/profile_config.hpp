#pragma once
#include <QJsonObject>
namespace tlbb {
QJsonObject portableProfile(const QJsonObject &profile);
bool readPortableProfile(const QJsonObject &document,QJsonObject &configuration,QString &error);
QJsonObject migrateTaskProfile(QJsonObject profile);
QJsonObject copyTaskConfiguration(const QJsonObject &source,const QJsonObject &target);
} // namespace tlbb
