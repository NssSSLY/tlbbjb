$ErrorActionPreference='Stop'
$env:PYTHONIOENCODING='utf-8'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskPython='C:\Users\liqia\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $taskPython -B (Join-Path $taskRoot 'tools\validate-navigation.py')
if($LASTEXITCODE -ne 0){throw 'Navigation data validation failed'}
$taskLua=Join-Path $taskRoot '.tools\bin\lua-navigation-tests.exe'
if(!(Test-Path -LiteralPath $taskLua)){
    New-Item -ItemType Directory -Path (Split-Path -Parent $taskLua) -Force | Out-Null
    & gcc '-O2' '-static' "-I$env:TLBB_LUA_SOURCE/src" (Join-Path $env:TLBB_LUA_SOURCE 'src\lua.c') (Join-Path $taskRoot '.tools\build\client\libtlbb_lua.a') '-lm' '-o' $taskLua
    if($LASTEXITCODE -ne 0){throw 'Lua fixture runner build failed'}
}
$taskReport=& $taskLua (Join-Path $taskRoot 'tests\navigation_planner_tests.lua') $taskRoot
if($LASTEXITCODE -ne 0){throw 'Navigation planner fixtures failed'}
$taskReport | ConvertFrom-Json | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskRoot 'artifacts\navigation\planner-verification.json') -Encoding utf8
Write-Output $taskReport
