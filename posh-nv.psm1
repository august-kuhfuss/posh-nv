Get-ChildItem -Path .\Modules -Filter *.ps1 | ForEach-Object {
    Import-Module -Force -Verbose $_.FullName
}
