Set-StrictMode -Version Latest

function Install-ComfyUI {

    [CmdletBinding()]
    param()

    Write-StudioLog -Level INFO -Message "Verifying ComfyUI installation..."

    $config = Get-StudioConfiguration

    if (Test-Path $config.Paths.ComfyUIRoot) {

        Write-StudioLog -Level SUCCESS -Message "ComfyUI already installed."

        return
    }

    Write-StudioLog -Level WARNING -Message "ComfyUI is not installed."

    Write-StudioLog -Level INFO -Message "Cloning ComfyUI..."

git clone https://github.com/comfyanonymous/ComfyUI.git $config.Paths.ComfyUIRoot

if ($LASTEXITCODE -ne 0) {
    throw "Failed to clone ComfyUI."
}

Write-StudioLog -Level SUCCESS -Message "ComfyUI installed successfully."
}

Export-ModuleMember -Function Install-ComfyUI