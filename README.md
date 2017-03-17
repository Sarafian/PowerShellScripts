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

## What is new?

Check the [CHANGELOG.md](CHANGELOG.md) for release updates.