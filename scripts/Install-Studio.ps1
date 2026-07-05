#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\..\src\Core\Configuration.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Core\Logging.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Core\Validation.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Installation\FolderStructure.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Installation\ComfyUI.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Installation\VirtualEnvironment.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Installation\PythonDependencies.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Installation\ComfyUIManager.psm1" -Force

Write-StudioLog -Level INFO -Message "Starting AI Photo Studio installation..."

if (-not (Test-PowerShellVersion)) {
    throw "PowerShell 7 or later is required."
}

if (-not (Test-Python)) {
    throw "Python is not installed."
}

if (-not (Test-Git)) {
    throw "Git is not installed."
}

Write-StudioLog -Level SUCCESS -Message "Prerequisite validation passed."

Initialize-FolderStructure
Install-ComfyUI
Initialize-VirtualEnvironment
Install-PythonDependencies
Install-ComfyUIManager

Write-StudioLog -Level SUCCESS -Message "Installation complete."