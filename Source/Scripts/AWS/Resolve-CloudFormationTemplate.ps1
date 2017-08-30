#requires -Version 5.0

<#PSScriptInfo

.VERSION 1.0

.GUID 3ef0cacf-ac76-487a-8bec-dbf437d67f42

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
.Synopsis
   Resolves the conditions of a AWS cloud formation template 
.DESCRIPTION
   Resolves the conditions of a AWS cloud formation template
   1. Flip to json first when input is yaml
   1. Execute cft-simulate from Dome9/cft-simulator
   1. Flip response to yaml if the input is yaml
.EXAMPLE
   Resolve-CloudFormationTemplate
.LINK
   https://github.com/awslabs/aws-cfn-template-flip
.LINK
   https://nodejs.org/en/
.LINK
   https://github.com/Dome9/cft-simulator
.LINK
   https://github.com/Sarafian/PowerShellScripts
.LINK
   https://www.powershellgallery.com/packages/Get-Github/
.EXAMPLE
    $splat=@{
        CFTPath="cft.json"
        CFTParameters='{"env":"prod","a":123}'
        CFTResolvedPath="cft.resolved.json"
    }
    Resolve-CloudFormationTemplate @splat -JSON
.EXAMPLE
    $splat=@{
        CFTPath="cft.yaml"
        CFTParameters='{"env":"prod","a":123}'
        CFTResolvedPath="cft.resolved.yaml"
    }
    Resolve-CloudFormationTemplate @splat -YAML

#>
param(
    [Parameter(Mandatory=$true,ParameterSetName="JSON")]
    [Parameter(Mandatory=$true,ParameterSetName="YAML")]
    [string]$CFTPath,
    [Parameter(Mandatory=$true,ParameterSetName="JSON")]
    [Parameter(Mandatory=$true,ParameterSetName="YAML")]
    [string]$CFTParameters,
    [Parameter(Mandatory=$true,ParameterSetName="JSON")]
    [Parameter(Mandatory=$true,ParameterSetName="YAML")]
    [string]$CFTResolvedPath,
    [Parameter(Mandatory=$true,ParameterSetName="JSON")]
    [switch]$JSON,
    [Parameter(Mandatory=$true,ParameterSetName="YAML")]
    [switch]$YAML
)

