# dev-box

dev-box is a thin wrapper around Vagrant that lets you create and manage multiple hyper-v machines in a Windows environment.


If you are a developer who is consulting with several customers it may be common for you to be working in different projects on different technology stacks.  In order for you to avoid installing tools and SDKs that you might only use briefly it makes sense to create a virtual machine for each project or customer.
 
When you create a machine with the dev-box script it stores each machine's vagrant configuration and customization in dedicated folder (`machines/machine-name`).  From there you can customize them as needed and even run vagrant commands as needed.
 
**Base Configuration**
Dev-box uses Chocolatey to install software packages and includes a base configuration file that lets you define common software tools that should be installed for most projects.  For example: VSCode, SQL Server Management Studio, and Postman.
 
**Custom Configuration**
Each virtual machine will have a custom configuration that can include more specific tools and frameworks.  You can place project specify tools are SDKs here.
 
Virtual machines also have a custom PowerShell script which will let install software outside of Chocolatey. 


### Prereq
* HyperV enabled
* Install vagrant
* set `VAGRANT_HOME` environmental variable to location where you want the vagrant data to be stored (this can include large files)

The `devbox.ps1` script will allow you to `add`, `drop`, and `list` machines. 

### Getting started
1. Clone the repo to you local machine
2. Update `setup-scripts\base.config` with standard Chocolatey packages you'd like to install
3. Run `.\devbox.ps1` 

### Creating a new VM
Run the following from an elevated terminal:
`.\devbox.ps1 add <machine-name>`
  * pass in `-username` if you want to have it create a custom username 
  * pass in `-boxname` if you want to use a custom vagrant box (by default it will use `gusztavvargadr/windows-11`)

Vagrant may prompt you for a local account while provisioning the SMB shares. 

New machines will be created in a folder called `machines` and you can manually tweak their configuration files if you need to. 

You can run manual `vagrant` commands from the machine's folder.

### Dropping an existing VM
Run the following from an elevated terminal:
`.\devbox.ps1 drop <machine-name>`

This will destroy the VM that is created.  You may get a confirmation prompt. 

### Customizing your machine
1. Navigate to the folder of your VM `\machines\my-fm`
2. Edit `Vagrantfile` to customize the cpu and memory for the vm. By default it is using 6 CPUs and 8 GB of RAM.   
3. [Optional] Edit `<your-machine-name>.ps1` to add any custom powershell that you want to run when the machine is provisioned. 
4. [Optional] Edit `<your-machine-name>.config` to add any chocolatey packages to the machine (see `setup-scripts\base.config` for a list of default chocolatey packages that are installed by default)
5. Navigate to your VM folder and run `vagrant provision` from an elevated command prompt.  This will your existing vm.


### Customizing your base config
You can customize which base packages are installed on virtual machines by editing `setup-scripts\base.config` and adding or removing chocolatey packages.

### Adding custom box
`vagrant box add <box-name> <location of box file>`


### Todo: 
* update script to handle customization before running vagrant up












