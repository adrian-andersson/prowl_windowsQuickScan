
@{
  CmdletsToExport = @()
  CompanyName = ' '
  RootModule = 'prowl.psm1'
  Copyright = '2021  '
  Description = 'Like the autobot of the same name, prowl around the Windows System and report back on security implications'
  FunctionsToExport = @('Get-prowlAntivirusProducts','get-prowlAwsMetaData','get-prowlFileEncoding','get-prowlInternetIpAddress','get-prowlUserAnalysis','get-prowlNetworkConnections','get-prowlNonMsServices','get-prowlSystemReport','get-prowlVirusTotalFileHashDetails','get-prowlAdminStatus','get-prowlWindowsOsData')
  ModuleVersion = '1.0.1'
  Author = 'Adrian.Andersson'
  AliasesToExport = @()
  GUID = '28a16472-e184-4f75-aac6-c5bd3c0a5c64'
  PowerShellVersion = '5.0.0.0'
  ScriptsToProcess = @()
  PrivateData = @{
    builtOn = '2021-03-15T23:28:12'
    builtBy = 'Adrian.Andersson'
    moduleRevision = '1.0.0.7'
    PSData = @{
      ReleaseNotes = 'First actual release'
    }
    bartenderCopyright = '2020 Domain Group'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
    bartenderVersion = '6.2.0'
  }
}
