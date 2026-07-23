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

$DeferredCleanup = [System.Collections.Generic.HashSet[string]]::new(
    [System.StringComparer]::OrdinalIgnoreCase
)

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

function Wait-FileUnlocked {

    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [int]$TimeoutSeconds = 30,

        [int]$PollMilliseconds = 500
    )

    $Deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    do {

        if (!(Test-Path -LiteralPath $Path)) {
            return $true
        }

        try {

            $Stream = [System.IO.File]::Open(
                $Path,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::None
            )

            $Stream.Dispose()

            return $true

        }
        catch [System.IO.IOException] {
        }
        catch [System.UnauthorizedAccessException] {
        }

        Start-Sleep -Milliseconds $PollMilliseconds

    } while ((Get-Date) -lt $Deadline)

    return $false

}

function Remove-FileWithRetry {

    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [int]$TimeoutSeconds = 30
    )

    if (!(Test-Path -LiteralPath $Path)) {
        return $true
    }

    if (!(Wait-FileUnlocked -Path $Path -TimeoutSeconds $TimeoutSeconds)) {
        return $false
    }

    try {

        Remove-Item `
            -LiteralPath $Path `
            -Force `
            -ErrorAction Stop

        return $true

    }
    catch [System.IO.IOException] {
        return $false
    }
    catch [System.UnauthorizedAccessException] {
        return $false
    }

}

function Copy-FileWithRetry {

    param(
        [Parameter(Mandatory)]
        [string]$Source,

        [Parameter(Mandatory)]
        [string]$Destination,

        [int]$TimeoutSeconds = 30
    )

    $Deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    $LastError = $null

    do {

        try {

            Copy-Item `
                -LiteralPath $Source `
                -Destination $Destination `
                -Force `
                -ErrorAction Stop

            return

        }
        catch [System.IO.IOException] {
            $LastError = $_
        }
        catch [System.UnauthorizedAccessException] {
            $LastError = $_
        }

        Start-Sleep -Milliseconds 500

    } while ((Get-Date) -lt $Deadline)

    throw "Unable to copy workflow output after $TimeoutSeconds seconds: $Source`n$($LastError.Exception.Message)"

}

function Add-DeferredCleanup {

    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if ($DeferredCleanup.Add($Path)) {
        Write-Log ("Temporary output cleanup deferred: {0}" -f $Path)
    }

}

function Retry-DeferredCleanup {

    if ($DeferredCleanup.Count -eq 0) {
        return
    }

    Write-Log ("Retrying {0} deferred cleanup item(s)..." -f $DeferredCleanup.Count)

    foreach ($Path in @($DeferredCleanup)) {

        if (Remove-FileWithRetry -Path $Path -TimeoutSeconds 10) {
            [void]$DeferredCleanup.Remove($Path)
            Write-Log ("Deferred cleanup completed: {0}" -f $Path)
        }

    }

    foreach ($Path in $DeferredCleanup) {
        Write-Log ("Deferred cleanup still locked; leaving file in place: {0}" -f $Path)
    }

}

function Reset-Runtime {

    Write-Log "Resetting runtime folders..."


    #######################################################################
    # Clear Runtime Output
    #######################################################################

    $RuntimeFiles = @(
        Get-ChildItem `
            -Path $OutputFolder `
            -File `
            -ErrorAction SilentlyContinue
    )

    foreach ($File in $RuntimeFiles) {

        if (!(Remove-FileWithRetry -Path $File.FullName -TimeoutSeconds 10)) {
            Add-DeferredCleanup -Path $File.FullName
        }

    }

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

            if (!(Remove-FileWithRetry -Path $Destination -TimeoutSeconds 30)) {
                throw "Destination file is locked and cannot be replaced:`n$Destination"
            }

        }

        #
        # Archive the generated output.
        #
        Copy-FileWithRetry `
            -Source $File.FullPath `
            -Destination $Destination `
            -TimeoutSeconds 30

        #
        # Best-effort cleanup of the temporary ComfyUI output.
        #
        if (!(Remove-FileWithRetry -Path $File.FullPath -TimeoutSeconds 30)) {
            Add-DeferredCleanup -Path $File.FullPath
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

###########################################################################
# Prepare Runtime Once Per Batch
###########################################################################

Reset-Runtime

foreach ($Image in $Images) {

    $ImageNumber++

    Write-Host ""
    Write-Host "-------------------------------------"
    Write-Host ("Image {0}/{1}" -f $ImageNumber, $Images.Count)
    Write-Host "-------------------------------------"
    Write-Host ""

$OriginalImage = $Image.FullName

$CurrentImage = $OriginalImage


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

Retry-DeferredCleanup

Write-Log "====================================="
Write-Log "Pipeline completed successfully."
Write-Log ("Images Processed : {0}" -f $Images.Count)
Write-Log ("Completed        : {0}" -f (Get-Date))
Write-Log "====================================="

exit 0
