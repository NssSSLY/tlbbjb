#pragma once
// Finds every build-specific address in Game.exe itself, so a game update does not need a new release.
// Read from the file on disk (code and constant data are the same as in memory). Each address has its own evidence:
// RTTI class names for vtables, machine code for functions, slots in a known vtable, and for globals a fixed position
// relative to the object table that must also be a heavily referenced global. Anything that does not check out stops
// with a named reason instead of guessing. docs/GAME_UPDATE_2026-11-07.md has the method.
#include "live_layout.hpp"
#include "mechanism_world.hpp"
#include <cstdint>
#include <cstring>
#include <string>
#include <vector>
#include <windows.h>

namespace tlbb::layout {
struct Image {
    struct Section { char name[9]{}; uint32_t va = 0, vsize = 0, raw = 0, rsize = 0; };
    std::vector<unsigned char> bytes;
    std::vector<Section> sections;
    uint64_t imageBase = 0;
    const Section *find(const char *name) const {
        for (const auto &s : sections) if (!std::strcmp(s.name, name)) return &s;
        return nullptr;
    }
    // Pointer to rva..rva+n inside the file, or nullptr.
    const unsigned char *at(uint64_t rva, size_t n) const {
        for (const auto &s : sections)
            if (rva >= s.va && rva + n <= uint64_t(s.va) + s.rsize && uint64_t(s.raw) + (rva - s.va) + n <= bytes.size())
                return bytes.data() + s.raw + (rva - s.va);
        return nullptr;
    }
    template <class T> bool get(uint64_t rva, T &v) const {
        const auto *p = at(rva, sizeof(T));
        if (!p) return false;
        std::memcpy(&v, p, sizeof(T));
        return true;
    }
};

inline bool load(const wchar_t *path, Image &out, std::string &error) {
    HANDLE file = CreateFileW(path, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, nullptr, OPEN_EXISTING, 0, nullptr);
    if (file == INVALID_HANDLE_VALUE) { error = "cannot open Game.exe"; return false; }
    LARGE_INTEGER size{};
    bool ok = GetFileSizeEx(file, &size) && size.QuadPart > 0x1000 && size.QuadPart < 128LL * 1024 * 1024;
    if (ok) {
        out.bytes.resize(size_t(size.QuadPart));
        size_t done = 0;
        while (ok && done < out.bytes.size()) {
            DWORD got = 0;
            const DWORD chunk = DWORD(std::min<size_t>(out.bytes.size() - done, 1u << 24));
            ok = ReadFile(file, out.bytes.data() + done, chunk, &got, nullptr) && got > 0;
            done += got;
        }
    }
    CloseHandle(file);
    if (!ok) { error = "cannot read Game.exe"; return false; }
    const auto &b = out.bytes;
    uint32_t pe = 0;
    std::memcpy(&pe, b.data() + 0x3c, 4);
    if (pe + 0x108 > b.size() || std::memcmp(b.data() + pe, "PE\0\0", 4)) { error = "Game.exe is not a PE image"; return false; }
    uint16_t count = 0, optional = 0, magic = 0;
    std::memcpy(&count, b.data() + pe + 6, 2);
    std::memcpy(&optional, b.data() + pe + 20, 2);
    std::memcpy(&magic, b.data() + pe + 24, 2);
    if (magic != 0x20b || count == 0 || count > 32) { error = "Game.exe is not a 64-bit image"; return false; }
    std::memcpy(&out.imageBase, b.data() + pe + 24 + 24, 8);
    for (uint16_t i = 0; i < count; ++i) {
        const size_t o = pe + 24 + optional + i * 40u;
        if (o + 40 > b.size()) { error = "section table truncated"; return false; }
        Image::Section s;
        std::memcpy(s.name, b.data() + o, 8);
        std::memcpy(&s.vsize, b.data() + o + 8, 4);
        std::memcpy(&s.va, b.data() + o + 12, 4);
        std::memcpy(&s.rsize, b.data() + o + 16, 4);
        std::memcpy(&s.raw, b.data() + o + 20, 4);
        out.sections.push_back(s);
    }
    return true;
}

struct Result {
    uint64_t objectGlobal = 0, worldGlobal = 0, inputGlobal = 0, relationGlobal = 0, luaGlobal = 0, serverManagerGlobal = 0;
    uint64_t positionFunction = 0, moveFunction = 0, openLootFunction = 0, serverInfoFunction = 0;
    uint64_t managerVtable = 0, npcVtable = 0, selfVtable = 0, otherVtable = 0, specialVtable = 0, lootVtable = 0, inputVtable = 0;
};

// Vtable of a class by its RTTI name: type descriptor -> complete object locator (offset 0) -> the slot after it.
inline uint64_t vtableOf(const Image &img, const char *name) {
    const auto *data = img.find(".data");
    const auto *rdata = img.find(".rdata");
    if (!data || !rdata) return 0;
    const size_t len = std::strlen(name) + 1;
    uint64_t td = 0;
    for (const auto *s : {data, rdata}) {
        const auto *p = img.bytes.data() + s->raw;
        for (uint32_t i = 16; i + len <= s->rsize; ++i)
            if (p[i] == '.' && !std::memcmp(p + i, name, len)) { td = uint64_t(s->va) + i - 16; break; }
        if (td) break;
    }
    if (!td) return 0;
    uint64_t col = 0;
    const auto *r = img.bytes.data() + rdata->raw;
    for (uint32_t i = 0; i + 24 <= rdata->rsize; i += 4) {
        uint32_t sig, off, td2, self;
        std::memcpy(&sig, r + i, 4);
        if (sig != 1) continue;
        std::memcpy(&off, r + i + 4, 4);
        std::memcpy(&td2, r + i + 12, 4);
        std::memcpy(&self, r + i + 20, 4);
        if (off == 0 && td2 == td && self == rdata->va + i) { col = rdata->va + i; break; }
    }
    if (!col) return 0;
    const uint64_t want = img.imageBase + col;
    uint64_t found = 0;
    for (uint32_t i = 0; i + 16 <= rdata->rsize; i += 8) {
        uint64_t v;
        std::memcpy(&v, r + i, 8);
        if (v == want) {
            if (found) return 0; // a second primary vtable for the same locator: not something to guess between
            found = rdata->va + i + 8;
        }
    }
    return found;
}

// RIP-relative references from code to each of the given addresses (mov/lea/cmp/store forms).
inline void referenceCounts(const Image &img, const uint64_t *targets, size_t n, unsigned *counts) {
    for (size_t k = 0; k < n; ++k) counts[k] = 0;
    const auto *text = img.find(".text");
    if (!text) return;
    const auto *t = img.bytes.data() + text->raw;
    for (uint32_t i = 0; i + 7 <= text->rsize; ++i) {
        if ((t[i] != 0x48 && t[i] != 0x4c) || (t[i + 2] & 0xc7) != 0x05) continue;
        const unsigned char op = t[i + 1];
        if (op != 0x8b && op != 0x8d && op != 0x89 && op != 0x39 && op != 0x3b && op != 0x83 && op != 0xc7) continue;
        int32_t disp;
        std::memcpy(&disp, t + i + 3, 4);
        const uint64_t target = uint64_t(text->va) + i + 7 + int64_t(disp);
        for (size_t k = 0; k < n; ++k) if (target == targets[k]) ++counts[k];
    }
}

inline bool resolve(const Image &img, Result &r, std::string &error) {
    const auto *text = img.find(".text");
    if (!text) { error = "no code section"; return false; }
    const auto *t = img.bytes.data() + text->raw;
    // Player position: the world manager's getter reads the object table and copies +4c/+50/+54.
    static const unsigned char tail[] = {0x48,0x8b,0x88,0x08,0x01,0x00,0x00,0x8b,0x41,0x4c,0x89,0x02,0x8b,0x41,0x50,0x89,0x42,0x04,0x8b,0x41,0x54,0x89,0x42,0x08,0x48,0x8b,0xc2,0xc3};
    unsigned hits = 0;
    for (uint32_t i = 0; i + 7 + sizeof(tail) <= text->rsize; ++i) {
        if (t[i] != 0x48 || t[i + 1] != 0x8b || t[i + 2] != 0x05 || std::memcmp(t + i + 7, tail, sizeof(tail))) continue;
        int32_t disp;
        std::memcpy(&disp, t + i + 3, 4);
        r.positionFunction = text->va + i;
        r.objectGlobal = text->va + i + 7 + int64_t(disp);
        ++hits;
    }
    if (hits != 1) { error = "position function not found (" + std::to_string(hits) + " matches)"; return false; }
    struct Named { uint64_t *slot; const char *name; };
    const Named classes[] = {
        {&r.managerVtable, ".?AVCObjectManager@@"}, {&r.npcVtable, ".?AVCObject_PlayerNPC@@"}, {&r.selfVtable, ".?AVCObject_PlayerMySelf@@"},
        {&r.otherVtable, ".?AVCObject_PlayerOther@@"}, {&r.specialVtable, ".?AVCObject_Special@@"}, {&r.lootVtable, ".?AVCTripperObject_ItemBox@@"},
        {&r.inputVtable, ".?AVCGameInterface@@"}};
    for (const auto &c : classes) {
        *c.slot = vtableOf(img, c.name);
        if (!*c.slot) { error = std::string("class ") + c.name + " not found"; return false; }
    }
    // Moving and opening a parcel are the game interface's own slots.
    uint64_t move = 0, loot = 0;
    if (!img.get(r.inputVtable + 0xa8, move) || !img.get(r.inputVtable + 0x110, loot) || move <= img.imageBase || loot <= img.imageBase) {
        error = "game interface slots unreadable"; return false;
    }
    r.moveFunction = move - img.imageBase;
    r.openLootFunction = loot - img.imageBase;
    static const unsigned char moveHead[] = {0x41, 0xb8, 0x01, 0x00, 0x00, 0x00, 0xe9};
    const auto *m = img.at(r.moveFunction, sizeof(moveHead));
    if (!m || std::memcmp(m, moveHead, sizeof(moveHead))) { error = "move function changed shape"; return false; }
    // Server entry: the current-server getter calls it as (manager, area, server).
    static const unsigned char call[] = {0x44, 0x8b, 0x43, 0x64, 0x41, 0x8b, 0xd1, 0x48, 0x8b, 0xcb, 0xe8};
    unsigned calls = 0;
    for (uint32_t i = 0; i + sizeof(call) + 4 <= text->rsize; ++i) {
        if (std::memcmp(t + i, call, sizeof(call))) continue;
        int32_t rel;
        std::memcpy(&rel, t + i + sizeof(call), 4);
        const uint64_t target = text->va + i + sizeof(call) + 4 + int64_t(rel);
        if (calls && target != r.serverInfoFunction) { error = "server entry calls disagree"; return false; }
        r.serverInfoFunction = target;
        ++calls;
    }
    if (!calls) { error = "server entry function not found"; return false; }
    // Globals around the object table. Both builds seen so far keep these distances; each must also be a real,
    // much-used global in this image, so a reshuffled data section stops here rather than reading the wrong thing.
    struct Global { uint64_t *slot; int64_t offset; const char *name; };
    const Global globals[] = {{&r.inputGlobal, 0xbd8, "input"}, {&r.worldGlobal, 0x3198, "world"}, {&r.relationGlobal, -0x7b78, "relation"},
                              {&r.luaGlobal, -0x60c0, "game Lua"}, {&r.serverManagerGlobal, 0xb38, "server list"}};
    uint64_t targets[5];
    unsigned counts[5];
    for (size_t k = 0; k < 5; ++k) targets[k] = *globals[k].slot = uint64_t(int64_t(r.objectGlobal) + globals[k].offset);
    referenceCounts(img, targets, 5, counts);
    for (size_t k = 0; k < 5; ++k)
        if (counts[k] < 20) { error = std::string(globals[k].name) + " global moved (" + std::to_string(counts[k]) + " references)"; return false; }
    return true;
}

inline void apply(const Result &r) {
    live::objectGlobal = r.objectGlobal; live::worldGlobal = r.worldGlobal; live::inputGlobal = r.inputGlobal;
    live::positionFunction = r.positionFunction; live::moveFunction = r.moveFunction;
    live::relationGlobal = r.relationGlobal; live::luaGlobal = r.luaGlobal; live::serverManagerGlobal = r.serverManagerGlobal;
    live::serverInfoFunction = r.serverInfoFunction;
    combat::managerGlobal = r.objectGlobal; combat::managerVtable = r.managerVtable; combat::npcVtable = r.npcVtable;
    combat::selfVtable = r.selfVtable; combat::otherVtable = r.otherVtable; combat::specialVtable = r.specialVtable;
    combat::lootVtable = r.lootVtable; combat::inputGlobal = r.inputGlobal; combat::inputVtable = r.inputVtable;
    combat::openLootFunction = r.openLootFunction;
    live::resolved = true;
}

// Once per process and Game.exe file (size and write time); a re-run after an update resolves again.
inline bool ensure(const wchar_t *path, std::string &error) {
    static std::wstring lastPath;
    static uint64_t lastStamp = 0;
    WIN32_FILE_ATTRIBUTE_DATA info{};
    if (!GetFileAttributesExW(path, GetFileExInfoStandard, &info)) { error = "cannot read Game.exe"; return false; }
    const uint64_t stamp = (uint64_t(info.ftLastWriteTime.dwHighDateTime) << 32 | info.ftLastWriteTime.dwLowDateTime) ^ (uint64_t(info.nFileSizeHigh) << 32 | info.nFileSizeLow);
    if (live::resolved && lastPath == path && lastStamp == stamp) return true;
    Image img;
    Result r;
    if (!load(path, img, error) || !resolve(img, r, error)) { live::resolved = false; return false; }
    apply(r);
    lastPath = path;
    lastStamp = stamp;
    return true;
}
// Inside the game process: its own executable.
inline bool ensureSelf(std::string &error) {
    wchar_t path[32768]{};
    const DWORD n = GetModuleFileNameW(nullptr, path, 32768);
    if (n == 0 || n >= 32768) { error = "module path unavailable"; return false; }
    return ensure(path, error);
}
// Resolved, and the code in memory matches what was resolved from the file.
inline bool ready(uintptr_t base) {
    std::string error;
    return ensureSelf(error) && live::signature(GetCurrentProcess(), base);
}
} // namespace tlbb::layout
