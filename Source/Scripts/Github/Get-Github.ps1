#Requires –Version 5

<#PSScriptInfo

.VERSION 0.1

.GUID 2d4a2e50-1ae2-4030-8f78-ac0c3d041e72

.AUTHOR Alex Sarafian

.COMPANYNAME 

.COPYRIGHT 

.TAGS Github

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
 Download a github repository or a gist 

#> 
Param(
    [Parameter(Mandatory=$true,ParameterSetName="Repository Branch")]
    #[Parameter(Mandatory=$true,ParameterSetName="Repository Tag")]
#    [Parameter(Mandatory=$true,ParameterSetName="Gist")]
    [string]$User,
    [Parameter(Mandatory=$true,ParameterSetName="Repository Branch")]
#    [Parameter(Mandatory=$true,ParameterSetName="Repository Tag")]
    [string]$Repository,
    [Parameter(Mandatory=$false,ParameterSetName="Repository Branch")]
    [string]$Branch="master",
#    [Parameter(Mandatory=$true,ParameterSetName="Repository Tag")]
#    [string]$Tag,
    [Parameter(Mandatory=$false,ParameterSetName="Repository Branch")]
#    [Parameter(Mandatory=$false,ParameterSetName="Repository Tag")]
    [switch]$Expand=$false
#    [Parameter(Mandatory=$true,ParameterSetName="Gist")]
#    [string]$ID,
#    [Parameter(Mandatory=$false,ParameterSetName="Gist")]
#    [string[]]$Filename
)
$parameterSetName=$PSCmdlet.ParameterSetName
Write-Debug "parameterSetName=$parameterSetName"

switch ($parameterSetName)
{
    {$_ -like 'Repository*'} {
        $repositoryZipUrl="https://github.com/$User/$Repository/archive/"
        switch ($parameterSetName)
        {
            <#
            {$_ -like '*Tag'} {
                $repositoryZipUrl+="$Tag.zip"
                $downloadFileName="$Repository-$Tag.zip"
            }
            #>
            {$_ -like '*Branch'} {
                $repositoryZipUrl+="$Branch.zip"
                $downloadFileName="$Repository-$Branch.zip"
            }
        }
        Write-Debug "repositoryZipUrl=$repositoryZipUrl"
        Write-Debug "downloadFileName=$downloadFileName"
        $downloadRepositoryActivity="Get Github repository $Repository from $User"
        # Download release artifact to temp folder
        Write-Progress -Activity $downloadRepositoryActivity -Status "Downloading $downloadFileName"
        $tempPath=Join-Path $env:TEMP $downloadFileName
        Write-Debug "tempPath=$tempPath"
        if(Test-Path $tempPath)
        {
            Write-Warning "$tempPath already exists. Removing..."
            Remove-Item -Path $tempPath -Force
            Write-Verbose "Removed $tempPath with recurse"
        }
        Write-Verbose "$tempPath is ready"
        Write-Debug "Downloading $repositoryZipUrl to $tempPath"
        Invoke-WebRequest -Uri $repositoryZipUrl -UseBasicParsing -OutFile $tempPath
        Write-Verbose "Downloaded $repositoryZipUrl to $tempPath"

        if($Expand)
        {
            Write-Progress -Activity $downloadRepositoryActivity -Status "Expanding $downloadFileName"
            $expandPath=Join-Path $env:TEMP $Repository
            Write-Debug "expandPath=$expandPath"
            # Remove the directory if it exists
            if(Test-Path $expandPath)
            {
                Write-Warning "$expandPath already exists. Removing"
                Get-ChildItem -Path $expandPath -Recurse -File| ForEach-Object { 
                    $_.IsReadOnly=$false 
                }
                $item=Get-Item $expandPath
                $item=IsReadOnly=$false
                Start-Sleep -Milliseconds 500
                Remove-Item -Path "$expandPath\*" -Recurse -Force
                Remove-Item -Path "$expandPath"  -Force
                Write-Verbose "Removed $expandPath with recurse"
            }
#            Start-Sleep -Milliseconds 500
<#
            while(Test-Path $expandPath -PathType Container -ErrorAction SilentlyContinue)
            {
                # sleep to make sure the file is available
                $milliseconds=100
                Write-Debug "Sleeping $milliseconds ms"
                Start-Sleep -Milliseconds 500
                Write-Verbose "Slept $milliseconds ms"
            }
#>
#            New-Item $expandPath -ItemType Directory |Out-Null
            Write-Verbose "$expandPath is ready"
<#            
            while(-not(Test-Path $tempPath -PathType Leaf -ErrorAction SilentlyContinue))
            {
                # sleep to make sure the file is available
                $milliseconds=100
                Write-Debug "Sleeping $milliseconds ms"
                Start-Sleep -Milliseconds 500
                Write-Verbose "Slept $milliseconds ms"
            }
#>            
            Write-Debug "Expanding $tempPath to $expandPath"
<# Powershell v4 version
            [System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')|Out-Null
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tempPath, $expandPath)|Out-Null
#>            
            Expand-Archive -Path $tempPath -DestinationPath $expandPath -Force
            Write-Verbose "Expanded $tempPath to $expandPath"
            
            
            Write-Debug "Removing $tempPath"
            Remove-Item -Path $tempPath -Recurse -Force
            Write-Verbose "Removed $tempPath"
            Get-ChildItem -Path $expandPath|Select-Object -First 1
        }
        else
        {
            Get-Item -Path $tempPath
        }
    }
<#
    {$_ -like 'Gist'} {

    }
#>
}



