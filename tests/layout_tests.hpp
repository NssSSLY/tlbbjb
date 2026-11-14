#pragma once
#include "game_layout.hpp"
#include <QCryptographicHash>
#include <QFile>
namespace tlbb {
// Runs the address finder on the real Game.exe in the game folder next to the project.
template<class Test>void layoutTests(const QString &root,Test test){
    auto must=[](bool v,const std::string &s){if(!v)throw std::runtime_error(s);};
    test("game_layout_resolves_from_the_installed_game",[&]{
        const auto path=QDir::cleanPath(root+"/../Bin64/Game.exe");
        if(!QFile::exists(path))return; // no game here: nothing to check
        layout::Image img;layout::Result r;std::string why;
        must(layout::load(reinterpret_cast<const wchar_t*>(QDir::toNativeSeparators(path).utf16()),img,why),"load: "+why);
        must(layout::resolve(img,r,why),"resolve: "+why);
        QFile f(path);must(f.open(QIODevice::ReadOnly),"open");QCryptographicHash h(QCryptographicHash::Sha256);h.addData(&f);
        // The 2026-11-07 build was checked by hand; every automatic answer must agree with that.
        if(h.result().toHex()=="47d9d3ead930824347e63b07d521fc3af986f9a2597c4f3f6ecfcd536f7e6d9f"){
            const std::pair<uint64_t,uint64_t> expected[]={{r.objectGlobal,0x105ba30},{r.worldGlobal,0x105ebc8},{r.inputGlobal,0x105c608},{r.relationGlobal,0x1053eb8},
                {r.luaGlobal,0x1055970},{r.serverManagerGlobal,0x105c568},{r.positionFunction,0x6dae80},{r.moveFunction,0x224660},{r.openLootFunction,0x225170},
                {r.serverInfoFunction,0x635010},{r.managerVtable,0xc2f8b8},{r.npcVtable,0xc39918},{r.selfVtable,0xc37d28},{r.otherVtable,0xc3b748},
                {r.specialVtable,0xc3f298},{r.lootVtable,0xc3fa28},{r.inputVtable,0xb27618}};
            int i=0;for(const auto &e:expected){must(e.first==e.second,"address "+std::to_string(i)+" resolved to "+std::to_string(e.first));++i;}
        }
    });
    test("game_layout_rejects_a_file_that_is_not_the_game",[&]{
        layout::Image img;std::string why;
        const auto self=QCoreApplication::applicationFilePath();
        if(layout::load(reinterpret_cast<const wchar_t*>(QDir::toNativeSeparators(self).utf16()),img,why)){layout::Result r;must(!layout::resolve(img,r,why),"Client exe accepted as the game");}
    });
}
}
