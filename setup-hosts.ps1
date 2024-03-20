#Requires -Version 5.1

$configFile = "$PSScriptRoot/config.json"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.json not found. exiting"
    return
}

$(Get-Content $configFile | ConvertFrom-Json).app_hosts | ForEach-Object -Parallel {
    $app_host = $PSItem
    $session = New-PSSession $app_host

    $script = {
        New-Item -ItemType Directory "/temp/eNVenta/archive" -ErrorAction SilentlyContinue
    }

    Write-Host "finished setup $app_host"

    Invoke-Command -ScriptBlock $script -Session $session
}