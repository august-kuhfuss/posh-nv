# `posh-nv`: eNVenta Admin tools in Powershell

| Function                  | Description                              | Parameters                                                                                                             |
| ------------------------- | ---------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `Compile-NVPackages`      | Compiles specified FS Packages           | `[string[]]` `PackageNames` (if not specified, all)                                                                    |
| `Prepare-NVPublish`       | Prepares a Package Publish               | `[string[]]` `DestinationHosts`                                                                                        |
| `Restart-NVPrintServices` | Restarts all NV Print Services on Hosts  | `[string[]]` `Configs` (formats: _package:version:config_ -> single, _package:version:(config1, config2)_ -> multiple) |
| `Copy-CrystalReports`     | Copies Crystal reports to target servers | `[string[]]` `DestinationHosts`                                                                                        |
