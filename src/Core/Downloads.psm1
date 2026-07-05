Set-StrictMode -Version Latest

function Invoke-Download {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Destination
    )

    if (Test-Path $Destination) {

        Write-StudioLog -Level INFO -Message "File already exists."

        return
    }

    Write-StudioLog -Level INFO -Message "Downloading..."

    Invoke-WebRequest `
        -Uri $Uri `
        -OutFile $Destination

    Write-StudioLog -Level SUCCESS -Message "Download complete."
}

Export-ModuleMember -Function Invoke-Download