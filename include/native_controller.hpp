#pragma once
#include <QJsonObject>
#include <QStringList>
namespace tlbb {
QJsonObject bridgeCommand(quint32 pid, const QString &created, const QString &root, const QString &dll,
                          quint32 command, float x = 0, float y = 0, bool fixture = false);
int runNativeCommand(const QStringList &arguments);
int runBridgeFixture();
} // namespace tlbb
