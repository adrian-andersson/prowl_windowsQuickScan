---
external help file: prowl-help.xml
Module Name: prowl
online version: https://thesysadminchannel.com/get-reboot-history-using-powershell -
schema: 2.0.0
---

# Get-RebootHistory

## SYNOPSIS
This will output who initiated a reboot or shutdown event.

## SYNTAX

```
Get-RebootHistory [[-ComputerName] <String[]>] [[-DaysFromToday] <Int32>] [[-MaxEvents] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### EXAMPLE 1
```
Get-RebootHistory -ComputerName Server01, Server02
```

### EXAMPLE 2
```
Get-RebootHistory -DaysFromToday 30 -MaxEvents 1
```

## PARAMETERS

### -ComputerName
Specify a computer name you would like to check. 
The default is the local computer

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $env:COMPUTERNAME
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -DaysFromToday
Specify the amount of days in the past you would like to search for

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 7
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxEvents
Specify the number of events you would like to search for (from newest to oldest)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 9999
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Name: Get-RebootHistory
Author: theSysadminChannel
Version: 1.0
DateCreated: 2020-Aug-5

## RELATED LINKS

[https://thesysadminchannel.com/get-reboot-history-using-powershell -](https://thesysadminchannel.com/get-reboot-history-using-powershell -)

[https://thesysadminchannel.com/get-reboot-history-using-powershell -]()

