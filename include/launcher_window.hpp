#pragma once
#include "core.hpp"
#include "client_store.hpp"
#include <QAbstractNativeEventFilter>
#include <QElapsedTimer>
#include <QHash>
#include <QMainWindow>
#include <QSet>
class QComboBox; class QLineEdit; class QCheckBox; class QListWidget;
class QLabel; class QSystemTrayIcon; class QProcess;
class QPushButton;
class QTimer;
namespace tlbb {
class SessionPanel;
class MainWindow final : public QMainWindow, public QAbstractNativeEventFilter {
  public:
    MainWindow(const QString &gameRoot,const QString &script,bool testMode=false,const QString &dataRoot={});
    ~MainWindow() override;
    void syncHotkeys();
    bool nativeEventFilter(const QByteArray &,void *,qintptr *) override;
    bool saveScreenshot(const QString &path);
    bool bindForSmoke(quint32 pid);
    QJsonObject diagnostics() const;
    int runUiTests(const QString &fixtureRoot,const QString &report);
    void startConfiguredGame();
  protected:
    void closeEvent(QCloseEvent *) override;
  private:
    struct Session;
    QHash<quint32,Session*> sessions_;
    QHash<quintptr,QLabel*> toasts_;
    QVector<GameInfo> games_;
    QLineEdit *root_=nullptr;
    QComboBox *district_=nullptr,*server_=nullptr,*role_=nullptr;
    QCheckBox *multi_=nullptr;
    QListWidget *accounts_=nullptr;
    QLabel *status_=nullptr;
    QSystemTrayIcon *tray_=nullptr;
    ClientStore store_;
    QString script_,selectedAccount_;
    bool testMode_=false,quitting_=false,loading_=false;
    bool homeRegistered_=false,endRegistered_=false,insertRegistered_=false,allStopRegistered_=false;
    quintptr lastHotkey_=0;
    DWORD hotkeyError_=0;
    HANDLE workerJob_=nullptr;
    HWINEVENTHOOK foregroundHook_=nullptr;
    QElapsedTimer launchTime_;
    QSet<quint32> beforeLaunch_,launchFamily_;
    QJsonObject pendingIdentity_;
    QProcess *launcherProcess_=nullptr;
    QProcess *loginWorker_=nullptr;
    QPushButton *startButton_=nullptr;
    QByteArray loginOutput_;
    quint32 loginPid_=0;
    bool launchButtonSent_=false;
    QTimer *refreshTimer_=nullptr;
    QElapsedTimer officialPoll_,officialStartTime_;
    QJsonObject lastLauncherProbe_;
    void loginAudit(const QString &event,const QJsonObject &details={});
    QString protectedLoginFingerprint_;
    QString protectedAccountId_;
    quint32 protectedGamePid_=0;
    void beginLogin(const GameInfo &game);
    void cancelLogin();
    void setLoginBusy(bool busy);
    QString gameRoot() const;
    void loadAccounts();
    void chooseAccount(const QString &id);
    void editAccount(bool isNew);
    void fillRoles();
    QJsonObject selectedIdentity() const;
    bool saveLauncher();
    void refreshGames();
    void launchGame();
    void bind(quint32 pid,const QString &source="home",QJsonObject identity={},bool show=true);
    void detach(quint32 pid,const QString &reason);
    void release(Session *s);
    void send(Session *s,QJsonObject command);
    void handle(Session *s,const QJsonObject &event);
    void runQueue(Session *s,QJsonArray queue);
    void runNext(Session *s);
    void runPlan(Session *s,QJsonObject plan);
    void runLegacyQueue(Session *s,QJsonArray queue);
    void runLegacyNext(Session *s);
    bool saveProfile(Session *s);
    void copyProfile(Session *s);
    void associate(Session *s);
    void updatePanel(Session *s);
    void append(Session *s,const QString &message);
    void toast(const GameInfo &game,const QString &message);
    GameInfo gameInfo(quint32 pid) const;
    quint32 foregroundGame() const;
    bool dispatchHotkey(quintptr id);
    void stopAll();
    void quitClient();
};
} // namespace tlbb
