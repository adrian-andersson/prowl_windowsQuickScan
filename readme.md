# PROWL


> Like the autobot of the same name, prowl around the Windows System and report back on security implications

[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=1.0.3&color=blue
[datebadge]: https://img.shields.io/static/v1.svg?label=Date&message=2021-03-15&color=yellow
[psbadge]: https://img.shields.io/static/v1.svg?label=PowerShell&message=4.0.0&color=5391FE&logo=powershell
[btbadge]: https://img.shields.io/static/v1.svg?label=bartender&message=6.2.0&color=0B2047


| Language | Release Version | Release Date | Bartender Version |
|:-------------------:|:-------------------:|:-------------------:|:-------------------:|
|![psbadge]|![releasebadge]|![datebadge]|![btbadge]|


Authors: Adrian.Andersson

Company:  

Latest Release Notes: [here](./documentation/1.0.1/release.md)

***

<!--Bartender Dynamic Header -- Code Below Here -->



***
##  Getting Started

### Installation
Start PowerShell in Admin

---

### Download and import

```powershell
#Ensure TLS 12 is enabled. Should not be a problem for most PowerShell and OS Configs, but just in case (TLS1.2 is required by GH)
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$path = 'c:\psprowl' #DownloadPath

#Code to get the latest release
$releaseList = Invoke-RestMethod 'https://api.github.com/repos/adrian-andersson/prowl_windowsQuickScan/releases'
$latestRelease = $releaseList |Sort-Object -Property published_at -Descending |Select-Object -First 1
$verTag = $latestRelease.tag_name.replace('v','')
write-warning "Latest published Name: $($latestRelease.name) - From: $($latestRelease.published_at) - VersionTag:$verTag"
$latestDownloadLink = $($latestRelease.assets.where{$_.name -eq 'prowl.zip'}|select-object -First 1).browser_download_url

#Code to download and expand
if(!(test-path $path))
{
    new-item -itemtype directory -path $path
}
$zipPath = "$path\prowl.zip"
Invoke-WebRequest -Uri $latestDownloadLink -OutFile $zipPath -Verbose -UseBasicParsing

#Check for, and expand-archive
if($(try{get-command expand-archive -erroraction stop}catch{}))
{
    expand-archive $zipPath $path
}else{
    write-warning 'Your version of PowerShell does not support Expand-Archive, failing back to legacy mode'
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath,'c:\prowl\')
}

#Import module
import-module "$path\prowl\$verTag\prowl.psd1"
```

### Start Investigating

```powershell
get-prowlSystemReport -filepath 'c:\psProwlReport.txt'

```

***
## What Is It
A PowerShell module to help get a security profile of a windows instance

## To Do

 - Fix the problem with getting local users that seems to sometimes occur

***
## Acknowledgements



<!--Bartender Link, please leave this here if you make use of this module -->
***

## Build With Bartender
> [A PowerShell Module Framework](https://github.com/DomainGroupOSS/bartender)

