$nugetProviderName="NuGet"
Write-Host "Forcing update of $nugetProviderName package provider"
Install-PackageProvider -Name $nugetProviderName -Force -Scope CurrentUser
