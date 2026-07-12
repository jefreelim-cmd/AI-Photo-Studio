[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Workflow,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$InputImage
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

###########################################################################
# Load Configuration
###########################################################################

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

$ConfigFile = Join-Path $ScriptRoot "Config.psd1"

if (!(Test-Path $ConfigFile)) {
    throw "Configuration file not found: $ConfigFile"
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

$ProcessedFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.ProcessedFolder

$TempFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.TempFolder

$LogFolder = Join-Path `
    $config.ComfyUIRoot `
    $config.LogFolder

###########################################################################
# Resolve Workflow
###########################################################################

if (-not $config.Workflows.ContainsKey($Workflow)) {
    throw "Unknown workflow '$Workflow'."
}

$WorkflowConfig = $config.Workflows[$Workflow]

if (-not $WorkflowConfig.Enabled) {
    throw "Workflow '$Workflow' is disabled."
}

###########################################################################
# Validate Input Image
###########################################################################

if (!(Test-Path $InputImage)) {
    throw "Input image not found:`n$InputImage"
}

###########################################################################
# Resolve Workflow File
###########################################################################

$WorkflowFile = Join-Path `
    (Join-Path $config.RepositoryRoot $config.WorkflowFolder) `
    $WorkflowConfig.File

if (!(Test-Path $WorkflowFile)) {
    throw "Workflow file not found:`n$WorkflowFile"
}

###########################################################################
# Load Workflow JSON
###########################################################################

Write-Host ""
Write-Host "====================================="
Write-Host " AI Photo Studio"
Write-Host "====================================="
Write-Host ""

Write-Host ("Workflow : {0}" -f $Workflow)
Write-Host ("Image    : {0}" -f (Split-Path $InputImage -Leaf))
Write-Host ""

$WorkflowJson = Get-Content `
    $WorkflowFile `
    -Raw |
    ConvertFrom-Json

###########################################################################
# Locate Required Nodes
###########################################################################

$LoadImageNode = $null
$SaveImageNode = $null

foreach ($Node in $WorkflowJson.PSObject.Properties) {

    switch ($Node.Value.class_type) {

        "LoadImage" {

            $LoadImageNode = $Node

        }

        "SaveImage" {

            $SaveImageNode = $Node

        }

    }

}

if ($null -eq $LoadImageNode) {
    throw "Workflow does not contain a LoadImage node."
}

if ($null -eq $SaveImageNode) {
    throw "Workflow does not contain a SaveImage node."
}

###########################################################################
# Inject Runtime Values
###########################################################################

$ImageName = Split-Path $InputImage -Leaf

$LoadImageNode.Value.inputs.image = $ImageName

$Prefix = "{0}_{1}" -f `
    $WorkflowConfig.Prefix, `
    ([System.IO.Path]::GetFileNameWithoutExtension($InputImage))

$SaveImageNode.Value.inputs.filename_prefix = $Prefix

Write-Host ("Input Image  : {0}" -f $ImageName)
Write-Host ("Output Prefix: {0}" -f $Prefix)
Write-Host ""


###########################################################################
# Submit Workflow
###########################################################################

$Request = @{

    prompt = $WorkflowJson

} | ConvertTo-Json -Depth 100

###########################################################################
# Record Workflow Start Time
###########################################################################

$StartTime = Get-Date

Write-Host "Submitting workflow..."

$Response = Invoke-RestMethod `
    -Uri ($config.ComfyUI.Url + $config.ComfyUI.PromptEndpoint) `
    -Method Post `
    -ContentType "application/json" `
    -Body $Request

if (-not $Response.prompt_id) {
    throw "ComfyUI did not return a Prompt ID."
}

$PromptId = $Response.prompt_id

Write-Host ("Prompt ID : {0}" -f $PromptId)
Write-Host ""

###########################################################################
# Wait For Completion
###########################################################################

$HistoryUrl = "{0}{1}/{2}" -f `
    $config.ComfyUI.Url, `
    $config.ComfyUI.HistoryEndpoint, `
    $PromptId

Write-Host "Waiting for workflow completion..."

$Completed = $false

while (-not $Completed) {

    Start-Sleep -Seconds $config.ComfyUI.PollIntervalSec

    try {

        $History = Invoke-RestMethod `
            -Uri $HistoryUrl `
            -Method Get

        if ($History.PSObject.Properties.Name -contains $PromptId) {

            $Completed = $true

        }

    }
    catch {

        # Workflow still running

    }

}
###########################################################################
# Detect Generated Output Files
###########################################################################

Write-Host ""
Write-Host "Workflow completed."
Write-Host ""

###########################################################################
# Detect Workflow Output
#
# ComfyUI does not reliably populate the History API outputs on our
# installation. Detect generated images by scanning the runtime output
# folder for files written during this workflow execution.
###########################################################################

$ExpectedPrefix = "$($WorkflowConfig.Prefix)_"

$NewFiles = @(
    Get-ChildItem `
        -Path $OutputFolder `
        -Filter "$ExpectedPrefix*.png" `
        -File |
    Where-Object {
        $_.LastWriteTime -ge $StartTime.AddSeconds(-1)
    }
)

if ($NewFiles.Count -eq 0) {
    throw "Workflow completed but no workflow output files were detected."
}

$OutputFiles = @()

foreach ($File in $NewFiles) {

    $OutputFiles += [PSCustomObject]@{

        Filename  = $File.Name

        FullPath  = $File.FullName

        Type      = "output"

        Subfolder = ""

    }

}

Write-Host "Generated Output(s)"
Write-Host "-------------------"

foreach ($File in $OutputFiles) {

    Write-Host $File.FullPath

}

Write-Host ""

###########################################################################
# Return Result
###########################################################################

return [PSCustomObject]@{

    Status      = "Processed"

    Workflow    = $Workflow

    PromptId    = $PromptId

    OutputFiles = $OutputFiles

}