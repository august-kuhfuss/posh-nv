function Copy-CrystalReports {
    param(
        [string[]]$DestinationHosts
    )

    $config = Get-NVConfig

    # if empty, copy to all hosts
    if ($null -eq $DestinationHosts) {
        $DestinationHosts = $config.app_hosts
    }

    $hosts = $config.app_hosts | Where-Object {
        $DestinationHosts -match $_
    }

    # if no matches, error
    if ($hosts.Count -eq 0) {
        Write-Output "host(s) `"$($DestinationHosts -join ", ")`" not found. exiting"
        return
    }

    # create zip
    $zip = "$env:TEMP/reports.zip"
    Compress-Archive -Force "$($config.reports_source)/*.rpt" $zip

    # copy and expand
    $hosts | ForEach-Object {
        $hst = $PSItem
        $session = New-PSSession -ComputerName $hst
        $zipZip = "$env:TEMP/reports.zip"

        Copy-Item -Path $zip -Destination $zipZip -ToSession $session

        Invoke-Command -Session $session -ScriptBlock {
            $zipZip = "$env:TEMP/reports.zip"

            # get all folders Report under C:/eNVenta/*/Report
            $rptFolders = Get-ChildItem -Path "C:/eNVenta" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
                $_.Name -eq "Report"
            }

            # expand zip into rptFolders
            $rptFolders.FullName | ForEach-Object {
                Expand-Archive -Force -Path $zipZip -Destination $_
            }

            # remove zip
            Remove-Item -Path $zipZip
        }

        Remove-PSSession $session
    }

    Remove-Item -r -force $zip
}
Export-ModuleMember -Function Copy-CrystalReports
