function Get-QueueCoverage
{
    <#
        .SYNOPSIS
        Who is on the queue.

        .DESCRIPTION
        Who is on the queue.

        .PARAMETER Date
        Date and time, if no value is provided it defaults to the current time

        .OUTPUTS
        [String]

        .EXAMPLE
        Get-QueueCoverage

        Dimi   : 6 to 9
        Martin : 9 to 12
        Ryan   : 12 to 14

        Returns the queue coverage times and highlights in green the current person on the queue
    #>

    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter()]
        [DateTime]$Date = $(Get-Date)
    )

    begin
    {
        $Queue = [ordered]@{ 
            "Dimi  " = @('6', '9') 
            "Martin" = @('9', '12') 
            "Ryan  " = @('12', '14')
        }
    }

    process
    {
        $QueueName = "NA"
        foreach ($User in $Queue.GetEnumerator()) {
            if ($Date.Hour -ge $User.Value[0] -and $Date.Hour -le $User.Value[1])
            {
                 $QueueName = $User.Name
            }
        }

        foreach ($User in $Queue.GetEnumerator()) {
            if ($QueueName -eq $User.Name)
            {
                Write-Host "$($User.Name) : $($User.Value  -join " to ")" -ForegroundColor Green
            }
            else 
            {
                Write-Host "$($User.Name) : $($User.Value  -join " to ")" 
            }
        }
    }  
}
