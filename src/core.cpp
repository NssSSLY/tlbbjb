#include "core.hpp"
#include "builtin_resources.hpp"
#include "live_layout.hpp"
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonValue>
#include <QRegularExpression>
#include <algorithm>
#include <cmath>
#include <cstdlib>
#include <psapi.h>
#include <stdexcept>
#include <tlhelp32.h>
extern "C" {
#include <lauxlib.h>
#include <lua.h>
#include <lualib.h>
}

namespace tlbb {
QString processPath(quint32 pid) {
    HANDLE h = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!h)
        return {};
    wchar_t buffer[32768];
    DWORD count = 32768;
    bool ok = QueryFullProcessImageNameW(h, 0, buffer, &count);
    CloseHandle(h);
    return ok ? QDir::cleanPath(QString::fromWCharArray(buffer, int(count))) : QString();
}
QString processCreated(HANDLE h) {
    FILETIME created{}, exit{}, kernel{}, user{};
    if (!GetProcessTimes(h, &created, &exit, &kernel, &user))
        return {};
    ULARGE_INTEGER time{};
    time.LowPart = created.dwLowDateTime;
    time.HighPart = created.dwHighDateTime;
    return QString::number(time.QuadPart);
}
bool isGamePath(const QString &path, const QString &root) {
    QString normalized = QDir::cleanPath(path), base = QDir::cleanPath(root);
    return normalized.compare(base + "/Bin64/Game.exe", Qt::CaseInsensitive) == 0 ||
           normalized.compare(base + "/Bin/Game.exe", Qt::CaseInsensitive) == 0;
}
QVector<GameInfo> discoverGames(const QString &root) {
    QVector<GameInfo> result;
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE)
        return result;
    PROCESSENTRY32W entry{};
    entry.dwSize = sizeof(entry);
    if (Process32FirstW(snapshot, &entry))
        do {
            if (QString::fromWCharArray(entry.szExeFile).compare("Game.exe", Qt::CaseInsensitive) != 0)
                continue;
            QString path = processPath(entry.th32ProcessID);
            if (!isGamePath(path, root))
                continue;
            HANDLE h = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, entry.th32ProcessID);
            GameInfo info;
            info.pid = entry.th32ProcessID;
            info.path = path;
            if (h) {
                info.created = processCreated(h);
                CloseHandle(h);
            }
            result.append(info);
        } while (Process32NextW(snapshot, &entry));
    CloseHandle(snapshot);
    struct Context {
        QVector<GameInfo> *list;
    } context{&result};
    EnumWindows(
        [](HWND window, LPARAM data) -> BOOL {
            DWORD pid = 0;
            GetWindowThreadProcessId(window, &pid);
            auto &games = *reinterpret_cast<Context *>(data)->list;
            for (auto &game : games)
                if (game.pid == pid && IsWindowVisible(window)) {
                    wchar_t title[512]{};
                    GetWindowTextW(window, title, 512);
                    if (!game.window || title[0]) {
                        game.window = reinterpret_cast<quintptr>(window);
                        game.title = QString::fromWCharArray(title);
                    }
                }
            return TRUE;
        },
        reinterpret_cast<LPARAM>(&context));
    return result;
}
ProcessBinding::~ProcessBinding() {
    close();
}
void ProcessBinding::close() {
    if (handle_)
        CloseHandle(handle_);
    handle_ = nullptr;
    headerReadable = false;
}
bool ProcessBinding::alive() const {
    return handle_ && WaitForSingleObject(handle_, 0) == WAIT_TIMEOUT;
}
bool ProcessBinding::open(quint32 pid, const QString &root, const QString &expected, bool fixture) {
    close();
    error.clear();
    info_ = {};
    QString path = processPath(pid);
    const bool testPath =
        fixture &&
        QFileInfo(path).canonicalFilePath().compare(
            QFileInfo(QCoreApplication::applicationFilePath()).canonicalFilePath(), Qt::CaseInsensitive) == 0;
    if (!isGamePath(path, root) && !testPath) {
        error = "目标不是该安装目录的游戏进程";
        return false;
    }
    handle_ = OpenProcess(SYNCHRONIZE | PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    if (!handle_) {
        error = QString("打开只读进程失败，错误码 %1").arg(GetLastError());
        return false;
    }
    info_.pid = pid;
    info_.path = path;
    info_.created = processCreated(handle_);
    if (info_.created.isEmpty() || (!expected.isEmpty() && expected != info_.created) || !alive()) {
        error = "进程已退出或身份已改变";
        close();
        return false;
    }
    HMODULE first = nullptr;
    DWORD required = 0;
    if (EnumProcessModules(handle_, &first, sizeof(first), &required) && first) {
        unsigned char bytes[64]{};
        SIZE_T read = 0;
        headerReadable = ReadProcessMemory(handle_, first, bytes, sizeof(bytes), &read) && read == 64 &&
                         bytes[0] == 'M' && bytes[1] == 'Z';
    }
    return true;
}

bool LiveGameReader::open(const ProcessBinding &binding, QString &error) {
    binding_ = nullptr;
    base_ = 0;
    QFile image(binding.info().path);
    QCryptographicHash hash(QCryptographicHash::Sha256);
    if (!image.open(QIODevice::ReadOnly) || !hash.addData(&image) ||
        hash.result().toHex() != live::imageSha256) {
        error = "当前游戏版本尚未适配真实位置与移动";
        return false;
    }
    HMODULE base = nullptr;
    DWORD needed = 0;
    if (!EnumProcessModules(binding.handle(), &base, sizeof(base), &needed) ||
        !live::signature(binding.handle(), quintptr(base))) {
        error = "游戏内存版本签名不匹配";
        return false;
    }
    binding_ = &binding;
    base_ = quintptr(base);
    return true;
}
bool LiveGameReader::snapshot(QJsonObject &state, QString &error) const {
    state = {};
    live::Snapshot sample;
    if (!binding_ || !binding_->alive() || !live::snapshot(binding_->handle(), base_, sample)) {
        error = "角色位置暂不可用（退出、登录或切换地图）";
        return false;
    }
    state = {{"position_valid", true},
             {"map", QString::fromWCharArray(sample.map)},
             {"scene_id", sample.scene},
             {"x", sample.x},
             {"y", sample.y},
             {"height", sample.height},
             {"preview", false}};
    return true;
}

struct LuaTask::Impl {
    lua_State *L = nullptr;
    size_t bytes = 0, limit = 16 * 1024 * 1024;
    int module = LUA_NOREF, remaining = 0;
    QElapsedTimer elapsed;
    static void *allocate(void *user, void *pointer, size_t old, size_t size) {
        auto *self = static_cast<Impl *>(user);
        if (!pointer)
            old = 0;
        if (size == 0) {
            std::free(pointer);
            self->bytes -= std::min(old, self->bytes);
            return nullptr;
        }
        if (size > old && size - old > self->limit - self->bytes)
            return nullptr;
        void *next = std::realloc(pointer, size);
        if (next)
            self->bytes = self->bytes - old + size;
        return next;
    }
    static void hook(lua_State *L, lua_Debug *) {
        auto *self = *static_cast<Impl **>(lua_getextraspace(L));
        self->remaining -= 1000;
        if (self->remaining <= 0 || self->elapsed.elapsed() > 20)
            luaL_error(L, "Lua execution budget exceeded");
    }
    void budget() {
        remaining = 200000;
        elapsed.restart();
        lua_sethook(L, hook, LUA_MASKCOUNT, 1000);
    }
    static void raw(lua_State *L, int table, const char *key) {
        table = lua_absindex(L, table);
        lua_pushstring(L, key);
        lua_rawget(L, table);
    }
    static QString string(lua_State *L, int index) {
        if (lua_type(L, index) != LUA_TSTRING)
            throw std::runtime_error("Expected a string");
        size_t n = 0;
        const char *text = lua_tolstring(L, index, &n);
        if (n > 4096)
            throw std::runtime_error("Lua string too long");
        return QString::fromUtf8(text, qsizetype(n));
    }
    static void push(lua_State *L, const QJsonValue &value, int depth = 0) {
        if (depth > 8)
            throw std::runtime_error("Input nesting limit");
        if (value.isObject()) {
            lua_newtable(L);
            auto object = value.toObject();
            for (auto it = object.begin(); it != object.end(); ++it) {
                auto key = it.key().toUtf8();
                lua_pushlstring(L, key.constData(), size_t(key.size()));
                push(L, it.value(), depth + 1);
                lua_rawset(L, -3);
            }
        } else if (value.isString()) {
            auto text = value.toString().toUtf8();
            lua_pushlstring(L, text.constData(), size_t(text.size()));
        } else if (value.isBool())
            lua_pushboolean(L, value.toBool());
        else if (value.isDouble())
            lua_pushnumber(L, value.toDouble());
        else
            lua_pushnil(L);
    }
    static QJsonValue read(lua_State *L, int index, int depth, int &count) {
        if (++count > 512 || depth > 8)
            throw std::runtime_error("Lua result too large");
        switch (lua_type(L, index)) {
        case LUA_TNIL:
            return QJsonValue();
        case LUA_TBOOLEAN:
            return bool(lua_toboolean(L, index));
        case LUA_TNUMBER: {
            double v = lua_tonumber(L, index);
            if (!std::isfinite(v))
                throw std::runtime_error("Non-finite Lua number");
            return v;
        }
        case LUA_TSTRING:
            return string(L, index);
        case LUA_TTABLE: {
            index = lua_absindex(L, index);
            if (lua_getmetatable(L, index)) {
                lua_pop(L, 1);
                throw std::runtime_error("Metatables are not allowed in results");
            }
            QJsonObject object;
            lua_pushnil(L);
            while (lua_next(L, index)) {
                QString key = string(L, -2);
                object.insert(key, read(L, -1, depth + 1, count));
                lua_pop(L, 1);
            }
            return object;
        }
        default:
            throw std::runtime_error("Unsupported Lua result type");
        }
    }
};
LuaTask::LuaTask() : p_(std::make_unique<Impl>()) {
    p_->L = lua_newstate(Impl::allocate, p_.get());
    if (!p_->L)
        throw std::runtime_error("Cannot create limited Lua VM");
    *static_cast<Impl **>(lua_getextraspace(p_->L)) = p_.get();
    for (const auto &library : {std::pair<const char *, lua_CFunction>{"_G", luaopen_base},
                                {LUA_MATHLIBNAME, luaopen_math},
                                {LUA_TABLIBNAME, luaopen_table},
                                {LUA_STRLIBNAME, luaopen_string}}) {
        luaL_requiref(p_->L, library.first, library.second, 1);
        lua_pop(p_->L, 1);
    }
    for (const char *name : {"dofile", "loadfile", "load", "collectgarbage", "print", "pcall", "xpcall"}) {
        lua_pushnil(p_->L);
        lua_setglobal(p_->L, name);
    }
}
LuaTask::~LuaTask() {
    if (p_->L)
        lua_close(p_->L);
}
size_t LuaTask::allocated() const {
    return p_->bytes;
}
bool LuaTask::load(const QString &path, QString &error) {
    auto *L = p_->L;
    lua_settop(L, 0);
    try {
        QFile file(BuiltinResources::path(path));
        if (!file.open(QIODevice::ReadOnly) || file.size() > 256 * 1024)
            throw std::runtime_error("Script missing or exceeds 256 KiB");
        QByteArray code = file.readAll();
        p_->budget();
        if (luaL_loadbufferx(L, code.constData(), size_t(code.size()), "task", "t") != LUA_OK ||
            lua_pcall(L, 0, 1, 0) != LUA_OK) {
            error = lua_tostring(L, -1) ? QString::fromUtf8(lua_tostring(L, -1)) : "Lua load failed";
            lua_settop(L, 0);
            return false;
        }
        if (!lua_istable(L, -1) || lua_getmetatable(L, -1))
            throw std::runtime_error("Task must return a plain table");
        Impl::raw(L, -1, "id");
        id = Impl::string(L, -1);
        lua_pop(L, 1);
        Impl::raw(L, -1, "version");
        version = Impl::string(L, -1);
        lua_pop(L, 1);
        Impl::raw(L, -1, "context_schema");
        schema = lua_isinteger(L, -1) && lua_tointeger(L, -1) == 1 ? 1 : 0;
        lua_pop(L, 1);
        Impl::raw(L, -1, "step");
        bool function = lua_isfunction(L, -1);
        lua_pop(L, 1);
        if ((id != "luoyang_plant" && id != "wait_until") || schema != 1 || !function)
            throw std::runtime_error("Unsupported task ID, schema or entry");
        p_->module = luaL_ref(L, LUA_REGISTRYINDEX);
        return true;
    } catch (const std::exception &e) {
        error = QString::fromUtf8(e.what());
        lua_settop(L, 0);
        return false;
    }
}
bool LuaTask::step(const QJsonObject &state, const QJsonObject &config, const QJsonObject &context,
                   Decision &out, QString &error) {
    auto *L = p_->L;
    lua_settop(L, 0);
    try {
        lua_rawgeti(L, LUA_REGISTRYINDEX, p_->module);
        Impl::raw(L, -1, "step");
        lua_remove(L, -2);
        Impl::push(L, state);
        Impl::push(L, config);
        Impl::push(L, context);
        p_->budget();
        if (lua_pcall(L, 3, 1, 0) != LUA_OK) {
            error = lua_tostring(L, -1) ? QString::fromUtf8(lua_tostring(L, -1)) : "Lua step failed";
            lua_settop(L, 0);
            return false;
        }
        int count = 0;
        QJsonValue value = Impl::read(L, -1, 0, count);
        lua_settop(L, 0);
        if (!value.isObject())
            throw std::runtime_error("Task step must return an object");
        QJsonObject object = value.toObject();
        out = {};
        out.kind = object.value("kind").toString();
        out.message = object.value("message").toString();
        out.crop = object.value("crop").toString();
        out.x = object.value("x").toDouble();
        out.y = object.value("y").toDouble();
        out.context = object.value("context").toObject();
        if (!QStringList{"wait", "move", "plant", "complete", "error"}.contains(out.kind))
            throw std::runtime_error("Unknown action kind");
        return true;
    } catch (const std::exception &e) {
        error = QString::fromUtf8(e.what());
        lua_settop(L, 0);
        return false;
    }
}
bool validateWaitConfig(const QJsonObject &c, QString &error) {
    error.clear();
    const auto kind=c.value("wait_kind").toString();
    const double seconds=c.value("wait_seconds").toDouble(-1), timeout=c.value("timeout_seconds").toDouble(-1);
    if (!std::isfinite(timeout)||timeout<1||timeout>90000||std::floor(timeout)!=timeout) {
        error="最长等待应为 1–90000 秒的整数";return false;
    }
    if (kind=="等待时长") {
        if (!std::isfinite(seconds)||seconds<1||seconds>86400||std::floor(seconds)!=seconds||timeout<seconds) {
            error="等待时长应为 1–86400 秒，最长等待不得短于时长";return false;
        }
    } else if (kind=="指定时刻") {
        const auto time=c.value("wait_time").toString();
        if (!QRegularExpression("^(?:[01][0-9]|2[0-3]):[0-5][0-9]$").match(time).hasMatch()) {
            error="指定时刻请填写 HH:mm，例如 20:05";return false;
        }
    } else { error="请选择等待时长或指定时刻";return false; }
    return true;
}
bool validatePlantConfig(const QJsonObject &c, QString &error) {
    auto crop = c.value("crop").toString().trimmed();
    double x = c.value("x").toDouble(-1), y = c.value("y").toDouble(-1);
    double rounds = c.value("rounds").toDouble(-1), tolerance = c.value("tolerance").toDouble(-1);
    if ((crop.isEmpty() && c.value("operation").toString() != "move") || crop.size() > 64) {
        error = "请填写作物参数（最多 64 字符）";
        return false;
    }
    if (!std::isfinite(x) || !std::isfinite(y) || x < 0 || x > 10000 || y < 0 || y > 10000) {
        error = "坐标必须在 0–10000 范围";
        return false;
    }
    if (rounds < 1 || rounds > 100 || rounds != std::floor(rounds)) {
        error = "次数必须为 1–100 的整数";
        return false;
    }
    if (tolerance < 0.1 || tolerance > 5) {
        error = "到达容差必须在 0.1–5 范围";
        return false;
    }
    double timeout = c.value("timeout_seconds").toDouble(120);
    if (!std::isfinite(timeout) || timeout < 1 || timeout > 1800 || timeout != std::floor(timeout)) {
        error = "超时必须为 1–1800 秒的整数";
        return false;
    }
    return true;
}
QStringList liveMissingCapabilities() {
    return {"可种植状态与物品读取", "种植动作及结果确认"};
}
QJsonObject PreviewWorld::snapshot() const {
    return {{"map", "洛阳"},
            {"x", x_},
            {"y", y_},
            {"position_valid", true},
            {"seed_available", true},
            {"can_plant", true},
            {"planted_count", plants_},
            {"pending", pending()},
            {"preview", true}};
}
bool PreviewWorld::submit(const Decision &d, QString &error) {
    if (pending()) {
        error = "已有动作等待确认";
        return false;
    }
    if (d.kind != "move" && d.kind != "plant") {
        error = "不支持的预演动作";
        return false;
    }
    if (d.kind == "move" &&
        (!std::isfinite(d.x) || !std::isfinite(d.y) || d.x < 0 || d.x > 10000 || d.y < 0 || d.y > 10000)) {
        error = "非法移动坐标";
        return false;
    }
    if (d.kind == "plant" && d.crop.trimmed().isEmpty()) {
        error = "种植参数为空";
        return false;
    }
    pendingKind_ = d.kind;
    nextX_ = d.x;
    nextY_ = d.y;
    pendingTicks_ = 3;
    ++actions;
    return true;
}
void PreviewWorld::advance() {
    if (pendingTicks_ > 0 && --pendingTicks_ == 0) {
        if (pendingKind_ == "move") {
            x_ = nextX_;
            y_ = nextY_;
        } else if (pendingKind_ == "plant")
            ++plants_;
        pendingKind_.clear();
    }
}
} // namespace tlbb
