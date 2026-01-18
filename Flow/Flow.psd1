@{
    Description       = 'Flow tools'
    ModuleToProcess   = 'Flow.psm1'
    ModuleVersion     = '1.0.0.0'
    GUID              = '7cfbc158-2fa3-43d2-86a1-5f27f29a5d06'
    Author            = 'Mark Hall'
    CompanyName       = 'Mark Hall'
    Copyright         = '(c) Mark Hall All rights reserved.'
    PowerShellVersion = '7.0'
    RequiredModules   = @()
    FunctionsToExport = @(
        'ConvertTo-Base64',
        'Find-WeekDay',
        'Get-Calendar',
        'Get-DemoGeneralQuestion'
        'Get-ErrorStream',
        'Get-HelpKey',
        'Get-PatchTuesday',
        'Get-QueueCoverage',
        'Get-ServerState',
        'New-IndexHashtable',
        'Open-TicketSystem',
        'Test-Import',
        'Write-LogFile'
    )
    PrivateData       = @{
        PSData = @{
            Tags      = @(
                'flow',
                'tools'
            )
            OSVersion = '8.0'
        }
    }
}
