Set-StrictMode -Version Latest

function Initialize-VirtualEnvironment {

    [CmdletBinding()]
    param()

    Write-StudioLog -Level INFO -Message "Verifying Python virtual environment..."

    $config = Get-StudioConfiguration

    $venvPath = Join-Path $config.Paths.ComfyUIRoot ".venv"

    if (Test-Path $venvPath) {

        Write-StudioLog -Level SUCCESS -Message "Virtual environment already exists."

        return
    }

    Write-StudioLog -Level WARNING -Message "Virtual environment not found."

    python -m venv $venvPath

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create Python virtual environment."
    }

    Write-StudioLog -Level SUCCESS -Message "Virtual environment created."
}

Export-ModuleMember -Function Initialize-VirtualEnvironment