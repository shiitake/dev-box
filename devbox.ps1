#requires -version 2
<#
.SYNOPSIS
  devbox - creates new vagrant vms
.DESCRIPTION
  This script allows you to add and drop virtual machines in HyperV based on a base image you've created.
.PARAMETER action
  List - list all machines. (default action)
  Add - add a new machine.
  Drop - remove an existing machine
.PARAMETER machineName
  Name of the machine to be create
.PARAMETER userName
  User that can be created on the new machine (default is usually vagrant but may vary depending on the box)
.PARAMETER boxName
  Name of the vagrant box that you want to use.  (default is gusztavvargadr/windows-11 )

.NOTES
  Version:        1.0
  Author:         devbox
  Creation Date:  06/27/2024
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\devbox.ps1 add my-machine
#>

param(
  [Parameter(Position=0)]
  [ValidateSet("List", "Add", "Drop")]
  [string]$action = "List",
  
  [Parameter(Position=1, HelpMessage="Machine Name")]
  [string]$machineName,
  
  [Parameter(Position=2, HelpMessage="User Name")]
  [string]$userName,
  
  [Parameter(Position=3, HelpMessage="Box Name")]
  [string]$boxName
)


#---------------------------------------------------------[Initializations]--------------------------------------------------------

#Set Error Action to Silently Continue
# $ErrorActionPreference = "SilentlyContinue"


  
#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

  
#-----------------------------------------------------------[Functions]------------------------------------------------------------


function Get-Input {
  param
  (
      [Parameter(Position = 0, ValueFromPipeline = $true)]
      [string]$msg,
      [string]$BackgroundColor = "Black",
      [string]$ForegroundColor = "DarkGreen"
  )

  Write-Host -ForegroundColor $ForegroundColor -NoNewline $msg ": ";
  return Read-Host
}

function Write-Header {
  param(
    [Parameter(Position = 0, ValueFromPipeline = $true)]
    [string]$statement,
    [Parameter(Position = 1)]
    [int]$width = 60
  )
  $newline = "`r`n"
  # create border
  $border = ""
  $border = $border.PadLeft($width, '=')
  
  # add spacing to statement
  $statement = $statement.PadLeft($statement.Length + 1,' ')
  $statement = $statement.PadRight($statement.Length + 1,' ')
  $diff = $border.Length - $statement.Length
  $lpad = $diff/2
  $rpad = $diff/2
  if ($diff % 2 -ne 0)
  {
      $lpad = ($diff + 1)/2
      $rpad = $lpad - 1
  }

  $t = $host.ui.RawUI.ForegroundColor
  $host.ui.RawUI.ForegroundColor = "Yellow"

  $lformated = $statement.PadLeft($statement.Length + $lpad,'=')
  $formated = $lformated.PadRight($lformated.Length + $rpad,'=')  
  $newline
  $border
  $formated
  $border
  $newline

  $host.ui.RawUI.ForegroundColor = $t
}




function Get-MachineList {
  $FolderPath = Join-Path -Path $PWD -ChildPath "machines"
  $DirectoryList = @()
  If( Test-Path $FolderPath) {
    $Directories = Get-ChildItem -Path $FolderPath -Directory
    $DirectoryList = $Directories | ForEach-Object { $_.Name}
  }
  return $DirectoryList  
}

function New-Machine {
  param(
    [Parameter(Position = 0)]
    [string]$machineName,
    [Parameter(Position = 1)]
    [string]$userName,
    [Parameter(Position = 2)]
    [string]$boxName
  )
  # create folder path
  $FolderPath = Join-Path -Path $PWD -ChildPath "machines" -AdditionalChildPath $machineName
  mkdir $FolderPath | Out-Null

  # copy setup files
  Copy-Item .\setup-scripts\vagrantfile.base (Join-Path -Path $FolderPath -ChildPath "Vagrantfile")
  Copy-Item .\setup-scripts\custom.config (Join-Path -Path $FolderPath -ChildPath "$machineName.config")
  Copy-Item .\setup-scripts\custom.ps1 (Join-Path -Path $FolderPath -ChildPath "$machineName.ps1")

  # create .env
  Write-Output "MACHINE_NAME=$machineName" > (Join-Path -Path $FolderPath -ChildPath ".env")
  if (![string]::IsNullOrEmpty($userName))
  {
    Write-Output "USER_NAME=$userName" >> (Join-Path -Path $FolderPath -ChildPath ".env")
  }
  if (![string]::IsNullOrEmpty($boxName))
  {
    Write-Output "BOX_NAME=$boxName" >> (Join-Path -Path $FolderPath -ChildPath ".env")
  }

  # move to folder
  Set-Location $FolderPath

  $CMD = "vagrant"

  # install vagrant-env plugin
  & $CMD plugin install vagrant-env 
  
  # start vagrant
  & $CMD up --provider=hyperv  

  if ($LASTEXITCODE -ne 0) {
    throw
  }
}

function Remove-Machine {
  param(
    [string]$machineName
  )
  $Originalpath = $PWD
  $FolderPath = Join-Path -Path $PWD -ChildPath "machines" -AdditionalChildPath $machineName

  # move to machine location
  Set-Location $FolderPath  

  # destroy vagrant box
  $CMD = "vagrant"
  & $CMD destroy 

  # clean up folders
  Set-Location $Originalpath  
  Remove-Item $FolderPath -Force -Recurse
  


}

function Test-Administrator {
  $user = [Security.Principal.WindowsIdentity]::GetCurrent();
  (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}





switch ($action) {
  'List' {        
    $machineList = Get-MachineList
    Write-Header "Machine List"
    if ($machineList.Count -gt 0) {
      $machineList | ForEach-Object {
        Write-Output $_
      }
    }
    else {
      write-output "There are no machines created."
    }  
  }

  'Add' {
    if (!(Test-Administrator)) {
      Write-Warning "Adding or dropping machines requires administrator priveleges. Please re-run from an elevated prompt."
      break
    }     
    
    while([string]::IsNullOrWhiteSpace($machineName)) {
      $machineName = Get-Input "What is the name of the machine you want to add? "
    }    

    # check if machine already exists
    if ((Get-MachineList) -contains $machineName){
      Write-Output "There is already a machine named $machineName."

      Write-Output "If you don't see $machineName listed in Hyper-V Manager try dropping the machine and re-adding it."
      break
    }
    
    try {      
      Write-Header "Creating new machine: $machineName"
      New-Machine $machineName $userName $boxName
    }
    catch {
      Write-Error "There was a problem adding the new machine. Please see the errors above."      
      EXIT 1
    }
    
  }

  'Drop' {      
    if (!(Test-Administrator)) {
      Write-Warning "Adding or dropping machines requires administrator priveleges. Please re-run from an elevated prompt."
      break
    }
    while([string]::IsNullOrWhiteSpace($machineName)) {
      $machineName = Get-Input "What is the name of the machine you want to add? "
    }

    # check if machine already exists
    if ((Get-MachineList) -notcontains $machineName){
      Write-Output "There isn't a machine named $machineName."    
      break
    }

    try {
      Write-Header "Dropping machine: $machineName"       
      Remove-Machine $machineName
    }
    catch {
      Write-Error "There was a problem dropping the machine. Please see the errors above."      
      EXIT 1
    }
  }
}
