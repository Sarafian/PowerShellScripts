$scriptPath=Resolve-Path -Path "$PSScriptRoot\..\..\Scripts\PSRepository\Copy-Module.ps1"

$moduleName="MarkdownPS"
$invalidModuleName="Invalid"
$maximumVersion="1.4"
$requiredVersion="1.0"
$from="from"
$apiKey="apiKey"
$to="to"

Describe "Copy-Module.ps1 (Mock Publish-Module)" {
    Mock Publish-Module {
            
    }
    It "Copy-Module.ps1 -ModuleName -APIKey -to" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to} | Should Not Throw
        Assert-MockCalled Publish-Module -Exactly 1 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }
    It "Copy-Module.ps1 -ModuleName -APIKey -to -from" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to -from $from} | Should Throw
        Assert-MockCalled Publish-Module -Exactly 1 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }
    It "Copy-Module.ps1 -ModuleName -APIKey -to -RequiredVersion" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to -RequiredVersion $requiredVersion} | Should Not Throw
        Assert-MockCalled Publish-Module -Exactly 2 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }

    It "Copy-Module.ps1 -ModuleName -APIKey -to -from -RequiredVersion" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to  -from $from -RequiredVersion $requiredVersion} | Should Throw
        Assert-MockCalled Publish-Module -Exactly 2 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }
}