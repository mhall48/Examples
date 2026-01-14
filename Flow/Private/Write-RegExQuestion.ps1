Function Write-RegExQuestion
{
    <#
        .SYNOPSIS
        Asks a question with a regex match requirement

        .DESCRIPTION
        Asks a question with a regex match requirement

        .PARAMETER Question
        Question to ask

        .PARAMETER Regex
        Array of options

        .OUTPUTS
        [string]

        .EXAMPLE
        Write-RegExQuestion -RegEx '^\d{1,9}$' -Question "Enter a number"
    #>

    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$Question,

        [Parameter(Mandatory=$true)]
        [string]$RegEx,

        [Parameter()]
        [string]$Default
    )

    Write-Host " "
    $Quit = $false
    do
    {
        if ($Default -notmatch $RegEx)
        {
            Write-Error "Default answer does not match RegEx e.g. Default = $Default, Regex = $RegEx"
        }

        if ($Default)
        {
            $QuestionText = "$Question (Defaults to $Default)"
        }
        else 
        {
            $QuestionText = "$Question"
        }

        [string]$Answer = Read-Host  $QuestionText
        if ($Answer -match "$RegEx" -or ($Default -and $Answer -eq ""))
        {
            if ($Answer -eq "")
            {
                $Answer = $Default
            }

            $Quit = $true
        }
    }
    while (-not $Quit)

    return $Answer
}
