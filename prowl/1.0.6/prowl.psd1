
@{
  CompanyName = ' '
  Description = 'Like the autobot of the same name, prowl around the Windows System and report back on security implications'
  Author = 'Adrian.Andersson'
  FunctionsToExport = @('Get-prowlAntivirusProducts','get-prowlAwsMetaData','get-prowlFileEncoding','get-prowlInternetIpAddress','get-prowlUserAnalysis','get-prowlNetworkConnections','get-prowlNonMsServices','get-prowlSystemReport','Get-RebootHistory','verb-noun','get-prowlVirusTotalFileHashDetails','get-prowlAdminStatus','get-prowlWindowsOsData','stop-shutdown')
  AliasesToExport = @()
  Copyright = '2022  '
  GUID = '28a16472-e184-4f75-aac6-c5bd3c0a5c64'
  RootModule = 'prowl.psm1'
  ModuleVersion = '1.0.6'
  PowerShellVersion = '4.0'
  ScriptsToProcess = @()
  PrivateData = @{
    bartenderCopyright = '2020 Domain Group'
    bartenderVersion = '6.2.0'
    moduleRevision = '1.0.5.1'
    PSData = @{
      ProjectUri = 'https://github.com/adrian-andersson/prowl_autobot'
    }
    builtBy = 'Adrian.Andersson'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
    builtOn = '2022-08-02T12:01:55'
  }
  CmdletsToExport = @()
}
