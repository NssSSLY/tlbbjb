#include "official_launcher.hpp"
#include "core.hpp"
#include <QCryptographicHash>
#include <QDateTime>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <cmath>

namespace tlbb {
bool officialSkinPoint(int width,int height,QPoint &point) {
    struct Profile{int width,height,x,y;};
    // Exact PE ZIP skin metadata. (1343,608) is inside BOTH main.xml's animated
    // start region and staticmain.xml's start region, not a guessed screen coordinate.
    for(const auto &p:{Profile{1470,787,1343,608},Profile{650,414,577,301}}){
        const double sx=double(width)/p.width,sy=double(height)/p.height;
        if(sx>=0.5&&sx<=2.0&&std::abs(sx-sy)<=0.006){point=QPoint(qRound(p.x*sx),qRound(p.y*sy));return true;}
    }
    point={};return false;
}
static bool updateFinished(const QString &root,quint32 pid,const QString &created){
    QFile file(root+"/Launch.log");if(!file.open(QIODevice::ReadOnly)||file.size()>16*1024*1024)return false;
    const auto createdMs=qint64(created.toULongLong()/10000ULL)-11644473600000LL;
    if(QFileInfo(file).lastModified().toMSecsSinceEpoch()+1000<createdMs)return false;
    if(file.size()>256*1024)file.seek(file.size()-256*1024);
    return launchLogUpdateFinished(file.read(256*1024),pid);
}
bool launchLogUpdateFinished(const QByteArray &log,quint32 pid){
    // Launch.log pads the pid to five digits ("[04428|"); pids under 10000 never matched before.
    const QByteArray owner="["+QByteArray::number(pid).rightJustified(5,'0')+"|";
    for(const auto &line:log.split('\n'))if(line.contains(owner)&&line.contains("LaunchSystem::workThread exit running")&&line.contains("m_nUpdateExit : 2"))return true;
    return false;
}
QJsonObject tryOfficialStart(quint32 pid,const QString &created,const QString &root,bool issue){
    QJsonObject result{{"pid",int(pid)},{"identified",false},{"ready",false},{"issued",false}};
    HANDLE process=OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION|SYNCHRONIZE,FALSE,pid);
    if(!process){result.insert("phase","process_unavailable");return result;}
    const auto path=processPath(pid);const auto name=QFileInfo(path).fileName();
    const bool identity=processCreated(process)==created&&WaitForSingleObject(process,0)==WAIT_TIMEOUT
        &&(name.compare("Launch.exe",Qt::CaseInsensitive)==0||name.compare("Launch.bin",Qt::CaseInsensitive)==0)
        &&QFileInfo(path).canonicalPath().compare(QFileInfo(root).canonicalFilePath(),Qt::CaseInsensitive)==0;
    CloseHandle(process);if(!identity){result.insert("phase","identity_mismatch");return result;}
    result.insert("identified",true);
    struct Windows{DWORD pid;QVector<HWND> tops;HWND button=nullptr;} windows{pid,{},nullptr};
    EnumWindows([](HWND top,LPARAM value)->BOOL{auto &w=*reinterpret_cast<Windows*>(value);DWORD owner=0;GetWindowThreadProcessId(top,&owner);if(owner!=w.pid||!IsWindowVisible(top)||!IsWindowEnabled(top))return TRUE;w.tops.append(top);
        EnumChildWindows(top,[](HWND child,LPARAM value)->BOOL{auto &w=*reinterpret_cast<Windows*>(value);wchar_t cls[32]{},text[80]{};GetClassNameW(child,cls,32);if(_wcsicmp(cls,L"Button")||!IsWindowVisible(child)||!IsWindowEnabled(child))return TRUE;GetWindowTextW(child,text,80);const auto name=QString::fromWCharArray(text).remove('&').trimmed();if(name=="开始游戏"||name=="进入游戏"){w.button=child;return FALSE;}return TRUE;},value);return TRUE;},LPARAM(&windows));
    if(windows.button){result.insert("ready",true);result.insert("phase","standard_start_ready");if(issue){DWORD_PTR sent=0;SetLastError(0);const bool delivered=SendMessageTimeoutW(windows.button,BM_CLICK,0,0,SMTO_ABORTIFHUNG|SMTO_BLOCK,250,&sent)!=0;result.insert("issued",true);result.insert("delivery_confirmed",delivered);result.insert("win32_error",int(delivered?0:GetLastError()));}return result;}
    static QHash<QString,QPair<QString,QByteArray>> fingerprints;
    const QFileInfo info(path);const QString revision=QString::number(info.size())+"/"+QString::number(info.lastModified().toMSecsSinceEpoch());
    if(!fingerprints.contains(path)||fingerprints.value(path).first!=revision){QFile image(path);QCryptographicHash hash(QCryptographicHash::Sha256);if(!image.open(QIODevice::ReadOnly)||!hash.addData(&image)){result.insert("phase","launcher_image_unreadable");return result;}if(fingerprints.size()>=16)fingerprints.clear();fingerprints.insert(path,{revision,hash.result().toHex()});}
    if(fingerprints.value(path).second!=officialLauncherSha256){result.insert("phase","unsupported_launcher_skin");return result;}
    if(!updateFinished(root,pid,created)){result.insert("phase","waiting_official_update");return result;}
    HWND target=nullptr;QPoint point;
    for(HWND window:windows.tops){RECT rect{};QPoint candidate;if(GetClientRect(window,&rect)&&officialSkinPoint(rect.right,rect.bottom,candidate)){if(target){result.insert("phase","ambiguous_launcher_windows");return result;}target=window;point=candidate;result.insert("client_width",int(rect.right));result.insert("client_height",int(rect.bottom));}}
    if(!target){result.insert("phase","skin_window_not_ready");return result;}
    result.insert("ready",true);result.insert("phase","verified_skin_start_ready");
    if(issue){
        // These messages use the launcher's own client coordinate space. They never call
        // SendInput, SetCursorPos or change the user's foreground input target.
        const LPARAM location=MAKELPARAM(point.x(),point.y());
        const bool move=PostMessageW(target,WM_MOUSEMOVE,0,location);
        const bool down=move&&PostMessageW(target,WM_LBUTTONDOWN,MK_LBUTTON,location);
        const bool up=down&&PostMessageW(target,WM_LBUTTONUP,0,location);
        result.insert("issued",down);result.insert("delivery_confirmed",up);result.insert("win32_error",int(up?0:GetLastError()));
    }
    return result;
}
}
