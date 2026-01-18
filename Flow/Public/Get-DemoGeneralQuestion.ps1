
Function Get-DemoGeneralQuestion
{
    <#
        .SYNOPSIS
        Asks questions for a thing

        .DESCRIPTION
        Demo of asking questions using private functions Write-Question and Write-RegExQuestion

        .EXAMPLE
        Get-DemoGeneralQuestion

        0 : Red
        1 : Blue
        2 : Green
        Choose Colour: 1
        Blue

        0 : Quit
        1 : Yes
        Make thing? (Defaults to Yes):
        Yes

        Please input a number (Defaults to 3): 1
        1

        Above is the example appearance of questions.
    #>

    [CmdletBinding()]
    [OutputType([string])]
    Param ()

    begin
    {
        $Colour = @(
            'Red',
            'Blue',
            'Green'
        )
    }

    process
    {
        Write-Question -question 'Choose Colour' -list $Colour
        Write-Question -question 'Make thing?' -list @('Quit', 'Yes') -Default 'Yes'        
        Write-RegExQuestion -RegEx '^\d{1,9}$' -Question "Please input a number" -Default 3
    }
}
