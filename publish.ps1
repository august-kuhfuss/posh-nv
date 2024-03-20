#Requires -RunAsAdministrator
#Requires -Version 5

$cli = "$PSScriptRoot/Publish2Go.exe"

$cliArgs = @(
    "\PUBLISH",
    "\SETTING", "$PSScriptRoot\settings.FSSetting"
)

$p = Start-Process $cli -ArgumentList $cliArgs -PassThru -NoNewWindow -Wait
Exit $p.ExitCode