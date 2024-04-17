function Compile-NVPackages {
	param(
		[string[]]$PackageNames
	)

	$packages = Get-NVPackages

	# compile all if nothing is specified
	if ($null -eq $PackageNames) {
		$PackageNames = $packages.name
	}

	$matched = $packages | Where-Object {
		$PackageNames -match $_.name
	}

	$matched = $matched | Select-Object -Unique @{
		Name       = 'PackageName'
		Expression = { $_.package.name }
	}, @{
		Name       = 'VersionName'
		Expression = { $_.version.name }
	}

	# if no matches, error and exit
	if ($matched.Count -eq 0) {
		Write-Output "package(s) `"$($PackageNames -join ", ")`" not found. exiting"
		return
	}

	$cli = Get-FSConsole
	$repoArgs = Get-FSRepoArgs
	$matched | ForEach-Object -Parallel {
		$p = $PSItem

		$compileArgs = $using:repoArgs + @(
			"\PACKAGE", $p.PackageName,
			"\VERSION", $p.VersionName,
			"\COMPILE"
		)
		$compile = Start-Process -FilePath $using:cli -ArgumentList $compileArgs -NoNewWindow -PassThru -Wait
		Write-Output "Process Ended with Code $($compile.ExitCode)"
	}
}
Export-ModuleMember -Function Compile-NVPackages
