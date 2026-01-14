function Set-RoundMin
{
    <#
        .SYNOPSIS
        Rounds a time to a half hour interval

        .DESCRIPTION
        Rounds a time to a half hour interval

        .PARAMETER Date
        Date object to round time on

        .OUTPUTS
        [date]

        .EXAMPLE
        Set-RoundMin -MinInterval 30 -Date "03/12/2012 06:59:59"

        12 March 2012 07:00:00

        Round a time to the closest 30 min interval

        .EXAMPLE
        Set-RoundMin -MinInterval 30 -Date "03/12/2012 06:18:00"

        12 March 2012 06:30:00

        Round a time to the closest 30 min interval
    #>

    [CmdletBinding()]
    [OutputType([DateTime])]

    param
    (
        [Parameter()]
        [DateTime]$Date
    )

    switch ($Date.Minute)
    {
        {$_ -eq 0 -or $_ -eq 30} {$NewMinute = 0 }
        {$_ -ge 1  -and $_ -le 14} {$NewMinute = $Date.Minute * -1 }
        {$_ -ge 15 -and $_ -le 29} {$NewMinute = 30 - $Date.Minute }
        {$_ -ge 31 -and $_ -le 44} {$NewMinute = ($Date.Minute -30) * -1 }
        {$_ -ge 45 -and $_ -le 59} {$NewMinute = 60 - $Date.Minute}
    }
    $Date.AddMinutes($NewMinute)
}
