function Get-NVConfig {
    $path = "$HOME\.posh-nv\config.json"
    if ((Test-Path $path) -eq $false) {
        Write-Output "default config not found. Creating default config at $path"

        # create directories if not exists
        if ((Test-Path "$HOME\.posh-nv") -eq $false) {
            New-Item -ItemType Directory -Path "$HOME\.posh-nv"
        }

        @{ "`$schema" = "https://raw.githubusercontent.com/august-kuhfuss/posh-nv/main/schemas/config.schema.json" } | ConvertTo-Json | Out-File $path
    }

    if ((Test-Path $path) -eq $false) {
        Write-Output "$path not found."

    }
    return (Get-Content $path -Raw | ConvertFrom-Json)
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
    $config = Get-NVConfig
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
    $config = Get-NVConfig

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