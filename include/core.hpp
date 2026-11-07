#pragma once
#include <QJsonObject>
#include <QString>
#include <QVector>
#include <memory>
#include <windows.h>
struct lua_State;

namespace tlbb {
struct GameInfo {
    quint32 pid = 0;
    QString path, title, created;
    quintptr window = 0;
};
QVector<GameInfo> discoverGames(const QString &root);
QString processPath(quint32 pid);
QString processCreated(HANDLE process);
bool isGamePath(const QString &path, const QString &root);
class ProcessBinding {
  public:
    ~ProcessBinding();
    bool open(quint32 pid, const QString &root, const QString &expected = {}, bool fixture = false);
    void close();
    bool alive() const;
    HANDLE handle() const {
        return handle_;
    }
    const GameInfo &info() const {
        return info_;
    }
    QString error;
    bool headerReadable = false;

  private:
    HANDLE handle_ = nullptr;
    GameInfo info_;
};

struct Decision {
    QString kind, message, crop;
    double x = 0, y = 0;
    QJsonObject context;
};
class LiveGameReader {
  public:
    bool open(const ProcessBinding &binding, QString &error);
    bool snapshot(QJsonObject &state, QString &error) const;

  private:
    const ProcessBinding *binding_ = nullptr;
    quintptr base_ = 0;
};
class LuaTask {
  public:
    LuaTask();
    ~LuaTask();
    bool load(const QString &path, QString &error);
    bool step(const QJsonObject &state, const QJsonObject &config, const QJsonObject &context, Decision &out,
              QString &error);
    QString id, version;
    int schema = 0;
    size_t allocated() const;

  private:
    struct Impl;
    std::unique_ptr<Impl> p_;
};

bool validatePlantConfig(const QJsonObject &config, QString &error);
bool validateWaitConfig(const QJsonObject &config, QString &error);
QStringList liveMissingCapabilities();
class PreviewWorld {
  public:
    QJsonObject snapshot() const;
    bool submit(const Decision &decision, QString &error);
    void advance();
    bool pending() const {
        return pendingTicks_ > 0;
    }
    int actions = 0;

  private:
    double x_ = 350, y_ = 310, nextX_ = 0, nextY_ = 0;
    int plants_ = 0, pendingTicks_ = 0;
    QString pendingKind_;
};
int runWorker(const QStringList &arguments);
int runSelfTests(const QString &root, const QString &report);
} // namespace tlbb
