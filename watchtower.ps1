#Requires -Version 5.1
#Requires -RunAsAdministrator

$dir = "C:\temp\eNVenta\"

$files = Get-Childitem -Path $dir -Filter "*.zip" -ErrorAction SilentlyContinue
if ($files.length -eq 0) {
    write-host "nothing found"
    exit 0
}

$files | ForEach-Object {
    $file = $_
    $dest = "C:\temp\eNVenta\$($file.Basename)"
    Expand-Archive -Path "$($dir)\$($file)" -DestinationPath $dest

    $cliArgs = @(
        "-C",
        "$dest\publish.ps1"
    )

    $p = Start-Process "powershell.exe" -ArgumentList $cliArgs -PassThru -NoNewWindow -Wait

    if ($p.ExitCode -ne 0) {
        Write-Error "Execution stopped with code $($p.ExitCode)"
    }
    else {
        Move-Item "$($dir)\$($file)" "C:\temp\eNVenta\archive"
    }

    Write-Output "process exited with code $($p.ExitCode) at $($p.ExitTime)"
    Remove-Item -Recurse $dest
    Exit $p.ExitCode
}
