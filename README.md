# PowerShell scripts

This is a repository for PowerShell scripts published in the [PowerShell gallery](http://www.powershellgallery.com/)

The repository is devided among different sections

## Github

[Get-Github.ps1](Source\Scripts\Github\Get-Github.ps1) downloads artifacts from github for the following cases

**Repository**
- Default branch `master`.
- Specified branch.
- Specified released artifact. **(Not yet available)**

It has also the ability to automatically expand the downloaded articact.

```powershell
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts -Branch develop
.\Get-Github.ps1 -User Sarafian -Repository PowerShellScripts -Tag v0.1 # Not yet available
```

## What is new?

Check the [CHANGELOG.md](CHANGELOG.md) for release updates.