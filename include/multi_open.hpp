#pragma once
// Game.exe allows two clients per machine: at start it tries to create
// Global\A292F57D-84FD-4465-9A03-0C8232E731AA_0 and _1 and shows
// “因为您运行的客户端过多,导致资源不足,无法启动!” when both already exist (Game.exe 3.72, 0x6a4b60).
// With 允许多开 checked, the launcher closes those two mutex handles inside the already running
// Game.exe processes before starting another one, so the next client can take a free slot.
// Only Mutant handles whose name carries that GUID are touched; nothing else in the game changes.
#include <windows.h>
#include <tlhelp32.h>
#include <QList>
#include <QString>
#include <vector>
#include <string>
#include <cwchar>
namespace tlbb::multi_open {
namespace detail {
struct HandleEntry{PVOID object;ULONG_PTR pid;ULONG_PTR handle;ULONG access;USHORT creatorBackTrace;USHORT typeIndex;ULONG attributes;ULONG reserved;};
struct HandleTable{ULONG_PTR count;ULONG_PTR reserved;HandleEntry handles[1];};
struct UnicodeName{USHORT length;USHORT maximum;PWSTR buffer;};
using QuerySystem=LONG(NTAPI*)(ULONG,PVOID,ULONG,PULONG);
using QueryObject=LONG(NTAPI*)(HANDLE,ULONG,PVOID,ULONG,PULONG);
inline constexpr wchar_t guid[]=L"A292F57D-84FD-4465-9A03-0C8232E731AA_";
inline bool snapshot(QuerySystem query,std::vector<unsigned char> &buffer){
    ULONG size=1<<20;
    for(int i=0;i<8;++i){buffer.resize(size);ULONG need=0;const LONG status=query(64/*SystemExtendedHandleInformation*/,buffer.data(),size,&need);
        if(status>=0)return true;
        if(status!=LONG(0xC0000004))return false; // STATUS_INFO_LENGTH_MISMATCH
        size=need>size?need+(1<<16):size*2;}
    return false;
}
}
// Returns how many limit mutexes were released; detail explains a failure.
inline int releaseInstanceLimit(const QList<quint32> &gamePids,QString &detail){
    using namespace detail;
    if(gamePids.isEmpty())return 0;
    auto ntdll=GetModuleHandleW(L"ntdll.dll");
    auto querySystem=reinterpret_cast<QuerySystem>(GetProcAddress(ntdll,"NtQuerySystemInformation"));
    auto queryObject=reinterpret_cast<QueryObject>(GetProcAddress(ntdll,"NtQueryObject"));
    if(!querySystem||!queryObject){detail="系统接口不可用";return 0;}
    // Our own unnamed mutex tells the Mutant type index on this Windows build.
    HANDLE probe=CreateMutexW(nullptr,FALSE,nullptr);if(!probe){detail="无法创建探测互斥量";return 0;}
    std::vector<unsigned char> buffer;
    if(!snapshot(querySystem,buffer)){CloseHandle(probe);detail="无法读取系统句柄表";return 0;}
    auto *table=reinterpret_cast<HandleTable*>(buffer.data());
    USHORT mutant=0;const ULONG_PTR self=GetCurrentProcessId();
    for(ULONG_PTR i=0;i<table->count;++i){const auto &e=table->handles[i];if(e.pid==self&&e.handle==ULONG_PTR(probe)){mutant=e.typeIndex;break;}}
    CloseHandle(probe);
    if(!mutant){detail="无法识别互斥量类型";return 0;}
    int released=0,denied=0;
    for(quint32 pid:gamePids){
        HANDLE process=OpenProcess(PROCESS_DUP_HANDLE,FALSE,pid);if(!process){++denied;continue;}
        for(ULONG_PTR i=0;i<table->count;++i){
            const auto &e=table->handles[i];if(e.pid!=pid||e.typeIndex!=mutant)continue;
            HANDLE copy=nullptr;
            if(!DuplicateHandle(process,HANDLE(e.handle),GetCurrentProcess(),&copy,0,FALSE,DUPLICATE_SAME_ACCESS))continue;
            alignas(8) unsigned char name[1024]{};ULONG got=0;bool match=false;
            if(queryObject(copy,1/*ObjectNameInformation*/,name,sizeof(name)-2,&got)>=0){
                auto *u=reinterpret_cast<UnicodeName*>(name);
                if(u->buffer&&u->length){std::wstring text(u->buffer,u->length/2);match=text.find(guid)!=std::wstring::npos;}
            }
            CloseHandle(copy);
            if(match&&DuplicateHandle(process,HANDLE(e.handle),nullptr,nullptr,0,FALSE,DUPLICATE_CLOSE_SOURCE))++released;
        }
        CloseHandle(process);
    }
    if(denied&&!released)detail=QString("有 %1 个游戏进程无权访问（游戏以管理员身份运行时，本程序也需以管理员身份运行）").arg(denied);
    return released;
}
}
