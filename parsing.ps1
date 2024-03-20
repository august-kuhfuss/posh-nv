param(
    [Parameter(Mandatory)]
    [string[]]$Configs
)

# package:version:config -> single object
# package:version:(config1, config2) -> array of objects
$obj = $Configs | ForEach-Object {
    $tokens = $PSItem -split ":"

    $package = $tokens[0]
    $version = $tokens[1]
    $config = $tokens[2]

    # if config is a list, return an array of objects
    if ($config -match "\((.+)\)") {
        $config = $matches[1] -split ","
        $config | ForEach-Object {
            [PSCustomObject]@{
                package = $package
                version = $version
                config  = $_
            }
        }
        return
    }

    [PSCustomObject]@{
        package = $package
        version = $version
        config  = $config
    }

}

$obj
