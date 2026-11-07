param(
    [string]$GameRoot = 'E:\game\tlbb'
)

$ErrorActionPreference = 'Stop'
$rootPath = (Resolve-Path -LiteralPath $GameRoot).Path.TrimEnd('\')
$rootPrefix = $rootPath + '\'
$outputRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\artifacts'))
[IO.Directory]::CreateDirectory($outputRoot) | Out-Null

function Get-PeInfo([string]$Path) {
    $data = [IO.File]::ReadAllBytes($Path)
    function U16([int]$Offset) { [BitConverter]::ToUInt16($data, $Offset) }
    function U32([int]$Offset) { [BitConverter]::ToUInt32($data, $Offset) }
    function AsciiZ([int]$Offset) {
        $end = $Offset
        while ($end -lt $data.Length -and $data[$end] -ne 0 -and ($end - $Offset) -lt 2048) { $end++ }
        [Text.Encoding]::ASCII.GetString($data, $Offset, $end - $Offset)
    }
    if ($data.Length -lt 64 -or (U16 0) -ne 0x5A4D) { throw "Not a PE file: $Path" }
    $pe = [int](U32 0x3C)
    if ((U32 $pe) -ne 0x4550) { throw "Invalid PE signature: $Path" }
    $machine = U16 ($pe + 4)
    $sectionCount = U16 ($pe + 6)
    $optionalSize = U16 ($pe + 20)
    $optional = $pe + 24
    $magic = U16 $optional
    $directory = if ($magic -eq 0x20B) { $optional + 112 } elseif ($magic -eq 0x10B) { $optional + 96 } else { throw "Unsupported PE format: $Path" }
    $sections = @()
    for ($i = 0; $i -lt $sectionCount; $i++) {
        $s = $optional + $optionalSize + 40 * $i
        $sections += [PSCustomObject]@{VirtualSize=(U32 ($s+8));Rva=(U32 ($s+12));RawSize=(U32 ($s+16));RawOffset=(U32 ($s+20))}
    }
    function RvaOffset([uint32]$Rva) {
        if ($Rva -lt (U32 ($optional+60))) { return [int]$Rva }
        foreach ($section in $sections) {
            $length = [Math]::Max([long]$section.VirtualSize, [long]$section.RawSize)
            if ($Rva -ge $section.Rva -and [long]$Rva -lt ([long]$section.Rva+$length)) {
                $offset = [long]$section.RawOffset + ([long]$Rva-$section.Rva)
                if ($offset -lt 0 -or $offset -ge $data.Length) { throw 'RVA is not backed by file bytes' }
                return [int]$offset
            }
        }
        throw 'Cannot map RVA to file offset'
    }
    $exportNames = @()
    $exportRva = U32 $directory
    if ($exportRva -ne 0) {
        $export = RvaOffset $exportRva
        $nameCount = U32 ($export+24)
        if ($nameCount -gt 20000) { throw 'Unexpected export-name count' }
        if ($nameCount -gt 0) {
            $nameTable = RvaOffset (U32 ($export+32))
            for ($i=0; $i -lt $nameCount; $i++) {
                $exportNames += AsciiZ (RvaOffset (U32 ($nameTable+4*$i)))
            }
        }
    }
    $imports = @()
    $importRva = U32 ($directory+8)
    if ($importRva -ne 0) {
        $descriptor = RvaOffset $importRva
        for ($i=0; $i -lt 512; $i++) {
            $d = $descriptor+20*$i
            $nameRva = U32 ($d+12)
            if ($nameRva -eq 0) { break }
            $imports += AsciiZ (RvaOffset $nameRva)
        }
    }
    $versionStrings = @()
    if ([IO.Path]::GetFileName($Path) -ieq 'LuaPlus.dll') {
        $ascii = [Text.Encoding]::ASCII.GetString($data)
        $versionStrings = @([regex]::Matches($ascii, '[\x20-\x7e]{6,}') | ForEach-Object Value | Where-Object { $_ -match 'Lua\s+[0-9]\.[0-9]|LuaPlus.*[0-9]\.[0-9]' } | Select-Object -Unique -First 12)
    }
    [PSCustomObject]@{
        Architecture=if($machine -eq 0x8664){'x64'}elseif($machine -eq 0x14C){'x86'}else{'0x{0:X4}' -f $machine}
        PeFormat=if($magic -eq 0x20B){'PE32+'}else{'PE32'}
        ImportedLibraries=$imports
        NamedExportCount=$exportNames.Count
        ExportNames=$exportNames
        LuaVersionStrings=$versionStrings
    }
}

Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public static class TlbbReadOnlyProbe {
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern IntPtr OpenProcess(uint access, bool inherit, uint pid);
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern bool ReadProcessMemory(IntPtr process, IntPtr address, byte[] buffer, UIntPtr size, out UIntPtr read);
    [DllImport("kernel32.dll")]
    static extern bool CloseHandle(IntPtr handle);
    delegate bool EnumCallback(IntPtr window, IntPtr parameter);
    [DllImport("user32.dll", SetLastError=true)]
    static extern bool EnumWindows(EnumCallback callback, IntPtr parameter);
    [DllImport("user32.dll")]
    static extern uint GetWindowThreadProcessId(IntPtr window, out uint pid);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)]
    static extern int GetWindowText(IntPtr window, StringBuilder text, int count);
    [DllImport("user32.dll", CharSet=CharSet.Unicode)]
    static extern int GetClassName(IntPtr window, StringBuilder text, int count);
    [DllImport("user32.dll")]
    static extern bool IsWindowVisible(IntPtr window);
    [DllImport("kernel32.dll")]
    static extern uint GetCurrentThreadId();
    [DllImport("user32.dll", SetLastError=true)]
    static extern IntPtr GetThreadDesktop(uint threadId);
    [DllImport("user32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    static extern bool GetUserObjectInformation(IntPtr obj, int index, StringBuilder information, uint bytes, out uint needed);
    public sealed class ProbeResult {
        public bool OpenSucceeded;
        public int OpenError;
        public bool ReadSucceeded;
        public int ReadError;
        public ulong BytesRead;
        public string FirstTwoBytes;
    }
    public sealed class WindowResult {
        public long Handle;
        public string Title;
        public string Class;
        public bool Visible;
    }
    public sealed class WindowEnumerationResult {
        public bool Succeeded;
        public int Error;
        public int TopLevelWindowsSeen;
        public WindowResult[] TargetWindows;
    }
    public static string ThreadDesktop(uint threadId) {
        IntPtr desktop = GetThreadDesktop(threadId == 0 ? GetCurrentThreadId() : threadId);
        if (desktop == IntPtr.Zero) return "Unavailable:" + Marshal.GetLastWin32Error();
        var name = new StringBuilder(512);
        uint needed;
        return GetUserObjectInformation(desktop, 2, name, 1024, out needed) ? name.ToString() : "Unavailable:" + Marshal.GetLastWin32Error();
    }
    public static ProbeResult Probe(uint pid, long moduleBase) {
        var result = new ProbeResult();
        // Read and limited-query rights only. No writes, allocation or execution.
        IntPtr handle = OpenProcess(0x1010, false, pid);
        result.OpenSucceeded = handle != IntPtr.Zero;
        result.OpenError = result.OpenSucceeded ? 0 : Marshal.GetLastWin32Error();
        if (!result.OpenSucceeded) return result;
        try {
            byte[] bytes = new byte[64];
            UIntPtr read;
            result.ReadSucceeded = ReadProcessMemory(handle, new IntPtr(moduleBase), bytes, new UIntPtr(64), out read);
            result.ReadError = result.ReadSucceeded ? 0 : Marshal.GetLastWin32Error();
            result.BytesRead = read.ToUInt64();
            result.FirstTwoBytes = result.BytesRead >= 2 ? BitConverter.ToString(bytes, 0, 2) : "";
        } finally { CloseHandle(handle); }
        return result;
    }
    public static WindowEnumerationResult Windows(uint targetPid) {
        var results = new List<WindowResult>();
        int seen = 0;
        EnumCallback callback = delegate(IntPtr window, IntPtr parameter) {
            seen++;
            uint pid;
            GetWindowThreadProcessId(window, out pid);
            if (pid == targetPid) {
                var title = new StringBuilder(1024);
                var cls = new StringBuilder(256);
                GetWindowText(window, title, title.Capacity);
                GetClassName(window, cls, cls.Capacity);
                results.Add(new WindowResult {Handle=window.ToInt64(),Title=title.ToString(),Class=cls.ToString(),Visible=IsWindowVisible(window)});
            }
            return true;
        };
        bool success = EnumWindows(callback, IntPtr.Zero);
        int error = success ? 0 : Marshal.GetLastWin32Error();
        GC.KeepAlive(callback);
        return new WindowEnumerationResult {Succeeded=success,Error=error,TopLevelWindowsSeen=seen,TargetWindows=results.ToArray()};
    }
}
'@

$relativeFiles = @('Launch.exe','Bin\Game.exe','Bin64\Game.exe','Bin64\LuaPlus.dll','Bin64\tEngine.dll','Bin64\PathLib.dll','Bin64\UI_CEGUI.dll','Bin\autohelp.dll')
$fileReports = foreach ($relative in $relativeFiles) {
    $path = Join-Path $rootPath $relative
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { continue }
    $item = Get-Item -LiteralPath $path
    $hashBefore = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    $peInfo = Get-PeInfo $path
    $hashAfter = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash
    [PSCustomObject]@{Path=$path;Bytes=$item.Length;FileVersion=$item.VersionInfo.FileVersion;ProductVersion=$item.VersionInfo.ProductVersion;Description=$item.VersionInfo.FileDescription;Company=$item.VersionInfo.CompanyName;SHA256Before=$hashBefore;SHA256After=$hashAfter;UnchangedDuringInspection=($hashBefore -eq $hashAfter);PE=$peInfo}
}

$processReports = foreach ($gameProcess in @(Get-Process -Name Game -ErrorAction SilentlyContinue)) {
    $imagePath = $gameProcess.Path
    if (!$imagePath -or !$imagePath.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase)) { continue }
    $startTime = $gameProcess.StartTime
    $modules = @($gameProcess.Modules)
    $mainModule = $gameProcess.MainModule
    # Recheck identity immediately before the read-only live-memory probe.
    $check = Get-Process -Id $gameProcess.Id -ErrorAction Stop
    if ($check.Path -ine $imagePath -or $check.StartTime -ne $startTime) { throw 'Game process identity changed' }
    $probe = [TlbbReadOnlyProbe]::Probe([uint32]$gameProcess.Id,$mainModule.BaseAddress.ToInt64())
    [PSCustomObject]@{
        PID=$gameProcess.Id
        Path=$imagePath
        StartTime=$startTime.ToString('o')
        SessionId=$gameProcess.SessionId
        InspectionSessionId=(Get-Process -Id $PID).SessionId
        InspectionDesktop=[TlbbReadOnlyProbe]::ThreadDesktop(0)
        GameThreadDesktopNames=@($gameProcess.Threads | Select-Object -First 16 | ForEach-Object { [TlbbReadOnlyProbe]::ThreadDesktop([uint32]$_.Id) } | Select-Object -Unique)
        ModuleCount=$modules.Count
        GameDirectoryModules=@($modules | Where-Object { $_.FileName.StartsWith($rootPrefix,[StringComparison]::OrdinalIgnoreCase) } | Select-Object ModuleName,FileName,ModuleMemorySize)
        HeaderReadProbe=$probe
        WindowEnumeration=[TlbbReadOnlyProbe]::Windows([uint32]$gameProcess.Id)
    }
}

