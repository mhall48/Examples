

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

        .PARAMETER Default
        Default answer if enter is pressed and no value provided

        .OUTPUTS
        [string]

        .EXAMPLE
        Write-Question -List @('yes','no','takethefith') -Question "I have never..." -default "Yes"

        .NOTES
        You can rely on the PowerShell parameter validation and prompting for input for mandatory parameters. 
        This function offers a more efficient option for input validation.

        See Public\Get-DemoGeneralQuestion for using this function
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
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

    if ($Default)
    {
        $Question = "$Question (Defaults to $Default)"
    }

    do
    {
        $Select = Read-Host $Question
        if ($Select -eq "")
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
