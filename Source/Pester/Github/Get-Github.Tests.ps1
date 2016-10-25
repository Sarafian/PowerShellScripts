$scriptPath=Resolve-Path -Path "$PSScriptRoot\..\..\Scripts\Github\Get-Github.ps1"

$repository="PowerShellScripts"
$user="Sarafian"
$developBranch="develop"
$tag="v0.1"
# File inside the zip is suffixed with the release name v0.1 vs 0.1
$release="0.1"

$expectedMasterZipPath=Join-Path $env:TEMP "$repository-master.zip"
$expectedMasterPath=Join-Path $env:TEMP "$repository\$repository-master"
$expectedDevelopZipPath=Join-Path $env:TEMP "$repository-$developBranch.zip"
$expectedDevelopPath=Join-Path $env:TEMP "$repository\$repository-$developBranch"
$expectedTagZipPath=Join-Path $env:TEMP "$repository-$tag.zip"
$expectedTagPath=Join-Path $env:TEMP "$repository\$repository-$release"

Describe "Get-Github.ps1" {
    It "Download default master branch" {
        & $scriptPath -User $user -Repository $repository
        Test-Path -Path $expectedMasterZipPath -PathType Leaf |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository
        $expected=Get-Item -Path $expectedMasterZipPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
    It "Download and expand default master branch" {
        #& $scriptPath -User $user -Repository $repository -Expand
        #Test-Path -Path $expectedMasterZipPath -PathType Leaf |Should BeExactly $false
        #Test-Path -Path $expectedMasterPath -PathType Container |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository -Expand
        $expected=Get-Item -Path $expectedMasterPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
    It "Download specified $developBranch branch" {
        & $scriptPath -User $user -Repository $repository -Branch $developBranch
        Test-Path -Path $expectedDevelopZipPath -PathType Leaf |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository -Branch $developBranch
        $expected=Get-Item -Path $expectedDevelopZipPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
    It "Download and expand specified $developBranch branch" {
        #& $scriptPath -User $user -Repository $repository  -Branch $developBranch -Expand
        #Test-Path -Path $expectedDevelopZipPath -PathType Leaf |Should BeExactly $false
        #Test-Path -Path $expectedDevelopPath -PathType Container |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository  -Branch $developBranch -Expand
        $expected=Get-Item -Path $expectedDevelopPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
    It "Download specified $tag tag" {
        & $scriptPath -User $user -Repository $repository -Tag $tag
        Test-Path -Path $expectedTagZipPath -PathType Leaf |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository -Tag $tag
        $expected=Get-Item -Path $expectedTagZipPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
    It "Download and expand specified $tag tag" {
#        & $scriptPath -User $user -Repository $repository -Tag $tag -Expand
#        Test-Path -Path $expectedTagZipPath -PathType Leaf |Should BeExactly $false
#        Test-Path -Path $expectedTagPath -PathType Container |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository -Tag $tag -Expand
        $expected=Get-Item -Path $expectedTagPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
<# Problem with pester
    It "Download and expand default master branch" {
        {& $scriptPath -User $user -Repository $repository -Expand} |Should not throw
        Test-Path -Path $expectedMasterZipPath -PathType Leaf |Should BeExactly $false
        Test-Path -Path $expectedMasterPath -PathType Container |Should BeExactly $true
        $actual=& $scriptPath -User $user -Repository $repository -Expand
        $expected=Get-Item -Path $expectedMasterPath
        $actual.FullName | Should BeExactly ($expected.FullName)
    }
#>
}
