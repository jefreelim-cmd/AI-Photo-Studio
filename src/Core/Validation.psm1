Set-StrictMode -Version Latest

function Test-PowerShellVersion {

    [CmdletBinding()]
    param()

    return ($PSVersionTable.PSVersion.Major -ge 7)
}

function Test-Python {

    [CmdletBinding()]
    param()

    try {
        $null = Get-Command python -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-Git {

    [CmdletBinding()]
    param()

    try {
        $null = Get-Command git -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-VirtualEnvironment {

    [CmdletBinding()]
    param()

    return ($null -ne $env:VIRTUAL_ENV)
}

function Test-ComfyUI {

    [CmdletBinding()]
    param()

    $config = Get-StudioConfiguration

    return (Test-Path $config.Paths.ComfyUIRoot)
}

function Test-ComfyUIManager {

    [CmdletBinding()]
    param()

    $config = Get-StudioConfiguration

    $managerPath = Join-Path $config.Paths.ComfyUIRoot "custom_nodes\ComfyUI-Manager"

    return (Test-Path $managerPath)
}

Export-ModuleMember -Function `
    Test-PowerShellVersion, `
    Test-Python, `
    Test-Git, `
    Test-VirtualEnvironment, `
    Test-ComfyUI, `
    Test-ComfyUIManager