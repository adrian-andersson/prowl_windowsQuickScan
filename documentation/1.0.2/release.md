# prowl - Release 1.0.2
| Version | Code Coverage | Code Based Help Coverage |Bartender Version|
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![releasebadge]|![pesterbadge]|![helpcoveragebadge]|![btbadge]|
## Overview
|item|value|
|:-:|:-:|
|BuildUser|Adrian.Andersson|
|Company| |
|BuildDate|2021-03-23T14:04:42|
|Author(s)|Adrian.Andersson|



### Release Notes:

Lower PSVersion; Check for AV




---
## Changes Summary
|item|value|
|:-:|:-:|
|commentBasedHelpCoverage|79|
|comparisonVersion|1.0.1|
|version|1.0.2|
|estimatedChangePercent|0.52 %|



---
## File

### Summary

|item|value|
|:-:|:-:|
|newFiles|0|
|totalFiles|15|
|modifiedFiles|4|
|totalFileSize|64.0458984375 kb|

### File List


#### Modified Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|get-networkConnections.ps1|.\functions\test\get-networkConnections.ps1.x|.x|3.8|
|get-antiVirusProducts|.\functions\get-antiVirusProducts.ps1|.ps1|2.15|
|get-localUserData|.\functions\get-localUserData.ps1|.ps1|7.1|
|get-prowlSystemReport|.\functions\get-prowlSystemReport.ps1|.ps1|3.9|


#### Unchanged Files
|name|path|extension|size(kb)
|----------------|--------------------------------|-----|-----|
|get-logonHistory.ps1|.\functions\test\get-logonHistory.ps1.x|.x|15.66|
|get-logonHistoryAmmend.ps1|.\functions\test\get-logonHistoryAmmend.ps1.x|.x|7.48|
|get-awsData|.\functions\get-awsData.ps1|.ps1|1.63|
|get-fileEncoding|.\functions\get-fileEncoding.ps1|.ps1|6.46|
|get-internetIpAddress|.\functions\get-internetIpAddress.ps1|.ps1|4.16|
|get-networkConnectionsCompat|.\functions\get-networkConnectionsCompat.ps1|.ps1|3.81|
|get-prowlNonMSServices|.\functions\get-prowlNonMSServices.ps1|.ps1|2.11|
|get-virusTotalHashResult|.\functions\get-virusTotalHashResult.ps1|.ps1|1.53|
|get-winAdminStatus|.\functions\get-winAdminStatus.ps1|.ps1|1.47|
|get-windowsOsData|.\functions\get-windowsOsData.ps1|.ps1|2.1|
|baseModuleTest|.\pester\baseModuleTest.ps1|.ps1|0.68|





---
## Functions

### Summary

|item|value|
|:-:|:-:|
|totalFunctions|14|
|publicFunctions|14|
|modifiedFunctions|4|
|newFunctions|0|
|privateFunctions|0|

### Function List


#### Modified Functions
|function|type|markdown link|filename|
|-|-|-|-|
|Get-prowlAntivirusProducts {|Public||.\get-antiVirusProducts.ps1|
|get-prowlUserAnalysis|Public|[link](./functions/get-prowlUserAnalysis.md)|.\get-localUserData.ps1|
|get-prowlSystemReport|Public|[link](./functions/get-prowlSystemReport.md)|.\get-prowlSystemReport.ps1|
|get-prowlNetworkConnections|Public|[link](./functions/get-prowlNetworkConnections.md)|.\test\get-networkConnections.ps1.x|

#### Unmodified Functions
|function|type|markdown link|filename|
|-|-|-|-|
|get-prowlAwsMetaData|Public|[link](./functions/get-prowlAwsMetaData.md)|.\get-awsData.ps1|
|get-prowlFileEncoding|Public|[link](./functions/get-prowlFileEncoding.md)|.\get-fileEncoding.ps1|
|get-prowlInternetIpAddress|Public|[link](./functions/get-prowlInternetIpAddress.md)|.\get-internetIpAddress.ps1|
|get-prowlNetworkConnections|Public|[link](./functions/get-prowlNetworkConnections.md)|.\get-networkConnectionsCompat.ps1|
|get-prowlNonMsServices|Public|[link](./functions/get-prowlNonMsServices.md)|.\get-prowlNonMSServices.ps1|
|get-prowlVirusTotalFileHashDetails|Public|[link](./functions/get-prowlVirusTotalFileHashDetails.md)|.\get-virusTotalHashResult.ps1|
|get-prowlAdminStatus|Public|[link](./functions/get-prowlAdminStatus.md)|.\get-winAdminStatus.ps1|
|get-prowlWindowsOsData|Public|[link](./functions/get-prowlWindowsOsData.md)|.\get-windowsOsData.ps1|
|get-prowlLogonHistory|Public||.\test\get-logonHistory.ps1.x|
|get-prowlLogonHistory|Public||.\test\get-logonHistoryAmmend.ps1.x|









---
## Git Details
|item|value|
|:-:|:-:|
|origin|https://github.com/adrian-andersson/prowl_autobot.git|
|commit|da9faf8|
|branch|master|



[pesterbadge]: https://img.shields.io/static/v1.svg?label=pester&message=na&color=lightgrey
[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=6.2.0&color=0B2047
[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=1.0.2&color=blue
[helpcoveragebadge]: https://img.shields.io/static/v1.svg?label=get-help&message=79&color=green
