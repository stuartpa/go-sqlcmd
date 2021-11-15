#------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
#------------------------------------------------------------------------------

# Description:
#
# Instructions to be invoked under the build CI pipeline in AzureDevOps.
#
# Kickoff MSI package install test.
#
# Usage:
#
# set SYSTEM_ARTIFACTSDIRECTORY=\path\to\msi\go-mssqltools-<CL_VERSION>.msi
#
# $ pipeline-test.ps1

tree /A /F $env:SYSTEM_ARTIFACTSDIRECTORY

$msiPath = Join-Path $env:SYSTEM_ARTIFACTSDIRECTORY "msi\go-mssql-tools.msi"

$msiPath

$InstallArgs = @(
    "/I"
    $msiPath
    "/norestart"
    "/L*v"
    ".\install-logs.txt"
    "/qn"
)
        
Write-Output "Starting msi install $msiPath..."
Start-Process "msiexec.exe" -ArgumentList $InstallArgs -Wait -NoNewWindow
Get-Content .\install-logs.txt

Write-Output "Done installing msi, checking PATH setup..."
Write-Output "$env:path"
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
Write-Output "$env:path"

$sqlcmd = $env:ProgramFiles + "\Microsoft SQL Server\Tools\sqlcmd"
& $sqlcmd --help