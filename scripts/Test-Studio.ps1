#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\..\src\Core\Configuration.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Core\Logging.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Core\Validation.psm1" -Force

Write-StudioLog -Level INFO -Message "Starting AI Photo Studio validation..."

Write-StudioLog -Level INFO -Message "PowerShell 7: $(Test-PowerShellVersion)"
Write-StudioLog -Level INFO -Message "Python: $(Test-Python)"
Write-StudioLog -Level INFO -Message "Git: $(Test-Git)"
Write-StudioLog -Level INFO -Message "Virtual Environment: $(Test-VirtualEnvironment)"
Write-StudioLog -Level INFO -Message "ComfyUI: $(Test-ComfyUI)"
Write-StudioLog -Level INFO -Message "ComfyUI Manager: $(Test-ComfyUIManager)"

Write-StudioLog -Level SUCCESS -Message "Validation complete."