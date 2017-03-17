#requires -module PowerShellGet

<#PSScriptInfo

.VERSION 0.1

.GUID 7c4258c9-27b3-40c3-91eb-92c8bf3a7175

.AUTHOR Alex Sarafian

.COMPANYNAME 

.COPYRIGHT 

.TAGS Modules

.LICENSEURI https://github.com/Sarafian/PowerShellScripts/blob/master/LICENSE

.PROJECTURI https://github.com/Sarafian/PowerShellScripts

.ICONURI 

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS 

.EXTERNALSCRIPTDEPENDENCIES 

.RELEASENOTES

#>

<# 

.DESCRIPTION 
 Copy a module from one repisotry to anotther 

#> 
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Mandatory=$true)]
    [string]$ModuleName,
    [Parameter(Mandatory=$false)]
    [string]$RequiredVersion=$null,
    [Parameter(Mandatory=$false)]
    [string]$FromRepository="PSGallery",
    [Parameter(Mandatory=$true)]
    [string]$ApiKey,
    [Parameter(Mandatory=$true)]
    [string]$ToRepository
)
Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"

Write-Debug "ModuleName=$ModuleName"
Write-Debug "RequiredVersion=$RequiredVersion"
Write-Debug "FromRepository=$FromRepository"
Write-Debug "ApiKey=$ApiKey"
Write-Debug "ToRepository=$ToRepository"

$savePath=$env:TEMP


$saveModuleHash=@{
    Name=$ModuleName

}
if($FromRepository)
{
    $saveModuleHash.Repository=$FromRepository
}

if(-not $RequiredVersion)
{
    $RequiredVersion=Find-Module @saveModuleHash|Select-Object -ExpandProperty Version -First 1
}
$saveModuleHash.RequiredVersion=$RequiredVersion
$moduleOnTargetRepository=Find-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Repository $ToRepository -ErrorAction SilentlyContinue
if($moduleOnTargetRepository -eq $null)
{
    Save-Module @saveModuleHash -Path $savePath -ErrorAction Stop
    Write-Host "Saved $ModuleName"

    $savedModulePath=Join-Path $savePath $ModuleName
    Publish-Module -Path $savedModulePath -Repository $ToRepository -NuGetApiKey $ApiKey
    Write-Host "Published $ModuleName"
}
else
{
    Write-Warning "$ModuleName with $RequiredVersion is already available on $ToRepository"
}