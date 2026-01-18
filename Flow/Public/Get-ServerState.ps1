Function Get-ServerState
{
    <#
        .SYNOPSIS
        Check server vitals to highlight any obvious issues
        
        .DESCRIPTION
        Check server vitals to highlight any obvious issues e.g. low disk space, dns not working, etc.

        .PARAMETER RawOutput
        Switch if -RawOutput used returns a PSO of data for reuse in other code.

        .EXAMPLE
        Get-ServerState

        Name           = Example-12345
        OS             = Windows Server 2022 Datacenter Azure Edition
        RamPercentLoad = 44.5 %
        CpuPercentLoad = 4 %
        TimeZone       = UTC | (UTC) Coordinated Universal Time
        Time           = 10/Jun/25 16:59
        OSInstallDate  = 07/Oct/24 17:26
        LastBootUpTime = 18/Mar/25 03:52
        UpTimeInDays   = 84
        LastOSPatch    = 05/Sep/24 00:00
        LoggedInUser :
        USERNAME              SESSIONNAME        ID  STATE   IDLE TIME  LOGON TIME
        >jeff123              rdp-tcp#81         11  Active          .  7/14/2025 11:30 AM
        DNSTestPassed  = True
        Hostfile       = No entries found
        Diskspace :

        Drive TotalSize FreeSpace FreePercent
        ----- --------- --------- -----------
        C:    126.45 GB 72.26 GB  57.15 %
        D:    32 GB     29.51 GB  92.22 %

        ScriptError    = False

        Outputs a formatted string for read ability

        .EXAMPLE
        Get-ServerState -RawOutput

        ServerName     : Example-12345
        ServerTime     : Monday 09/June/2025 07:21
        LastBootUpTime : Tuesday 18/March/2025 03:52
        UpTimeInDays   : 83
        DNSTestPassed  : True
        Hostfile       : {}
        Diskspace      : {@{Drive=C:; TotalSize=126.45 GB; FreeSpace=75.6 GB; FreePercent=59.79 %}, @{Drive=D:; TotalSize=32
                        GB; FreeSpace=29.51 GB; FreePercent=92.22 %}}
        ScriptError    : False

        Outputs a PSCustomObject, this is designed for reuse of data by code.

        .OUTPUTS
        [PSCustomObject], [String]

        .NOTES
        Author: Mark Hall
        Version: 1.0.0.0 | 15/7/2025
        Code can be run in a standard PowerShell window and doesn't require an admin window
        Quick troubleshooting code for server state during Major Incident troubleshooting
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject], [String])]
    Param (
        [Parameter()]
        [switch]$RawOutput
    )

    begin
    {
        $PSO = New-Object PSObject -Property ([ordered]@{
            Name             = "$($env:COMPUTERNAME)"
            OS               = ""
            RamPercentLoad   = ""
            CpuPercentLoad   = ""
            TimeZone         = ""
            Time             = ""
            OSInstallDate    = ""
            LastBootUpTime   = ""
            UpTimeInDays     = ""
            LastOSPatch      = ""
            LoggedInUser     = @()
            DNSTestPassed    = $false
            Hostfile         = @()
            Diskspace        = @()
            ScriptError      = @()
        })
    }

    process
    {
        try
        {
            $Zone = Get-Timezone
            $PSO.TimeZone = "$($Zone.ID) | $($Zone.DisplayName)"
        }
        catch
        {
            $PSO.ScriptError += "Timezone : $_"
        }

        try
        {
            $PSO.Time = Get-Date -UFormat "%d/%b/%y %R" -ErrorAction Stop
            $WinOS = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop

            $PSO.OSInstallDate = $WinOS.InstallDate |
                Get-Date -UFormat "%d/%b/%y %R"  -ErrorAction Stop

            $PSO.OS = $WinOS.Caption

            $Date = Get-Date
            $PSO.LastBootUpTime = $WinOS.LastBootUpTime |
                Get-Date -UFormat "%d/%b/%y %R"  -ErrorAction Stop

            $PSO.UpTimeInDays = ($Date - $($WinOS.LastBootUpTime)).Days

            $PSO.RamPercentLoad = (100 - ($WinOS.FreePhysicalMemory / $WinOS.TotalVisibleMemorySize) * 100)
            $PSO.CpuPercentLoad = (Get-CimInstance -ClassName Win32_Processor -ErrorAction Stop).LoadPercentage

            $PSO.RamPercentLoad = "$([math]::Round($($PSO.RamPercentLoad),1)) %"
            $PSO.CpuPercentLoad = "$([math]::Round($($PSO.CpuPercentLoad),1)) %"
        }
        catch
        {
            $PSO.ScriptError += "Date, Uptime and Domain: $_ "
        }

        try
        {
            $PSO.OS = $(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ProductName
        }
        catch
        {
            $PSO.ScriptError += "Install Date Reg: $_ "
        }

        try
        {
            $LastPatch = (Get-HotFix -ErrorAction Stop |
                Sort-Object InstalledOn -Descending |
                Select-Object -First 1 ).InstalledOn

            if ($LastPatch)
            {
                $PSO.LastOSPatch = $LastPatch | Get-Date -UFormat "%d/%b/%y %R" -ErrorAction Stop
            }
        }
        catch
        {
            $PSO.ScriptError += "Last OS Patch: $_ "
        }

        try
        {
            if (Resolve-DnsName -Type CNAME www.google.com -ErrorAction Stop)
            {
                $PSO.DNSTestPassed =  $true
            }
        }
        catch
        {
            $PSO.ScriptError += "DNS CHeck: $_ "
        }

        try
        {
            # Host files entries
            $Pattern = '^(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(?<Host>.+)$'
            $Entries = @()
            $File    = "C:\Windows\System32\Drivers\etc\hosts"
            (Get-Content -Path $File) |
                ForEach-Object {
                if ($_ -match $Pattern)
                {
                    $Entries += "$($Matches.IP),$($Matches.Host)"
                }
            }
            $PSO.Hostfile = $Entries

            if (-not $PSO.Hostfile)
            {
                $PSO.Hostfile = "No entries found"
            }
        }
        catch
        {
            $PSO.ScriptError += "HostFile Check: $_ "
        }

        try
        {
            $LoggedIn = quser 2>&1
            $PSO.LoggedInUser = $LoggedIn
            If ($LASTEXITCODE -ne 0)
            {
                Write-Error "LastExit code $LASTEXITCODE" -ErrorAction Stop
            }
        }
        catch
        {
            $PSO.ScriptError += "Logged In User: $_ "
        }

        try
        {
            # Disk Space of local disk (type 3)
            $Disks = Get-CimInstance -Class Win32_LogicalDisk -ErrorAction Stop|
                Where-Object {$_.DriveType -eq 3}

            ForEach ($Disk in $Disks)
            {
                $TotalSize = $Disk.Size / 1MB
                $FreeSpace = $Disk.FreeSpace / 1MB
                $FreePercentage = if ($TotalSize -eq 0) { 0 } else {[math]::Round($FreeSpace / $TotalSize * 100, 2)}

                $SizeUnit = "MB"
                $TotalSizeGB = $TotalSize
                $FreeSpaceGB = $freeSpace

                if ($TotalSize -gt 1024)
                {
                    $sizeUnit = "GB"
                    $TotalSizeGB = [math]::Round($TotalSize / 1024, 2)
                    $FreeSpaceGB = [math]::Round($freeSpace / 1024, 2)
                }

                $PSO.Diskspace += [PSCustomObject]@{
                    Drive       = $Disk.DeviceID
                    TotalSize   = "$totalSizeGB $sizeUnit"
                    FreeSpace   = "$FreeSpaceGB $sizeUnit"
                    FreePercent = "$FreePercentage %"
                }
            }
        }
        catch
        {
            $PSO.ScriptError += "Disk Check: $_ "
        }

        if (-not $PSO.ScriptError)
        {
            $PSO.ScriptError = $False
        }

        # Format txt output
        if ($RawOutput)
        {
            return $PSO
        }
        else
        {
            $Output = ""

            $Longest = (
                $PSO.PSObject.Properties.Name | 
                Sort-Object length -Descending | 
                Select-Object -first 1
                ).length

            foreach ($Property in $PSO.PSObject.Properties)
            {
                if ($Property.value -is [system.array])
                {
                    $Output += "$($Property.Name) : `n"
                    $Output += $Property.Value |
                        Format-Table -AutoSize |
                        Out-String
                }
                else
                {
                    $Pad = $Longest - $($($Property.Name).Length)
                    $Output += "$($Property.Name)$(" " * $Pad) = $($Property.Value) `n"
                }
            }
            return $Output
        }
    }
}
