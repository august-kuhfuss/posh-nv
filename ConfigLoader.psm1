$defaultConfigPath = "$HOME\.posh-nv\config.json"
$defaultConfig = @{
    "`$schema"  = "https://raw.githubusercontent.com/august-kuhfuss/posh-nv/main/schemas/config.json"
    app_hosts   = @()
    print_hosts = @()
    repository  = @{
        host          = "localhost"
        database_name = "NVRep"
        username      = "NVRep"
        password      = "NVRep"
    }
    packages    = @()
}

if ((Test-Path $defaultConfigPath) -eq $false) {
    Write-Output "default config not found. Creating default config at $defaultConfigPath"
    $defaultConfig | ConvertTo-Json | Out-File $defaultConfigPath
}

function Get-NVConfig {
    param(
        [string]$Path = $defaultConfigPath
    )

    if ((Test-Path $Path) -eq $false) {
        Write-Output "$Path not found."

    }
    return (Get-Content $defaultConfigPath -Raw | ConvertFrom-Json)
}
Export-ModuleMember -Function Get-NVConfig

function Get-NVAppHosts {
    $config = Get-NVConfig
    return $config.app_hosts
}
Export-ModuleMember -Function Get-NVAppHosts

function Get-NVPrintHosts {
    $config = Get-NVConfig
    return $config.print_hosts
}
Export-ModuleMember -Function Get-NVPrintHosts

function Get-FSRepoArgs {
    $config = Get-Config
    $repo = $config.repository
    return @(
        "\SERVER", $repo.host,
        "\Database", $repo.database_name,
        "\DBUser", $repo.username,
        "\DBPassword", $repo.password,
        "\ConnectionType", "SqlServer"
    )
}

Export-ModuleMember -Function Get-FSRepoArgs

function Get-NVPackages {
    $config = Get-Config

    foreach ($package in $config.packages) {
        $package.versions | ForEach-Object {
            $version = $PSItem
            $version.configurations | ForEach-Object {
                $cfg = $PSItem
                [PSCustomObject]@{
                    package = $package
                    version = $version
                    config  = $cfg
                }
            }
        }
    }
}

Export-ModuleMember -Function Get-NVPackages