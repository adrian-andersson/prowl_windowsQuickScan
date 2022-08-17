
@{
  CompanyName = ' '
  PowerShellVersion = '4.0'
  Author = 'Adrian.Andersson'
  PrivateData = @{
    PSData = @{
      ProjectUri = 'https://github.com/adrian-andersson/prowl_windowsQuickScan'
      ReleaseNotes = 'Improved Sys Report with date and stopwatch'
    }
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
    moduleRevision = '1.0.9.1'
    bartenderVersion = '6.2.0'
    bartenderCopyright = '2020 Domain Group'
    builtOn = '2022-08-17T11:40:58'
    builtBy = 'Adrian.Andersson'
  }
  Description = 'Like the autobot of the same name, prowl around the Windows System and report back on security implications'
  RootModule = 'prowl.psm1'
  FunctionsToExport = @('Get-prowlAntivirusProducts','get-prowlAwsMetaData','get-prowlFileEncoding','get-prowlInternetIpAddress','get-prowlUserAnalysis','get-prowlLog4jJars','get-prowlNetworkConnections','get-prowlNonMsServices','get-prowlSystemReport','Get-RebootHistory','get-prowlScheduledTasks','get-prowlVirusTotalFileHashDetails','get-prowlAdminStatus','get-prowlWindowsOsData','stop-shutdown')
  AliasesToExport = @()
  CmdletsToExport = @()
  ModuleVersion = '1.0.10'
  ScriptsToProcess = @()
  Copyright = '2022  '
  GUID = '28a16472-e184-4f75-aac6-c5bd3c0a5c64'
}
