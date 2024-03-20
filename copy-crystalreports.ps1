param(
    [string[]]$DestinationHosts
)

$config = Get-Content "$PSScriptRoot\config.json" | ConvertFrom-Json

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
$source = "$env:USERPROFILE/FS45/Compile/KUHFDB5N.KUHFUSS_1_NVRep_Kuhfuss_4.5_sotnikow/Report"
$zip = "$env:TEMP/reports.zip"
Compress-Archive -Force "$source/*.rpt" $zip

# copy and expand
$hosts | ForEach-Object {
    $hst = $PSItem
    $session = New-PSSession -ComputerName $hst
    $dstZip = "$env:TEMP/reports.zip"

    Copy-Item -Path $zip -Destination $dstZip -ToSession $session

    Invoke-Command -Session $session -ScriptBlock {
        $dstZip = "$env:TEMP/reports.zip"

        # get all folders Report under C:/eNVenta/*/Report
        $rptFolders = Get-ChildItem -Path "C:/eNVenta" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object {
            $_.Name -eq "Report"
        }

        # expand zip into rptFolders
        $rptFolders.FullName | ForEach-Object {
            Expand-Archive -Force -Path $dstZip -Destination $_
        }

        # remove zip
        Remove-Item -Path $dstZip
    }

    Remove-PSSession $session
}

Remove-Item -r -force $zip
