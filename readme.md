# PROWL


> Like the autobot of the same name, prowl around the Windows System and report back on security implications

[releasebadge]: https://img.shields.io/static/v1.svg?label=version&message=1.0.3&color=blue
[datebadge]: https://img.shields.io/static/v1.svg?label=Date&message=2021-03-15&color=yellow
[psbadge]: https://img.shields.io/static/v1.svg?label=PowerShell&message=5.0.0&color=5391FE&logo=powershell
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
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
$path = 'c:\psprowl'
if(!(test-path $path))
{
    new-item -itemtype directory -path $path
}
$zipPath = "$path\prowl.zip"
Invoke-WebRequest -Uri 'https://github.com/adrian-andersson/prowl_autobot/releases/download/v1.0.3/prowl.zip' -OutFile $zipPath -Verbose -UseBasicParsing

#Check for expand-archive
if($(try{get-command expand-archive -erroraction stop}catch{}))
{
    expand-archive -path $zipPath -destinationPath 'c:\prowl\'

}else{
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath,'c:\prowl\')
}

import-module 'C:\prowl\prowl\1.0.3\prowl.psd1'
```

### Start Investigating

```powershell
get-prowlSystemReport

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

