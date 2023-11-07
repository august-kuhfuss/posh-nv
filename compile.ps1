param(
    [Parameter(Mandatory)]
    [string[]]$Packages
)

$configFile = "$PSScriptRoot\config.toml"
if ((Test-Path $configFile) -eq $false) {
    Write-Output "config.toml not found. exiting"
    return
}
$config = Get-Content $configFile | ConvertFrom-Toml

$cli = $(Get-Childitem -Path "$env:ProgramFiles\Framework Systems\" -Recurse -Force "FSConsole.exe" -ErrorAction SilentlyContinue)

$repo = $config.repo
$repoArgs = @(
    "\SERVER", $repo.host,
    "\Database", $repo.database,
    "\DBUser", $repo.user,
    "\DBPassword", $repo.password
    "\ConnectionType", "SqlServer"
)


$packages = $config.packages
$Packages | ForEach-Object -Parallel {
    $p = $($using:packages) | Where-Object { $_.name -eq $c } | Select-Object -First 1

    $compileArgs = $($using:repoArgs) + @(
        "\LabelID", $p.labelId
        "\Compile"
    )
    $compile = Start-Process -FilePath $($using:cli) -ArgumentList $compileArgs -NoNewWindow -PassThru -Wait

    Write-Output "Process Ended with Code $($compile.ExitCode)"
}
