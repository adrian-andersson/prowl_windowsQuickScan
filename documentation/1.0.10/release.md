# prowl - Release 1.0.10
| Version | Code Coverage | Code Based Help Coverage |Bartender Version|
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![releasebadge]|![pesterbadge]|![helpcoveragebadge]|![btbadge]|
## Overview
|item|value|
|:-:|:-:|
|Company| |
|Author(s)|Adrian.Andersson|
|BuildUser|Adrian.Andersson|
|BuildDate|2022-08-17T11:40:58|



### Release Notes:

Improved Sys Report with date and stopwatch




---
## Changes Summary
|item|value|
|:-:|:-:|
|version|1.0.10|
|estimatedChangePercent|0.21 %|
|comparisonVersion|1.0.9|
|commentBasedHelpCoverage|78|



---
## File

### Summary

|item|value|
|:-:|:-:|
|totalFiles|19|
|newFiles|19|
|modifiedFiles|0|
|totalFileSize|79.6982421875 kb|

### File List

#### New Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|get-logonHistory.ps1|.\functions\test\get-logonHistory.ps1.x|.x|15.37|
|get-logonHistoryAmmend.ps1|.\functions\test\get-logonHistoryAmmend.ps1.x|.x|7.32|
|get-networkConnections.ps1|.\functions\test\get-networkConnections.ps1.x|.x|3.68|
|get-antiVirusProducts|.\functions\get-antiVirusProducts.ps1|.ps1|3.14|
|get-awsData|.\functions\get-awsData.ps1|.ps1|1.58|
|get-fileEncoding|.\functions\get-fileEncoding.ps1|.ps1|6.27|
|get-internetIpAddress|.\functions\get-internetIpAddress.ps1|.ps1|4.04|
|get-localUserData|.\functions\get-localUserData.ps1|.ps1|6.89|
|get-log4jVulnerabilities|.\functions\get-log4jVulnerabilities.ps1|.ps1|8.17|
|get-networkConnectionsCompat|.\functions\get-networkConnectionsCompat.ps1|.ps1|3.95|
|get-prowlNonMSServices|.\functions\get-prowlNonMSServices.ps1|.ps1|2.04|
|get-prowlSystemReport|.\functions\get-prowlSystemReport.ps1|.ps1|4.6|
|get-rebootHistory|.\functions\get-rebootHistory.ps1|.ps1|2.76|
|get-scheduledTasks|.\functions\get-scheduledTasks.ps1|.ps1|3.81|
|get-virusTotalHashResult|.\functions\get-virusTotalHashResult.ps1|.ps1|1.47|
|get-winAdminStatus|.\functions\get-winAdminStatus.ps1|.ps1|1.42|
|get-windowsOsData|.\functions\get-windowsOsData.ps1|.ps1|2.03|
|stop-shutdown|.\functions\stop-shutdown.ps1|.ps1|0.51|
|baseModuleTest|.\pester\baseModuleTest.ps1|.ps1|0.66|







---
## Functions

### Summary

|item|value|
|:-:|:-:|
|privateFunctions|0|
|newFunctions|18|
|modifiedFunctions|0|
|totalFunctions|18|
|publicFunctions|18|

### Function List

#### New Functions
|function|type|markdown link|filename|
|-|-|-|-|
|Get-prowlAntivirusProducts {|Public||.\get-antiVirusProducts.ps1|
|get-prowlAwsMetaData|Public|[link](./functions/get-prowlAwsMetaData.md)|.\get-awsData.ps1|
|get-prowlFileEncoding|Public|[link](./functions/get-prowlFileEncoding.md)|.\get-fileEncoding.ps1|
|get-prowlInternetIpAddress|Public|[link](./functions/get-prowlInternetIpAddress.md)|.\get-internetIpAddress.ps1|
|get-prowlUserAnalysis|Public|[link](./functions/get-prowlUserAnalysis.md)|.\get-localUserData.ps1|
|get-prowlLog4jJars|Public|[link](./functions/get-prowlLog4jJars.md)|.\get-log4jVulnerabilities.ps1|
|get-prowlNetworkConnections|Public|[link](./functions/get-prowlNetworkConnections.md)|.\get-networkConnectionsCompat.ps1|
|get-prowlNonMsServices|Public|[link](./functions/get-prowlNonMsServices.md)|.\get-prowlNonMSServices.ps1|
|get-prowlSystemReport|Public|[link](./functions/get-prowlSystemReport.md)|.\get-prowlSystemReport.ps1|
|Get-RebootHistory {|Public||.\get-rebootHistory.ps1|
|get-prowlScheduledTasks|Public|[link](./functions/get-prowlScheduledTasks.md)|.\get-scheduledTasks.ps1|
|get-prowlVirusTotalFileHashDetails|Public|[link](./functions/get-prowlVirusTotalFileHashDetails.md)|.\get-virusTotalHashResult.ps1|
|get-prowlAdminStatus|Public|[link](./functions/get-prowlAdminStatus.md)|.\get-winAdminStatus.ps1|
|get-prowlWindowsOsData|Public|[link](./functions/get-prowlWindowsOsData.md)|.\get-windowsOsData.ps1|
|stop-shutdown|Public|[link](./functions/stop-shutdown.md)|.\stop-shutdown.ps1|
|get-prowlLogonHistory|Public||.\test\get-logonHistory.ps1.x|
|get-prowlLogonHistory|Public||.\test\get-logonHistoryAmmend.ps1.x|
|get-prowlNetworkConnections|Public|[link](./functions/get-prowlNetworkConnections.md)|.\test\get-networkConnections.ps1.x|











---
## Git Details
|item|value|
|:-:|:-:|
|commit|e106487|
|branch|master|
|origin|https://github.com/adrian-andersson/prowl_windowsQuickScan|



[pesterbadge]: https://img.shields.io/static/v1.svg?label=pester&message=na&color=lightgrey
[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=6.2.0&color=0B2047
[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=1.0.10&color=blue
[helpcoveragebadge]: https://img.shields.io/static/v1.svg?label=get-help&message=78&color=green
