Set-StrictMode -Version Latest

function Initialize-FolderStructure {

    [CmdletBinding()]
    param()

    $config = Get-StudioConfiguration

    Write-StudioLog -Level INFO -Message "Verifying folder structure..."

$Folders = @(
    "assets",
    "assets\branding",
    "assets\fonts",
    "assets\icons",
    "assets\templates",
    "assets\watermarks",

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

    "workflows",
    "workflows\restoration",
    "workflows\portrait",
    "workflows\background",
    "workflows\upscaling",
    "workflows\experiments",

    "input",
    "input\restore",
    "input\portraits",
    "input\background",

    "output",
    "output\restore",
    "output\portraits",
    "output\background",
    "output\previews",

    "archive",
    "logs"
)

foreach ($Folder in $Folders) {

    $Path = Join-Path $config.Paths.ProjectRoot $Folder

    if (Test-Path $Path) {

        Write-StudioLog -Level INFO -Message "Exists: $Folder"

    }
    else {

        New-Item -ItemType Directory -Path $Path | Out-Null

        Write-StudioLog -Level SUCCESS -Message "Created: $Folder"
    }
}

    # Folder creation logic will go here
}

Export-ModuleMember -Function Initialize-FolderStructure