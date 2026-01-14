
Function Get-DemoGeneralQuestion
{
    <#
        .SYNOPSIS
        Asks questions for a thing

        .DESCRIPTION
        Asks questions for a thing

        .EXAMPLE
        Get-DemoGeneralQuestion
    #>

    [CmdletBinding()]
    [OutputType([string])]
    Param
    (
        [Parameter()]
        [string]$Summary,

        [Parameter()]
        [string]$Comment
    )

    begin
    {
        $Colour = @(
            'Red',
            'Blue',
            'Green'
        )

        $Shape = @(
            'Square',
            'Circule',
            'Triangle'
        )
    }

    process
    {
        Write-Question -question 'Chosse Colour' -list $Colour
        Write-Question -question 'Make thing?' -list @('Quit', 'Yes') -Default 'Yes'        
        Write-RegExQuestion -RegEx '^\d{1,9}$' -Question "Number" -Default 3
    }
}
