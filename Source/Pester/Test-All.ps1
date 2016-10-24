#Requires –Module Pester

Param (
    [Parameter(Mandatory = $false)]
    [string]$OutputPath=$null
)
$failedCount=0
$pesterHash=@{
    Script="$PSScriptRoot"
    PassThru=$true
}
if($OutputPath)
{
    $pesterHash.OutputFormat="NUnitXml"
    $pesterHash.OutputPath=$OutputPath
}
$pesterResult=Invoke-Pester @pesterHash

if($pesterResult.FailedCount -gt 0)
{
    $failedCount+=$pesterResult.FailedCount
}

return $failedCount