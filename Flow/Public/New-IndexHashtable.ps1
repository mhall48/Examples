Function New-IndexHashtable
{
    <#
        .SYNOPSIS
        Creates a dict/hashtable for indexing on a field for faster comparison

        .DESCRIPTION
        Creates a dict/hashtable for indexing on a field for faster comparison.
        Compare device list quicker for example

        .OUTPUTS
        [string]

        .EXAMPLE
        $Data = Find-FleetManagementData -Index 'windows_patching'
        $Hash = New-IndexHashtable -InputArray $Data -IndexFieldName "device_number"

        $Hash["$deviceID"]

        $Output = @()
        Foreach ($item in $devicelist) #$devicelist is an array of devices numbers to match
        {
        $Thing = $hash["$item"]
        if ($Thing)
        {
                $Output += $Thing
        }
        }

        Returns index you can then sort by
    #>
    [CmdletBinding()]
    [OutputType([psobject[]])]
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
