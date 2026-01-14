# Load functions
Get-ChildItem $PSScriptRoot\Private -Filter '*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem $PSScriptRoot\Public  -Filter '*.ps1' | ForEach-Object { . $_.FullName }

# Load module variables
. "$PSScriptRoot\Resource\ModuleVariables.ps1"

# Set aliases
foreach($alias in $Script:FUNCTION_ALIAS.GetEnumerator()) {
    Write-Verbose "Set-Alias $($alias.key) $($alias.value)"
    Set-Alias "$($alias.key)" "$($alias.value)" -force
}

#import in scope to auto generate global var, otherwise description is missing.
Get-HelpKey -screenno

$Modules = @('PSScriptAnalyzer')
Foreach ($Mod in $Modules)
{
    Write-Host "Importing $Mod"
    Import-Module $Mod -Force -Global
}
