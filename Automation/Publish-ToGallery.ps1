param(
    [Parameter(Mandatory=$false)]
    [string]$NuGetApiKey=$null
)
$visualStudioServicesScriptsPath="$PSScriptRoot\VisualStudioTeamServices"
$isVSTSHostedAgent=& "$visualStudioServicesScriptsPath\Test-VisualStudioTeamServicesBuildHostedAgent.ps1"

$tempWorkFolderPath=Join-Path $env:TEMP "PowerShellScripts-Publish"
if(Test-Path $tempWorkFolderPath)
{
    Remove-Item -Path $tempWorkFolderPath -Recurse -Force
}
New-Item -Path $tempWorkFolderPath -ItemType Directory|Out-Null
Write-Verbose "Temporary working folder $tempWorkFolderPath is ready"

$sourceScripts=Get-ChildItem -Path "$PSScriptRoot\..\Source\Scripts" -Filter "*.ps1" -File -Recurse

$sourceScripts |ForEach-Object {
    $sourceScript=$_

    $scriptName=$sourceScript.Name.Replace($sourceScript.Extension,"")
    $progressActivity="Publish $scriptName"

    Write-Debug "Querying $scriptName"
    Write-Progress -Activity $progressActivity -Status "Querying..."
    $galleryScript=Find-Script -Name $scriptName -Repository PSGallery -ErrorAction SilentlyContinue
    Write-Verbose "Queried $scriptName"
    $shouldTryPublish=$false
    if($galleryScript)
    {
        $publishedVersion=$galleryScript.Version
        $publishedMajor=$publishedVersion.Major
        $publishedMinor=$publishedVersion.Minor

        Write-Verbose "Found existing published script with version $publishedVersion"

        $sourceScriptContent=$sourceScript | Get-Content -Raw
        $versionRegEx="\.VERSION (?<Major>([0-9]+))\.(?<Minor>([0-9]+))"
        $sourceVersion=$sourceScriptContent -match $versionRegEx
        $sourceMajor=[int]$Matches["Major"]
        $sourceMinor=[int]$Matches["Minor"]

        Write-Debug "sourceMajor=$sourceMajor"
        Write-Debug "sourceMinor=$sourceMinor"

        if(($sourceMajor -ne $publishedMajor) -or ($sourceMinor -ne $publishedMinor))
        {
            Write-Verbose "Source version $sourceMajor.$sourceMinor is different that published version $publishedVersion"
            $shouldTryPublish=$true
        }
        else
        {
            Write-Verbose "Source version $sourceMajor.$sourceMinor is the same. Will skip publishing"
        }
    }
    else
    {
        Write-Verbose "Script is not yet published to the gallery"
        $shouldTryPublish=$true
    }

    if($shouldTryPublish)
    {
        Write-Debug "Publishing $($sourceScript.FullName)"
        Write-Progress -Activity $progressActivity -Status "Publishing..."
        if($NuGetApiKey)
        {
            Publish-Script -Repository PSGallery -Path $sourceScript.FullName -NuGetApiKey $NuGetApiKey -Force
        }
        else
        {
            $mockKey="MockKey"
            if($isVSTSHostedAgent)
            {
                # When VSTS hosted agent is detected, the -Force is required. But it overrides the -WhatIf. 
                # This is only to check if it is possible to publish.
                Write-Warning "VSTS detected. Simulating publishing with -Force parameter."
                Publish-Script -Repository PSGallery -Path $sourceScript.FullName -NuGetApiKey $mockKey -WhatIf -Force -ErrorAction SilentlyContinue
                Write-Warning "Publish script is expected to have failed because of the $mockKey key."
            }
            else
            {
                Publish-Script -Repository PSGallery -Path $sourceScript.FullName -NuGetApiKey $mockKey -WhatIf
            }
        }
        Write-Verbose "Published $($sourceScript.FullName)"
    }
    Write-Progress -Activity $progressActivity -Completed
}