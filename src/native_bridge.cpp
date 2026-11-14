#include "game_layout.hpp"
#include "bridge_protocol.hpp"
#include "live_layout.hpp"
#include <cwchar>

using namespace tlbb;
static bool createdMatches(uint64_t expected) {
    FILETIME created{}, exit{}, kernel{}, user{};
    if (!GetProcessTimes(GetCurrentProcess(), &created, &exit, &kernel, &user))
        return false;
    return expected == ((uint64_t(created.dwHighDateTime) << 32) | created.dwLowDateTime);
}
static void execute(bridge::Packet &packet, HWND window) {
    packet.executedThread = GetCurrentThreadId();
    auto reject = [&](DWORD error) {
        packet.error = error;
        InterlockedExchange(&packet.status, bridge::Rejected);
    };
    if (packet.targetThread != GetCurrentThreadId() || !createdMatches(packet.created) ||
        GetTickCount64() > packet.expires || packet.expires - GetTickCount64() > 10000) {
        reject(ERROR_INVALID_DATA);
        return;
    }
    wchar_t path[32768]{};
    GetModuleFileNameW(nullptr, path, 32768);
    const wchar_t *name = std::wcsrchr(path, L'\\');
    name = name ? name + 1 : path;
    if (packet.fixture) {
        wchar_t cls[64]{};
        GetClassNameW(window, cls, 64);
        if (packet.command != bridge::ThreadProbe || _wcsicmp(name, L"TLBB.exe") ||
            std::wcscmp(cls, L"TLBBBridgeFixture")) {
            reject(ERROR_ACCESS_DENIED);
            return;
        }
        InterlockedExchange(&packet.status, bridge::Done);
        return;
    }
    if (_wcsicmp(name, L"Game.exe")) {
        reject(ERROR_ACCESS_DENIED);
        return;
    }
    auto base = reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr));
    live::Snapshot state;
    if (!layout::ready(base) || !live::snapshot(GetCurrentProcess(), base, state)) {
        reject(ERROR_REVISION_MISMATCH);
        return;
    }
    packet.x = state.x;
    packet.y = state.y;
    packet.scene = state.scene;
    std::wmemcpy(packet.map, state.map, 129);
    if (packet.command == bridge::Move) {
        const float dx = packet.targetX - state.x, dy = packet.targetY - state.y;
        if (!std::isfinite(packet.targetX) || !std::isfinite(packet.targetY) ||
            state.scene != packet.expectedScene || packet.targetX < 0 || packet.targetY < 0 ||
            packet.targetX > 10000 || packet.targetY > 10000 || dx * dx + dy * dy > 32 * 32) {
            reject(ERROR_INVALID_PARAMETER);
            return;
        }
        const float destination[2] = {packet.targetX, packet.targetY};
        // Same native dispatch used by AutoRunToTargetEx for movement in the current scene.
        // This runs on the game's window thread; no remote thread or system input is created.
        using MoveFunction = void (*)(void *, const float *);
        auto move = reinterpret_cast<MoveFunction>(base + live::moveFunction);
        move(reinterpret_cast<void *>(state.input), destination);
        packet.actionIssued = 1;
    } else if (packet.command != bridge::ReadState && packet.command != bridge::ThreadProbe) {
        reject(ERROR_INVALID_FUNCTION);
        return;
    }
    InterlockedExchange(&packet.status, bridge::Done);
}
extern "C" __declspec(dllexport) LRESULT CALLBACK TlbbBridgeHook(int code, WPARAM removed, LPARAM parameter) {
    if (code == HC_ACTION && removed == PM_REMOVE) {
        auto *message = reinterpret_cast<MSG *>(parameter);
        static const UINT id = RegisterWindowMessageW(bridge::messageName);
        if (message && message->message == id && id && message->wParam == GetCurrentProcessId()) {
            wchar_t name[128]{};
            bridge::mappingName(name, GetCurrentProcessId(), uint64_t(message->lParam));
            HANDLE mapping = OpenFileMappingW(FILE_MAP_READ | FILE_MAP_WRITE, FALSE, name);
            if (mapping) {
                auto *packet = static_cast<bridge::Packet *>(
                    MapViewOfFile(mapping, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, sizeof(bridge::Packet)));
                if (packet) {
                    if (packet->marker == bridge::magic && packet->version == 1 &&
                        packet->bytes == sizeof(*packet) && packet->targetPid == GetCurrentProcessId() &&
                        packet->nonce == uint64_t(message->lParam) && packet->ownerPid != packet->targetPid &&
                        InterlockedCompareExchange(&packet->status, bridge::Executing, bridge::Pending) ==
                            bridge::Pending)
                        execute(*packet, message->hwnd);
                    UnmapViewOfFile(packet);
                }
                CloseHandle(mapping);
            }
            message->message = WM_NULL;
            message->wParam = 0;
            message->lParam = 0;
        }
    }
    return CallNextHookEx(nullptr, code, removed, parameter);
}
#ifndef TLBB_ENGINE_COMBINED
BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH)
        DisableThreadLibraryCalls(instance);
    return TRUE;
}
#endif
