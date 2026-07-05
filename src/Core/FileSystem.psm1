Set-StrictMode -Version Latest

Import-Module "$PSScriptRoot\Logging.psm1" -Force

function New-StudioDirectory {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (Test-Path $Path) {

        Write-StudioLog -Level INFO -Message "Directory already exists."

        return
    }

    New-Item `
        -ItemType Directory `
        -Path $Path | Out-Null

    Write-StudioLog -Level SUCCESS -Message "Directory created."
}

Export-ModuleMember -Function New-StudioDirectory