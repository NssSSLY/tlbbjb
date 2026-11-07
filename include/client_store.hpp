#pragma once
#include <QJsonObject>
#include <QString>
#include <QByteArray>

namespace tlbb {
class ClientStore {
  public:
    explicit ClientStore(QString directory);
    QString root;
    QJsonObject launcher;
    bool load(QString &error);
    bool save(QString &error) const;
    enum class ProfileState { Missing, Loaded, Restored, Damaged };
    // Missing: a new role. Restored: the file was damaged, its last backup was loaded. Damaged: no usable
    // copy; the caller must not save over it.
    ProfileState loadProfile(const QString &key, QJsonObject &profile, QString &message) const;
    QString profilePath(const QString &key) const;
    QJsonObject profile(const QString &key) const;
    bool saveProfile(const QString &key, const QJsonObject &profile, QString &error) const;
    bool savePassword(const QString &account, const QString &password, QString &error) const;
    bool readPassword(const QString &account, QByteArray &password, QString &error) const;
    static bool writeJson(const QString &path, const QJsonObject &data, QString &error);
    static QJsonObject readJson(const QString &path);
    static QString roleKey(const QJsonObject &identity);
    static QString loginFingerprint(const QString &login);
    static QJsonObject rememberRole(QJsonObject account, const QString &district, const QString &server,
                                   int slot, const QString &verifiedName);
};
} // namespace tlbb
