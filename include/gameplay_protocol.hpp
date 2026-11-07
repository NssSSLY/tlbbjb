#pragma once
#include "game_snippets.hpp"
#include <windows.h>
#include <cstdint>
#include <cwchar>
namespace tlbb::gameplay {
inline constexpr wchar_t messageName[]=L"TLBBClient.Gameplay.v2.20261025";
inline constexpr uint32_t magic=0x31504c54;
enum Command:uint32_t { Query=1,DailySign=2,ClaimMonthlyReward=3,CloseMonthly=4,RunSnippet=5 };
enum Status:LONG { Pending=0,Executing=1,Done=2,Rejected=3,Cancelled=4 };
struct Packet {
    uint32_t marker=magic,version=2,bytes=sizeof(Packet),command=Query;
    uint32_t targetPid=0,ownerPid=0,targetThread=0,executedThread=0;
    uint64_t created=0,nonce=0,expires=0;
    volatile LONG status=Pending;
    uint32_t error=0,actionIssued=0,argument=0,frameKind=0,frameVisible=0,stateReady=0;
    uint32_t today=0,signedToday=0,signedDays=0,manual=0;
    wchar_t detail[97]{};
    // RunSnippet: argument is the snippet id. Results are the snippet's first values.
    SnippetArgs args;
    uint32_t resultCount=0;
    double results[8]{};
    wchar_t resultText[513]{};
};
inline bool validCommand(uint32_t command,uint32_t argument){
    if(command==RunSnippet)return argument>=1&&argument<=SnippetLast;
    return command>=Query&&command<=CloseMonthly&&(command==ClaimMonthlyReward?(argument>=1&&argument<=5):argument==0);
}
inline void mappingName(wchar_t (&out)[128],DWORD pid,uint64_t nonce){
    std::swprintf(out,128,L"Local\\TLBBClient-Gameplay-%lu-%016llx",static_cast<unsigned long>(pid),static_cast<unsigned long long>(nonce));
}
inline void cancelPending(Packet &packet,DWORD error=WAIT_TIMEOUT){
    if(InterlockedCompareExchange(&packet.status,Cancelled,Pending)==Pending)packet.error=error;
}
}
