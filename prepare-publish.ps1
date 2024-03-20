#Requires -Version 7

param(
    [Parameter(Mandatory)]
    [string[]]$Configs
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$configFile = "$PSScriptRoot\config.json"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.json not found. exiting"
    return
}
$config = Get-Content $configFile | ConvertFrom-Json

$settings = $config.packages | ForEach-Object {
    $package = $PSItem
    $package.versions | ForEach-Object {
        $version = $PSItem
        $version.configurations | ForEach-Object {
            $c = $PSItem
            [PSCustomObject]@{
                package = $package
                version = $version
                config  = $c
            }
        }
    }
} | Where-Object {
    # split package:version:config from $configs
    $Configs -match "$($PSItem.package.name):$($PSItem.version.name):$($PSItem.config.short_name)"
}

$repo = $config.repository
$repoArgs = @(
    "\SERVER", $repo.host,
    "\Database", $repo.database_name,
    "\DBUser", $repo.username,
    "\DBPassword", $repo.password
    "\ConnectionType", "SqlServer"
)

$cli = $(Get-Childitem -Path "$env:ProgramFiles\Framework Systems\" -Recurse -Force "FSConsole.exe" -ErrorAction SilentlyContinue) | Select-Object -First 1

$settings | ForEach-Object -Parallel {
    $setting = $PSItem
    $name = "$($setting.package.name)_$($setting.version.name)_$($setting.config.short_name)"
    $dir = "\temp\eNVenta\$name"

    # compile
    $p2goArgs = $($using:repoArgs) + @(
        "\LABELID", $setting.version.label_id,
        "\SETTING", "`"$($setting.config.internal_full_name)`"",
        "\PUBLISH2GO"
    )
    $p2go = Start-Process -FilePath $using:cli -ArgumentList $p2goArgs -NoNewWindow -PassThru -Wait
    if ($p2go.ExitCode -ne 0) {
        return
    }

    # create settings
    $createSettingsArgs = $($using:repoArgs) + @(
        "\LabelID", $setting.version.label_id,
        "\ExportSetting", "`"$($setting.config.internal_full_name)`"",
        "\SettingFile", "$dir\settings.FSSetting"
    )
    $createSettings = Start-Process -FilePath $using:cli -ArgumentList $createSettingsArgs -NoNewWindow -PassThru -Wait
    if ($createSettings.ExitCode -ne 0) {
        return
    }

    # include publish script
    Copy-Item -Path "$($using:PSScriptRoot)\publish.ps1" -Destination "$dir\publish.ps1"

    # zip
    $zip = "$env:TEMP\$($using:timestamp)-$name.zip"
    Compress-Archive -Path "$dir\*" -DestinationPath $zip

    # distribute
    $session = New-PSSession $setting.config.target_host
    Copy-Item -Path $zip -Destination $zip -ToSession $session

    # cleanup
    Remove-Item $zip
    Remove-Item -Recurse $dir
}

