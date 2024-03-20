#Requires -Version 7

$configFile = "$PSScriptRoot/config.json"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.json not found. exiting"
    return
}

$(Get-Content $configFile | ConvertFrom-Json).print_hosts | Foreach-Object  -Parallel {
    $ps_host = $_
    $session = New-PSSession -ComputerName $ps_host

    $script = {
        get-childitem -path "\eNVenta" -recurse -include PrintServiceRestart.exe | ForEach-Object {
            Start-Process $_
            Write-Output "done $ps_host $_"
        }
    }

    Invoke-Command -ScriptBlock $script -Session $session
}