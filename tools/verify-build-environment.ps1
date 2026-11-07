param([ValidateRange(1,8)][int]$Jobs = 4)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskBuild = Join-Path $taskRoot '.tools\build\environment-smoke'
$taskArtifacts = Join-Path $taskRoot 'artifacts'
New-Item -ItemType Directory -Path $taskArtifacts -Force | Out-Null
& cmake -S (Join-Path $PSScriptRoot 'environment-smoke') -B $taskBuild -G Ninja `
    '-DCMAKE_BUILD_TYPE=Release' "-DCMAKE_C_COMPILER=$env:TLBB_MINGW_ROOT/bin/gcc.exe" `
    "-DCMAKE_CXX_COMPILER=$env:TLBB_MINGW_ROOT/bin/g++.exe" `
    "-DCMAKE_PREFIX_PATH=$env:TLBB_QT_ROOT" "-DTLBB_LUA_SOURCE=$env:TLBB_LUA_SOURCE"
if ($LASTEXITCODE -ne 0) { throw 'Environment configure failed' }
& cmake --build $taskBuild --parallel $Jobs
if ($LASTEXITCODE -ne 0) { throw 'Environment compilation failed' }
& ctest --test-dir $taskBuild --output-on-failure --output-junit (Join-Path $taskArtifacts 'environment-ctest.xml')
if ($LASTEXITCODE -ne 0) { throw 'Environment smoke tests failed' }
& (Join-Path $taskBuild 'environment_smoke.exe') (Join-Path $taskArtifacts 'environment-smoke.json')
if ($LASTEXITCODE -ne 0) { throw 'Environment report failed' }
