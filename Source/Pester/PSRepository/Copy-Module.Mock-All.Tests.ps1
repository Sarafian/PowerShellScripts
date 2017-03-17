$scriptPath=Resolve-Path -Path "$PSScriptRoot\..\..\Scripts\PSRepository\Copy-Module.ps1"

$moduleName="MarkdownPS"
$invalidModuleName="Invalid"
$maximumVersion="1.4"
$requiredVersion="1.0"
$from="from"
$apiKey="apiKey"
$to="to"

Describe "Copy-Module.ps1 (Mock-All)" {
    Mock Publish-Module {
            
    }
    Mock Find-Module {
        switch ($Repository)
        {
            'PSGallery' {
                $hash=@{
                    Version="1.4"
                }
                New-Object -TypeName PSObject -Property $hash
            }
            $from {
                throw "No match was found for the specified search criteria"
            }
            $to {
                $null    
            }
        }

    }
    Mock Save-Module {
        switch ($Repository)
        {
            'PSGallery' {

            }
            $from {
                throw "No match was found for the specified search criteria"
            }
            $to {
                    
            }
        }
            
    }
    It "Copy-Module.ps1 -ModuleName -APIKey -to" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to} | Should Not Throw
        Assert-MockCalled Find-Module -Exactly 1 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq "PSGallery") }
        Assert-MockCalled Find-Module -Exactly 1 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq $to) -and ($RequiredVersion -eq $maximumVersion) }
        Assert-MockCalled Save-Module -Exactly 1 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq "PSGallery") -and ($RequiredVersion -eq $maximumVersion) }
        Assert-MockCalled Publish-Module -Exactly 1 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }
    It "Copy-Module.ps1 -ModuleName -APIKey -to -from" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to -from $from} | Should Throw
        Assert-MockCalled Find-Module -Exactly 1 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq $from) }
        Assert-MockCalled Save-Module -Exactly 0 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq $from) -and ($RequiredVersion -eq $maximumVersion) }
        Assert-MockCalled Publish-Module -Exactly 1 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }
    It "Copy-Module.ps1 -ModuleName -APIKey -to -RequiredVersion" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to -RequiredVersion $requiredVersion} | Should Not Throw
        Assert-MockCalled Find-Module -Exactly 1 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq "PSGallery") }
        Assert-MockCalled Find-Module -Exactly 2 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq $to) -and ($RequiredVersion -eq $requiredVersion) }
        Assert-MockCalled Save-Module -Exactly 2 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq "PSGallery") -and ($RequiredVersion -eq $requiredVersion) }
        Assert-MockCalled Publish-Module -Exactly 2 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }

    It "Copy-Module.ps1 -ModuleName -APIKey -to -from -RequiredVersion" {
        { & $scriptPath -ModuleName $moduleName -ApiKey $apiKey -to $to  -from $from -RequiredVersion $requiredVersion} | Should Throw
        Assert-MockCalled Find-Module -Exactly 3 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq $to) -and ($RequiredVersion -eq $requiredVersion) }
        Assert-MockCalled Save-Module -Exactly 1 -ParameterFilter { ($Name -eq $moduleName) -and ($Repository -eq $from) -and ($RequiredVersion -eq $requiredVersion) }
        Assert-MockCalled Publish-Module -Exactly 2 -ParameterFilter { ($Repository -eq $to) -and ($NuGetApiKey -eq $apiKey) }
    }
}