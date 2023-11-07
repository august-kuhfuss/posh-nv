$configFile = "$PSScriptRoot/config.toml"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.toml not found. exiting"
    return
}
$config = Get-Content $configFile | ConvertFrom-Toml

$hosts = $config.printHosts

$hosts | Foreach-Object  -Parallel {
    $session = New-PSSession -ComputerName $_

    $script = {
        get-childitem -path "\eNVenta" -recurse -include PrintServiceRestart.exe | ForEach-Object {
            Start-Process $_
            Write-Output "done $_"
        }
    }

    Invoke-Command -ScriptBlock $script -Session $session
}