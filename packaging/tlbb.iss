#ifndef StageDir
  #error StageDir must point to a verified full release folder
#endif
#ifndef OutputDir
  #error OutputDir required
#endif
[Setup]
AppId={{F6413950-C80B-4515-BF01-10417B981374}
AppName=TLBB Launcher
AppVersion=0.15.0
AppPublisher=TLBBClient Project
DefaultDirName=E:\TLBBClient
DisableDirPage=no
DefaultGroupName=TLBB Launcher
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir={#OutputDir}
OutputBaseFilename=TLBBClient-0.15.0-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\TLBB.exe
CloseApplications=no
RestartApplications=no
AppMutex=Local\TLBBClientLauncher-v3
SetupLogging=yes
[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"
[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked
[Files]
Source: "{#StageDir}\TLBB.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\TLBBRuntime.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\TLBBEngine.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\scripts\builtin\*"; DestDir: "{app}\scripts\builtin"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#StageDir}\scripts\tasks\*"; DestDir: "{app}\scripts\tasks"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#StageDir}\data\docs\*"; DestDir: "{app}\data\docs"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "{#StageDir}\data\package-manifest.json"; DestDir: "{app}\data"; Flags: ignoreversion
[Dirs]
Name: "{app}\data\profiles"
Name: "{app}\data\logs"
Name: "{app}\data\cache"
Name: "{app}\scripts\user"
[InstallDelete]
; Remove only obsolete files shipped by earlier versions; never remove data or user scripts.
Type: files; Name: "{app}\TLBBNativeBridge.dll"
Type: files; Name: "{app}\TLBBLoginBridge.dll"
Type: files; Name: "{app}\TLBBGameplayBridge.dll"
Type: files; Name: "{app}\Qt6Network.dll"
Type: files; Name: "{app}\generic\qtuiotouchplugin.dll"
Type: files; Name: "{app}\imageformats\qgif.dll"
Type: files; Name: "{app}\imageformats\qico.dll"
Type: files; Name: "{app}\imageformats\qjpeg.dll"
Type: files; Name: "{app}\networkinformation\qnetworklistmanager.dll"
Type: files; Name: "{app}\tls\qcertonlybackend.dll"
Type: files; Name: "{app}\tls\qschannelbackend.dll"
; Everything below moved into TLBBRuntime.dll or under scripts\ and data\ in the two-DLL layout.
Type: files; Name: "{app}\Qt6Core.dll"
Type: files; Name: "{app}\Qt6Gui.dll"
Type: files; Name: "{app}\Qt6Widgets.dll"
Type: files; Name: "{app}\libgcc_s_seh-1.dll"
Type: files; Name: "{app}\libstdc++-6.dll"
Type: files; Name: "{app}\libwinpthread-1.dll"
Type: files; Name: "{app}\qt.conf"
Type: files; Name: "{app}\TLBBData.rcc"
Type: files; Name: "{app}\package-manifest.json"
Type: files; Name: "{app}\使用说明.md"
Type: files; Name: "{app}\THIRD_PARTY_NOTICES.txt"
Type: files; Name: "{app}\LICENSE-LGPL-3.0.txt"
Type: files; Name: "{app}\LICENSE-LUA.txt"
Type: files; Name: "{app}\sanhuan-flow-tests.json"
Type: files; Name: "{app}\sijue-tests.json"
Type: files; Name: "{app}\water-prison-tests.json"
Type: files; Name: "{app}\yanzi-tests.json"
Type: filesandordirs; Name: "{app}\platforms"
Type: filesandordirs; Name: "{app}\styles"
Type: dirifempty; Name: "{app}\cache"
Type: dirifempty; Name: "{app}\overrides\scripts\builtin"
Type: dirifempty; Name: "{app}\overrides\scripts"
Type: dirifempty; Name: "{app}\overrides"
[UninstallDelete]
; The unpacked runtime is ours; accounts and logs under data stay.
Type: filesandordirs; Name: "{app}\data\cache"
[Icons]
Name: "{group}\TLBB Launcher"; Filename: "{app}\TLBB.exe"
Name: "{autodesktop}\TLBB Launcher"; Filename: "{app}\TLBB.exe"; Tasks: desktopicon
[Run]
Filename: "{app}\TLBB.exe"; Description: "Open TLBB Launcher"; Flags: nowait postinstall skipifsilent