begin {
    Write-Debug "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
    foreach($psbp in $PSBoundParameters.GetEnumerator()){Write-Debug "$($psbp.Key)=$($psbp.Value)"}

    $CFTItem=Get-Item -Path $CFTPath
}
process {
    #region Initialize JSON. Flip YAML if necessary
    switch($PSCmdlet.ParameterSetName)
    {
        'JSON' {
            $JSONPath=$CFTItem
        }
        'YAML' {
            Write-Warning "cft-simulator supports only JSON only JSON. Using cfn-flip to convert $($CFTItem.FullName) to JSON format"
            $cfnFlipPath=& C:\Windows\System32\where.exe cfn-flip
            $isCFNFlipInstalled=$LASTEXITCODE -eq 0

            if(-not $isCFNFlipInstalled)
            {
                throw "cfn-flip.exe not available. Install with pip install pip install cfn_flip"
            }
            $JSONPath=Join-Path -Path $env:TEMP -ChildPath ($CFTItem.Name.Replace(".yaml",".json"))
            $cfnFlipArgs=@(
                $CFTItem.FullName
                $JSONPath
            )
            & cfn-flip $cfnFlipArgs 2>&1
        }
    } 
    #endregion   

    #region Make sure NodeJS is installed
    $nodePath=& C:\Windows\System32\where.exe node
    $isNodeInstalled=$LASTEXITCODE -eq 0
    $npmPath=& C:\Windows\System32\where.exe npm
    $isNPMInstalled=$LASTEXITCODE -eq 0

    if(-not ($isNodeInstalled -and $isNPMInstalled))
    {
        throw "node.exe or npm.cmd not available. Install NodeJS"
    }
    $npmPath=$npmPath|Select-Object -First 1 -Skip 1
    #endregion

    #region Bootstrap cft-simulator
    # To avoid delays do this only on daily basis
    # 1. Download the code on a daily basis. Expected location C:\Users\myusername\AppData\Local\Temp\20170830-Resolve-CloudFormationTemplate\cft-simulator-master
    # 2. Do npm install

    $tempFolder=Join-Path -Path $env:TEMP -ChildPath "$(Get-Date -Format "yyyyMMdd")-Resolve-CloudFormationTemplate"
    if(-not (Test-Path -Path $tempFolder))
    {
        Write-Warning "Today's cft-simulator cached not found. Initializing"

        Write-Progress -Activity "Bootstrap cft-simulator" -Status "Downloading"
        $null=New-Item -Path $tempFolder -ItemType Directory
        $cftSimulatorUri="https://github.com/Dome9/cft-simulator/archive/master.zip"
        $downloadFileName="cft-simulator-master.zip"
        $downloadPath=Join-Path -Path $tempFolder -ChildPath $downloadFileName
        Invoke-WebRequest -Uri $cftSimulatorUri -UseBasicParsing -OutFile $downloadPath
        Write-Progress -Activity "Bootstrap cft-simulator" -Status "Expanding"
        Expand-Archive -Path $downloadPath -DestinationPath $tempFolder
        Push-Location -Path "$tempFolder\cft-simulator-master" -StackName npm

        Write-Progress -Activity "Bootstrap cft-simulator" -Status "NPM Installing"
        try{
            $npmOutputPath=Join-Path -Path $tempFolder -ChildPath "npm-install.out"
            $npmErrorPath=Join-Path -Path $tempFolder -ChildPath "npm-install.err"
            $process=Start-Process -FilePath $npmPath -ArgumentList @("install") -Wait -NoNewWindow -PassThru -RedirectStandardOutput $npmOutputPath -RedirectStandardError $npmErrorPath
            if($process.ExitCode -ne 0)
            {
                Get-Content -Path $npmOutputPath -Raw
                Get-Content -Path $npmErrorPath -Raw
                throw "Could not initialize cft-simulator"
            }
        }
        finally
        {
            Pop-Location -StackName npm
            Write-Progress -Activity "Bootstrap cft-simulator" -Completed
        }

    }
    else
    {
        Write-Verbose "Using today's cft-simulator cached download"
    }
    $cftSimulatorJSPath=Join-Path -Path $tempFolder -ChildPath "cft-simulator-master\cft-simulator.js"
    
    #endregion

    #region Run cft-simulator
    $nodeArgs=@(
        "cft-simulator.js"
        "-p"
        $CFTParameters.Replace('"', '\"')
        $JSONPath
    )
    Write-Verbose "$nodePath $($nodeArgs -join ' ')"

    $nodeOutputPath=Join-Path -Path $tempFolder -ChildPath "npm-install.out"
    $nodeErrorPath=Join-Path -Path $tempFolder -ChildPath "npm-install.err"

    $process=Start-Process -FilePath $nodePath -ArgumentList $nodeArgs -PassThru -NoNewWindow -Wait -WorkingDirectory "$tempFolder\cft-simulator-master" -RedirectStandardOutput $nodeOutputPath -RedirectStandardError $nodeErrorPath
    #endregion

    #region Process result
    if($process.ExitCode -eq 0)
    {
        switch($PSCmdlet.ParameterSetName)
        {
            'JSON' {
                Get-Content -Path $nodeOutputPath -Raw|ConvertFrom-Json|ConvertTo-Json |Out-File -FilePath $CFTResolvedPath -NoNewline
            }
            'YAML' {
                $cfnFlipArgs=@(
                    $nodeOutputPath
                    $CFTResolvedPath
                )
                & cfn-flip $cfnFlipArgs 2>&1
            }
        } 

        $result=$true
    }
    else
    {
        Write-Warning "cft-simulator executed with errors"
        Copy-Item -Path $nodeErrorPath -Destination $CFTResolvedPath -Force
        $result=$false
    }
    $result
    #endregion
}

end {

}