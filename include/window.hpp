#pragma once
#include "core.hpp"
#include <QAbstractNativeEventFilter>
#include <QElapsedTimer>
#include <QHash>
#include <QMainWindow>
#include <QSet>
class QComboBox;
class QDoubleSpinBox;
class QLineEdit;
class QSpinBox;
class QTreeWidget;
class QTreeWidgetItem;
class QPlainTextEdit;
class QLabel;
class QProcess;
class QSystemTrayIcon;
class QWinEventNotifier;
class QPushButton;

namespace tlbb {
class MainWindow final : public QMainWindow, public QAbstractNativeEventFilter {
  public:
    MainWindow(const QString &gameRoot, const QString &script, bool testMode = false);
    ~MainWindow() override;
    void syncHotkeys();
    bool nativeEventFilter(const QByteArray &, void *, qintptr *) override;
    bool saveScreenshot(const QString &path);
    bool bindForSmoke(quint32 pid);
    QJsonObject diagnostics() const;

  protected:
    void closeEvent(QCloseEvent *) override;

  private:
    struct Session;
    QHash<quint32, Session *> sessions_;
    QVector<GameInfo> games_;
    QTreeWidget *gamesList_ = nullptr;
    QPlainTextEdit *logs_ = nullptr;
    QLabel *banner_ = nullptr, *sessionLabel_ = nullptr, *status_ = nullptr;
    QLineEdit *root_ = nullptr, *crop_ = nullptr;
    QSpinBox *x_ = nullptr, *y_ = nullptr, *rounds_ = nullptr, *timeout_ = nullptr;
    QDoubleSpinBox *tolerance_ = nullptr;
    QComboBox *mode_ = nullptr;
    QPushButton *start_ = nullptr, *pause_ = nullptr, *stop_ = nullptr, *reload_ = nullptr;
    QSystemTrayIcon *tray_ = nullptr;
    QString script_, dataRoot_;
    HANDLE workerJob_ = nullptr;
    HWINEVENTHOOK foregroundHook_ = nullptr;
    bool testMode_ = false, quitting_ = false, homeRegistered_ = false, endRegistered_ = false,
         insertRegistered_ = false, allStopRegistered_ = false;
    quint32 selected_ = 0;
    HWND returnWindow_ = nullptr;
    QSet<quint32> beforeLaunch_;
    QElapsedTimer launchTime_;
    QJsonObject savedProfiles_;
    void refreshGames();
    void bind(quint32 pid);
    void detach(quint32 pid, const QString &reason);
    void send(Session *, QJsonObject);
    void handle(Session *, const QJsonObject &);
    void select(quint32 pid);
    void updateRows();
    void append(Session *, const QString &);
    void taskStart();
    void saveProfile();
    QJsonObject config() const;
    void applyConfig(const QJsonObject &);
    void togglePanel();
    void stopAll();
    void quitClient();
    void launchGame();
    quint32 foregroundGame() const;
};
} // namespace tlbb
