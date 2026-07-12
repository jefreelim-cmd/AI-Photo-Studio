[CmdletBinding()]
param(

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Pipeline

)

Set-StrictMode -Version Latest

$ErrorActionPreference = "Stop"

###########################################################################
# Load Configuration
###########################################################################

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$ConfigFile = Join-Path $ScriptRoot "Config.psd1"

if (!(Test-Path $ConfigFile)) {
    throw "Configuration file not found:`n$ConfigFile"
}

$config = Import-PowerShellDataFile $ConfigFile

###########################################################################
# Resolve Runtime Folders
###########################################################################

$InputFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.InputFolder

$OutputFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.OutputFolder

$ArchiveFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.ArchiveFolder

$ProcessedFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.ProcessedFolder

$LogFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.LogFolder

$WorkflowFolder = Join-Path `
    $config.RepositoryRoot `
    $config.WorkflowFolder

$RunWorkflowScript = Join-Path `
    $ScriptRoot `
    "Run-Workflow.ps1"

###########################################################################
# Log File
###########################################################################

if (!(Test-Path $LogFolder)) {

    New-Item `
        -ItemType Directory `
        -Path $LogFolder `
        -Force | Out-Null

}

$LogFile = Join-Path `
    $LogFolder `
    ("Pipeline_{0}.log" -f (Get-Date -Format "yyyyMMdd_HHmmss"))

###########################################################################
# Resolve Pipeline
###########################################################################

if (-not $config.Pipelines.ContainsKey($Pipeline)) {
    throw "Unknown pipeline '$Pipeline'."
}

$PipelineStages = $config.Pipelines[$Pipeline]

###########################################################################
# Validate Environment
###########################################################################

foreach ($Folder in @(
    $InputFolder,
    $OutputFolder,
    $ArchiveFolder,
    $ProcessedFolder,
    $WorkflowFolder
)) {

    if (!(Test-Path $Folder)) {
        throw "Folder not found:`n$Folder"
    }

}

if (!(Test-Path $RunWorkflowScript)) {
    throw "Run-Workflow.ps1 not found."
}

$Images = Get-ChildItem `
    -Path $InputFolder `
    -File |
Where-Object {
    $_.Extension.ToLower() -in $config.SupportedExtensions
}

$Images = @($Images)

if ($Images.Count -eq 0) {
    throw "No input images found."
}

###########################################################################
# Helper Functions
###########################################################################

