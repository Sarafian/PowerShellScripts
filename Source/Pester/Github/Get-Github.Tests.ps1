$scriptPath=Resolve-Path -Path "$PSScriptRoot\..\..\Scripts\Github\Get-Github.ps1"

$repository="PowerShellScripts"
$user="Sarafian"
$developBranch="develop"

$expectedMasterZipPath=Join-Path $env:TEMP "$repository-master.zip"
$expectedMasterPath=Join-Path $env:TEMP "$repository\$repository-master"
$expectedDevelopZipPath=Join-Path $env:TEMP "$repository-develop.zip"
$expectedDevelopPath=Join-Path $env:TEMP "$repository\$repository-develop"

Describe "Get-Github.ps1" {
    It "Download default master branch" {
        {& $scriptPath -User $user -Repository $repository} |Should not throw
        Test-Path -Path $expectedMasterZipPath -PathType Leaf |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository
        $expected=Get-Item -Path $expectedMasterZipPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
    It "Download and expand default master branch" {
        {& $scriptPath -User $user -Repository $repository -Expand} |Should not throw
        Test-Path -Path $expectedMasterZipPath -PathType Leaf |Should BeExactly $false
        Test-Path -Path $expectedMasterPath -PathType Container |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository -Expand
        $expected=Get-Item -Path $expectedMasterPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }

    It "Download specified develop branch" {
        {& $scriptPath -User $user -Repository $repository -Branch develop} |Should not throw
        Test-Path -Path $expectedDevelopZipPath -PathType Leaf |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository -Branch develop
        $expected=Get-Item -Path $expectedDevelopZipPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
    It "Download and expand specified develop branch" {
        {& $scriptPath -User $user -Repository $repository  -Branch develop -Expand} |Should not throw
        Test-Path -Path $expectedDevelopZipPath -PathType Leaf |Should BeExactly $false
        Test-Path -Path $expectedDevelopPath -PathType Container |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository  -Branch develop -Expand
        $expected=Get-Item -Path $expectedDevelopPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
}
