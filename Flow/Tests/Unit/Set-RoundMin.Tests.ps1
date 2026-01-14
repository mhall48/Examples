InModuleScope 'Flow' {
    Describe "Set-RoundMin" {

        BeforeDiscovery {
            $TestCases = @(
                @{
                    Date   = $(Get-Date '12/03/2012 06:00:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:01:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:02:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:03:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:04:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:05:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:06:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:07:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:08:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:09:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:10:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:11:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:12:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:13:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:14:00')
                    Result = $(Get-Date '12/03/2012 06:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:15:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:16:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:17:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:18:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:19:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:18:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:19:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:20:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:21:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:22:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:23:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:24:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:25:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:26:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:27:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:28:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:29:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:30:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:31:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:32:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:33:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:34:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:35:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:36:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:37:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:38:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:39:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:40:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:41:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:42:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:43:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:44:00')
                    Result = $(Get-Date '12/03/2012 06:30:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:45:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:46:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:47:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:48:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:49:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:50:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:51:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:52:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:53:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:54:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:55:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:56:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:57:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:58:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 06:59:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                },
                @{
                    Date   = $(Get-Date '12/03/2012 07:00:00')
                    Result = $(Get-Date '12/03/2012 07:00:00')
                }
            )
        }

        It 'Date Tests' -TestCases $TestCases {
            param
            (
                $Date,
                $Result
            )

            Set-RoundMin -Date $Date | Should -Contain $Result
        }
    }
}
