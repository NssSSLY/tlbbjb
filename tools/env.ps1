# Dot-source to activate tools only in the current PowerShell process.
$taskWorkspace = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskTools = Join-Path $taskWorkspace '.tools'
# Keep build subprocess temporary files and package caches inside this project.
# These assignments affect only this PowerShell process and its children.
$taskTemp = Join-Path $taskTools 'temp'
$taskPipCache = Join-Path $taskTools 'cache\pip'
$taskPythonCache = Join-Path $taskTools 'cache\pycache'
foreach ($taskDirectory in @($taskTemp, $taskPipCache, $taskPythonCache)) {
    New-Item -ItemType Directory -Path $taskDirectory -Force | Out-Null
}
$env:TEMP = $taskTemp
$env:TMP = $taskTemp
$env:PIP_CACHE_DIR = $taskPipCache
$env:PYTHONPYCACHEPREFIX = $taskPythonCache
$env:TLBB_QT_ROOT = Join-Path $taskTools 'Qt\6.8.3\mingw_64'
$env:TLBB_MINGW_ROOT = Join-Path $taskTools 'Qt\Tools\mingw1310_64'
$env:TLBB_LUA_SOURCE = Join-Path $taskTools 'src\lua-5.4.9'
$taskBins = @(
    (Join-Path $taskTools 'cmake\bin'),
    (Join-Path $taskTools 'ninja'),
    (Join-Path $env:TLBB_MINGW_ROOT 'bin'),
    (Join-Path $env:TLBB_QT_ROOT 'bin')
)
foreach ($taskBin in $taskBins) {
    if (!(Test-Path -LiteralPath $taskBin)) { throw "Missing build tool directory: $taskBin" }
}
$taskExisting = @($env:PATH -split ';' | Where-Object { $_ -and $_ -notin $taskBins })
$env:PATH = ($taskBins + $taskExisting) -join ';'
$env:CMAKE_PREFIX_PATH = $env:TLBB_QT_ROOT
