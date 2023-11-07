param(
    [Parameter(Mandatory)]
    [string[]]$Configs
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmm"

$configFile = "$PSScriptRoot\config.toml"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.toml not found. exiting"
    return
}
$config = Get-Content $configFile | ConvertFrom-Toml
$repo = $config.repo
$settings = $config.settings

$cli = $(Get-Childitem -Path "$env:ProgramFiles\Framework Systems\" -Recurse -Force "FSConsole.exe" -ErrorAction SilentlyContinue)

$repoArgs = @(
    "\SERVER", $repo.host,
    "\Database", $repo.database,
    "\DBUser", $repo.user,
    "\DBPassword", $repo.password
    "\ConnectionType", "SqlServer"
)

$Configs | ForEach-Object -Parallel {
    $c = $_
    $todo = $($using:settings) | Where-Object { $_.name -eq $c } | Select-Object -First 1

    $dir = "\temp\eNVenta\$($todo.name)\"
    $archiveFile = "$($using:timestamp)-$($todo.name).zip"
    $archivePath = "$env:TEMP\$archiveFile"

    # create files
    $p2goArgs = $($using:repoArgs) + @(
        "\LabelID", $todo.package,
        "\Setting", "`"$($todo.configuration)`""
        "\PUBLISH2GO"
    )

    $p2go = Start-Process -FilePath $($using:cli) -ArgumentList $p2goArgs -NoNewWindow -PassThru -Wait
    if ($p2go.ExitCode -ne 0) {
        return
    }

    $createSettingsArgs = $($using:repoArgs) + @(
        "\LabelID", $todo.package,
        "\ExportSetting", "`"$($todo.configuration)`""
        "\SettingFile", "$dir\settings.FSSetting"
    )
    $createSettings = Start-Process -FilePath $($using:cli) -ArgumentList $createSettingsArgs -NoNewWindow -PassThru -Wait
    if ($createSettings.ExitCode -ne 0) {
        return
    }

    Copy-Item -Path "$($using:PSScriptRoot)\publish.ps1" -Destination "$dir\publish.ps1"

    # zip
    Compress-Archive -Path "$dir\*" -DestinationPath $archivePath

    # distribute
    $session = New-PSSession $todo.host
    Copy-Item -Path $archivePath -Destination "c:/temp/eNVenta/$archiveFile" -ToSession $session

    # cleanup
    Remove-Item $archivePath
    Remove-Item -Recurse $dir
}

