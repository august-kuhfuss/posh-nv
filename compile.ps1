#Requires -Version 7
param(
    [string[]]$PackageNames
)

$cli = $(Get-Childitem -Path "$env:ProgramFiles\Framework Systems\" -Recurse -Force "FSConsole.exe" -ErrorAction SilentlyContinue)
$configFile = "$PSScriptRoot\config.json"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.json not found. exiting"
    return
}
$config = Get-Content $configFile | ConvertFrom-Json

$repo = $config.repository
$repoArgs = @(
    "\SERVER", $repo.host,
    "\Database", $repo.database_name,
    "\DBUser", $repo.username,
    "\DBPassword", $repo.password
    "\ConnectionType", "SqlServer"
)

# compile all if nothing is specified
if ($null -eq $PackageNames) {
    $PackageNames = $config.packages.name
}

$packages = $config.packages | Where-Object {
    $PackageNames -match $_.name
}

# if no matches, error
if ($packages.Count -eq 0) {
    Write-Output "package(s) `"$($PackageNames -join ", ")`" not found. exiting"
    return
}

$packages | ForEach-Object -Parallel {
    $package = $PSItem
    $compileArgs = $($using:repoArgs) + @(
        "\LabelID", $package.label_id
        "\Compile"
    )
    $compile = Start-Process -FilePath $($using:cli) -ArgumentList $compileArgs -NoNewWindow -PassThru -Wait
    Write-Output "Process Ended with Code $($compile.ExitCode)"
}
