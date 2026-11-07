#pragma once
#include <cstdint>
#include <cstdio>
#include <cwchar>
#include <windows.h>

namespace tlbb::bridge {
inline constexpr wchar_t messageName[] = L"TLBBClient.NativeBridge.v1.20261024";
inline constexpr uint32_t magic = 0x31424c54;
enum Command : uint32_t { ThreadProbe = 1, ReadState = 2, Move = 3 };
enum Status : LONG { Pending = 0, Executing = 1, Done = 2, Rejected = 3 };
struct Packet {
    uint32_t marker = magic, version = 1, bytes = sizeof(Packet), command = ThreadProbe;
    uint32_t targetPid = 0, ownerPid = 0, targetThread = 0, executedThread = 0;
    uint64_t created = 0, nonce = 0, expires = 0;
    volatile LONG status = Pending;
    uint32_t error = 0, fixture = 0, actionIssued = 0;
    int32_t expectedScene = -1, scene = -1;
    float targetX = 0, targetY = 0, x = 0, y = 0;
    wchar_t map[129]{};
};
inline void mappingName(wchar_t (&out)[128], DWORD pid, uint64_t nonce) {
    std::swprintf(out, 128, L"Local\\TLBBClient-Bridge-%lu-%016llx", static_cast<unsigned long>(pid),
                  static_cast<unsigned long long>(nonce));
}
} // namespace tlbb::bridge
