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

        Url                = "http://127.0.0.1:8188"

        PromptEndpoint     = "/prompt"
        HistoryEndpoint    = "/history"
        ViewEndpoint       = "/view"

        RequestTimeoutSec  = 300
        PollIntervalSec    = 2

    }

    ###########################################################################
    # Repository
    ###########################################################################

    RepositoryRoot = "D:\AI-Photo-Studio\AI-Photo-Studio"

    ###########################################################################
    # Runtime Folders
    ###########################################################################

    InputFolder     = "D:\AI-Photo-Studio\ComfyUI\input"
    OutputFolder    = "D:\AI-Photo-Studio\ComfyUI\output"
    TempFolder      = "D:\AI-Photo-Studio\ComfyUI\temp"
    LogFolder       = "D:\AI-Photo-Studio\ComfyUI\logs"

    ###########################################################################
    # Output Naming
    ###########################################################################

Output = @{

    FilenameFormat = "{Workflow}_{InputFilename}"

    ReplaceSpacesWith = "_"

    RemoveInvalidCharacters = $true

    Extension = "png"

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

        }


        CCSR = @{

            Enabled = $true

            Name = "Photo Restoration"

            File = "02 - Photo Restoration - CCSR.json"

            Prefix = "ccsr"

        }

        CodeFormer = @{

            Enabled = $true

            Name = "Face Restoration"

            File = "02 - Face Restoration - CodeFormer.json"

            Prefix = "codeformer"

        }

        Upscale = @{

            Enabled = $true

            Name = "Upscale"

            File = "03 - Basic 4x Upscale.json"

            Prefix = "upscale"

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

        Enabled = $true

        WriteConsole = $true

        WriteFile = $true

    }

}