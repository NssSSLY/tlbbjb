#pragma once
#include <QByteArray>
#include <QJsonArray>
#include <QJsonObject>
#include <QString>

namespace tlbb {
// Reference data is available to configuration only. This is not a game-action adapter.
class RouteCatalog {
  public:
    static bool parse(const QByteArray &bytes, QJsonArray &routes, QString &error);
    static bool load(const QString &path, QJsonArray &routes, QString &error);
    static QJsonObject reference(const QJsonObject &route);
};
} // namespace tlbb
