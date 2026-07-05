Set-StrictMode -Version Latest

function Expand-StudioArchive {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Archive,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    Write-StudioLog -Level INFO -Message "Extracting archive..."

    Expand-Archive `
        -Path $Archive `
        -DestinationPath $Destination `
        -Force

    Write-StudioLog -Level SUCCESS -Message "Archive extracted."
}

Export-ModuleMember -Function Expand-StudioArchive