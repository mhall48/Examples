Function Get-ErrorStream
{
    <#
        .SYNOPSIS
        Reads the error stream from an exception object and returns it

        .DESCRIPTION
        When invoke-restmethod gets a http error and data is sent in the response,
        the throw does not properly handle it and fails to return the object.
        This function parses the error stream from the response and returns it as an object

        .PARAMETER ErrorRecord
        The ErrorRecord object containing the exception

        .EXAMPLE
        Get-ErrorStream -ErrorRecord $Exception

        .OUTPUTS
        [string]

    #>
    Param
    (
        [Parameter()]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    $result = $ErrorRecord.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($result)
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    write-output ($reader.ReadToEnd())
}
