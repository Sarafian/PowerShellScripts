# PowerShell scripts

This is a repository for PowerShell scripts published in the [PowerShell gallery](http://www.powershellgallery.com/)

The repository is devided among different sections

## Github

[Get-Github.ps1](Source\Scripts\Github\Get-Github.ps1) downloads archives from github for the following cases

**Repository**
- Default branch `master`.
- Specified branch.
- Specified released artifact.

Using the script for this repository would look like this 

```powershell
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts -Branch develop
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts -Tag v0.1
```

There is also the option to expand the downloaded archive.

```powershell
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts -Expand
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts -Branch develop -Expand
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts -Tag v0.1 -Expand
```

## PSRepository

[CopyModule.ps1](Source\Scripts\PSRepository\Copy-Module.ps1) copies a module from repository to another.

To copy e.g [MarkdownPS](https://www.powershellgallery.com/packages/MarkdownPS/) module to a repository name `to` with api key `apikey` use one of the following script variants:

```powershell
$moduleName="MarkdownPS"
# Copy the latest version from PSGallery
.\Copy-Module.ps1 -ModuleName $moduleName -ToRepository "to" -APIKey "apikey"

# Copy the 1.0 version from PSGallery
.\Copy-Module.ps1 -ModuleName $moduleName -ToRepository "to" -APIKey "apikey" -RequiredVersion 1.0

# Copy the latest version from a repository
.\Copy-Module.ps1 -ModuleName $moduleName -ToRepository "to" -APIKey "apikey" -FromRepository "from"
```
# Amazon Web Services

[Resolve-CloudFormationTemplate.ps1](Source\Scripts\AWS\Resolve-CloudFormationTemplate.ps1) runs a local simulation of an AWS CloudFormation template file.

The script requires the following installed

- [Node](https://nodejs.org/)
- [aws-cfn-template-flip](https://github.com/awslabs/aws-cfn-template-flip)

The simulation is run by [Dome9's cft-simulator](https://github.com/Dome9/cft-simulator). As the simulator has not official releases, the script will download the master branch on every day and then run `npm install`. During the same day, the cached version will be used.

Because [Dome9's cft-simulator](https://github.com/Dome9/cft-simulator) supports only **JSON** type CloudFormation templates, the script will internally *flip* from one format to another when the template is in **YAML** format.

**Example for JSON**

```powershell

$splat=@{
    CFTPath="cft.json"
    CFTParameters='{"env":"prod","a":123}'
    CFTResolvedPath="cft.resolved.json"
}
Resolve-CloudFormationTemplate @splat -JSON
```

**Example for YAML**
```powershell

$splat=@{
    CFTPath="cft.yaml"
    CFTParameters='{"env":"prod","a":123}'
    CFTResolvedPath="cft.resolved.yaml"
}
Resolve-CloudFormationTemplate @splat -YAML
```

## What is new?

Check the [CHANGELOG.md](CHANGELOG.md) for release updates.