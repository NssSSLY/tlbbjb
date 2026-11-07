param([switch]$UseVerifiedRelease,[switch]$IncludeZip)
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'env.ps1')
$taskWorkspace=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskPython='C:\Users\liqia\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$taskStage=Join-Path $taskWorkspace 'dist\TLBBClient-0.15.0'
$taskOutput=Join-Path $taskWorkspace 'dist\packages'
if(!$UseVerifiedRelease){
    & (Join-Path $PSScriptRoot 'build-client.ps1')
    & $taskPython -B (Join-Path $PSScriptRoot 'verify-release.py')
    if($LASTEXITCODE -ne 0){throw 'Native release verification failed'}
}
$taskVerification=Get-Content -LiteralPath (Join-Path $taskWorkspace 'artifacts\release-verification-0.15.0.json') -Raw | ConvertFrom-Json
$taskHash=(Get-FileHash -LiteralPath (Join-Path $taskStage 'TLBB.exe') -Algorithm SHA256).Hash
if($taskVerification.status -ne 'pass' -or $taskVerification.sha256 -ne $taskHash){throw 'The release has not passed verification at its current hash'}
$taskEngineHash=(Get-FileHash -LiteralPath (Join-Path $taskStage 'TLBBEngine.dll') -Algorithm SHA256).Hash
if($taskVerification.engine_sha256 -ne $taskEngineHash){throw 'The engine DLL differs from the verified release'}
& $taskPython -B (Join-Path $PSScriptRoot 'verify-original-rules.py')
if($LASTEXITCODE -ne 0){throw 'Original-rule provenance verification failed'}
& $taskPython -B (Join-Path $PSScriptRoot 'verify-daily-rules.py')
if($LASTEXITCODE -ne 0){throw 'Daily-rule completion verification failed'}
if($IncludeZip){& $taskPython -B (Join-Path $PSScriptRoot 'package-client.py') --include-zip}else{& $taskPython -B (Join-Path $PSScriptRoot 'package-client.py')}
if($LASTEXITCODE -ne 0){throw 'Package collection failed'}
$taskCompiler=Join-Path $taskWorkspace '.tools\inno\compiler\ISCC.exe'
if(!(Test-Path -LiteralPath $taskCompiler)){throw 'Missing project-local Inno compiler: .tools\inno\compiler\ISCC.exe'}
& $taskCompiler '--quiet' "--define=StageDir=$taskStage" "--define=OutputDir=$taskOutput" (Join-Path $taskWorkspace 'packaging\tlbb.iss')
if($LASTEXITCODE -ne 0){throw 'Installer compilation failed'}
$taskInstaller=Join-Path $taskOutput 'TLBBClient-0.15.0-Setup.exe'
[PSCustomObject]@{Installer=$taskInstaller;Bytes=(Get-Item -LiteralPath $taskInstaller).Length;SHA256=(Get-FileHash -LiteralPath $taskInstaller -Algorithm SHA256).Hash;Signed=$false;ExecutableSHA256=$taskHash;VerifiedRelease=$true} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $taskWorkspace 'artifacts\installer-build-0.15.0.json') -Encoding utf8
Write-Output "安装包已生成：$taskInstaller"
