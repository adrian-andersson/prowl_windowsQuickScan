---
external help file: prowl-help.xml
Module Name: prowl
online version:
schema: 2.0.0
---

# get-prowlVirusTotalFileHashDetails

## SYNOPSIS
Find a file, grab its hash, send to VirusTotal to get the ID results

## SYNTAX

```
get-prowlVirusTotalFileHashDetails [-virusTotalAPI] <String> [-filePath] <String> [<CommonParameters>]
```

## DESCRIPTION
Find a file, grab its hash, send to VirusTotal to get the ID results

Currently in a bit of a PoC

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -virusTotalAPI
PARAM DESCRIPTION

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -filePath
{{ Fill filePath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Adrian Andersson


Changelog:

    2021-03-15 - AA
        - Initial Script

## RELATED LINKS
