---
external help file: prowl-help.xml
Module Name: prowl
online version:
schema: 2.0.0
---

# get-prowlInternetIpAddress

## SYNOPSIS
Query the AKAMAI URI for current IP

## SYNTAX

```
get-prowlInternetIpAddress [-detailed] [<CommonParameters>]
```

## DESCRIPTION
Invoke-webrequest against the AKAMAI page whatismyip.akamai.com
Supports the /advanced path so you can get some more details about your IP

------------

## EXAMPLES

### EXAMPLE 1
```
get-myIp
```

#### OUTPUT
180.80.180.80

### EXAMPLE 2
```
get-myIp -detailed
```

#### OUTPUT
180.80.180.80

## PARAMETERS

### -detailed
Should we get some more details

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: all

Required: False
Position: Named
Default value: False
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

    yyyy-mm-dd - AA
        - Changed x for y

## RELATED LINKS
