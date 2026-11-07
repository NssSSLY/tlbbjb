#pragma once
#include "combat_world.hpp"
#include "mechanism_world.hpp"
#include <vector>
#include <set>
namespace tlbb::combat {
// Current Game.exe: 5ecd80 (lookup), 5edb40 (+188 size), 61f600
// (enumerate IDs -> DB 1062cc8). The reference uses the same +180 tree.
// Read-only; caller first checks image hash and resolves a client/server pair.
template<class Read> bool buffIds(Read read,uintptr_t object,std::vector<int> &ids){
    ids.clear();auto get=[&](uintptr_t at,auto &v){return read(at,&v,sizeof(v));};
    uintptr_t head=0,root=0;uint64_t count=0;
    if(!get(object+0x180,head)||!head||!get(object+0x188,count)||count>256||!get(head+8,root))return false;
    struct Node{uintptr_t left,parent,right;uint8_t color,nil,pad[6];int key,pad2;};
    static_assert(sizeof(Node)==40);
    uint8_t sentinel=0;if(!get(head+25,sentinel)||sentinel!=1)return false;
    std::vector<uintptr_t> pending;if(root!=head)pending.push_back(root);std::set<uintptr_t> seen;std::set<int> unique;
    while(!pending.empty()){
        const auto at=pending.back();pending.pop_back();Node n{};
        if(!at||!seen.insert(at).second||seen.size()>count||!read(at,&n,sizeof(n))||n.nil||n.key<0)return false;
        if(!unique.insert(n.key).second)return false;
        ids.push_back(n.key);
        for(const auto child:{n.left,n.right})if(child!=head){if(pending.size()>=64)return false;pending.push_back(child);}
    }
    uintptr_t again=0,rootAgain=0;uint64_t sizeAgain=0;
    return seen.size()==count&&get(object+0x180,again)&&again==head&&get(head+8,rootAgain)&&rootAgain==root
        &&get(object+0x188,sizeAgain)&&sizeAgain==count;
}
// Resolve only self or a verified NPC/other player, never a foreign raw pointer.
template<class Read> uintptr_t buffObject(Read read,uintptr_t base,uintptr_t self,int client,int server){
    auto get=[&](uintptr_t at,auto &v){return read(at,&v,sizeof(v));};
    uintptr_t manager=0,vt=0,head=0,node=0;uint64_t count=0;
    if(!get(base+managerGlobal,manager)||!get(manager,vt)||vt!=base+managerVtable||!get(manager+0x108,node)||node!=self)return 0;
    if(client==-1&&server==-1)return self;
    if(client<0||server<0||!get(manager+0xe0,head)||!get(manager+0xe8,count)||count>512||!get(head+8,node))return 0;
    for(unsigned i=0;node!=head&&i<32;++i){
        int key=-1;uint8_t nil=0;uintptr_t object=0;
        if(!get(node+25,nil)||nil||!get(node+32,key))return 0;
        if(key!=client){if(!get(node+(client<key?0:16),node))return 0;continue;}
        int own=-1,sid=-1;uint8_t removed=0;
        if(!get(node+40,object)||!get(object,vt)||(vt!=base+npcVtable&&vt!=base+otherVtable)||!get(object+0x28,own)||own!=client
            ||!get(object+0x2c,sid)||sid!=server||!get(object+0x48,removed)||removed)return 0;
        return object;
    }
    return 0;
}
}
