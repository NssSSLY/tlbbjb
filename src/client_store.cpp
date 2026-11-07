#include "client_store.hpp"
#include "builtin_resources.hpp"
#include <QCryptographicHash>
#include <QDir>
#include <QDateTime>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QSaveFile>
#include <windows.h>
#include <wincrypt.h>
#include <cstring>

namespace tlbb {
ClientStore::ClientStore(QString directory) : root(QDir::cleanPath(directory)) {}
QJsonObject ClientStore::readJson(const QString &path) {
    QFile file(BuiltinResources::path(path));
    if (!file.open(QIODevice::ReadOnly) || file.size() > 1024 * 1024)
        return {};
    return QJsonDocument::fromJson(file.readAll()).object();
}
bool ClientStore::writeJson(const QString &path, const QJsonObject &data, QString &error) {
    QDir().mkpath(QFileInfo(path).absolutePath());
    QSaveFile file(path);
    const auto bytes=QJsonDocument(data).toJson();
    if (!file.open(QIODevice::WriteOnly) || file.write(bytes) != bytes.size() || !file.commit()) {
        error = "配置保存失败，请选择可写的软件目录";
        return false;
    }
    return true;
}
bool ClientStore::load(QString &error) {
    const QString file = root + "/launcher.json";
    if (QFile::exists(file)) {
        launcher = readJson(file);
        if (launcher.isEmpty()) {
            error = "启动器配置无效，原文件已保留";
            return false;
        }
    }
    if (launcher.isEmpty())
        launcher = {{"schema", 3}, {"game_root", "E:/game/tlbb"}, {"multi_open", false},
                    {"accounts", QJsonArray{}}};
    auto accounts = launcher.value("accounts").toArray();
    bool changed = false;
    for (int i=0;i<accounts.size();++i) {
        auto account=accounts[i].toObject(), destinations=account.value("destinations").toObject();
        for (const auto &key:destinations.keys()) {
            auto destination=destinations.value(key).toObject();
            if (!destination.value("roles").toObject().isEmpty() && destination.value("role_text_encoding").toString()!="cegui-utf8-v1") {
                destination.remove("roles");
                destination.insert("role_text_encoding","cegui-utf8-v1");
                destinations.insert(key,destination);changed=true;
            }
        }
        account.insert("destinations",destinations);accounts[i]=account;
    }
    if (changed) {
        const auto backup=root+"/migrations/launcher-before-role-utf8-"+QDateTime::currentDateTimeUtc().toString("yyyyMMdd-HHmmss-zzz")+".json";
        if (!writeJson(backup,launcher,error)) return false;
        launcher.insert("accounts",accounts);
        if (!save(error)) return false;
    }
    return true;
}
bool ClientStore::save(QString &error) const { return writeJson(root + "/launcher.json", launcher, error); }
QString ClientStore::roleKey(const QJsonObject &identity) {
    return QString::fromLatin1(QCryptographicHash::hash(QJsonDocument(identity).toJson(QJsonDocument::Compact),
                                                      QCryptographicHash::Sha256).toHex());
}
QString ClientStore::loginFingerprint(const QString &login) {
    const auto value=login.trimmed().toCaseFolded().section('@',0,0).toUtf8();
    return value.isEmpty()?QString():QString::fromLatin1(QCryptographicHash::hash(value,QCryptographicHash::Sha256).toHex());
}
QString ClientStore::profilePath(const QString &key) const { return root + "/profiles/" + roleKey({{"key", key}}) + ".json"; }
// A profile file counts only when it opens, fits, parses and is an object; anything else is damage, not "new".
static bool readProfileFile(const QString &path, QJsonObject &out) {
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly) || file.size() > 1024 * 1024) return false;
    QJsonParseError parse;const auto document = QJsonDocument::fromJson(file.readAll(), &parse);
    if (parse.error != QJsonParseError::NoError || !document.isObject()) return false;
    out = document.object();return true;
}
ClientStore::ProfileState ClientStore::loadProfile(const QString &key, QJsonObject &profile, QString &message) const {
    profile = {};message.clear();
    const auto path = profilePath(key), backup = path + ".bak";
    if (!QFile::exists(path) && !QFile::exists(backup)) return ProfileState::Missing;
    if (QFile::exists(path) && readProfileFile(path, profile)) return ProfileState::Loaded;
    QJsonObject restored;
    if (readProfileFile(backup, restored)) {
        // Keep the damaged file next to the profile; later saves then write the restored configuration.
        const auto damaged = path + ".damaged-" + QDateTime::currentDateTime().toString("yyyyMMdd-HHmmss") + ".json";
        if (QFile::exists(path) && !QFile::copy(path, damaged)) {
            message = "角色配置文件损坏，备份可用但无法另存损坏文件，已停止自动保存：" + QDir::toNativeSeparators(path);
            return ProfileState::Damaged;
        }
        profile = restored;
        message = "角色配置文件损坏，已从上次保存的备份恢复" + (QFile::exists(path) ? "；损坏文件另存为 " + QDir::toNativeSeparators(damaged) : QString());
        return ProfileState::Restored;
    }
    message = "角色配置文件损坏且没有可用备份，已停止自动保存，原文件保留：" + QDir::toNativeSeparators(path);
    return ProfileState::Damaged;
}
QJsonObject ClientStore::profile(const QString &key) const {
    QJsonObject result;QString message;loadProfile(key, result, message);return result;
}
bool ClientStore::saveProfile(const QString &key, const QJsonObject &profile, QString &error) const {
    // The last valid file becomes the backup used if the next one is found damaged.
    const auto path = profilePath(key), backup = path + ".bak";QJsonObject previous;
    if (readProfileFile(path, previous)) {
        QFile::remove(backup);
        if (!QFile::copy(path, backup)) { error = "角色配置备份失败，本次未保存：" + QDir::toNativeSeparators(backup); return false; }
    }
    return writeJson(path, profile, error);
}
bool ClientStore::savePassword(const QString &account, const QString &password, QString &error) const {
    QByteArray plain = password.toUtf8();
    DATA_BLOB source{DWORD(plain.size()), reinterpret_cast<BYTE *>(plain.data())}, encrypted{};
    const bool ok = CryptProtectData(&source, L"TLBBClient local account", nullptr, nullptr, nullptr,
                                    CRYPTPROTECT_UI_FORBIDDEN, &encrypted);
    SecureZeroMemory(plain.data(), SIZE_T(plain.size()));
    if (!ok) { error = "凭据加密失败，密码未保存"; return false; }
    QDir().mkpath(root + "/credentials");
    QSaveFile file(root + "/credentials/" + roleKey({{"account", account}}) + ".dat");
    const bool written = file.open(QIODevice::WriteOnly) &&
                         file.write(reinterpret_cast<char *>(encrypted.pbData), encrypted.cbData) == encrypted.cbData &&
                         file.commit();
    LocalFree(encrypted.pbData);
    if (!written) error = "加密凭据写入失败";
    return written;
}
bool ClientStore::readPassword(const QString &account,QByteArray &password,QString &error) const {
    if(!password.isEmpty()){SecureZeroMemory(password.data(),SIZE_T(password.size()));password.clear();}
    QFile file(root+"/credentials/"+roleKey({{"account",account}})+".dat");
    if(account.isEmpty()||!file.open(QIODevice::ReadOnly)||file.size()<1||file.size()>16384){error="未找到已保存密码，请编辑账号并勾选本机加密保存密码";return false;}
    auto bytes=file.readAll();DATA_BLOB input{DWORD(bytes.size()),reinterpret_cast<BYTE*>(bytes.data())},output{};
    if(!CryptUnprotectData(&input,nullptr,nullptr,nullptr,nullptr,CRYPTPROTECT_UI_FORBIDDEN,&output)){error="密码无法解密，请在本机重新保存密码";return false;}
    const bool valid=output.cbData>0&&output.cbData<=512&&!std::memchr(output.pbData,0,output.cbData);
    if(valid)password=QByteArray(reinterpret_cast<const char*>(output.pbData),int(output.cbData));
    SecureZeroMemory(output.pbData,output.cbData);LocalFree(output.pbData);
    if(!valid)error="保存的密码无效，请重新保存";
    return valid;
}
QJsonObject ClientStore::rememberRole(QJsonObject account, const QString &district, const QString &server,
                                    int slot, const QString &name) {
    // Only a verified adapter result may call this; never infer a nickname from a PID or slot.
    if (name.trimmed().isEmpty() || name.size() > 64 || slot < 1 || slot > 12) return account;
    const QString key = district + "/" + server;
    auto destinations = account.value("destinations").toObject();
    auto destination = destinations.value(key).toObject();
    auto roles = destination.value("roles").toObject();
    roles.insert(QString::number(slot), name.trimmed());
    destination.insert("roles", roles);
    destination.insert("role_text_encoding", "cegui-utf8-v1");
    destinations.insert(key, destination);
    account.insert("destinations", destinations);
    return account;
}
} // namespace tlbb
