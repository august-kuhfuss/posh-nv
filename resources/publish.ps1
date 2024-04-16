#Requires -RunAsAdministrator
#Requires -Version 5
Exit $(Start-Process "$PSScriptRoot\Publish2Go.exe" @("\PUBLISH", "\SETTING", "$PSScriptRoot\settings.FSSetting") -PassThru -NoNewWindow -Wait).ExitCode