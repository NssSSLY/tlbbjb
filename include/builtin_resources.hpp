#pragma once
#include <QString>
#include <QStringList>
#include <QJsonObject>
namespace tlbb {
// One uncompressed runtime resource file, plus optional per-file user overrides.
class BuiltinResources {
public:
    static bool mount(QString &error);
    static QString path(const QString &requested);
    static QString child(const QString &directory,const QString &relative);
    static QStringList files(const QString &directory,const QString &filter);
    static QJsonObject report();
};
}
