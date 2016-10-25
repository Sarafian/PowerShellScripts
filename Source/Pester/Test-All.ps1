#Requires –Module Pester

Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("None","Temp","ScriptRoot")]
    [string]$OutputPath="None"
)

<#
$visualStudioServicesScriptsPath="$PSScriptRoot\..\..\Automation\VisualStudioTeamServices"
$isVSTSHostedAgent=& $visualStudioServicesScriptsPath\Test-VisualStudioTeamServicesBuildHostedAgent.ps1
if($isVSTSHostedAgent)
{
    & $visualStudioServicesScriptsPath\Initialize-NuGetPackageProvider.ps1 -Install -Import
    & $visualStudioServicesScriptsPath\Install-Module.ps1 -Name Pester
}
#>


$failedCount=0
$pesterHash=@{
    Script="$PSScriptRoot"
    PassThru=$true
}

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".").Replace(".ps1", "")
switch ($OutputPath)
{
    'None' {$outputFile=$null}
    'ScriptRoot' {$outputFile="$PSScriptRoot\$sut.xml"}
    'Temp' {$outputFile="$env:TEMP\$sut.xml"}
}

if($outputFile)
{
    $pesterHash.OutputFormat="NUnitXml"
    $pesterHash.OutputFile=$outputFile
}

$pesterResult=Invoke-Pester @pesterHash
$pesterResult | Add-Member -Name "TestResultPath" -Value $outputFile -MemberType NoteProperty
if($pesterResult.FailedCount -gt 0)
{
    $failedCount+=$pesterResult.FailedCount
}

if($failedCount -gt 0)
{
    throw "Test errors $failedCount detected"
}
return $failedCount