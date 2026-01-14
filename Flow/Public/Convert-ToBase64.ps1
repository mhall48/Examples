Function ConvertTo-Base64
{
    <#
        .SYNOPSIS
        Converts text to base 64 encoding

        .DESCRIPTION
        Converts text to base 64 encoding, Used for API calls auth for rest

        .PARAMETER Text
        Text to convert to base 64 encoding

        .PARAMETER ValidateDecode
        Converts the text back and validates it worked

        .EXAMPLE
        ConvertTo-Base64 'username:password'

        dXNlcm5hbWU6cGFzc3dvcmQ=

        .EXAMPLE
        ConvertTo-Base64 'username:password' -ValidateDecode

        True

        Encodes input then decodes input and checks it matches original text.

        .OUTPUTS
        [string]

    #>
    [CmdletBinding()]
    [OutputType([void])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$Text,

        [Parameter()]
        [Switch]$ValidateDecode
    )

    process
    {
        $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $EncodedText =[Convert]::ToBase64String($Bytes)
        
        if ($ValidateDecode)
        {
            $DecodedText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedText))
            if ($DecodedText -eq $Text)
            {
                return $true
            }
            else
            {
                return $false
            }
        }
        
        return $EncodedText
    }
}
