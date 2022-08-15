---
external help file: prowl-help.xml
Module Name: prowl
online version:
schema: 2.0.0
---

# get-prowlLog4jJars

## SYNOPSIS
Find all the jars on a computer.
Check them for 'JndiLookup.class'
Works with PowerShell 3 - 5 or 7+

## SYNTAX

```
get-prowlLog4jJars [<CommonParameters>]
```

## DESCRIPTION
Written to be as fast as possible, uses Robocopy to find the jars, and uses 5 threads to check the jar files

Why did I make this:

    I read about a dozen scripts from various sources and all of them had some deficiencies:
    Some used workflows (so Windows Powershell only). 
    Lots used Get-ChildItem / gci/ls with -recurse - which is significantly slower
    Not many did the reading in parallel, and those that did were very version specific
    Lots wrote a log file, rather than return a list of files
    Some were very proprietary or did other stuff that I didn't like

This one also excludes the weirdness that google drive does for local drives


On my laptop this scans the entire drive (With planted positives) in:

Pwsh 7.2: 39 seconds
Powershell 5.1: 53 seconds

------------

## EXAMPLES

### EXAMPLE 1
```
find-log4jJars -verbose
```

#### DESCRIPTION
1.
Identify local disk drives
2.
Scan each drive for .jar files using robocopy (1 scan per drive)
3.
Use the select-string function to search each file for the jndilookup.class, return only uniques
4.
Return a list of any that matched the above


#### OUTPUT
C:\temp2\trueHits\log4j-core-2.0-beta9.jar
C:\temp2\trueHits\log4j-core-2.10.0.jar
C:\temp2\trueHits\log4j-core-2.11.0.jar
C:\temp2\trueHits\log4j-core-2.12.0.jar
C:\temp2\trueHits\log4j-core-2.3.jar
C:\temp2\trueHits\log4j-core-2.14.0.jar
C:\temp2\trueHits\log4j-core-2.9.1.jar

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Adrian Andersson


Changelog:

    2022-01-05 - AA
        - Initial Script
        - Tested on laptop
            Tested with PS 7.2 and 5.1
        - Fix multiple drive issue with Ps 3..5 robocopy command
        - Better info/workflow avoid when nothing to scan

## RELATED LINKS
