$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskDeploy = Join-Path $taskRoot '.tools\deploy\environment-smoke'
$taskBuildExe = Join-Path $taskRoot '.tools\build\environment-smoke\environment_smoke.exe'
New-Item -ItemType Directory -Path $taskDeploy -Force | Out-Null
Copy-Item -LiteralPath $taskBuildExe -Destination (Join-Path $taskDeploy 'environment_smoke.exe') -Force
& (Join-Path $env:TLBB_QT_ROOT 'bin\windeployqt.exe') --release --compiler-runtime `
    --no-translations --no-opengl-sw --no-system-d3d-compiler --dir $taskDeploy `
    (Join-Path $taskDeploy 'environment_smoke.exe') 2>&1 |
    Tee-Object -FilePath (Join-Path $taskRoot 'artifacts\environment-deployment.log')
if ($LASTEXITCODE -ne 0) { throw 'Qt runtime deployment failed' }
@('[Paths]', 'Prefix=.', 'Plugins=.') | Set-Content -LiteralPath (Join-Path $taskDeploy 'qt.conf') -Encoding ascii
$taskOriginalPath = $env:PATH
$taskOriginalPluginPath = $env:QT_PLUGIN_PATH
$taskOriginalQpaPath = $env:QT_QPA_PLATFORM_PLUGIN_PATH
try {
    $env:PATH = "$env:SystemRoot\System32;$env:SystemRoot"
    $env:QT_PLUGIN_PATH = $null
    $env:QT_QPA_PLATFORM_PLUGIN_PATH = $null
    & (Join-Path $taskDeploy 'environment_smoke.exe') (Join-Path $taskRoot 'artifacts\environment-deployment.json')
    if ($LASTEXITCODE -ne 0) { throw 'Isolated deployment run failed' }
} finally {
    $env:PATH = $taskOriginalPath
    $env:QT_PLUGIN_PATH = $taskOriginalPluginPath
    $env:QT_QPA_PLATFORM_PLUGIN_PATH = $taskOriginalQpaPath
}
