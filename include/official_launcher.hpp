#pragma once
#include <QJsonObject>
#include <QPoint>
#include <QString>
#include <windows.h>
namespace tlbb {
inline constexpr char officialLauncherSha256[]="83aa071b3314bac9f734c396b395079e0c51470ebdaecc917e632df3120ace3d";
bool officialSkinPoint(int width,int height,QPoint &point);
// True when this Launch.log text has the given launcher pid's "update finished" line.
bool launchLogUpdateFinished(const QByteArray &log,quint32 pid);
// Called only for a process in the current launch chain. No global mouse/keyboard input.
QJsonObject tryOfficialStart(quint32 pid,const QString &created,const QString &root,bool issue);
}
