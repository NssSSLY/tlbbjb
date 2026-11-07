#include "route_catalog.hpp"
#include "builtin_resources.hpp"
#include <QFile>
#include <QJsonDocument>
#include <QJsonParseError>
#include <QRegularExpression>
#include <QSet>
#include <cmath>

namespace tlbb {
static constexpr int MaxBytes = 512 * 1024;
bool RouteCatalog::load(const QString &path, QJsonArray &routes, QString &error) {
    routes = {};
    QFile file(BuiltinResources::path(path));
    if (!file.open(QIODevice::ReadOnly) || file.size() < 1 || file.size() > MaxBytes) {
        error = "参考路线文件不可读或超过 512 KiB";
        return false;
    }
    return parse(file.read(MaxBytes + 1), routes, error);
}
bool RouteCatalog::parse(const QByteArray &bytes, QJsonArray &routes, QString &error) {
    routes = {};
    error.clear();
    auto reject = [&] { error = "参考路线数据无效，未载入"; return false; };
    if (bytes.isEmpty() || bytes.size() > MaxBytes) return reject();
    QJsonParseError parseError;
    const auto document = QJsonDocument::fromJson(bytes, &parseError);
    if (parseError.error != QJsonParseError::NoError || !document.isObject()) return reject();
    const auto root = document.object();
    if (root.value("schema") != QJsonValue(1) || root.value("runtime_enabled") != QJsonValue(false)
        || !root.value("routes").isArray()) return reject();
    const auto entries = root.value("routes").toArray();
    if (entries.isEmpty() || entries.size() > 128) return reject();
    const QRegularExpression idPattern("^(?:mtx|tlzz)-[0-9a-f]{16}$"), hashPattern("^[0-9a-f]{64}$");
    QSet<QString> ids;
    int total = 0;
    for (const auto &entry : entries) {
        if (!entry.isObject()) return reject();
        const auto route = entry.toObject(), source = route.value("source").toObject();
        const auto id = route.value("id").toString(), name = route.value("name").toString();
        const auto hint = route.value("map_hint").toString(), path = source.value("path").toString();
        const auto pack=source.value("pack").toString();
        const bool sourcePath=pack=="mtxjb"?(id.startsWith("mtx-")&&path.startsWith("坐标/")&&path.endsWith(".txt"))
            :pack=="tlzz"&&(id.startsWith("tlzz-"))&&((path.startsWith("data/坐标/")&&path.endsWith(".txt"))||(path.startsWith("data/模版/")&&path.endsWith(".json")));
        if (!idPattern.match(id).hasMatch() || ids.contains(id) || name.trimmed().isEmpty() || name.size() > 80
            || hint.trimmed().isEmpty() || hint.size() > 80 || !route.value("map").isNull()
            || route.value("verified") != QJsonValue(false) || route.value("runtime_enabled") != QJsonValue(false)
            || route.value("purpose").toString() != "unclassified" || !sourcePath
            || !hashPattern.match(source.value("sha256").toString()).hasMatch()
            || path.contains("..")
            || path.contains('\\') || path.contains(':') || path.size() > 160
            || !route.value("points").isArray()) return reject();
        ids.insert(id);
        const auto points = route.value("points").toArray();
        total += points.size();
        if (points.isEmpty() || points.size() > 2048 || total > 4096) return reject();
        double previousLine = 0;
        for (const auto &value : points) {
            if (!value.isObject()) return reject();
            const auto point = value.toObject();
            for (const auto &key : {"x", "y"}) {
                const auto coordinate = point.value(key);
                if (!coordinate.isDouble() || !std::isfinite(coordinate.toDouble())
                    || coordinate.toDouble() < 0 || coordinate.toDouble() > 10000) return reject();
            }
            const auto line = point.value("source_line");
            const double number = line.toDouble();
            if (!line.isDouble() || number <= previousLine || number > 1000000 || std::floor(number) != number)
                return reject();
            previousLine = number;
        }
    }
    routes = entries; // Atomic replacement; a bad last entry cannot leave a partial catalog.
    return true;
}
QJsonObject RouteCatalog::reference(const QJsonObject &route) {
    return {{"id", route.value("id")}, {"name", route.value("name")},
            {"source_sha256", route.value("source").toObject().value("sha256")},
            {"verified", false}, {"runtime_enabled", false}};
}
} // namespace tlbb
