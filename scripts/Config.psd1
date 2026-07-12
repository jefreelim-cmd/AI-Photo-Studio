@{

    ###########################################################################
    # Application
    ###########################################################################

    ApplicationName    = "AI Photo Studio"
    ApplicationVersion = "1.0.0"

    ###########################################################################
    # ComfyUI
    ###########################################################################

    ComfyUIRoot = "D:\AI-Photo-Studio\ComfyUI"

    ComfyUI = @{

        Url               = "http://127.0.0.1:8188"

        PromptEndpoint    = "/prompt"
        HistoryEndpoint   = "/history"
        ViewEndpoint      = "/view"

        RequestTimeoutSec = 300
        PollIntervalSec   = 2

    }

    ###########################################################################
    # Repository
    ###########################################################################

    RepositoryRoot = "D:\AI-Photo-Studio\AI-Photo-Studio"

    WorkflowFolder = "workflows"

    ###########################################################################
    # Runtime Folders
    ###########################################################################

    InputFolder     = "input"
    OutputFolder    = "output"
    ArchiveFolder   = "archive"
    TempFolder      = "temp"
    LogFolder       = "logs"
    ProcessedFolder = "processed"

    ###########################################################################
    # Output Naming
    ###########################################################################

    Output = @{

        FilenameFormat          = "{Workflow}_{InputFilename}"

        ReplaceSpacesWith       = "_"

        RemoveInvalidCharacters = $true

        Extension               = "png"

    }

    ###########################################################################
    # Supported Image Types
    ###########################################################################

    SupportedExtensions = @(
        ".jpg"
        ".jpeg"
        ".png"
        ".bmp"
        ".tif"
        ".tiff"
        ".webp"
    )

    ###########################################################################
    # Workflows
    ###########################################################################

Workflows = @{

    Kontext = @{

        Enabled = $true

        Name = "Photo Restoration"

        File = "01 - Photo Restoration - Kontext.api.json"

        Prefix = "kontext"

        StageFolder = "01 - Kontext"

    }

    CCSR = @{

        Enabled = $true

        Name = "Photo Restoration"

        File = "02 - Photo Restoration - CCSR Only.api.json"

        Prefix = "ccsr"

        StageFolder = "02 - CCSR"

    }

    CodeFormer = @{

        Enabled = $true

        Name = "Face Restoration"

        File = "02 - Face Restoration - CodeFormer.json"

        Prefix = "codeformer"

        StageFolder = "03 - CodeFormer"

    }

    Upscale = @{

        Enabled = $true

        Name = "Upscale"

        File = "03 - Basic 4x Upscale.json"

        Prefix = "upscale"

        StageFolder = "04 - Upscale"

    }

}

    ###########################################################################
    # Pipelines
    ###########################################################################

    Pipelines = @{

        Restore = @(
            "Kontext"
        )

        RestoreAndUpscale = @(
            "Kontext"
            "Upscale"
        )

        Portrait = @(
            "Kontext"
            "CodeFormer"
        )

        FullRestore = @(
            "Kontext"
            "CCSR"
            "Upscale"
        )

    }

    ###########################################################################
    # Logging
    ###########################################################################

    Logging = @{

        Enabled      = $true

        WriteConsole = $true

        WriteFile    = $true

    }

}