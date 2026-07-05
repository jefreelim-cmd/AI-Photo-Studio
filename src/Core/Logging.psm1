Set-StrictMode -Version Latest

function Write-StudioLog {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO','WARNING','ERROR','SUCCESS')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    switch ($Level) {

        'INFO' {
            Write-Host "[$timestamp] [INFO]    $Message" -ForegroundColor Cyan
        }

        'WARNING' {
            Write-Warning $Message
        }

        'ERROR' {
            Write-Error $Message
        }

        'SUCCESS' {
            Write-Host "[$timestamp] [SUCCESS] $Message" -ForegroundColor Green
        }
    }
}

Export-ModuleMember -Function Write-StudioLog