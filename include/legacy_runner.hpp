#pragma once
#include "gameplay_protocol.hpp"
#include <QJsonObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <memory>
namespace tlbb {
struct LegacyRequest {
    enum Kind { Game,Snippet,Host };
    quint64 id=0;Kind kind=Game;
    gameplay::Command command=gameplay::Query;int argument=0; // Game: monthly sign batch only
    uint32_t snippet=0;gameplay::SnippetArgs args;             // Snippet: fixed game snippet
    QString host;QString detail;                                // Host: position / alert
};
class LegacyRunner {
public:
    enum Progress { Waiting,Action,Finished,Failed };
    LegacyRunner();~LegacyRunner();
    // A non-empty prelude (compat.lua) enables the reference program API and GBK/Chinese names.
    bool load(const QString &path,QString &error,const QString &compatPrelude={},const QJsonObject &settings={});
    Progress poll(qint64 activeMilliseconds,LegacyRequest &request,QString &error);
    bool acknowledge(quint64 id,bool success,const QString &error={},const QVariantList &values={});
    QStringList takeMessages();
    size_t allocated() const;
    static bool parseGameCall(const QString &source,gameplay::Command &command,int &argument);
    // Maps reference GetLuaValue text to a whitelisted snippet. Anything else is refused.
    static bool parseScriptCall(const QString &source,uint32_t &snippet,gameplay::SnippetArgs &args);
    static QByteArray translateSource(const QByteArray &source,QString &error);
    static QByteArray mangle(const QByteArray &utf8Name);
private:
    struct Impl;std::unique_ptr<Impl> p_;
};
bool resolveLegacyEntry(const QString &directory,const QString &id,QJsonObject &entry,QString &path,QString &error);
bool applyOriginalSourceChoice(const QString &directory,const QJsonObject &config,QJsonObject &entry,QString &path,QString &error);
QJsonObject legacyDefaults(QJsonObject config);
bool validateLegacyConfig(const QJsonObject &config,QString &error);
}
