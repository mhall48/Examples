Function New-IndexHashtable
{
    <#
        .SYNOPSIS
        Creates a dict/hashtable for indexing on a field for faster comparison

        .DESCRIPTION
        Creates a dict/hashtable for indexing on a field for faster comparison.
        For example indexing on a list of device ids, using a hash is much faster that looping through an 
        array of PSOs looking for values. 

        .OUTPUTS
        [string]

        .EXAMPLE
        $PSO = New-Object PSObject -Property ([ordered]@{
            Name             = "Test"
            OS               = "Windows"
            RamPercentLoad   = "45"
            CpuPercentLoad   = "33"
            TimeZone         = "GMT"
            Time             = "09:00"
            DNSTestPassed    = $false
        })
        $PSO2 = New-Object PSObject -Property ([ordered]@{
            Name             = "Test2"
            OS               = "Linux"
            RamPercentLoad   = "99"
            CpuPercentLoad   = "1"
            TimeZone         = "CST"
            Time             = "10:00"
            DNSTestPassed    = $true
        })
        $Array += $PSO, $PSO2 
        $Hash = New-IndexHashtable -InputArray $Array -IndexFieldName "Name"

        Name                           Value
        ----                           -----
        Test2                          @{Name=Test2; OS=Linux; RamPercentLoad=99; CpuPercentLoad=1; TimeZone=CST; Time=10:00; …
        Test                           @{Name=Test; OS=Windows; RamPercentLoad=45; CpuPercentLoad=33; TimeZone=GMT; Time=09:00…

        Creates a hashtable referenced by name so you can use $Hash["Test2"] to return test2 data.

        .EXAMPLE
        $Data = Find-FleetManagementData -Index 'windows_patching'
        $Hash = New-IndexHashtable -InputArray $Data -IndexFieldName "device_number"

        $Hash["$DeviceID"]

        $Output = @()
        Foreach ($item in $devicelist) #$devicelist is an array of devices numbers to match
        {
        $Thing = $hash["$item"]
        if ($Thing)
        {
                $Output += $Thing
        }
        }

        Returns a hashtable referenced by DeviceID, which is much faster filter relevant device ids.
    #>
    [CmdletBinding()]
    [OutputType([Hashtable])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [psobject[]]$InputArray,

        [Parameter(Mandatory=$true)]
        [string]$IndexFieldName
    )

    $hash = @{}
    Foreach ($value in $InputArray)
    {
        $index = $value."$IndexFieldName"
        $hash.add("$index",$value)
    }
    return $hash
}
