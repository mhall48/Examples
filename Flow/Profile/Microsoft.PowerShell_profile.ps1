Set-ExecutionPolicy Bypass -Scope Process -Force
$MyPath = 'c:\githubdata'
$Folder = 'examples' #module folder
Set-Location $MyPath

# import module import e.g. third party
$Modules = @("posh-git")
Foreach ($Mod in $Modules)
{
    Write-Host "Importing $Mod" -ForegroundColor Cyan
    import-module $Mod -force -ErrorAction stop
}

# Set up a simple prompt, adding the git prompt parts inside git repos
function global:prompt {
    $realLASTEXITCODE = $LASTEXITCODE
    $LastCommandEnd   = (Get-History)[-1].EndExecutionTime
    $LastCommandStart = (Get-History)[-1].StartExecutionTime
    $Time = Get-Date ($LastCommandEnd) -UFormat %T
    $ExecutionTime    = ($LastCommandEnd - $LastCommandStart).Totalmilliseconds
    $TimeEx           = [math]::Round($ExecutionTime,0)
    $Display = 'ms'
    if ($TimeEx -ge 1000)
    {
        $TimeEx = [math]::Round(($TimeEx / 1000),0)
        $Display = 's'
    }
    $Output = "$Time $TimeEx$Display"
    $TimeDisplay = "[$Output]"
    Write-host "$($TimeDisplay.PadRight(8,' ')) " -ForegroundColor yellow -NoNewline
    Write-host "$($pwd.ProviderPath)" -NoNewline
    Write-VcsStatus

    $global:LASTEXITCODE = $realLASTEXITCODE
    return "$('>' * ($nestedPromptLevel + 1))"
}

# local dev module import
$Modules = @("examples")
Foreach ($Mod in $Modules)
{
    $ModPath = "$MyPath\$Mod\$Mod.psd1"
    Write-Host "Importing $ModPath" -ForegroundColor Cyan
    import-module $ModPath -ErrorAction -Force
}

Set-Location $Folder
