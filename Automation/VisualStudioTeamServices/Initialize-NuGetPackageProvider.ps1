param(
    [Parameter(Mandatory=$false)]
    [switch]$Install=$false,
    [Parameter(Mandatory=$false)]
    [switch]$Import=$false
)
$nugetProviderName="NuGet"
if($Install)
{
    Write-Information "Forcing update of $nugetProviderName package provider"
    Install-PackageProvider -Name $nugetProviderName -Force -Scope CurrentUser
}
if($Install)
{
    Write-Information "Forcing import of $nugetProviderName package provider"
    Import-PackageProvider -Name $nugetProviderName
}