function Write-Log {

    param(

        [Parameter(Mandatory)]
        [string]$Message

    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $Line = "[{0}] {1}" -f $Timestamp, $Message

    if ($config.Logging.WriteConsole) {

        Write-Host $Line

    }

    if ($config.Logging.WriteFile) {

        Add-Content `
            -Path $LogFile `
            -Value $Line

    }

}

function Reset-Runtime {

    Write-Log "Resetting runtime folders..."


    #######################################################################
    # Clear Runtime Output
    #######################################################################

    Get-ChildItem `
        -Path $OutputFolder `
        -File `
        -ErrorAction SilentlyContinue |
    Remove-Item `
        -Force

    Write-Log "Runtime reset complete."

}

function Remove-RuntimeTemporaryImages {

    param(
        [string]$InputFolder
    )

    $Patterns = @(
        "kontext_*",
        "ccsr_*",
        "upscale_*",
        "face_*"
    )

    foreach ($Pattern in $Patterns) {

        Get-ChildItem `
            -Path $InputFolder `
            -Filter $Pattern `
            -File `
            -ErrorAction SilentlyContinue |
        Remove-Item `
            -Force `
            -ErrorAction SilentlyContinue

    }

}

function Move-WorkflowOutput {

    param(

        [Parameter(Mandatory)]
        $WorkflowResult,

        [Parameter(Mandatory)]
        [string]$StageFolder

    )

    $DestinationFolder = Join-Path `
        $OutputFolder `
        $StageFolder

    if (!(Test-Path $DestinationFolder)) {

        New-Item `
            -ItemType Directory `
            -Path $DestinationFolder `
            -Force | Out-Null

    }

    $MovedFiles = @()

foreach ($File in $WorkflowResult.OutputFiles) {

    $Destination = Join-Path `
        $DestinationFolder `
        $File.Filename

    if (Test-Path $Destination) {

        Remove-Item `
            $Destination `
            -Force

    }

    $maxRetries = 10
    $retryDelayMs = 500

    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {

        try {

            Move-Item `
                -Path $File.FullPath `
                -Destination $Destination `
                -Force `
                -ErrorAction Stop

            break

        }
        catch {

            if ($attempt -eq $maxRetries) {
                throw
            }

            Write-Host "File is locked. Retrying ($attempt/$maxRetries)..."

            Start-Sleep -Milliseconds $retryDelayMs

        }

    }

    $MovedFiles += $Destination

}

    return $MovedFiles

}

###########################################################################
# Pipeline Processing
###########################################################################

Write-Host ""
Write-Host "====================================="
Write-Host " AI Photo Studio"
Write-Host "====================================="
Write-Host ""

Write-Log "====================================="
Write-Log "AI Photo Studio"
Write-Log "====================================="
Write-Log ("Pipeline : {0}" -f $Pipeline)
Write-Log ("Started  : {0}" -f (Get-Date))

$ImageNumber = 0

foreach ($Image in $Images) {

    $ImageNumber++

    Write-Host ""
    Write-Host "-------------------------------------"
    Write-Host ("Image {0}/{1}" -f $ImageNumber, $Images.Count)
    Write-Host "-------------------------------------"
    Write-Host ""

$OriginalImage = $Image.FullName

$CurrentImage = $OriginalImage


###########################################################################
# Prepare Runtime
###########################################################################

Reset-Runtime

foreach ($WorkflowName in $PipelineStages) {

    if (-not $config.Workflows.ContainsKey($WorkflowName)) {

        throw "Workflow '$WorkflowName' not found."

    }

    $WorkflowConfig = $config.Workflows[$WorkflowName]

    Write-Log ("Executing workflow: {0}" -f $WorkflowName)

if ($CurrentImage -ne $OriginalImage) {

    #
    # Remove any temporary runtime images left by previous workflow stages.
    #
    Remove-RuntimeTemporaryImages `
        -InputFolder $InputFolder

    #
    # Copy the current stage image into the ComfyUI runtime input folder.
    #
    Copy-Item `
        -Path $CurrentImage `
        -Destination (Join-Path $InputFolder (Split-Path $CurrentImage -Leaf)) `
        -Force

}

        $RuntimeImage = Join-Path `
            $InputFolder `
            (Split-Path $CurrentImage -Leaf)

        ###################################################################
        # Execute Workflow
        ###################################################################

        $Result = & $RunWorkflowScript `
            -Workflow $WorkflowName `
            -InputImage $RuntimeImage

Write-Host $Result.GetType().FullName

if ($Result -is [array]) {

    Write-Host "Array Count :" $Result.Count

    foreach ($Item in $Result) {
        Write-Host " - " $Item.GetType().FullName
    }

}
else {

    Write-Host "Properties:"
    $Result | Get-Member -MemberType NoteProperty

}

Write-Host ""

        ###################################################################
        # Move Output To Stage Folder
        ###################################################################

        $MovedFiles = Move-WorkflowOutput `
            -WorkflowResult $Result `
            -StageFolder $WorkflowConfig.StageFolder

        $MovedFiles = @($MovedFiles)

        if ($MovedFiles.Count -eq 0) {

            throw "Workflow produced no output."

        }

        ###################################################################
        # Prepare Next Stage
        ###################################################################

        $CurrentImage = $MovedFiles[0]

    }

    #######################################################################
    # Image Complete
    #######################################################################

    Move-Item `
        $OriginalImage `
        (Join-Path $ProcessedFolder (Split-Path $OriginalImage -Leaf)) `
        -Force

    Write-Log ("Completed image: {0}" -f (Split-Path $OriginalImage -Leaf))

}

###########################################################################
# Pipeline Summary
###########################################################################

Write-Host ""
Write-Host "====================================="
Write-Host " Pipeline Summary"
Write-Host "====================================="
Write-Host ""

Write-Host ("Pipeline : {0}" -f $Pipeline)
Write-Host ("Images   : {0}" -f $Images.Count)
Write-Host ("Status   : Success")
Write-Host ""

Write-Log "====================================="
Write-Log "Pipeline completed successfully."
Write-Log ("Images Processed : {0}" -f $Images.Count)
Write-Log ("Completed        : {0}" -f (Get-Date))
Write-Log "====================================="

exit 0