[CmdletBinding()]
param(

    [Parameter(Mandatory)]
    [string]$Workflow,

    [string]$InputFolder,

    [string]$OutputFolder,

    [string]$ProcessedFolder

)

$ErrorActionPreference = "Stop"

###########################################################################
# Initialise
###########################################################################

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$processedCount = 0
$skippedCount = 0
$failedCount = 0

###########################################################################
# Load Configuration
###########################################################################

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$config = Import-PowerShellDataFile (
    Join-Path $ScriptRoot "Config.psd1"
)

###########################################################################
# Resolve Folders
###########################################################################

if ([string]::IsNullOrWhiteSpace($InputFolder)) {
    $InputFolder = $config.InputFolder
}

if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
    $OutputFolder = $config.OutputFolder
}

if ([string]::IsNullOrWhiteSpace($ProcessedFolder)) {
    $ProcessedFolder = $config.ProcessedFolder
}

###########################################################################
# Locate Images
###########################################################################

Write-Host ""
Write-Host "Searching input folder..."
Write-Host ""

$images = Get-ChildItem `
    -Path $InputFolder `
    -File |
Where-Object {

    $_.Extension.ToLower() -in $config.SupportedExtensions

} |
Sort-Object Name

Write-Host ("Images Found : {0}" -f $images.Count)
Write-Host ""

###########################################################################
# Process Images
###########################################################################

foreach ($image in $images) {

    Write-Host "--------------------------------------------------"
    Write-Host ("Processing : {0}" -f $image.Name)
    Write-Host "--------------------------------------------------"

    $result = & (
      Join-Path $ScriptRoot "Run-Workflow.ps1"
    ) `
      -Workflow $Workflow `
      -InputImage $image.FullName `
      -OutputFolder $OutputFolder

###########################################################################
# Move Processed Image
###########################################################################

switch ($result.Status) {

    "Processed" {

        $processedCount++

        $destination = Join-Path `
            $ProcessedFolder `
            $image.Name

        Move-Item `
            -Path $image.FullName `
            -Destination $destination `
            -Force

        Write-Host ("Moved to : {0}" -f $destination)
        Write-Host ""

    }

    "Skipped" {

        $skippedCount++

        $destination = Join-Path `
            $ProcessedFolder `
            $image.Name

        Move-Item `
            -Path $image.FullName `
            -Destination $destination `
            -Force

        Write-Host ("Moved to : {0}" -f $destination)
        Write-Host ""

    }

    Default {

        $failedCount++

        Write-Warning ("Image not moved: {0}" -f $image.Name)

    }

}

}
$stopwatch.Stop()

###########################################################################
# Complete
###########################################################################

Write-Host ""
Write-Host "====================================="
Write-Host " Batch Complete"
Write-Host "====================================="
Write-Host ""

Write-Host ("Processed : {0}" -f $processedCount)
Write-Host ("Skipped  : {0}" -f $skippedCount)
Write-Host ("Failed   : {0}" -f $failedCount)
Write-Host ("Total    : {0}" -f $images.Count)
Write-Host ""
Write-Host ("Elapsed  : {0:hh\:mm\:ss}" -f $stopwatch.Elapsed)
Write-Host ""
Write-Host ("Input Folder     : {0}" -f $InputFolder)
Write-Host ("Output Folder    : {0}" -f $OutputFolder)
Write-Host ("Processed Folder : {0}" -f $ProcessedFolder)