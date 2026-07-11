[CmdletBinding()]
param(

    [Parameter(Mandatory)]
    [string]$Workflow

)

$ErrorActionPreference = "Stop"

###########################################################################
# Load Configuration
###########################################################################

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$config = Import-PowerShellDataFile (
    Join-Path $ScriptRoot "Config.psd1"
)

###########################################################################
# Locate Images
###########################################################################

Write-Host ""
Write-Host "Searching input folder..."
Write-Host ""

$images = Get-ChildItem `
    -Path $config.InputFolder `
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
        -InputImage $image.FullName

###########################################################################
# Move Processed Image
###########################################################################

if ($result.Status -in @("Processed", "Skipped")) {

    $destination = Join-Path `
        $config.ProcessedFolder `
        $image.Name

    Move-Item `
        -Path $image.FullName `
        -Destination $destination `
        -Force

    Write-Host ("Moved to : {0}" -f $destination)
    Write-Host ""

}
else {

    Write-Warning ("Image not moved: {0}" -f $image.Name)

}

    Write-Host ""

}

###########################################################################
# Complete
###########################################################################

Write-Host ""
Write-Host "====================================="
Write-Host " Batch Complete"
Write-Host "====================================="
Write-Host ""

Write-Host ("Images Processed : {0}" -f $images.Count)