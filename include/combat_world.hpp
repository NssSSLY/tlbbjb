#pragma once
#include <cmath>
#include <cstdint>
#include <initializer_list>
namespace tlbb::combat {
// Hash-locked Game.exe ABI. Evidence: combat-research/{static-vtables,manager*,targethp}.
// Set per process by game_layout.hpp; defaults are the 2026-11-07 build for offline fixtures.
inline uintptr_t managerGlobal=0x105ba30,managerVtable=0xc2f8b8,npcVtable=0xc39918;
struct Target { int client=-1,server=-1;float hp=0,x=0,y=0;uintptr_t object=0; };
struct Scan { Target target;int status=1,enemies=0;double selfHp=0; };
inline double percent(float v){return v<=1?v*100:v;}
// Bounded DFS of the client-id tree (+e0/+e8). The separate +f0 tree is keyed by server id.
// Read and enemy are injected so corrupt trees, stale ids and player exclusion can be tested.
template<class Read,class Enemy>
bool scan(Read read,Enemy enemy,uintptr_t base,int preferred,int server,double x,double y,double radius,Scan &out){
    out={};uintptr_t manager=0,vt=0,player=0,head=0,root=0;uint64_t count=0;
    auto get=[&](uintptr_t at,auto &v){return read(at,&v,sizeof(v));};
    if(!get(base+managerGlobal,manager)||!get(manager,vt)||vt!=base+managerVtable||!get(manager+0x108,player)
       ||!get(manager+0xe0,head)||!get(manager+0xe8,count)||count>512||!get(head+8,root))return false;
    auto hp=[&](uintptr_t object,float &value){uintptr_t data=0,values=0;return get(object+0x228,data)&&get(data+8,values)&&get(values+8,value)&&std::isfinite(value)&&value>=0&&value<=100;};
    float self=0;if(!hp(player,self))return false;out.selfHp=percent(self);
    uintptr_t pending[64]{};int top=0,seen=0;double best=radius*radius;
    if(root!=head)pending[top++]=root;
    while(top){
        const auto node=pending[--top];if(node==head)continue;
        if(++seen>int(count)||seen>(preferred>=0?32:512))return false;
        struct Node{uintptr_t left,parent,right;uint8_t color,nil,pad[6];int32_t key,pad2;uintptr_t object;} n{};
        static_assert(sizeof(Node)==48);
        if(!read(node,&n,sizeof(n))||n.nil)return false;
        if(preferred>=0){
            // Revalidate an existing target with one tree lookup, rather than rescanning the scene per cast.
            if(n.key!=preferred){const auto child=preferred<n.key?n.left:n.right;if(child!=head){if(!child)return false;pending[top++]=child;}continue;}
        }else for(auto child:{n.left,n.right})if(child!=head){if(top>=64||!child)return false;pending[top++]=child;}
        if(!get(n.object,vt))return false;
        if(vt!=base+npcVtable||n.object==player)continue; // excludes players, pets, drops and scenery
        Target t;t.client=n.key;t.object=n.object;float pos[3]{};uint8_t removed=0;
        int client=-1;
        if(!get(n.object+0x28,client)||client!=t.client||!get(n.object+0x2c,t.server)||!get(n.object+0x48,removed)||!read(n.object+0x4c,pos,sizeof(pos))||!hp(n.object,t.hp))return false;
        t.x=pos[0];t.y=pos[2];if(!std::isfinite(t.x)||!std::isfinite(t.y)||t.client<0||t.server<0)return false;
        if(preferred>=0&&t.client==preferred&&t.server==server&&t.hp<=0){out.target=t;out.status=2;}
        if(removed||t.hp<=0)continue;
        const double d=(t.x-x)*(t.x-x)+(t.y-y)*(t.y-y);if(d>radius*radius)continue;
        const int hostile=enemy(player,n.object);if(hostile<0)return false;if(!hostile)continue;
        ++out.enemies;
        if(preferred>=0){if(t.client==preferred&&t.server==server){out.target=t;out.status=1;}}
        else if(d<=best){best=d;out.target=t;}
    }
    uintptr_t again=0;uint64_t countAgain=0;
    if((preferred<0&&seen!=int(count))||!get(manager+0xe0,again)||again!=head||!get(manager+0xe8,countAgain)||countAgain!=count||!get(manager+0x108,again)||again!=player)return false;
    if(preferred>=0&&out.target.client<0)out.status=3; // lost/reused id is never a confirmed kill
    return true;
}
}
