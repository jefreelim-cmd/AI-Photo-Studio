#Requires -Version 7.0

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module "$PSScriptRoot\..\src\Core\Configuration.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Core\Logging.psm1" -Force
Import-Module "$PSScriptRoot\..\src\Installation\FolderStructure.psm1" -Force

Initialize-FolderStructure