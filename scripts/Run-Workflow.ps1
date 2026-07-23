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
$HistoryEntry = $null
$WorkflowFailure = $null

while (-not $Completed) {

    Start-Sleep -Seconds $config.ComfyUI.PollIntervalSec

    try {

        $History = Invoke-RestMethod `
            -Uri $HistoryUrl `
            -Method Get

        if ($History.PSObject.Properties.Name -contains $PromptId) {

            $HistoryEntry = $History.PSObject.Properties[$PromptId].Value
            $HasStatus = $HistoryEntry.PSObject.Properties.Name -contains "status"

            if (
                $HasStatus -and
                $HistoryEntry.status.status_str -eq "error"
            ) {

                $ExecutionError = $HistoryEntry.status.messages |
                    Where-Object {
                        $_[0] -eq "execution_error"
                    } |
                    Select-Object -Last 1

                if ($null -ne $ExecutionError) {
                    $WorkflowFailure = "ComfyUI workflow failed:`n$($ExecutionError[1].exception_message)"
                }
                else {
                    $WorkflowFailure = "ComfyUI workflow failed. Check the ComfyUI server log for details."
                }

                $Completed = $true

            }
            elseif (
                $HasStatus -and
                $HistoryEntry.status.completed -eq $true
            ) {
                $Completed = $true
            }

        }

    }
    catch {

        # Workflow still running

    }

    if ($null -ne $WorkflowFailure) {
        throw $WorkflowFailure
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
# Use only the files returned for this exact prompt ID. This prevents stale
# or concurrent files with the same workflow prefix from entering the
# pipeline.
###########################################################################

$OutputFiles = @()

if (
    $HistoryEntry.PSObject.Properties.Name -contains "outputs" -and
    $null -ne $HistoryEntry.outputs
) {

    foreach ($OutputNode in $HistoryEntry.outputs.PSObject.Properties) {

        if (
            $OutputNode.Value.PSObject.Properties.Name -notcontains "images" -or
            $null -eq $OutputNode.Value.images
        ) {
            continue
        }

        foreach ($Image in $OutputNode.Value.images) {

            if ($Image.type -ne "output") {
                continue
            }

            $OutputPath = $OutputFolder

            if (![string]::IsNullOrWhiteSpace($Image.subfolder)) {
                $OutputPath = Join-Path $OutputPath $Image.subfolder
            }

            $FullPath = Join-Path $OutputPath $Image.filename

            $Deadline = (Get-Date).AddSeconds(30)

            while (
                !(Test-Path -LiteralPath $FullPath) -and
                (Get-Date) -lt $Deadline
            ) {
                Start-Sleep -Milliseconds 500
            }

            if (!(Test-Path -LiteralPath $FullPath)) {
                throw "ComfyUI reported an output file that did not appear on disk:`n$FullPath"
            }

            $OutputFiles += [PSCustomObject]@{

                Filename  = $Image.filename

                FullPath  = $FullPath

                Type      = $Image.type

                Subfolder = $Image.subfolder

            }

        }

    }

}

if ($OutputFiles.Count -eq 0) {
    throw "Workflow completed successfully but its History API record contained no saved output images."
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
