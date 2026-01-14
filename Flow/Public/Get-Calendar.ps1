Function Get-Calendar
{
    <#
        .SYNOPSIS
        Gets outlook/teams appointments

        .DESCRIPTION
        Gets outlook/teams appointments and either returns a raw object or formatted text 

        .PARAMETER Subject
        Wildcard search for subject of appointment to filter to just that subject

        .PARAMETER Startup
        Outputs data as a write-host table used for when you import the module to see what appointments you have for the day.
        Data is returned as a raw object if parameter not specified

        .PARAMETER Day
        Returns number of days data from the calendar, default value is 1 for current day

        .EXAMPLE
        Get-Calendar

        Returns the current days appointments

        .EXAMPLE
        Get-Calendar -Day 7 -Title "Customer Name"

        Searches calendar for next 7 days for 'customer name' within meeting subject

        .EXAMPLE
        Get-Calendar -Startup

        Todays Meetings:
        05/02/2025 10:30:00 | Case review

        Used to display on powershell module load

        .OUTPUTS
        [string]
    #>
    [CmdletBinding()]
    [OutputType([Array], [Void])]
    Param
    (
        [Parameter()]
        [switch]$Subject,

        [Parameter()]
        [int]$Day = 1,

        [Parameter()]
        [switch]$Startup
    )

    begin
    {
        $outlook=New-Object -com outlook.application
        $mapi=$outlook.GetNamespace("MAPI")
    }

    process
    {
        $Start = ((Get-Date).AddDays(0).ToShortDateString())
        $End = ((Get-Date).AddDays($Day)).ToShortDateString()

        $Filter = "[MessageClass]='IPM.Appointment' AND [Start] > '$Start'  AND [Start] < '$End' AND [isRecurring] = 'False'"

        $Appointments = ($mapi.GetDefaultFolder(9).Items).restrict($filter)
        $Appointments.Sort("[Start]")
        $RecurringFilter = "[MessageClass]='IPM.Appointment' AND [isrecurring] = 'True'"
        $RecurringAppointments = ($mapi.GetDefaultFolder(9).Items).restrict($Recurringfilter)
        $RecurringAppointments.Sort("[Start]")
        $RecurringAppointments.includerecurrences = $true

        $Array = @()
        foreach($Appointment in $Appointments)
        {
            $Array +=$Appointment
        }

        $RecurringAppointment = $RecurringAppointments.find("  [Start] > '$Start' AND  [Start] < '$End'")
        $Array += $RecurringAppointment
        do
        {
            $RecurringAppointment = $RecurringAppointments.FindNext()
            $Array += $RecurringAppointment
        }
        until(!$RecurringAppointment)

        if ($Subject)
        {
            $Array = $Array | Where-Object{$_.Subject -like "*$Subject*"}
        }

        if ($Startup)
        {
            Write-Host "`nTodays Meetings:" -ForegroundColor Cyan
            Write-Host "     Start Time     |   Mins  | Subject `n" #| RequiredAttendees"
            $Sorted = $Array | Sort-Object Start
            foreach ($item in $Sorted)
            {
                if ($item.Start)
                {
                    Write-Host "$($item.Start)" -NoNewline
                    Write-Host " | " -ForegroundColor Cyan -NoNewline
                    Write-Host "$($item.Duration) Mins" -NoNewline
                    Write-Host " | " -ForegroundColor Cyan -NoNewline
                    Write-Host "$($item.Subject)"
                }
            }
            Write-Host " "
        }
        else
        {
            return $Array |
                Select-Object Start, Duration, Subject, RequiredAttendees |
                Sort-Object Start
        }
    }
}
