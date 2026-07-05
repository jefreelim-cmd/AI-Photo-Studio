Set-StrictMode -Version Latest

function Test-FileHash {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Sha256
    )

    if (-not (Test-Path $Path)) {
        return $false
    }

    $hash = (Get-FileHash -Path $Path -Algorithm SHA256).Hash

    return ($hash -ieq $Sha256)
}

Export-ModuleMember -Function Test-FileHash