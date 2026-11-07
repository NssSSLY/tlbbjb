param([switch]$PriorLoginBuilds)
$ErrorActionPreference='Stop'
$taskRoot=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$taskDist=[IO.Path]::GetFullPath((Join-Path $taskRoot 'dist'))
$taskPreparationName=if($PriorLoginBuilds){'artifacts\legacy-cleanup-preparation-0.4.json'}else{'artifacts\legacy-cleanup-preparation.json'}
$taskPreparation=Get-Content -LiteralPath (Join-Path $taskRoot $taskPreparationName) -Raw | ConvertFrom-Json
$taskBackup=[IO.Path]::GetFullPath($taskPreparation.archive)
if(!$taskBackup.StartsWith((Join-Path $taskRoot 'user-data\legacy-backups')+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Backup is outside intended private backup directory'}
if((Get-FileHash -LiteralPath $taskBackup -Algorithm SHA256).Hash -ne $taskPreparation.archive_sha256){throw 'Backup hash mismatch'}
$taskReferences=Get-Content -LiteralPath (Join-Path $taskRoot 'artifacts\legacy-runtime-references.json') -Raw | ConvertFrom-Json
$taskAllowed=@('TLBBClient','TLBBClient-0.3.0','packages\TLBBClient-0.3.0-full.zip','packages\TLBBClient-0.3.0-Setup.exe') | ForEach-Object {[IO.Path]::GetFullPath((Join-Path $taskDist $_))}
if($PriorLoginBuilds){$taskAllowed=@('TLBBClient-0.4.0','TLBBClient-0.4.0-login-test','TLBBClient-0.4.1','packages\TLBBClient-0.4.0-full.zip','packages\TLBBClient-0.4.0-Setup.exe','packages\TLBBClient-0.4.1-full.zip','packages\TLBBClient-0.4.1-Setup.exe') | ForEach-Object {[IO.Path]::GetFullPath((Join-Path $taskDist $_))}}
$taskProcesses=@(Get-CimInstance Win32_Process | Where-Object {$_.ExecutablePath})
foreach($taskFile in $taskPreparation.preserved_files){if(Test-Path -LiteralPath $taskFile.source){if((Get-FileHash -LiteralPath $taskFile.source -Algorithm SHA256).Hash -ne $taskFile.sha256){throw 'A preserved file changed after backup; cleanup aborted'}}}
$taskTargets=@()
foreach($taskCandidate in $taskPreparation.deletion_targets){
    $taskResolved=[IO.Path]::GetFullPath((Resolve-Path -LiteralPath $taskCandidate).ProviderPath)
    if(!$taskResolved.StartsWith($taskDist+'\',[StringComparison]::OrdinalIgnoreCase) -or $taskResolved -notin $taskAllowed){throw 'Deletion target is outside exact legacy allowlist'}
    $taskItem=Get-Item -LiteralPath $taskResolved -Force
    if($taskItem.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Reparse point cleanup target rejected'}
    if($taskItem.PSIsContainer){
        if(@(Get-ChildItem -LiteralPath $taskResolved -Recurse -Force | Where-Object {$_.Attributes -band [IO.FileAttributes]::ReparsePoint}).Count){throw 'Reparse point inside legacy runtime rejected'}
        $taskPrefix=$taskResolved+'\'
        if(@($taskProcesses | Where-Object {$_.ExecutablePath.StartsWith($taskPrefix,[StringComparison]::OrdinalIgnoreCase)}).Count){throw 'A legacy executable is running'}
        if(@($taskReferences.Shortcuts | Where-Object {$_.Target -and $_.Target.StartsWith($taskPrefix,[StringComparison]::OrdinalIgnoreCase)}).Count){throw 'A shortcut still references a legacy runtime'}
        if(@($taskReferences.Installed | Where-Object {$_.Location -and $_.Location.StartsWith($taskPrefix,[StringComparison]::OrdinalIgnoreCase)}).Count){throw 'A registered installation still references a legacy runtime'}
        $taskSize=(Get-ChildItem -LiteralPath $taskResolved -Recurse -File -Force | Measure-Object -Property Length -Sum).Sum
    }else{$taskSize=$taskItem.Length}
    $taskTargets+=[PSCustomObject]@{Path=$taskResolved;Directory=[bool]$taskItem.PSIsContainer;Bytes=[long]$taskSize}
}
foreach($taskTarget in $taskTargets){if($taskTarget.Directory){Remove-Item -LiteralPath $taskTarget.Path -Recurse -Force}else{Remove-Item -LiteralPath $taskTarget.Path -Force}}
$taskResultName=if($PriorLoginBuilds){'artifacts\legacy-cleanup-result-0.4.json'}else{'artifacts\legacy-cleanup-result.json'}
[PSCustomObject]@{Status='completed';Removed=$taskTargets;ReclaimedBytes=($taskTargets | Measure-Object -Property Bytes -Sum).Sum;PrivateBackup=$taskBackup;PreservedFileCount=$taskPreparation.preserved_files.Count;RegisteredPreviewKept=$true} | ConvertTo-Json -Depth 6 | Tee-Object -FilePath (Join-Path $taskRoot $taskResultName)
