function Prepare-NVPublish {
	param(
		[Parameter(Mandatory)]
		[string[]]$Configs
	)

	$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

	# package:version:config -> single object
	# package:version:(config1, config2) -> array of objects
	$parsedInput = $Configs | ForEach-Object {
		$tokens = $PSItem -split ":"

		$package = $tokens[0]
		$version = $tokens[1]
		$configuration = $tokens[2]

		# if config is a list, return an array of objects
		if ($configuration -match "\((.+)\)") {
			$configuration = $matches[1] -split ","
			$configuration | ForEach-Object {
				[PSCustomObject]@{
					package = $package
					version = $version
					config  = $_.Trim()
				}
			}
			return
		}

		[PSCustomObject]@{
			package = $package
			version = $version
			config  = $configuration
		}
	}

	$matched = $parsedInput | ForEach-Object {
		$item = $PSItem
		Get-NVPackages | Where-Object {
			$PSItem.package.short_name -eq $item.package -and
			$PSItem.version.name -eq $item.version -and
			$PSItem.config.short_name -eq $item.config
		}
	}

	$repoArgs = Get-FSRepoArgs
	$cli = Get-FSConsole
	$matched | ForEach-Object -Parallel {
		$setting = $PSItem
		$name = "$($setting.package.name)_$($setting.version.name)_$($setting.config.short_name)"
		$workDir = "\temp\eNVenta\"
		$dir = "$workDir\$name"

		# compile
		$p2goArgs = $using:repoArgs + @(
			"\PACKAGE", $setting.package.name,
			"\VERSION", $setting.version.name,
			"\SETTING", "`"$($setting.config.name)`"",
			"\PUBLISH2GO"
		)

		$p2go = Start-Process -FilePath $using:cli -ArgumentList $p2goArgs -NoNewWindow -PassThru -Wait
		if ($p2go.ExitCode -ne 0) {
			return
		}

		# create settings
		$createSettingsArgs = $using:repoArgs + @(
			"\PACKAGE", $setting.package.name,
			"\VERSION", $setting.version.name,
			"\ExportSetting", "`"$($setting.config.name)`"",
			"\SettingFile", "$dir\settings.FSSetting"
		)
		$createSettings = Start-Process -FilePath $using:cli -ArgumentList $createSettingsArgs -NoNewWindow -PassThru -Wait
		if ($createSettings.ExitCode -ne 0) {
			return
		}

		# include publish script
		$url = "https://raw.githubusercontent.com/august-kuhfuss/posh-nv/main/resources/publish.ps1"
		Invoke-WebRequest $url -OutFile "$dir\publish.ps1"

		# zip
		$zip = "$workDir\$name-$using:timestamp.zip"
		Compress-Archive -Path "$dir\*" -DestinationPath $zip

		# on target, create directory if not exists
		$targerDir = "C:\temp\eNVenta"
		$session = New-PSSession $setting.config.target_host
		Invoke-Command -Session $session -ScriptBlock {
			param($dir)
			if (-not (Test-Path $dir)) {
				New-Item -ItemType Directory -Path $dir
			}
		} -ArgumentList $targerDir

		# send zip to target
		Copy-Item -Path $zip -Destination $targerDir -ToSession $session


		# cleanup
		Remove-Item $zip
		Remove-Item -Recurse $dir
	}
}
Export-ModuleMember -Function Prepare-NVPublish
