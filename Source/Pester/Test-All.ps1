#Requires –Module Pester

Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("None","Temp","ScriptRoot")]
    [string]$OutputFolderPath="None"
)
$failedCount=0
$pesterHash=@{
    Script="$PSScriptRoot"
    PassThru=$true
}

$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".").Replace(".ps1", "")
switch ($OutputFolderPath)
{
    'None' {$outputPath=$null}
    'ScriptRoot' {$outputPath="$PSScriptRoot\$sut.xml"}
    'Temp' {$outputPath="$env:TEMP\$sut.xml"}
}

if($OutputPath)
{
    $pesterHash.OutputFormat="NUnitXml"
    $pesterHash.OutputPath=$outputPath
}

$pesterResult=Invoke-Pester @pesterHash

if($pesterResult.FailedCount -gt 0)
{
    $failedCount+=$pesterResult.FailedCount
}

return $failedCount