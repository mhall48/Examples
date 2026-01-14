function Open-TicketSystem
{
    <#
         .SYNOPSIS
        Opens this case in ticket system or knowledge base article

        .DESCRIPTION
        Opens this case in ticket system or knowledge base article

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
        I feel it's better to not uses Aliases in functions in a module as it's more descriptive and discoverable to use full name
        But for functions like this where it benefits from shortening the name for use on commandline, I set an alias 
        in the Resource\ModuleVariables which can be seen using Get-HelpKey or alias key
        E.g. instead of 'Open-TicketSystem 2345' you can type in 't 2345'  
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