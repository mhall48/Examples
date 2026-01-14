Function Find-WeekDay
{
    <#
        .SYNOPSIS
        Finds the Monday or Friday of the current week or the previous week

        .DESCRIPTION
        Finds the Monday of the current week or the previous week and returns the number of days since that day 
        and the date of that date

        .OUTPUTS
        [string]

        .EXAMPLE
        Find-WeekDay -Day Monday

        Day Date
        --- ----
        2   24Jun24

        Returns the number of days since last Monday and the date

        .EXAMPLE
        Find-WeekDay -Day Friday

        Day Date
        --- ----
        5   21Jun24

        Returns the number of days since last Friday and the date

        .EXAMPLE
        Find-WeekDay -Day Monday -Previous

        Day Date
        --- ----
        9   17Jun24

        .EXAMPLE

        $Date = Get-Date
        Find-WeekDay -Day Monday -Date $Date -Previous
        Find-WeekDay -Day Friday -Date $Date

        Day Date
        --- ----
        9   17Jun24

        Returns the Monday and Friday of last week.
    #>

    [CmdletBinding()]
    [OutputType([psobject])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Monday","Friday")]
        [string]$Day,

        [Parameter()]
        [switch]$Previous,

        [Parameter()]
        [datetime]$Date = $(Get-Date)
    )

    begin
    {
        $Output = New-Object PSObject -Property @{
            Date = ''
            Day = 0
            StartDate = ''
            DateTime = $null
        }
    }

    process
    {
        $Count = -1
        if ($Previous)
        {
            $Loop = $True
        }
        else
        {
            $Loop = $False
        }
        do
        {
            $Count++
            if ($DateTmp.DayOfWeek -eq $Day -and $Count -gt 0)
            {
                $Loop = $False
            }
            if ($Date)
            {
                $DateTmp = (Get-Date -Date $Date -Hour 0 -Minute 0 -Second 0).AddDays(-$Count)
            }
            else
            {
                $DateTmp = (Get-Date -Hour 0 -Minute 0 -Second 0).AddDays(-$Count)
            }
        }
        until ($DateTmp.DayOfWeek -eq $Day -and $Loop -eq $False)

        $DateF = [string]$(Get-Date $DateTmp -UFormat "%d%b%g")
        $Output.Date = $DateF
        $Output.Day = $Count
        $Output.DateTime = $(Get-Date -Date $Date -Hour 0 -Minute 0 -Second 0)
        return $Output
    }
}
