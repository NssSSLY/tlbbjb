param([ValidateRange(1,8)][int]$Jobs=4,[switch]$SkipTests)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskBuild=Join-Path $taskRoot '.tools\build\client-0.15.0'
$taskRelease=Join-Path $taskRoot 'dist\TLBBClient-0.15.0'
$taskExe=Join-Path $taskRelease 'TLBB.exe'
$running=@(Get-Process -Name TLBB -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $taskExe })
if($running.Count){throw '请先从托盘退出发布目录中的 TLBB 客户端，再生成新版；不需要关闭游戏。'}
& cmake -S $taskRoot -B $taskBuild -G Ninja '-DCMAKE_BUILD_TYPE=Release' `
    "-DCMAKE_C_COMPILER=$env:TLBB_MINGW_ROOT/bin/gcc.exe" "-DCMAKE_CXX_COMPILER=$env:TLBB_MINGW_ROOT/bin/g++.exe" `
    "-DCMAKE_PREFIX_PATH=$env:TLBB_QT_ROOT" "-DTLBB_LUA_SOURCE=$env:TLBB_LUA_SOURCE" '-DTLBB_PACKAGED=ON'
if($LASTEXITCODE -ne 0){throw 'Client configure failed'}
& cmake --build $taskBuild --parallel $Jobs
if($LASTEXITCODE -ne 0){throw 'Client compilation failed'}
if(!$SkipTests){
    & ctest --test-dir $taskBuild --output-on-failure --output-junit (Join-Path $taskRoot 'artifacts\client-ctest.xml')
    if($LASTEXITCODE -ne 0){throw 'Client tests failed; package was not updated'}
    Copy-Item -LiteralPath (Join-Path $taskBuild 'self-test.json') -Destination (Join-Path $taskRoot 'artifacts\client-self-test.json') -Force
}
New-Item -ItemType Directory -Path $taskRelease -Force | Out-Null
# Layout users see: TLBB.exe, TLBBRuntime.dll, TLBBEngine.dll, scripts\, data\. Everything else lives inside TLBBRuntime.dll.
$taskReleaseAbsolute=[IO.Path]::GetFullPath($taskRelease)
foreach($taskOld in @('Qt6Core.dll','Qt6Gui.dll','Qt6Widgets.dll','Qt6Network.dll','libgcc_s_seh-1.dll','libstdc++-6.dll','libwinpthread-1.dll','qt.conf','TLBBData.rcc','platforms','styles','generic','networkinformation','tls','imageformats','overrides','cache','logs','scripts\builtin','scripts\tasks','package-manifest.json','使用说明.md','THIRD_PARTY_NOTICES.txt','LICENSE-LGPL-3.0.txt','LICENSE-LUA.txt','sanhuan-flow-tests.json','sijue-tests.json','water-prison-tests.json','yanzi-tests.json','TLBBNativeBridge.dll','TLBBLoginBridge.dll','TLBBGameplayBridge.dll')){
    $taskOldPath=[IO.Path]::GetFullPath((Join-Path $taskReleaseAbsolute $taskOld))
    if(!$taskOldPath.StartsWith($taskReleaseAbsolute+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Release prune boundary mismatch'}
    if(Test-Path -LiteralPath $taskOldPath){Remove-Item -LiteralPath $taskOldPath -Recurse -Force}
}
Copy-Item -LiteralPath (Join-Path $taskBuild 'launcher\TLBB.exe') -Destination $taskExe -Force
Copy-Item -LiteralPath (Join-Path $taskBuild 'TLBBEngine.dll') -Destination (Join-Path $taskRelease 'TLBBEngine.dll') -Force
$taskRuntime=Join-Path $taskBuild 'runtime-stage'
if(Test-Path -LiteralPath $taskRuntime){Remove-Item -LiteralPath $taskRuntime -Recurse -Force}
New-Item -ItemType Directory -Path $taskRuntime -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $taskBuild 'TLBBApp.dll') -Destination (Join-Path $taskRuntime 'TLBBApp.dll') -Force
# Windows PowerShell 5.1 turns native stderr warnings into terminating errors under Stop.
$taskPreference=$ErrorActionPreference;$ErrorActionPreference='Continue'
& (Join-Path $env:TLBB_QT_ROOT 'bin\windeployqt.exe') --release --compiler-runtime --no-translations `
    --no-opengl-sw --no-system-d3d-compiler --dir $taskRuntime (Join-Path $taskRuntime 'TLBBApp.dll') 2>&1 |
    Tee-Object -FilePath (Join-Path $taskRoot 'artifacts\client-deployment.log')
$taskDeployExit=$LASTEXITCODE;$ErrorActionPreference=$taskPreference
if($taskDeployExit -ne 0){throw 'Client runtime deployment failed'}
# This Widgets client uses no networking, image codecs, touch input, or TLS plugins.
# Prune only regenerable output inside this version's verified release directory.
foreach($taskUnused in @('generic','networkinformation','tls','imageformats','Qt6Network.dll')){
    $taskUnusedPath=Join-Path $taskRuntime $taskUnused
    if(Test-Path -LiteralPath $taskUnusedPath){Remove-Item -LiteralPath $taskUnusedPath -Recurse -Force}
}
& python -B (Join-Path $PSScriptRoot 'make-runtime-pack.py') $taskRuntime (Join-Path $taskRelease 'TLBBRuntime.dll') --mingw $env:TLBB_MINGW_ROOT --work (Join-Path $taskBuild 'runtime-pack')
if($LASTEXITCODE -ne 0){throw 'Runtime pack failed'}
# Rule scripts stay plain files under scripts\, editable in place; only data\ holds accounts, logs and what the program writes.
$taskScripts=Join-Path $taskRelease 'scripts'
foreach($taskFile in @(Get-ChildItem -LiteralPath (Join-Path $taskRoot 'scripts') -Recurse -File)){
    $taskRelative=$taskFile.FullName.Substring((Join-Path $taskRoot 'scripts').Length+1)
    if($taskRelative -match '^(user|__pycache__)\\' -or $taskRelative -match '\\__pycache__\\' -or $taskRelative -match '^original-library\\[^\\]+\.bin$'){continue}
    $taskTarget=Join-Path (Join-Path $taskScripts 'builtin') $taskRelative
    New-Item -ItemType Directory -Path (Split-Path -Parent $taskTarget) -Force | Out-Null
    Copy-Item -LiteralPath $taskFile.FullName -Destination $taskTarget -Force
}
New-Item -ItemType Directory -Path (Join-Path $taskScripts 'tasks') -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $taskRoot 'design\task-catalog.json') -Destination (Join-Path $taskScripts 'tasks\catalog.json') -Force
foreach($taskSubdir in @('scripts\user','data\profiles','data\logs','data\cache','data\docs')){New-Item -ItemType Directory -Path (Join-Path $taskRelease $taskSubdir) -Force | Out-Null}
Copy-Item -LiteralPath (Join-Path $taskRoot 'packaging\使用说明.md') -Destination (Join-Path $taskRelease 'data\docs\使用说明.md') -Force
Copy-Item -LiteralPath (Join-Path $taskRoot 'packaging\THIRD_PARTY_NOTICES.txt') -Destination (Join-Path $taskRelease 'data\docs\THIRD_PARTY_NOTICES.txt') -Force
Copy-Item -LiteralPath (Join-Path $taskRoot 'packaging\LICENSE-LGPL-3.0.txt') -Destination (Join-Path $taskRelease 'data\docs\LICENSE-LGPL-3.0.txt') -Force
[PSCustomObject]@{Executable=$taskExe;SHA256=(Get-FileHash -LiteralPath $taskExe).Hash;TestsSkipped=[bool]$SkipTests;UserDataPreserved=$true} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskRoot 'artifacts\client-build.json') -Encoding UTF8
Write-Output "客户端已生成：$taskExe"
