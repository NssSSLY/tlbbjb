#include "native_controller.hpp"
#include "bridge_protocol.hpp"
#include "core.hpp"
#include "live_layout.hpp"
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QRandomGenerator>
#include <cstring>
#include <psapi.h>

namespace tlbb {
QJsonObject bridgeCommand(quint32 pid, const QString &created, const QString &root, const QString &dll,
                          quint32 command, float x, float y, bool fixture) {
    QJsonObject result{{"success", false}, {"pid", int(pid)}, {"game_actions_issued", 0}};
    auto fail = [&](QString message, DWORD code = 0) {
        result.insert("error", message);
        result.insert("win32_error", int(code));
        return result;
    };
    ProcessBinding binding;
    if (!binding.open(pid, root, created, fixture))
        return fail(binding.error);
    if (!fixture) {
        QFile image(binding.info().path);
        if (!image.open(QIODevice::ReadOnly))
            return fail("无法验证游戏版本");
        QCryptographicHash hash(QCryptographicHash::Sha256);
        if (!hash.addData(&image) || hash.result().toHex() != live::imageSha256)
            return fail("游戏版本未适配，拒绝调用动作");
    }
    HMODULE base = nullptr;
    DWORD needed = 0;
    if (!EnumProcessModules(binding.handle(), &base, sizeof(base), &needed))
        return fail("无法读取模块", GetLastError());
    live::Snapshot before;
    if (!fixture && (!live::signature(binding.handle(), uintptr_t(base)) ||
                     !live::snapshot(binding.handle(), uintptr_t(base), before)))
        return fail("真实状态或函数签名不可用");
    struct Windows {
        DWORD pid;
        HWND window = nullptr;
        bool fixture;
    };
    Windows windows{pid, nullptr, fixture};
    EnumWindows(
        [](HWND w, LPARAM value) -> BOOL {
            auto &state = *reinterpret_cast<Windows *>(value);
            DWORD owner = 0;
            GetWindowThreadProcessId(w, &owner);
            if (owner != state.pid || GetWindow(w, GW_OWNER))
                return TRUE;
            wchar_t cls[64]{};
            GetClassNameW(w, cls, 64);
            if (state.fixture ? std::wcscmp(cls, L"TLBBBridgeFixture") == 0 : IsWindowVisible(w)) {
                state.window = w;
                return FALSE;
            }
            return TRUE;
        },
        LPARAM(&windows));
    if (!windows.window)
        return fail("未找到当前桌面的目标窗口");
    DWORD owner = 0;
    DWORD thread = GetWindowThreadProcessId(windows.window, &owner);
    if (!thread || owner != pid)
        return fail("窗口身份已改变");
    auto library = LoadLibraryExW(reinterpret_cast<LPCWSTR>(QDir::toNativeSeparators(dll).utf16()), nullptr,
                                  LOAD_LIBRARY_SEARCH_DLL_LOAD_DIR | LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if (!library)
        return fail("无法加载本项目桥接库", GetLastError());
    auto entry = GetProcAddress(library, "TlbbBridgeHook");
    HOOKPROC hookFunction = nullptr;
    static_assert(sizeof(hookFunction) == sizeof(entry));
    std::memcpy(&hookFunction, &entry, sizeof(entry));
    if (!hookFunction) {
        FreeLibrary(library);
        return fail("缺少桥接入口");
    }
    uint64_t nonce = QRandomGenerator::system()->generate64();
    wchar_t name[128]{};
    bridge::mappingName(name, pid, nonce);
    HANDLE mapping =
        CreateFileMappingW(INVALID_HANDLE_VALUE, nullptr, PAGE_READWRITE, 0, sizeof(bridge::Packet), name);
    DWORD mappingError = GetLastError();
    if (!mapping || mappingError == ERROR_ALREADY_EXISTS) {
        if (mapping)
            CloseHandle(mapping);
        FreeLibrary(library);
        return fail("无法创建独立命令通道", mappingError);
    }
    auto *packet = static_cast<bridge::Packet *>(
        MapViewOfFile(mapping, FILE_MAP_READ | FILE_MAP_WRITE, 0, 0, sizeof(bridge::Packet)));
    if (!packet) {
        DWORD error = GetLastError();
        CloseHandle(mapping);
        FreeLibrary(library);
        return fail("无法映射命令", error);
    }
    bridge::Packet initial;
    initial.targetPid = pid;
    initial.ownerPid = GetCurrentProcessId();
    initial.targetThread = thread;
    initial.created = binding.info().created.toULongLong();
    initial.nonce = nonce;
    initial.expires = GetTickCount64() + 2000;
    initial.command = command;
    initial.fixture = fixture;
    initial.targetX = x;
    initial.targetY = y;
    initial.expectedScene = before.scene;
    std::memcpy(packet, &initial, sizeof(initial));
    auto hook = SetWindowsHookExW(WH_GETMESSAGE, hookFunction, library, thread);
    DWORD error = hook ? 0 : GetLastError();
    bool posted = false;
    if (hook) {
        UINT message = RegisterWindowMessageW(bridge::messageName);
        posted = message && PostMessageW(windows.window, message, pid, LPARAM(nonce));
        if (!posted)
            error = GetLastError();
        QElapsedTimer timer;
        timer.start();
        while (posted && packet->status < bridge::Done && timer.elapsed() < 2500 && binding.alive()) {
            Sleep(10);
        }
        UnhookWindowsHookEx(hook);
    }
    LONG status = packet->status;
    result.insert("bridge_status", int(status));
    result.insert("target_thread", int(thread));
    result.insert("executed_thread", int(packet->executedThread));
    result.insert("game_actions_issued", int(packet->actionIssued));
    result.insert("map", QString::fromWCharArray(packet->map));
    result.insert("scene_id", packet->scene);
    result.insert("before_x", packet->x);
    result.insert("before_y", packet->y);
    result.insert("target_x", x);
    result.insert("target_y", y);
    result.insert("win32_error", int(error ? error : packet->error));
    result.insert("success", status == bridge::Done && packet->executedThread == thread);
    if (status != bridge::Done)
        result.insert("error", status == bridge::Rejected ? "桥接校验拒绝执行" : "桥接未执行或超时；未重试");
    UnmapViewOfFile(packet);
    CloseHandle(mapping);
    FreeLibrary(library);
    return result;
}
static QString option(const QStringList &args, const QString &key, const QString &fallback = {}) {
    int at = args.indexOf(key);
    return at >= 0 && at + 1 < args.size() ? args[at + 1] : fallback;
}
int runNativeCommand(const QStringList &args) {
    const QString root = option(args, "--game-root", "E:/game/tlbb");
    const bool fixture = args.contains("--bridge-test-target");
    quint32 command = args.contains("--native-move")
                          ? bridge::Move
                          : (args.contains("--native-state") ? bridge::ReadState : bridge::ThreadProbe);
    auto report = bridgeCommand(
        option(args, "--target-pid").toUInt(), option(args, "--created"), root,
        option(args, "--bridge-dll", QCoreApplication::applicationDirPath() + "/TLBBEngine.dll"),
        command, option(args, "--x").toFloat(), option(args, "--y").toFloat(), fixture);
    QFile output(option(args, "--report"));
    if (!output.open(QIODevice::WriteOnly))
        return 3;
    output.write(QJsonDocument(report).toJson());
    return report.value("success").toBool() ? 0 : 1;
}
int runBridgeFixture() {
    HINSTANCE instance = GetModuleHandleW(nullptr);
    WNDCLASSW cls{};
    cls.hInstance = instance;
    cls.lpszClassName = L"TLBBBridgeFixture";
    cls.lpfnWndProc = [](HWND w, UINT msg, WPARAM wp, LPARAM lp) -> LRESULT {
        if (msg == WM_CLOSE || msg == WM_TIMER) {
            DestroyWindow(w);
            return 0;
        }
        if (msg == WM_DESTROY) {
            PostQuitMessage(0);
            return 0;
        }
        return DefWindowProcW(w, msg, wp, lp);
    };
    if (!RegisterClassW(&cls))
        return 2;
    HWND window = CreateWindowW(cls.lpszClassName, L"TLBB bridge owned test target", WS_OVERLAPPED, 0, 0, 100,
                                100, nullptr, nullptr, instance, nullptr);
    if (!window)
        return 3;
    SetTimer(window, 1, 20000, nullptr);
    MSG message{};
    while (GetMessageW(&message, nullptr, 0, 0) > 0) {
        TranslateMessage(&message);
        DispatchMessageW(&message);
    }
    return 0;
}
} // namespace tlbb
