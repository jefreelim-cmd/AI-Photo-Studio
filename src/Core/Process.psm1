Set-StrictMode -Version Latest

function Invoke-StudioProcess {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [string[]]$ArgumentList
    )

    Write-StudioLog -Level INFO -Message "Running: $FilePath"

    & $FilePath @ArgumentList

    if ($LASTEXITCODE -ne 0) {
        throw "Process failed: $FilePath"
    }
}

Export-ModuleMember -Function Invoke-StudioProcess