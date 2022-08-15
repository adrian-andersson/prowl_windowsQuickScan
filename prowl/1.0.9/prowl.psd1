
@{
  AliasesToExport = @()
  RootModule = 'prowl.psm1'
  ModuleVersion = '1.0.9'
  Copyright = '2022  '
  FunctionsToExport = @('Get-prowlAntivirusProducts','get-prowlAwsMetaData','get-prowlFileEncoding','get-prowlInternetIpAddress','get-prowlUserAnalysis','get-prowlLog4jJars','get-prowlNetworkConnections','get-prowlNonMsServices','get-prowlSystemReport','Get-RebootHistory','get-prowlScheduledTasks','get-prowlVirusTotalFileHashDetails','get-prowlAdminStatus','get-prowlWindowsOsData','stop-shutdown')
  ScriptsToProcess = @()
  PowerShellVersion = '4.0'
  Description = 'Like the autobot of the same name, prowl around the Windows System and report back on security implications'
  GUID = '28a16472-e184-4f75-aac6-c5bd3c0a5c64'
  Author = 'Adrian.Andersson'
  CmdletsToExport = @()
  PrivateData = @{
    bartenderVersion = '6.2.0'
    moduleRevision = '1.0.8.1'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
    builtOn = '2022-08-15T16:07:15'
    bartenderCopyright = '2020 Domain Group'
    PSData = @{
      ProjectUri = 'https://github.com/adrian-andersson/prowl_autobot'
    }
    builtBy = 'Adrian.Andersson'
  }
  CompanyName = ' '
}
