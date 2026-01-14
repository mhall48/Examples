
Function Test-Import
{
    <#
        .SYNOPSIS
        Removes existing loaded version and re-imports module from path

        .DESCRIPTION
        Removes existing loaded version and re-imports module from path

        .EXAMPLE
        Test-Import

        Re-import the module from the current dir

        .EXAMPLE
        Test-Import -Folder C:\githubdata\module

        Imports module

        .OUTPUTS
        [void]
    #>
    [CmdletBinding()]
    [OutputType([void])]
    Param
    (
        [Parameter()]
        [string]$Module = $((Get-ChildItem *.psd1).basename),

        [Parameter()]
        [string]$Folder,

        [Parameter()]
        [switch]$Silent,

        [Parameter()]
        [switch]$psm1,

        [Parameter()]
        [switch]$flow
    )

    if($flow)
    {
        $Module = "flow"
        $Folder = "C:\GitHubData\$Module"
    }

    if ($folder)
    {
        $Module = $((Get-ChildItem $Folder\*.psd1).basename)
    }
    else
    {
        $Folder = Get-Location
    }

    if (-not $Module)
    {
        Write-Warning "Run in a directory not containing the psd1 file."
        return
    }

    $old = Get-Module $Module -ErrorAction SilentlyContinue | Select Name, Version
    if($old)
    {
        if (-not $Silent)
        {
            Write-Host "Previous: $($old.Name) $($old.version)" -ForegroundColor yellow
        }
        Remove-Module $Module -Force
    }
    else
    {
        if (-not $Silent)
        {
            Write-Host "Previous: $Module not loaded"
        }
    }

    if (Get-Module $Module)
    {
        Write-Error "Error: Module $module failed to unload"
        return
    }

    [String]$Extension = "psd1"
    if ($psm1)
    {
        $Extension = "psm1"
    }

    Import-Module "$Folder\$Module.$Extension"  -Global -Force -DisableNameChecking
    $current = Get-Module $Module -ErrorAction SilentlyContinue | Select-Object Name, Version
    if (-not $Silent)
    {
        Write-Host "Current:  $($current.Name) $($current.version)" -ForegroundColor Green
    }
}
