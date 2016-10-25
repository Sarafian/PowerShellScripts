param(
    [Parameter(Mandatory=$true)]
    [string[]]$Name
)
$Name | ForEach-Object {
    Find-Module -Name $_ | Install-Module -Scope CurrentUser -Force
    #Find-Module -Name $_ | Install-Module -Scope CurrentUser -Force -SkipPublisherCheck
}