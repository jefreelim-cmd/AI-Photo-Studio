[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Workflow,

    [Parameter(Mandatory)]
    [string]$InputImage
)

$ErrorActionPreference = "Stop"


###########################################################################
# Load Configuration
###########################################################################

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigFile = Join-Path $ScriptRoot "Config.psd1"

if (!(Test-Path $ConfigFile)) {
    throw "Config.psd1 not found."
}

$config = Import-PowerShellDataFile $ConfigFile

###########################################################################
# Validate Workflow
###########################################################################

if (!$config.Workflows.ContainsKey($Workflow)) {
    throw "Unknown workflow '$Workflow'."
}

$workflowConfig = $config.Workflows[$Workflow]

if (!$workflowConfig.Enabled) {
    throw "Workflow '$Workflow' is disabled."
}

###########################################################################
# Validate Image
###########################################################################

if (!(Test-Path $InputImage)) {
    throw "Input image not found:`n$InputImage"
}

###########################################################################
# Workflow File
###########################################################################

$WorkflowFile = Join-Path $config.RepositoryRoot "workflows\$($workflowConfig.File)"

if (!(Test-Path $WorkflowFile)) {
    throw "Workflow file not found:`n$WorkflowFile"
}

Write-Host ""
Write-Host "====================================="
Write-Host " AI Photo Studio"
Write-Host "====================================="
Write-Host ""

Write-Host "Workflow :" $workflowConfig.Name
Write-Host "Image    :" (Split-Path $InputImage -Leaf)
Write-Host ""

###########################################################################
# Load Workflow JSON
###########################################################################

Write-Host "Loading workflow..."

$workflowJson = Get-Content $WorkflowFile -Raw | ConvertFrom-Json

Write-Host "Loaded workflow successfully."

$nodeCount = ($workflowJson.PSObject.Properties).Count

#Write-Host ("Nodes found: {0}" -f $nodeCount)
Write-Host ""

###########################################################################
# Locate Workflow Nodes
###########################################################################

Write-Host "Searching workflow..."

$loadImageNode = $null
$saveImageNode = $null

foreach ($node in $workflowJson.PSObject.Properties) {

    if ($node.Value.class_type -eq "LoadImage") {
        $loadImageNode = $node
    }

    if ($node.Value.class_type -eq "SaveImage") {
        $saveImageNode = $node
    }

}

if ($null -eq $loadImageNode) {
    throw "LoadImage node not found."
}

if ($null -eq $saveImageNode) {
    throw "SaveImage node not found."
}

Write-Host ("LoadImage Node : {0}" -f $loadImageNode.Name)
Write-Host ("SaveImage Node : {0}" -f $saveImageNode.Name)
Write-Host ""

###########################################################################
# Update LoadImage Node
###########################################################################

Write-Host "Updating LoadImage node..."

$imageFileName = Split-Path $InputImage -Leaf

$imageFileName = Split-Path $InputImage -Leaf

$loadImageNode.Value.inputs.image = $imageFileName

Write-Host ("Image set to : {0}" -f $loadImageNode.Value.inputs.image)

###########################################################################
# Update SaveImage Node
###########################################################################

Write-Host "Updating SaveImage node..."

###########################################################################
# Build Output Filename
###########################################################################

$inputName = [System.IO.Path]::GetFileNameWithoutExtension($InputImage)

if ($config.Output.ReplaceSpacesWith) {
    $inputName = $inputName.Replace(" ", $config.Output.ReplaceSpacesWith)
}

if ($config.Output.RemoveInvalidCharacters) {

    foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {

      $inputName = $inputName.Replace($char.ToString(), "")

    }

}

$outputName = "{0}_{1}" -f `
    $workflowConfig.Prefix, `
    $inputName

$saveImageNode.Value.inputs.filename_prefix = $outputName

Write-Host ("Output Prefix : {0}" -f $saveImageNode.Value.inputs.filename_prefix)
Write-Host ""

###########################################################################
# Check For Existing Output
###########################################################################

$expectedOutput = Join-Path `
    $config.OutputFolder `
    ($outputName + "_00001_." + $config.Output.Extension)

if (Test-Path $expectedOutput) {

    Write-Host ""
    Write-Host "Output already exists."
    Write-Host $expectedOutput
    Write-Host "Skipping workflow."
    Write-Host ""

    return

}

###########################################################################
# Submit Workflow to ComfyUI
###########################################################################

Write-Host "Submitting workflow to ComfyUI..."

$body = @{
    prompt = $workflowJson
} | ConvertTo-Json -Depth 100

try {

    $response = Invoke-RestMethod `
        -Uri ($config.ComfyUI.Url + $config.ComfyUI.PromptEndpoint) `
        -Method Post `
        -ContentType "application/json" `
        -Body $body

}
catch {

    Write-Host ""
    Write-Host "ComfyUI returned an error:"
    Write-Host $_.Exception.Message

    if ($_.ErrorDetails.Message) {
        Write-Host ""
        Write-Host $_.ErrorDetails.Message
    }

    throw
}

if ($null -eq $response.prompt_id) {
    throw "ComfyUI did not return a Prompt ID."
}

$promptId = $response.prompt_id

Write-Host ("Prompt ID : {0}" -f $promptId)
Write-Host ""

###########################################################################
# Wait For Workflow Completion
###########################################################################

Write-Host "Waiting for workflow to complete..."

$historyUrl = "{0}{1}/{2}" -f `
    $config.ComfyUI.Url,
    $config.ComfyUI.HistoryEndpoint,
    $promptId

$completed = $false

while (-not $completed) {

    Start-Sleep -Seconds $config.ComfyUI.PollIntervalSec

    try {

        $history = Invoke-RestMethod `
            -Uri $historyUrl `
            -Method Get

        if ($history.PSObject.Properties.Name -contains $promptId) {

            $completed = $true

        }

    }
    catch {

        # Ignore while the workflow is still running

    }

}

Write-Host ""
Write-Host "Workflow completed."

if (Test-Path $expectedOutput) {

    Write-Host ""
    Write-Host "Output created:"
    Write-Host $expectedOutput

}
else {

    Write-Warning "Workflow completed but expected output was not found."

}
Write-Host ""