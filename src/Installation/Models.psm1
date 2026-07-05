Set-StrictMode -Version Latest

function Install-Models {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath
    )

    Write-StudioLog -Level INFO -Message "Loading model manifest..."

    $config = Get-StudioConfiguration

    $manifest = Get-ModelManifest -ManifestPath $ManifestPath

    foreach ($model in $manifest.Models) {

        $destination = Join-Path `
            $config.Paths.ModelsRoot `
            "$($model.Category)\$($model.FileName)"

        if (Test-Path $destination) {

            Write-StudioLog -Level SUCCESS -Message "$($model.Name) already installed."

        }
        else {

            Write-StudioLog -Level WARNING -Message "$($model.Name) is missing."

        }
    }

    Write-StudioLog -Level SUCCESS -Message "Manifest processed."
}

Export-ModuleMember -Function Install-Models