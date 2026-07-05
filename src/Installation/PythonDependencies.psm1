Set-StrictMode -Version Latest

function Install-PythonDependencies {

    [CmdletBinding()]
    param()

    Write-StudioLog -Level INFO -Message "Installing Python dependencies..."

    $config = Get-StudioConfiguration

    $requirements = Join-Path $config.Paths.ComfyUIRoot "requirements.txt"

    if (-not (Test-Path $requirements)) {
        throw "requirements.txt not found."
    }

    & "$($config.Paths.ComfyUIRoot)\.venv\Scripts\python.exe" `
        -m pip install -r $requirements

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to install Python dependencies."
    }

    Write-StudioLog -Level SUCCESS -Message "Python dependencies installed."
}

Export-ModuleMember -Function Install-PythonDependencies