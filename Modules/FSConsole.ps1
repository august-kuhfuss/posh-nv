function Get-FSConsole {
    $defaultCli = $(Get-Childitem -Path "$env:ProgramFiles\Framework Systems\" -Recurse -Force "FSConsole.exe" -ErrorAction SilentlyContinue) | Select-Object -First 1
    if ($null -eq $defaultCli) {
        Write-Output "FSConsole.exe not found. Please install Framework Studio"
        return
    }
    return $defaultCli
}
Export-ModuleMember -Function Get-FSConsole