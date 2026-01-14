function Set-TlsClient
{
    <#
    .SYNOPSIS
    Sets the client-side .NET SSL/TLS configuration for the session.

    .DESCRIPTION
    Optionally enables TLS protocols in the powershell session or disables cert trust checking.

    Changes persist for the session.

    .PARAMETER Protocol
    One or more TLS protocols to enable in the .NET TLS client.

    .PARAMETER SkipCertChecks
    Disables trust checking of server certificates in the .NET TLS client.

    .OUTPUTS
    [void]

    .EXAMPLE
    Set-TlsClient -Protocol Tls12

    Enables the current powershell session to connect to servers running TLS 1.2.

    .EXAMPLE
    Set-TlsClient -SkipCertChecks

    Enables the current powershell session to connect to servers with self-signed certificates.
    #>
    [CmdletBinding()]
    [OutputType([void])]
    param
    (
        [Parameter()]
        [Net.SecurityProtocolType[]]$Protocol,

        [Parameter()]
        [switch]$SkipCertChecks
    )

    if ($Protocol)
    {
        $ProtcolsToSet = $null
        foreach ($P in $Protocol)
        {
            $ProtcolsToSet = $ProtcolsToSet -bor $P
        }
        [Net.ServicePointManager]::SecurityProtocol = $ProtcolsToSet
    }

    if ($SkipCertChecks)
    {
        try
        {
            $AppDomain  = [System.AppDomain]::CurrentDomain
            $LoadedType = $AppDomain.GetAssemblies().
                                     Where({-not $_.IsDynamic}).
                                     Foreach({$_.GetExportedTypes()}).
                                     Where({$_.Name -eq 'TrustAllCertsPolicy'})

            if (-not $LoadedType)
            {
                Add-Type "
                using System.Net;
                using System.Security.Cryptography.X509Certificates;
                public class TrustAllCertsPolicy : ICertificatePolicy {
                    public bool CheckValidationResult(
                        ServicePoint srvPoint, X509Certificate certificate,
                        WebRequest request, int certificateProblem) {
                        return true;
                    }
                }
                "

                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            }
        }
        Catch
        {
            Throw "Error setting session to trust all certificates: $($_.Exception.Message)"
        }
    }
}
