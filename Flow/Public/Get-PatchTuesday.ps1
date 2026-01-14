function Get-PatchTuesday
{
    <#
        .SYNOPSIS
        Gets the date the next patch Tuesday

        .DESCRIPTION
        Gets the date the next patch Tuesday

        .PARAMETER Date
        Date Time object for when to check

        .OUTPUTS
        [Datetime]

        .EXAMPLE
        Get-PatchTuesday

        12 September 2023 00:00:00

        Returns the date of the next Patch Tuesday e.g. the second Tuesday of the month

        .EXAMPLE
        Get-PatchTuesday -Date $(Get-Date -Year 2023 -Month 10 -Day 01)

        10 October 2023 00:00:00

        Returns the patching Tuesday for specified date
    #>

    [CmdletBinding()]
    [OutputType([DateTime])]
    param
    (
        [Parameter()]
        [DateTime]$Date = $(Get-Date)
    )

    [DateTime]$Month = $Date.ToUniversalTime().ToString('yyyy-MM-01')
    while ($Month.DayofWeek -ine 'Tuesday')
    {
        $Month = $Month.AddDays(1)
    }
    $DayOffSet = 7
    $PatchTuesday = $Month.AddDays($DayOffSet)

    if ($PatchTuesday -le $Date)
    {
        $NextMonth = $PatchTuesday.AddMonths(1)

        [DateTime]$Month = $NextMonth.ToUniversalTime().ToString('yyyy-MM-01')
        while ($Month.DayofWeek -ine 'Tuesday')
        {
            $Month = $Month.AddDays(1)
        }
        $DayOffSet = 7
        $PatchTuesday = $Month.AddDays($DayOffSet)
    }

    return [DateTime]$PatchTuesday.ToString('yyyy-MM-dd')
}
