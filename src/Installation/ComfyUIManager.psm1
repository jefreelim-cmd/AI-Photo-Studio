Set-StrictMode -Version Latest

function Install-ComfyUIManager {

    [CmdletBinding()]
    param()

    Write-StudioLog -Level INFO -Message "Verifying ComfyUI Manager..."

    if (Test-ComfyUIManager) {

        Write-StudioLog -Level SUCCESS -Message "ComfyUI Manager already installed."

        return
    }

    Write-StudioLog -Level WARNING -Message "ComfyUI Manager is not installed."

    # Installation logic will be added next.
}

Export-ModuleMember -Function Install-ComfyUIManager