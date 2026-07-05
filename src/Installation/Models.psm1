Set-StrictMode -Version Latest

Import-Module "$PSScriptRoot\..\Core\Configuration.psm1" -Force
Import-Module "$PSScriptRoot\..\Core\Downloads.psm1" -Force
Import-Module "$PSScriptRoot\..\Core\FileSystem.psm1" -Force
Import-Module "$PSScriptRoot\..\Core\Hashing.psm1" -Force
Import-Module "$PSScriptRoot\..\Core\Logging.psm1" -Force
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

    $alreadyInstalled = Test-Path $destination

        if ($alreadyInstalled) {

            Write-StudioLog -Level SUCCESS -Message "$($Model.Name) already installed."

    }
    else {

        if ([string]::IsNullOrWhiteSpace($Model.Uri)) {

            Write-StudioLog -Level WARNING -Message "$($Model.Name) has no download URI. Skipping."

            return
        }

        $modelFolder = Join-Path `
            $config.Paths.ModelsRoot `
            $Model.Category

        New-StudioDirectory -Path $modelFolder

        Write-StudioLog -Level INFO -Message "Installing $($Model.Name)..."

        Invoke-Download `
            -Uri $Model.Uri `
            -Destination $destination

    }

    if (-not (Test-Path $destination)) {

        Write-StudioLog -Level ERROR -Message "$($Model.Name) installation failed."

        return
    }

    if (-not [string]::IsNullOrWhiteSpace($Model.Sha256)) {

        if (-not (Test-FileHash -Path $destination -Sha256 $Model.Sha256)) {

            Write-StudioLog -Level ERROR -Message "$($Model.Name) SHA256 verification failed."

            return
        }

        Write-StudioLog -Level SUCCESS -Message "$($Model.Name) SHA256 verified."

    }

    if (-not $alreadyInstalled) {

        Write-StudioLog -Level SUCCESS -Message "$($Model.Name) installed."

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