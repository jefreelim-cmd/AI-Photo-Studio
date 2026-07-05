Set-StrictMode -Version Latest

Import-Module "$PSScriptRoot\..\Core\Configuration.psm1" -Force
Import-Module "$PSScriptRoot\..\Core\Logging.psm1" -Force
Import-Module "$PSScriptRoot\..\Core\Downloads.psm1" -Force
Import-Module "$PSScriptRoot\..\Models\Models.psm1" -Force

function Install-SingleModel {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$Model
    )

    $config = Get-StudioConfiguration

    $destination = Join-Path `
        $config.Paths.ModelsRoot `
        "$($Model.Category)\$($Model.FileName)"

    if (Test-Path $destination) {

        Write-StudioLog -Level SUCCESS -Message "$($Model.Name) already installed."

        return
    }

    if ([string]::IsNullOrWhiteSpace($Model.Uri)) {

        Write-StudioLog -Level WARNING -Message "$($Model.Name) has no download URI. Skipping."

        return
    }

    Write-StudioLog -Level INFO -Message "Installing $($Model.Name)..."

    Invoke-Download `
        -Uri $Model.Uri `
        -Destination $destination

    if (Test-Path $destination) {

        Write-StudioLog -Level SUCCESS -Message "$($Model.Name) installed."

    }
    else {

        Write-StudioLog -Level ERROR -Message "$($Model.Name) installation failed."

    }
}

function Install-Models {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ManifestPath
    )

    Write-StudioLog -Level INFO -Message "Loading model manifest..."

    $manifest = Get-ModelManifest -ManifestPath $ManifestPath

    foreach ($model in $manifest.Models) {

        Install-SingleModel -Model $model

    }

    Write-StudioLog -Level SUCCESS -Message "Manifest processed."
}

Export-ModuleMember -Function Install-Models