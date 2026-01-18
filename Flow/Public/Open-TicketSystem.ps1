function Open-TicketSystem
{
    <#
         .SYNOPSIS
        Opens the case specified in ticket system or opens knowledge base article

        .DESCRIPTION
        Includes regex to strip out any text to grab the id of the case

        .EXAMPLE
        Open-TicketSystem -ticket 10415

        Opens a ticket with the id input

        .EXAMPLE
        Open-TicketSystem -ticket HFHG23423

        Opens a ticket but strips out the extra text

        .EXAMPLE
        Open-TicketSystem -ticket 1838 -kb

        Opens a knowledge base page

        .OUTPUTS
        [void]

        .NOTES
        It's better to not uses Aliases in functions in a module as it's more descriptive and discoverable to use full names.
        But for functions like this where it benefits from shortening the name for use in PowerShell commandline, I set an alias 
        in the Resource\ModuleVariables which can be seen using Get-HelpKey or alias 'key'.
        E.g. instead of typing out 'Open-TicketSystem 2345' you can type 't 2345' in the PowerShell commandline.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    Param
    (
        [Parameter(Position = 0, Mandatory=$true)]
        [string]$ticket,

        [Parameter()]
        [switch]$kb,

        [Parameter()]
        [string]$url = 'https://ticketsystem.example.com/ticket?id='
    )

    process
    {
        if($kb)
        {
            $url = "https://ticketsystem.example.com/kb?id=$ticket&latest=true"
            Write-Host "opening: $url"
            Start-Process "$url"
        }
        elseif ($ticket -Match "([0-9]{1,})")
        {   
            Write-Host "opening: $url$($Matches[1])"
            Start-Process "$url$($Matches[1])"
        }
        else 
        {
            Write-Error "check input: $ticket" -ErrorAction Stop
        }
    }
}