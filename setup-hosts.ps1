$configFile = "$PSScriptRoot/config.toml"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.toml not found. exiting"
    return
}
$config = Get-Content $configFile | ConvertFrom-Toml

$hosts = $config.hosts

$hosts | ForEach-Object -Parallel {
    $session = New-PSSession $_

    Invoke-Command -Session $session -ScriptBlock {
        New-Item -ItemType Directory "/temp/eNVenta/archive" -ErrorAction SilentlyContinue
        New-Item -ItemType Directory "/eNVenta/scripts" -ErrorAction SilentlyContinue
    }

    Copy-Item -Path "$($using:PSScriptRoot)/watchtower.ps1" -Destination "c:/eNVenta/scripts/watchtower.ps1" -ToSession $session
}