$report = [PSCustomObject]@{
    InspectedAt=[DateTimeOffset]::Now.ToString('o')
    GameRoot=$rootPath
    Scope='Read-only metadata, PE imports/exports, modules, windows, and 64-byte executable-header read; no gameplay state discovery or action execution.'
    Files=@($fileReports)
    Processes=@($processReports)
}
$reportPath = Join-Path $outputRoot 'tlbb-readonly-inspection.json'
$report | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $reportPath -Encoding UTF8
[PSCustomObject]@{
    Report=$reportPath
    InspectedAt=$report.InspectedAt
    FileCount=@($fileReports).Count
    AllInspectedHashesUnchanged=(@($fileReports | Where-Object { !$_.UnchangedDuringInspection }).Count -eq 0)
    Processes=@($processReports | Select-Object PID,Path,SessionId,InspectionSessionId,InspectionDesktop,GameThreadDesktopNames,ModuleCount,HeaderReadProbe,WindowEnumeration)
    FileSummary=@($fileReports | ForEach-Object { [PSCustomObject]@{Path=$_.Path;Architecture=$_.PE.Architecture;FileVersion=$_.FileVersion;Description=$_.Description;NamedExportCount=$_.PE.NamedExportCount;LuaVersionStrings=$_.PE.LuaVersionStrings} })
} | ConvertTo-Json -Depth 8
