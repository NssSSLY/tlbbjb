#pragma once
#include <windows.h>
#include <cstdint>
#include <cwchar>
namespace tlbb::resident {
inline constexpr wchar_t messageName[]=L"TLBBClient.Resident.v2.20261025";
inline constexpr uint32_t magic=0x31524c54;
// Generic original tasks carry their framework modules; 2 MiB keeps the largest closure with headroom.
inline constexpr size_t payloadCapacity=2*1024*1024;
enum Command:uint32_t{Start=1,Poll=2,Pause=3,Resume=4,Stop=5};
struct Packet{
    uint32_t marker=magic,version=3,bytes=sizeof(Packet),command=Poll,targetPid=0,ownerPid=0,targetThread=0,executedThread=0;
    uint64_t created=0,nonce=0,expires=0,session=0;
    volatile LONG status=0; // 0 pending, 1 executing, 2 done, 3 error, 4 cancelled
    uint32_t state=0,timeoutSeconds=600,allowFlags=0,combat=0,sourceBytes=0;
    uint64_t luaBytes=0,nativeCalls=0,rawCalls=0,ticks=0;
    uint32_t kills=0,boss=0,ipcRequests=0;
    char error[512]{},log[4096]{};
    char battle[64*1024]{};
    char source[payloadCapacity]{};
};
inline void mappingName(wchar_t (&out)[128],DWORD pid,uint64_t nonce){std::swprintf(out,128,L"Local\\TLBBClient-Resident-%lu-%016llx",static_cast<unsigned long>(pid),static_cast<unsigned long long>(nonce));}
}
