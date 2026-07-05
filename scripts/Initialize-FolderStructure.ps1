#Requires -Version 5.1

<#
.SYNOPSIS
    Creates the AI-Photo-Studio folder structure.

.DESCRIPTION
    Safely creates the required folders for the AI-Photo-Studio project.
    Existing folders are skipped.

.NOTES
    Author  : Jefree Lim
    Project : AI-Photo-Studio
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = "D:\AI-Photo-Studio"

$Folders = @(

    # GitHub Repository
    "AI-Photo-Studio\config",
    "AI-Photo-Studio\docs",
    "AI-Photo-Studio\scripts",
    "AI-Photo-Studio\src",
    "AI-Photo-Studio\tests",
    "AI-Photo-Studio\.github",

    # Assets
    "assets",
    "assets\branding",
    "assets\fonts",
    "assets\icons",
    "assets\templates",
    "assets\watermarks",

    # Models
    "models",
    "models\checkpoints",
    "models\clip",
    "models\clip_vision",
    "models\controlnet",
    "models\embeddings",
    "models\ipadapter",
    "models\loras",
    "models\sam",
    "models\ultralytics",
    "models\upscale_models",
    "models\vae",

    # Workflows
    "workflows",
    "workflows\restoration",
    "workflows\portrait",
    "workflows\background",
    "workflows\upscaling",
    "workflows\experiments",

    # Input
    "input",
    "input\restore",
    "input\portraits",
    "input\background",

    # Output
    "output",
    "output\restore",
    "output\portraits",
    "output\background",
    "output\previews",

    # Archive / Logs
    "archive",
    "logs"
)

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " AI Photo Studio Folder Initializer" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($Folder in $Folders)
{
    $Path = Join-Path $Root $Folder

    if (Test-Path $Path)
    {
        Write-Host "[SKIP]    $Path" -ForegroundColor Yellow
    }
    else
    {
        New-Item -ItemType Directory -Path $Path | Out-Null
        Write-Host "[CREATE]  $Path" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Folder structure verified." -ForegroundColor Green