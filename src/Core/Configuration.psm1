Set-StrictMode -Version Latest

function Get-StudioConfiguration {

    [CmdletBinding()]
    param()

    $configPath = Join-Path $PSScriptRoot "..\..\config\StudioConfig.psd1"

    $configPath = (Resolve-Path $configPath).Path

    Import-PowerShellDataFile -Path $configPath
}

Export-ModuleMember -Function Get-StudioConfiguration