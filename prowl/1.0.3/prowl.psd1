
@{
  PrivateData = @{
    bartenderVersion = '6.2.0'
    bartenderCopyright = '2020 Domain Group'
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'
    builtOn = '2021-03-23T15:06:33'
    moduleRevision = '1.0.2.1'
    builtBy = 'Adrian.Andersson'
    PSData = @{
      ReleaseNotes = 'Fix AV issue'
      ProjectUri = 'https://github.com/adrian-andersson/prowl_autobot.git'
    }
  }
  RootModule = 'prowl.psm1'
  AliasesToExport = @()
  CompanyName = ' '
  Author = 'Adrian.Andersson'
  FunctionsToExport = @('Get-prowlAntivirusProducts','get-prowlAwsMetaData','get-prowlFileEncoding','get-prowlInternetIpAddress','get-prowlUserAnalysis','get-prowlNetworkConnections','get-prowlNonMsServices','get-prowlSystemReport','get-prowlVirusTotalFileHashDetails','get-prowlAdminStatus','get-prowlWindowsOsData')
  CmdletsToExport = @()
  Description = 'Like the autobot of the same name, prowl around the Windows System and report back on security implications'
  GUID = '28a16472-e184-4f75-aac6-c5bd3c0a5c64'
  ScriptsToProcess = @()
  Copyright = '2021  '
  PowerShellVersion = '4.0'
  ModuleVersion = '1.0.3'
}
