# prowl - Release 1.0.8
| Version | Code Coverage | Code Based Help Coverage |Bartender Version|
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![releasebadge]|![pesterbadge]|![helpcoveragebadge]|![btbadge]|
## Overview
|item|value|
|:-:|:-:|
|BuildDate|2022-08-15T14:36:18|
|BuildUser|Adrian.Andersson|
|Author(s)|Adrian.Andersson|
|Company| |






---
## Changes Summary
|item|value|
|:-:|:-:|
|estimatedChangePercent|0.46 %|
|commentBasedHelpCoverage|72|
|version|1.0.8|
|comparisonVersion|1.0.7|



---
## File

### Summary

|item|value|
|:-:|:-:|
|totalFiles|19|
|totalFileSize|78.1748046875 kb|
|newFiles|1|
|modifiedFiles|1|

### File List

#### New Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|get-log4jVulnerabilities|.\functions\get-log4jVulnerabilities||8.36|


#### Modified Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|get-prowlSystemReport|.\functions\get-prowlSystemReport.ps1|.ps1|4.16|


#### Unchanged Files
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
|get-networkConnectionsCompat|.\functions\get-networkConnectionsCompat.ps1|.ps1|3.95|
|get-prowlNonMSServices|.\functions\get-prowlNonMSServices.ps1|.ps1|2.04|
|get-rebootHistory|.\functions\get-rebootHistory.ps1|.ps1|2.76|
|get-scheduledTasks|.\functions\get-scheduledTasks.ps1|.ps1|2.53|
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
|newFunctions|1|
|privateFunctions|0|
|publicFunctions|18|
|modifiedFunctions|1|
|totalFunctions|18|

### Function List

#### New Functions
|function|type|markdown link|filename|
|-|-|-|-|
|get-prowlLog4jJars|Public||.\get-log4jVulnerabilities|

#### Modified Functions
|function|type|markdown link|filename|
|-|-|-|-|
|get-prowlSystemReport|Public|[link](./functions/get-prowlSystemReport.md)|.\get-prowlSystemReport.ps1|

#### Unmodified Functions
|function|type|markdown link|filename|
|-|-|-|-|
|Get-prowlAntivirusProducts {|Public||.\get-antiVirusProducts.ps1|
|get-prowlAwsMetaData|Public|[link](./functions/get-prowlAwsMetaData.md)|.\get-awsData.ps1|
|get-prowlFileEncoding|Public|[link](./functions/get-prowlFileEncoding.md)|.\get-fileEncoding.ps1|
|get-prowlInternetIpAddress|Public|[link](./functions/get-prowlInternetIpAddress.md)|.\get-internetIpAddress.ps1|
|get-prowlUserAnalysis|Public|[link](./functions/get-prowlUserAnalysis.md)|.\get-localUserData.ps1|
|get-prowlNetworkConnections|Public|[link](./functions/get-prowlNetworkConnections.md)|.\get-networkConnectionsCompat.ps1|
|get-prowlNonMsServices|Public|[link](./functions/get-prowlNonMsServices.md)|.\get-prowlNonMSServices.ps1|
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
|origin|https://github.com/adrian-andersson/prowl_autobot|
|branch|master|
|commit|e5978df|



[pesterbadge]: https://img.shields.io/static/v1.svg?label=pester&message=na&color=lightgrey
[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=6.2.0&color=0B2047
[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=1.0.8&color=blue
[helpcoveragebadge]: https://img.shields.io/static/v1.svg?label=get-help&message=72&color=yellowgreen
