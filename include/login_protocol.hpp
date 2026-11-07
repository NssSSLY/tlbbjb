#pragma once
#include <windows.h>
#include <cstdint>
#include <cwchar>
namespace tlbb::login {
inline constexpr wchar_t messageName[]=L"TLBBClient.LoginBridge.v1.20261024";
inline constexpr uint32_t magic=0x31474f4c;
enum Command:uint32_t { Query=1, SelectServer=2, SubmitAccount=3, SelectRole=4, EnterWorld=5, BackToServer=6, SetAccountMode=7 };
enum Stage:uint32_t { Loading=0, Server=1, Account=2, Roles=3, World=4, Manual=5 };
enum Status:LONG { Pending=0,Executing=1,Done=2,Rejected=3,Cancelled=4 };
struct Packet {
    uint32_t marker=magic,version=1,bytes=sizeof(Packet),command=Query;
    uint32_t targetPid=0,ownerPid=0,targetThread=0,executedThread=0;
    uint64_t created=0,nonce=0,expires=0;
    volatile LONG status=Pending;
    uint32_t error=0,stage=Loading,actionIssued=0,slot=1,matched=0,inputMode=0,selectedMatches=0;
    int32_t areaIndex=-1,serverIndex=-1;
    wchar_t district[129]{},server[129]{},roleNames[3][65]{},prompt[65]{};
    wchar_t currentDistrict[129]{},currentServer[129]{};
    char account[257]{},password[513]{};
};
inline void mappingName(wchar_t (&out)[128],DWORD pid,uint64_t nonce){
    std::swprintf(out,128,L"Local\\TLBBClient-Login-%lu-%016llx",static_cast<unsigned long>(pid),static_cast<unsigned long long>(nonce));
}
inline constexpr char ceguiSha256[]="3e83904bfc3c954e14ee528e0b687b05759044ced9352f7ed521fc55f982e575";
inline constexpr char luaPlusSha256[]="0cceb8bf054bbb3dba89d79915d76830f844c8bb8403ba694a96d40e12a32eb6";
inline bool cancelPending(Packet &packet,DWORD dispatchError=0){
    if(InterlockedCompareExchange(&packet.status,Cancelled,Pending)!=Pending)return false;
    packet.error=dispatchError?dispatchError:WAIT_TIMEOUT;
    return true;
}
inline bool transientQueryFailure(const Packet &packet){
    if(packet.command!=Query)return false;
    return ((packet.status==Cancelled||packet.status==Executing)&&packet.error==WAIT_TIMEOUT)||
           (packet.status==Rejected&&(packet.error==ERROR_MOD_NOT_FOUND||packet.error==WAIT_TIMEOUT));
}
inline bool sameDistrict(const wchar_t *left,const wchar_t *right){
    // The 0.3 UI omitted the separator in 网通-华北网通一区. Keep those saved profiles usable.
    for(;;){while(*left==L'-'||*left==L' '||*left==L'\t')++left;while(*right==L'-'||*right==L' '||*right==L'\t')++right;if(*left!=*right)return false;if(!*left)return true;++left;++right;}
}
}
