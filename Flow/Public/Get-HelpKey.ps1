Function Get-HelpKey
{
    <#
        .SYNOPSIS
        Help info for my work flow

        .DESCRIPTION
        Help info for my work flow, prints out useful info for easy reference.

        Opens file in code for editing/viewing by default

        .OUTPUTS
        [string]

        .PARAMETER Type
        List of help files and options to return the data about e.g. alias

        .PARAMETER ScreenNo
        Used to preload the help alias information from the psm1 in a global var

        .PARAMETER Screen
        Displays the information i.e. help files content on screen

        .EXAMPLE
        Get-HelpKey

        Name     Definition
        ----     ----------
        commands Get-ModuleCommands
        e        Open-Explorer
        example  Get-Examples
        export   Set-PsdExportFunctions
        import   Test-Import
        key      Get-HelpKey
        psb      Get-SomeoneElseBranch
        rr       Get-RunCommand
        work     Open-Flow

        Help info for my work flow

        .EXAMPLE
        key Code

        Open the Code.txt help file in vscode
    #>

    [CmdletBinding()]
    Param
    (
        [Parameter(Position = 0)]
        [ArgumentCompleter(
            {
                param (
                       $CommandName,
                       $ParameterName,
                       $WordToComplete,
                       $CommandAst,
                       $FakeBoundParameters
                )
                $Script:HelpType = (Get-Childitem C:\githubdata\Examples\Flow\Notes\HelpFile\*.txt).basename # can't use a script var here doesn't load path
                $Script:HelpType += "HelpFiles"

                return ($Script:HelpType | Where-Object { $_ -like "$WordToComplete*"})
            }
        )]
        [string]$Type = "Alias",

        [Parameter()]
        [Switch]$ScreenNo,

        [Parameter()]
        [Switch]$Screen,

        [Parameter()]
        [Switch]$Notepad
    )

    if ($screenno)
    {
        $Type = "Alias"
    }

    if($Type -eq "Alias")
    {
        If (-Not $Global:AliasTable)
        {
            $Commands = ((Get-Module flow).ExportedCommands).values | Where-object{$_.commandtype -eq "alias"}
            $Alias = @()
            $Commands | ForEach-Object{$Alias += Get-Alias $_.name}
            $Global:AliasTable = $Alias | Select-Object name, definition | Sort-Object Description
        }

        #run from psm1 in this module to force creation of $Global:AliasTable inscope
        If (-not $screenno)
        {
            Write-Host "List of help files = key -Type helpfiles"
            "Alias List (`$Global:AliasTable):"
            $Global:AliasTable
        }
    }
    elseif ($Type -eq "HelpFiles")
    {
        (Get-childitem -File -Path $Script:HELP_FILE_PATH\*.txt | Select-Object BaseName).BaseName
    }
    elseif ($Screen)
    {
        $Key = Get-content "$Script:HELP_FILE_PATH\$Type.txt"
        " "

        $Key
        " "
    }
    elseif ($Notepad)
    {
        Notepad.exe "$Script:HELP_FILE_PATH\$Type.txt"
    }
    else
    {
        Code "$Script:HELP_FILE_PATH\$Type.txt"
    }
}
