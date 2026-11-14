#pragma once
#include "combat_world.hpp"
#include <vector>
#include <set>
namespace tlbb::combat {
// Current image RTTI COLs d618c8/d61b48/d624e8, all primary subobjects.
// Reference 180133810 reads common position +4c/+54 and maps Special to traps.
inline uintptr_t selfVtable=0xc37d28,otherVtable=0xc3b748,specialVtable=0xc3f298,lootVtable=0xc3fa28;
// CTripperObject_Resource (RTTI COL d61fc0): ore / herb spots and farm fields (原脚本“矿地”).
// +0x140 points to its resource definition: +0x08 GBK name (铜矿, 晚产彩棉（生长中）), +0x2c type
// (710000 ore; 711001 growing, 711002 ripe crop). Read live 2026-11-09 on 苏州 fields and 镜湖 ore.
inline uintptr_t resourceVtable=0xc40688;
inline uintptr_t inputGlobal=0x105c608,inputVtable=0xb27618,openLootFunction=0x225170;
struct Mechanism {int client=-1,server=-1,kind=0;float x=0,y=0;uintptr_t object=0;}; // 1 other player, 2 trap, 3 ItemBox
// Loot is a separate selection: existing trap/player consumers never see kind 3.
template<class Read> bool mechanismSnapshot(Read read,uintptr_t base,uintptr_t self,std::vector<Mechanism> &out,int mode=0){ // mode 0 players and traps, 1 loot, 2 every object (kind 4)
    out.clear();auto get=[&](uintptr_t at,auto &v){return read(at,&v,sizeof(v));};
    uintptr_t manager=0,vt=0,player=0,head=0,root=0;uint64_t count=0;
    if(!get(base+managerGlobal,manager)||!get(manager,vt)||vt!=base+managerVtable||!get(manager+0x108,player)||player!=self
        ||!get(player,vt)||vt!=base+selfVtable||!get(manager+0xe0,head)||!head||!get(manager+0xe8,count)||count>512||!get(head+8,root))return false;
    uint8_t sentinel=0;if(!get(head+25,sentinel)||sentinel!=1)return false;
    std::vector<uintptr_t> pending;std::set<uintptr_t> seen;std::set<int> ids;if(root!=head)pending.push_back(root);
    while(!pending.empty()){
        const auto at=pending.back();pending.pop_back();
        struct Node{uintptr_t left,parent,right;uint8_t color,nil,pad[6];int key,pad2;uintptr_t object;}n{};
        static_assert(sizeof(Node)==48);
        if(!at||!seen.insert(at).second||seen.size()>count||!read(at,&n,sizeof(n))||n.nil||n.key<0||!ids.insert(n.key).second)return false;
        for(auto child:{n.left,n.right})if(child!=head){if(pending.size()>=64)return false;pending.push_back(child);}
        if(!get(n.object,vt))return false;
        const int kind=mode==2?4:mode==1?(vt==base+lootVtable?3:0):(vt==base+otherVtable?1:vt==base+specialVtable?2:0);if(!kind)continue;
        Mechanism o;o.kind=kind;o.object=n.object;uint8_t removed=0;float xyz[3]{};
        if(!get(n.object+0x28,o.client)||o.client!=n.key||o.client<0||!get(n.object+0x2c,o.server)
            ||!get(n.object+0x48,removed)||!read(n.object+0x4c,xyz,sizeof(xyz)))return false;
        if(removed)continue;
        o.x=xyz[0];o.y=xyz[2];
        if(o.server<(kind==1?0:-1)||!std::isfinite(o.x)||!std::isfinite(o.y)||std::abs(o.x)>100000||std::abs(o.y)>100000)return false;
        uintptr_t still=0,objectAgain=0;int clientAgain=-1,serverAgain=-2;uint8_t removedAgain=0;
        if(!get(n.object,still)||still!=vt||!get(at+40,objectAgain)||objectAgain!=n.object||!get(n.object+0x28,clientAgain)||clientAgain!=o.client
            ||!get(n.object+0x2c,serverAgain)||serverAgain!=o.server||!get(n.object+0x48,removedAgain)||removedAgain)return false;
        out.push_back(o);
    }
    uintptr_t again=0;uint64_t countAgain=0;
    return seen.size()==count&&get(manager+0xe0,again)&&again==head&&get(head+8,again)&&again==root
        &&get(manager+0xe8,countAgain)&&countAgain==count&&get(manager+0x108,again)&&again==self;
}
// Current CGameInterface +110 sends the original OpenPackage(client, true).
// Resolve only a current ItemBox pair within interaction range, never a caller address.
template<class Read> bool lootOpenReady(Read read,uintptr_t base,uintptr_t self,uintptr_t input,int client,int server,bool anyObject=false){
    if(client<0||server<-1)return false;
    auto get=[&](uintptr_t at,auto &v){return read(at,&v,sizeof(v));};
    uintptr_t current=0,vt=0,fn=0;float pos[3]{};
    if(!get(base+inputGlobal,current)||current!=input||!get(input,vt)||vt!=base+inputVtable
        ||!get(vt+0x110,fn)||fn!=base+openLootFunction||!read(self+0x4c,pos,sizeof(pos))
        ||!std::isfinite(pos[0])||!std::isfinite(pos[2]))return false;
    std::vector<Mechanism> rows;if(!mechanismSnapshot(read,base,self,rows,anyObject?2:1))return false;
    for(const auto &o:rows)if(o.client==client&&o.server==server)
        return std::hypot(double(o.x-pos[0]),double(o.y-pos[2]))<=4;
    return false;
}
}
