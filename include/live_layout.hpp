#pragma once
#include <cmath>
#include <cstdint>
#include <cstring>
#include <windows.h>

namespace tlbb::live {
// Set from the game file by game_layout.hpp before any live use; defaults are the 2026-11-07 build for offline fixtures.
inline bool resolved = false;
inline uintptr_t objectGlobal = 0x105ba30, worldGlobal = 0x105ebc8, inputGlobal = 0x105c608,
                 positionFunction = 0x6dae80, moveFunction = 0x224660;
inline uintptr_t relationGlobal = 0x1053eb8, luaGlobal = 0x1055970, serverManagerGlobal = 0x105c568, serverInfoFunction = 0x635010;
struct Snapshot {
    float x = 0, height = 0, y = 0;
    int scene = -1;
    wchar_t map[129]{};
    uintptr_t player = 0, input = 0;
};
inline bool read(HANDLE process, uintptr_t address, void *buffer, size_t bytes) {
    if (address < 0x10000 || address >= 0x7fffffffffffULL || bytes > 4096)
        return false;
    SIZE_T actual = 0;
    return ReadProcessMemory(process, reinterpret_cast<void *>(address), buffer, bytes, &actual) &&
           actual == bytes;
}
template <typename T> inline bool get(HANDLE process, uintptr_t address, T &value) {
    return read(process, address, &value, sizeof(value));
}
inline bool signature(HANDLE process, uintptr_t base) {
    constexpr unsigned char position[] = {0x48, 0x8b, 0x05, 0x00, 0x00, 0x00, 0x00, 0x48, 0x8b,
                                          0x88, 0x08, 0x01, 0x00, 0x00, 0x8b, 0x41, 0x4c, 0x89,
                                          0x02, 0x8b, 0x41, 0x50, 0x89, 0x42, 0x04, 0x8b, 0x41,
                                          0x54, 0x89, 0x42, 0x08, 0x48, 0x8b, 0xc2, 0xc3};
    constexpr unsigned char move[] = {0x41, 0xb8, 0x01, 0x00, 0x00, 0x00, 0xe9};
    unsigned char p[sizeof(position)]{}, m[sizeof(move)]{};
    if (!read(process, base + positionFunction, p, sizeof(p)) || !read(process, base + moveFunction, m, sizeof(m)) ||
        std::memcmp(m, move, sizeof(m)) != 0 || std::memcmp(p, position, 3) != 0 || std::memcmp(p + 7, position + 7, sizeof(p) - 7) != 0)
        return false;
    // The displacement must point at the object table this process resolved.
    int32_t disp = 0;
    std::memcpy(&disp, p + 3, 4);
    return positionFunction + 7 + int64_t(disp) == objectGlobal;
}
inline bool snapshot(HANDLE process, uintptr_t base, Snapshot &out) {
    Snapshot result;
    uintptr_t objects = 0, world = 0, scene = 0, data = 0, table = 0, function = 0;
    float coordinates[3]{};
    if (!get(process, base + objectGlobal, objects) || !get(process, objects + 0x108, result.player) ||
        !read(process, result.player + 0x4c, coordinates, sizeof(coordinates)) ||
        !get(process, base + worldGlobal, world) || !get(process, world + 0x127c8, scene) ||
        !get(process, scene + 0x18, data) || !get(process, data, result.scene) ||
        !get(process, base + inputGlobal, result.input) || !get(process, result.input, table) ||
        !get(process, table + 0xa8, function) || function != base + moveFunction)
        return false;
    result.x = coordinates[0];
    result.height = coordinates[1];
    result.y = coordinates[2];
    if (!std::isfinite(result.x) || !std::isfinite(result.y) || !std::isfinite(result.height) ||
        result.x < 0 || result.y < 0 || result.x > 10000 || result.y > 10000 || result.scene < 0)
        return false;
    uintptr_t name = scene + 0xe0, length = 0, capacity = 0;
    if (!get(process, name + 0x10, length) || !get(process, name + 0x18, capacity) || length == 0 ||
        length > 128)
        return false;
    if (capacity >= 16 && !get(process, name, name))
        return false;
    char text[129]{};
    if (!read(process, name, text, length) ||
        !MultiByteToWideChar(936, MB_ERR_INVALID_CHARS, text, int(length), result.map, 128))
        return false;
    // Refuse a torn player/scene transition instead of returning stale coordinates.
    uintptr_t playerAgain = 0, sceneAgain = 0;
    if (!get(process, objects + 0x108, playerAgain) || playerAgain != result.player ||
        !get(process, world + 0x127c8, sceneAgain) || sceneAgain != scene)
        return false;
    out = result;
    return true;
}
} // namespace tlbb::live
