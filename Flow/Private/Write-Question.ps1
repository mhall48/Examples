

Function Write-Question
{
    <#
        .SYNOPSIS
        Asks a questions with a list of answers and returns the answer selected

        .DESCRIPTION
        Asks a questions with a list of answers and returns the answer selected

        .PARAMETER Question
        Question to ask

        .PARAMETER List
        Array of options

        .OUTPUTS
        [string]

        .EXAMPLE
        Write-Question -List @('yes','no','takethefith') -Question "I have never..." -default "Yes"
    #>

    Param
    (
        [Parameter(Mandatory=$true)]
        [string[]]$List,

        [Parameter(Mandatory=$true)]
        [string]$Question,

        [Parameter()]
        [string]$Default
    )

    $i = 0

    Write-Host " "
    Foreach ($item in $List)
    {
        if ($item -eq $default)
        {
            Write-Host "$i : $item" -ForegroundColor Green
        }
        else
        {
            Write-Host "$i : $item"
        }

        $i++
    }

    If ($Default)
    {
        $Question = "$Question (Defaults to $Default)"
    }

    do
    {
        $Select = Read-Host $Question
        If ($Select -eq "")
        {
            if ($default)
            {
                return $Default
            }
            else
            {
                $Select = $i + 1 #force to loop again as no valid input
            }
        }
        else
        {
            $Select  = [int]$Select
        }
    }
    while ($Select -lt 0 -or $Select -gt $i)

    return $List[$Select]
}
