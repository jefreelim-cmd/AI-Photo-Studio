Set-StrictMode -Version Latest

function Get-ModelManifest {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath
    )

    Import-PowerShellDataFile $ManifestPath
}

Export-ModuleMember -Function Get-ModelManifest