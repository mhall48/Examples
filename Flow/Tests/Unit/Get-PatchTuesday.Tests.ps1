InModuleScope 'Flow' {

    Describe "Get-PatchTuesday" {

        It "August Patch Tuesday" {
            $Result1 = Get-PatchTuesday -Date $(Get-Date -Year 2023 -Month 08 -Day 01)
            $Result1 | Should -Contain '08 August 2023 00:00:00'
        }
        It "Septembers Patch Tuesday" {
            $Result2 = Get-PatchTuesday -Date $(Get-Date -Year 2023 -Month 08 -Day 10)
            $Result2 | Should -Contain '12 September 2023 00:00:00'
        }
        It "Septembers Patch Tuesday" {
            $Result3 = Get-PatchTuesday -Date $(Get-Date -Year 2023 -Month 09 -Day 01)
            $Result3 | Should -Contain '12 September 2023 00:00:00'
        }
        It "Octobers Patch Tuesday" {
            $Result3 = Get-PatchTuesday -Date $(Get-Date -Year 2023 -Month 09 -Day 14)
            $Result3 | Should -Contain '10 October 2023 00:00:00'
        }
    }
}
