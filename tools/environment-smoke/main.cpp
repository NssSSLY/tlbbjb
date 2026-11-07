#include <QApplication>
#include <QCoreApplication>
#include <QDateTime>
#include <QFile>
#include <QImage>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLabel>
#include <QLocalServer>
#include <QLocalSocket>
#include <QLibraryInfo>
#include <QProcess>
#include <QSysInfo>
#include <QUuid>
#include <QWidget>
#include "ui_panel.h"
#include <windows.h>
#include <psapi.h>
#include <cstdio>
#include <stdexcept>
extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

static void require(bool value, const char* message) {
    if (!value) throw std::runtime_error(message);
}

class EnvironmentSignal final : public QObject {
    Q_OBJECT
signals:
    void changed(int value);
};

int main(int argc, char** argv) {
    if (argc > 1 && QString::fromLocal8Bit(argv[1]) == "--child") return 24;
    static_assert(sizeof(void*) == 8, "The client environment must target x64");
    QApplication app(argc, argv);
    try {
        QJsonArray checks;
        lua_State* state = luaL_newstate();
        require(state != nullptr, "Cannot create Lua state");
        luaL_openlibs(state);
        const int result = luaL_dostring(state, "return _VERSION, 6*7");
        const bool luaOk = result == LUA_OK && lua_isstring(state, -2)
            && QString::fromUtf8(lua_tostring(state, -2)) == "Lua 5.4"
            && lua_tointeger(state, -1) == 42;
        lua_close(state);
        require(luaOk, "Embedded Lua execution failed");
        checks.append("embedded_lua_54");

        QWidget panel;
        Ui::EnvironmentPanel ui;
        ui.setupUi(&panel);
        QImage image(panel.size(), QImage::Format_ARGB32);
        panel.render(&image);
        require(!image.isNull(), "Qt Widgets render failed");
        checks.append("qt_widgets_render_without_showing_window");
        checks.append("qt_uic_form_generation");
        EnvironmentSignal bus;
        int observed = 0;
        QObject::connect(&bus, &EnvironmentSignal::changed, [&observed](int value) { observed = value; });
        bus.changed(42);
        require(observed == 42, "Qt moc signal/slot failed");
        checks.append("qt_moc_signal_slot");

        QLocalServer server;
        const QString pipe = "tlbb-env-" + QUuid::createUuid().toString(QUuid::WithoutBraces);
        require(server.listen(pipe), "Cannot create local IPC server");
        QLocalSocket client;
        client.connectToServer(pipe);
        require(client.waitForConnected(2000), "Local IPC connection failed");
        require(server.waitForNewConnection(2000), "Local IPC accept failed");
        QLocalSocket* peer = server.nextPendingConnection();
        require(peer != nullptr, "No local IPC peer");
        client.write("ping", 4);
        client.flush();
        require(peer->bytesAvailable() > 0 || peer->waitForReadyRead(2000), "Local IPC read failed");
        require(peer->readAll() == "ping", "Local IPC payload mismatch");
        client.disconnectFromServer();
        delete peer;
        server.close();
        checks.append("qt_local_named_pipe");

        QProcess child;
        child.setCreateProcessArgumentsModifier([](QProcess::CreateProcessArguments* args) {
            args->flags |= CREATE_NO_WINDOW;
        });
        child.start(QCoreApplication::applicationFilePath(), {"--child"});
        require(child.waitForStarted(2000), "Worker process creation failed");
        require(child.waitForFinished(3000), "Worker process wait failed");
        require(child.exitStatus() == QProcess::NormalExit && child.exitCode() == 24, "Worker exit result mismatch");
        checks.append("qt_worker_start_and_exit");

        HANDLE job = CreateJobObjectW(nullptr, nullptr);
        require(job != nullptr, "CreateJobObject failed");
        JOBOBJECT_EXTENDED_LIMIT_INFORMATION limits{};
        limits.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_PROCESS_MEMORY;
        limits.ProcessMemoryLimit = 192ULL * 1024 * 1024;
        const bool jobOk = SetInformationJobObject(job, JobObjectExtendedLimitInformation, &limits, sizeof(limits));
        CloseHandle(job);
        require(jobOk, "Job memory-limit configuration failed");
        checks.append("win32_job_limit_configuration_only");

        PROCESS_MEMORY_COUNTERS_EX memory{};
        memory.cb = sizeof(memory);
        require(GetProcessMemoryInfo(GetCurrentProcess(), reinterpret_cast<PROCESS_MEMORY_COUNTERS*>(&memory), sizeof(memory)), "Process metrics failed");
        require(GetProcAddress(GetModuleHandleW(L"user32.dll"), "GetWindowThreadProcessId") != nullptr, "User32 API missing");
        checks.append("win32_process_metrics_and_user32");

        QJsonObject report{
            {"status", "pass"}, {"scope", "build_environment_only_no_game_access"},
            {"qt_version", qVersion()}, {"lua_version", LUA_RELEASE},
            {"qt_platform", QGuiApplication::platformName()},
            {"qt_plugins_path", QLibraryInfo::path(QLibraryInfo::PluginsPath)},
            {"compiler", __VERSION__}, {"architecture", QSysInfo::buildCpuArchitecture()},
            {"checked_at", QDateTime::currentDateTimeUtc().toString(Qt::ISODate)},
            {"private_commit_bytes", static_cast<double>(memory.PrivateUsage)},
            {"checks", checks}
        };
        const QByteArray json = QJsonDocument(report).toJson();
        if (argc > 1) {
            QFile file(QString::fromLocal8Bit(argv[1]));
            require(file.open(QIODevice::WriteOnly), "Cannot save environment report");
            require(file.write(json) == json.size(), "Cannot write complete report");
        }
        std::fwrite(json.constData(), 1, json.size(), stdout);
        return 0;
    } catch (const std::exception& error) {
        std::fprintf(stderr, "ENVIRONMENT CHECK FAILED: %s\n", error.what());
        return 1;
    }
}

#include "main.moc"
