Set-StrictMode -Version Latest

function Invoke-GitClone {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Repository,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (Test-Path $Destination) {

        Write-StudioLog -Level INFO -Message "Repository already exists."

        return
    }

    Invoke-StudioProcess `
        -FilePath git `
        -ArgumentList @(
            "clone",
            $Repository,
            $Destination
        )

    Write-StudioLog -Level SUCCESS -Message "Repository cloned."
}

Export-ModuleMember -Function Invoke-GitClone