#include "core.hpp"
#include "builtin_resources.hpp"
#include <cstdio>
#include "native_controller.hpp"
#include "gameplay_client.hpp"
#include "login_client.hpp"
#include "launcher_window.hpp"
#include "../tests/catalog_ui_tests.hpp"
#include <QApplication>
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QMessageBox>
#include <QTimer>
#include <shellapi.h>

static QString value(const QStringList &arguments, const QString &key, const QString &fallback = {}) {
    int index = arguments.indexOf(key);
    return index >= 0 && index + 1 < arguments.size() ? arguments[index + 1] : fallback;
}
#ifdef TLBB_APP_DLL
// Packaged release: TLBB.exe is a small launcher that loads this DLL and enters here.
extern "C" __declspec(dllexport) int TLBBAppMain(int argc, char **argv) {
    // Qt finds its plugins beside the unpacked runtime. A library path keeps a non-ASCII install folder intact, which QT_PLUGIN_PATH does not.
    wchar_t runtime[4096];
    const DWORD runtimeLength = GetEnvironmentVariableW(L"TLBB_RUNTIME", runtime, 4096);
    if (runtimeLength > 0 && runtimeLength < 4096)
        QCoreApplication::addLibraryPath(QString::fromWCharArray(runtime, int(runtimeLength)));
#else
int main(int argc, char **argv) {
#endif
    SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX);
    QStringList early;
    int wideCount = 0;
    auto wide = CommandLineToArgvW(GetCommandLineW(), &wideCount);
    if (wide) {
        for (int i = 0; i < wideCount; ++i)
            early.append(QString::fromWCharArray(wide[i]));
        LocalFree(wide);
    } else
        for (int i = 0; i < argc; ++i)
            early.append(QString::fromLocal8Bit(argv[i]));
    if (early.contains("--worker") || early.contains("--fixture-game") || early.contains("--self-test") ||
        early.contains("--probe-binding") || early.contains("--native-probe") ||
        early.contains("--native-state") || early.contains("--native-move") ||
        early.contains("--bridge-fixture") || early.contains("--login-worker") || early.contains("--login-self-test") || early.contains("--gameplay-probe") || early.contains("--assets-report")) {
        QCoreApplication app(argc, argv);
        QString assetError;if(!tlbb::BuiltinResources::mount(assetError)){std::fprintf(stderr,"%s",assetError.toUtf8().constData());return 2;}
        if(early.contains("--assets-report")){QFile out(value(early,"--assets-report"));if(!out.open(QIODevice::WriteOnly))return 3;out.write(QJsonDocument(tlbb::BuiltinResources::report()).toJson());const auto report=tlbb::BuiltinResources::report();return report.value("mounted").toBool()||report.value("loose_scripts").toBool()?0:2;}
        if(early.contains("--gameplay-probe"))return tlbb::runGameplayProbe(early);
        if(early.contains("--login-worker"))return tlbb::runLoginWorker(early);
        if(early.contains("--login-self-test"))return tlbb::runLoginTests(value(early,"--project-root"),value(early,"--report"));
        if (early.contains("--bridge-fixture"))
            return tlbb::runBridgeFixture();
        if (early.contains("--native-probe") || early.contains("--native-state") ||
            early.contains("--native-move"))
            return tlbb::runNativeCommand(early);
        if (early.contains("--worker"))
            return tlbb::runWorker(early);
        if (early.contains("--fixture-game")) {
            QTimer::singleShot(value(early, "--lifetime", "60000").toInt(), &app, &QCoreApplication::quit);
            return app.exec();
        }
        if (early.contains("--self-test")) {
            int i = early.indexOf("--self-test");
            return i + 2 < early.size() ? tlbb::runSelfTests(early[i + 1], early[i + 2]) : 2;
        }
        tlbb::ProcessBinding binding;
        bool ok =
            binding.open(value(early, "--target-pid").toUInt(), value(early, "--game-root", "E:/game/tlbb"));
        tlbb::LiveGameReader reader;
        QString adapterError;
        QJsonObject liveState;
        bool live = ok && reader.open(binding, adapterError) && reader.snapshot(liveState, adapterError);
        QJsonObject report{{"bound", ok},
                           {"header_readable", binding.headerReadable},
                           {"pid", int(binding.info().pid)},
                           {"created", binding.info().created},
                           {"error", binding.error},
                           {"game_actions_available", live},
                           {"planting_available", false},
                           {"live_state", liveState},
                           {"adapter_error", adapterError},
                           {"missing", QJsonArray::fromStringList(tlbb::liveMissingCapabilities())}};
        QFile output(value(early, "--report"));
        if (!output.open(QIODevice::WriteOnly))
            return 3;
        output.write(QJsonDocument(report).toJson());
        return ok ? 0 : 1;
    }
    QApplication app(argc, argv);
    QString assetError;if(!tlbb::BuiltinResources::mount(assetError)){QMessageBox::critical(nullptr,"内置资源错误",assetError);return 2;}
    app.setApplicationName("TLBBClient");
    app.setApplicationVersion("0.15.0");
    app.setQuitOnLastWindowClosed(false);
    if(early.contains("--catalog-ui-self-test"))return runCatalogUiTests();
    const bool uiTest = early.contains("--ui-self-test");
    const bool smoke = early.contains("--ui-smoke") || uiTest;
    QString source =
        value(early, "--script", tlbb::BuiltinResources::path("scripts/builtin/luoyang_plant.lua"));
    if (!QFileInfo::exists(source)) source = QCoreApplication::applicationDirPath() + "/scripts/luoyang_plant.lua";
    if (!QFileInfo::exists(source)) {
        QMessageBox::critical(nullptr, "缺少脚本",
                              "未找到 scripts/luoyang_plant.lua，请运行发布目录中的 TLBB.exe");
        return 2;
    }
    HANDLE singleton = nullptr;
    if (!smoke) {
        QString name = "Local\\TLBBClientLauncher-v3";
        singleton = CreateMutexW(nullptr, FALSE, reinterpret_cast<LPCWSTR>(name.utf16()));
        if (singleton && GetLastError() == ERROR_ALREADY_EXISTS) {
            CloseHandle(singleton);
            HWND existing = FindWindowW(nullptr, L"TLBB 启动器 · 0.15.0");
            if (existing) { ShowWindow(existing, SW_RESTORE); SetForegroundWindow(existing); }
            else QMessageBox::information(nullptr, "客户端已运行", "请通过托盘打开启动器，或在游戏前台按 Home。");
            return 0;
        }
    }
    int result = 0;
    {
        tlbb::MainWindow window(value(early, "--game-root"), source, smoke, value(early,"--data-root"));
        if (uiTest) {
            result=window.runUiTests(value(early,"--fixture-root"),value(early,"--report"));
        } else if (smoke) {
            bool binding = true;
            if (early.contains("--probe-ui-binding"))
                binding = window.bindForSmoke(value(early, "--probe-ui-binding").toUInt());
            QString path = value(early, "--ui-smoke");
            result = window.saveScreenshot(path) && binding ? 0 : 1;
            if (early.contains("--report")) {
                QFile report(value(early, "--report"));
                if (report.open(QIODevice::WriteOnly))
                    report.write(QJsonDocument(window.diagnostics()).toJson());
            }
        } else {
            if (early.contains("--diagnostics")) {
                auto *timer=new QTimer(&window);timer->setInterval(500);
                QObject::connect(timer,&QTimer::timeout,&window,[&window,early]{QString error;tlbb::ClientStore::writeJson(value(early,"--diagnostics"),window.diagnostics(),error);});
                timer->start();
            }
            window.show();
            window.syncHotkeys();
            if(early.contains("--auto-start"))QTimer::singleShot(100,&window,[&window]{window.startConfiguredGame();});
            result = app.exec();
        }
    }
    if (singleton)
        CloseHandle(singleton);
    return result;
}
