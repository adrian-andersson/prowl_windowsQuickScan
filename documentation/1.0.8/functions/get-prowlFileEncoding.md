---
external help file: prowl-help.xml
Module Name: prowl
online version:
schema: 2.0.0
---

# get-prowlFileEncoding

## SYNOPSIS
Rewrite of the get-fileEncoding script from MS KnowledgeBase

## SYNTAX

```
get-prowlFileEncoding [-FullName] <String[]> [<CommonParameters>]
```

## DESCRIPTION
The one supplied by MS is a bit of a mess

------------

## EXAMPLES

### EXAMPLE 1
```
get-fileEncoding -path 'c:\example\file.txt'
```

### EXAMPLE 2
```
get-fileEncoding -path 'c:\example\file1.txt','c:\example\file2.txt'
```

### EXAMPLE 3
```
$files = get-
get-fileEncoding -path 'c:\example\file1.txt','c:\example\file2.txt'
```

## PARAMETERS

### -FullName
Path to the file

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Path

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Adrian Andersson


Changelog:

    2020/12/16 - AA
        - Rewrite
            - Return an object
            - Accept multiple paths
            - work in PS 7
            - Use system.IO over get-content
            - Works with Get-ChildItem now as well

## RELATED LINKS
