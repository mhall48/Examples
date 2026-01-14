$ModuleRoot = $MyInvocation.MyCommand.Module.ModuleBase
if (-not $ModuleRoot)
{
    # When module loaded via PSM1 ModuleBase is null
    $ModuleRoot = "..\$PSScriptRoot"
}

$DocumentsPath = [Environment]::GetFolderPath("MyDocuments")

$ModuleVariables = @(
    @{
		Name = 'UPERCASE_NAME'  #example
		Description = 'description of the var'
		Value = 'Value to give it'
	},
    @{
		Name = 'HELP_FILE_PATH'  
		Description = 'help file locations'
		Value = 'C:\GitHubData\Examples\Flow\Notes\HelpFile'
	},
	@{
		Name = 'COMMON_PARAMETERS'
		Description = 'I class these as common parameters'
		Value = (
			'Verbose',
			'Debug',
			'ErrorAction',
			'WarningAction',
			'InformationAction',
			'ErrorVariable',
			'WarningVariable',
			'InformationVariable',
			'OutVariable',
			'OutBuffer',
			'PipelineVariable',
			'Confirm',
			'WhatIf'
		)
	},
    @{
        Name        = 'REPO_ROOT'
        Description = 'The root folder of the git repos'
        Value       = 'C:\Githubdata'
    },
    @{
        Name        = 'GITHUB_URI'
        Description = 'Github URL'
        Value       = 'https://github.com'
    },
    @{
        Name        = 'FUNCTION_ALIAS'
        Description = 'Alias to set'
        Value       = @{
            'key'      = 'Get-HelpKey'
            'import'   = 'Test-Import'
            't'        = 'Open-TicketSystem'
            'base64'   = 'ConvertTo-Base64'
            'cal'      = 'Get-Calendar'
            'q'        = 'Get-QueueCoverage'
        }
    }
)

$DefaultParams = @{
    Force  = $True
    Scope  = 'Script'
    Option = 'ReadOnly'
}

foreach ($VarParams in $ModuleVariables)
{
    if ($VarParams.Value -is [scriptblock])
    {
        $VarParams.Value = $VarParams.Value.Invoke()
    }
    Set-Variable @DefaultParams @VarParams
    Write-Verbose "Added Script Variable: $($VarParams.Name)"
}
