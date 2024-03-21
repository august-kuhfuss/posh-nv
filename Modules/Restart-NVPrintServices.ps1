function Restart-NVPrintServices {
    Get-NVPrintHosts | Foreach-Object -Parallel {
        $ps_host = $PSItem
        $session = New-PSSession -ComputerName $ps_host

        $script = {
            get-childitem -path "\eNVenta" -recurse -include PrintServiceRestart.exe | ForEach-Object {
                Start-Process $_
                Write-Output "done $ps_host $_"
            }
        }

        Invoke-Command -ScriptBlock $script -Session $session
    }
}
Export-ModuleMember -Function Restart-NVPrintServices

