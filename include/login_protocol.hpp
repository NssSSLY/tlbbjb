#pragma once
#include <windows.h>
#include <cstdint>
#include <cwchar>
namespace tlbb::login {
inline constexpr wchar_t messageName[]=L"TLBBClient.LoginBridge.v1.20261024";
inline constexpr uint32_t magic=0x31474f4c;
enum Command:uint32_t { Query=1, SelectServer=2, SubmitAccount=3, SelectRole=4, EnterWorld=5, BackToServer=6, SetAccountMode=7, RetryLogon=8, DismissNotice=9 };
enum Stage:uint32_t { Loading=0, Server=1, Account=2, Roles=3, World=4, Manual=5 };
enum Status:LONG { Pending=0,Executing=1,Done=2,Rejected=3,Cancelled=4 };
struct Packet {
    uint32_t marker=magic,version=1,bytes=sizeof(Packet),command=Query;
    uint32_t targetPid=0,ownerPid=0,targetThread=0,executedThread=0;
    uint64_t created=0,nonce=0,expires=0;
    volatile LONG status=Pending;
    uint32_t error=0,stage=Loading,actionIssued=0,slot=1,matched=0,inputMode=0,selectedMatches=0;
    // Read back on the account screen: 1 when the box holds text. Never the text itself.
    uint32_t accountFilled=0,passwordFilled=0,pressRoute=0;
    // Manual stage: 1 when the shown prompt is a plain notice whose only button is 确定.
    uint32_t noticeOk=0;
    int32_t areaIndex=-1,serverIndex=-1;
    wchar_t district[129]{},server[129]{},roleNames[3][65]{},prompt[65]{};
    wchar_t currentDistrict[129]{},currentServer[129]{};
    char account[257]{},password[513]{};
};
inline void mappingName(wchar_t (&out)[128],DWORD pid,uint64_t nonce){
    std::swprintf(out,128,L"Local\\TLBBClient-Login-%lu-%016llx",static_cast<unsigned long>(pid),static_cast<unsigned long long>(nonce));
}
inline constexpr char ceguiSha256[]="4f3e8c74caf298b9c2a0533eeed74a2b0698a26b126edc1408ff30340ab1eaa5";
inline constexpr char luaPlusSha256[]="40a6283ef06b8ab615f8346f8f583a7c7806b742fedc54cabb3348ee872ef77b";
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
