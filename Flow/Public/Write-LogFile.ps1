function Write-LogFile
{
    <#
        .Synopsis
        Writes a log file

        .DESCRIPTION
        Writes a log file

        .PARAMETER Message
        Message text

        .PARAMETER PassThru
        Passes message to another program

        .PARAMETER Path
        Folder path of log file

        .PARAMETER LogFile
        Log file name

        .OUTPUTS
        [void], [strings]

        .EXAMPLE
        Write-LogFile "Something" -path "C:\logs\"

        .EXAMPLE
        "Test Message" | Write-LogFile -PassThru | Write-EventLogMsg -PassThru | Write-Error

        Writes to log, then to event log and then Write-Errors the same message
    #>

    [CmdletBinding()]
    [OutputType([void, string])]
    param
    (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)]
        [AllowEmptyString()]
        [string]$Message,

        [Parameter()]
        [switch]$PassThru,

        [Parameter()]
        [string]$Path,

        [Parameter()]
        [ValidatePattern('.log')]
        [string]$LogFile
    )

    Process
    {
        if (-not $logFile)
        {
            $Module = $(PSCmdlet.Myinvocation.Mycommand.Module.Name)
            $LogFile = $(
                (
                    Get-PSCallStack |
                    Where-Object {$_.InvocationInfo.MyCommand.Module.Name -eq $Module}
                )[-1].Command + '.log'
            )
        }

        $FullPath = Join-Path $Path $LogFile
        $LogMsg = "$([datetime]::Now.ToString('s')) : $Message"

        try
        {
           $LogMsg >> $FilePath
        }
        catch
        {
            Start-Sleep -Milliseconds 50
            try
            {
               $LogMsg >> $FilePath
            }
            catch
            {
                Write-Warning "Failed to write logfile entry. Path : ($FullPath) Msg : ($LogMsg): $_"
            }
        }

        if ($PassThru) {$Message}
    }
}
