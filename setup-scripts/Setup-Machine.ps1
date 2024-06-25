#requires -version 2
<#
.SYNOPSIS
  Setup-Machine - Base script that sets up the machine
.DESCRIPTION
  This script sets up a new machine for dev use
.PARAMETER username
  The local user
.PARAMETER machinename
  The vm machine name
.INPUTS
  None
#>
  
#----------------------------------------------------------[Declarations]----------------------------------------------------------

param(
  [Parameter(Position=0,mandatory=$true)]
  [String]$username, 
  [Parameter(Position=1,mandatory=$true)]
  [String]$machinename
) 

Write-Host "Setting up $machinename for $username"


#-----------------------------------------------------------[Execution]------------------------------------------------------------

# 1. Create a directory called c:\git
Write-Host "Creating git directory"
New-Item -ItemType Directory -Force -Path C:\git
Set-Location -Path C:\git

# 2. Install chocolatey
Write-Host "Installing Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force;
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# 3. Install git using chocolatey
Write-Host "Installing Git"
choco install git -y

# reset path so git will be visible
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# 5. Install base applications
Write-Host "Installing base applications"
$baseConfigPath = "C:\$machinename-config\base.config"
choco install -y $baseConfigPath --limitoutput --no-progress 

# 6. Install custom applications 
$configPath = "C:\$machinename-config\$machinename\$machinename.config"
if (Test-Path $configPath)
{
  write-host "Installing custom applications from $machinename.config"
  choco install -y $configPath --limitoutput --no-progress
}

# 6. Run custom setup.ps1
$customScriptPath = "C:\$machinename-config\$machinename\$machinename.ps1"
if (Test-Path $customScriptPath)
{
  write-host "Running custom script: $machinename.ps1"
  & $customScriptPath $username
}
