#pragma once
#include <QDateTime>
#include <QHash>
#include <QJsonArray>
#include <QJsonObject>

namespace tlbb {
// One owner per game. Polling selects at most one node; completion releases it.
class FlowRunner {
  public:
    static bool validate(const QJsonObject &plan, QString &error, bool allowEmpty = false);
    // Removes a completed scheduled node by its stable node_id; fields added at run time or edited while it
    // ran do not keep it in the list. A node without an id is never matched.
    static QJsonArray withoutNode(QJsonArray nodes, const QJsonObject &completed) {
        const auto id = completed.value("node_id").toString();
        if (id.isEmpty()) return nodes;
        for (int i = nodes.size() - 1; i >= 0; --i) if (nodes[i].toObject().value("node_id").toString() == id) nodes.removeAt(i);
        return nodes;
    }
    bool start(const QJsonObject &plan, QString &error);
    void setJournalPath(const QString &path) { if(path!=journalPath_){journal_={};claimed_.clear();} journalPath_=path; }
    QString journalError() const { return journalError_; }
    QJsonObject poll(const QDateTime &now);
    QJsonObject finish(bool success,const QString &outcome = {});
    void stop();
    void pause(bool value) { paused_ = value; }
    bool paused() const { return paused_; }
    bool active() const { return active_; }
    bool busy() const { return !current_.isEmpty(); }
    QJsonObject states() const { return states_; }
    QJsonObject current() const { return current_; }
    bool deleteCompleted() const { return options_.value("delete_completed").toBool(); }
    QString status() const;
  private:
    QJsonArray queue_, scheduled_;
    QJsonObject options_, current_, states_;
    QHash<QString,QDate> claimed_;
    QString journalPath_,journalError_;
    QJsonObject journal_;
    bool persistJournal();
    int next_ = 0, round_ = 1;
    bool active_ = false, paused_ = false;
};
} // namespace tlbb
