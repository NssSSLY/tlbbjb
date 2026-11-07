#pragma once
#include "core.hpp"
#include <QJsonArray>
#include <QWidget>
#include <functional>
class QTabWidget;
class QTableWidget;
class QPlainTextEdit;
class QLabel;
class QPushButton;
class QCloseEvent;
class QComboBox;
class QLineEdit;
class QVBoxLayout;
class QListWidget;
class QTimeEdit;
class QCheckBox;
namespace tlbb {
class SessionPanel final : public QWidget {
  public:
    SessionPanel(GameInfo game, QJsonObject profile);
    ~SessionPanel() override;
    GameInfo game;
    std::function<void(QJsonArray)> runRequested;
    std::function<void(QJsonObject)> flowRequested;
    std::function<void()> pauseRequested, stopRequested, reloadRequested, detachRequested,
                          saveRequested, copyRequested, associateRequested, favoritesChanged, shown;
    QJsonObject profile() const;
    void setProfile(QJsonObject profile);
    void runtime(QString status, bool ready, bool running, QJsonObject live, qint64 bytes);
    void appendLog(const QString &text);
    void showForGame();
    void retire();
    QJsonObject diagnostics() const;
    bool screenshot(const QString &path);
    void selectTab(const QString &name);
    void selectTask(const QString &id);
    void flowStates(const QJsonObject &states);
  protected:
    void closeEvent(QCloseEvent *) override;
  private:
    QJsonObject profile_;
    QJsonArray catalog_;
    QTabWidget *tabs_ = nullptr;
    QTableWidget *queue_ = nullptr, *scheduled_ = nullptr, *library_ = nullptr;
    QTableWidget *battleSkills_ = nullptr;
    QLabel *battleVitals_ = nullptr, *battlePet_ = nullptr;
    QPushButton *battleRead_ = nullptr;
    QJsonObject battleView_;
    QComboBox *category_ = nullptr;
    QLineEdit *search_ = nullptr;
    QListWidget *taskSelector_ = nullptr, *categories_ = nullptr, *favorites_ = nullptr;
    QVBoxLayout *parameterLayout_ = nullptr;
    QTimeEdit *startTime_ = nullptr, *endTime_ = nullptr;
    QCheckBox *addScheduled_ = nullptr;
    QJsonObject runtimeStates_;
    QString lastRuntimeStatus_;
    bool lastReady_ = false, lastBusy_ = false;
    QJsonObject lastLive_;
    qint64 lastBytes_ = 0;
    QPlainTextEdit *logs_ = nullptr;
    QLabel *status_ = nullptr;
    QPushButton *start_ = nullptr, *pause_ = nullptr, *stop_ = nullptr;
    bool applying_ = false, tearingDown_ = false;
    QJsonObject parameters(const QString &id) const;
    void normalizeOriginalTasks();
    QWidget *editor(const QString &id, QJsonObject values, std::function<void(QJsonObject)> changed);
    QWidget *libraryPage();
    QWidget *parameterPage();
    QWidget *rulePage(const QString &section);
    QWidget *battlePage();
    void refreshBattle();
    void setBattleConfiguration(const QJsonObject &battle);
    QWidget *configForm(const QString &section, const QString &title, const QJsonArray &fields);
    QWidget *itemPage();
    QWidget *savePage();
    QWidget *queueBox(bool timed);
    void updateLibrary();
    void refreshFavorites();
    void setFavorite(const QString &id, bool enabled);
    void updateParameter();
    void editNode(bool timed);
    void changeNode(bool timed, const QString &action);
    void build();
    // Retained pre-0.5 builders while the new entry point is verified.
    void buildLegacy();
    void addLegacyTask(const QString &id);
    void refreshLegacyQueue();
    QWidget *taskPage(const QString &category);
    QWidget *legacyRulePage(const QString &section);
    void refreshQueue();
    void addTask(const QString &id, bool timed = false);
    QJsonArray enabledQueue() const;
};
} // namespace tlbb
