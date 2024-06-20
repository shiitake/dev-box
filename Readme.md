# dev-box

Managing the hyper-v machines using vagrant

### Prereq
* Install vagrant
* set `VAGRANT_HOME` environmental variable to location where you want the vagrant data to be stored (this can include large files)


### Creating new VM

This will be automated soon.  For now you have to do it manually. 
1. Create new folder with the name of your VM
2. Copy `setup-scripts\Vagrantfile.base` to the vm folder and rename it `Vagrantfile`
3. Edit the `Vagrantfile` and update the following variables:
  * `machine_name` - this will be the name of the vm in hyperv
  * `username` - this is the user that will be created on the vm
  * `base_directory` - this sets the location of the vm files. 
  * You can also customize the box, cpu and memory for the vm. By default it is using Windows 11 enterprise, 6 CPUs and 8 GB of RAM. 
4. [Optional] Copy `setup-scripts\custom.ps1` to the vm folder and rename it `<your-machine-name>.ps1`.
  * edit this script and add any custom powershell that you want to run when the machine is provisioned. 
5. [Optional] Copy `setup-scripts\custom.config` to the vm folder and rename it `<your-machine-name>.config`    
  * edit this config to add any chocolatey packages to the machine (see `setup-scripts\base.config` for a list of default chocolatey packages that are installed by default)
6. Navigate to your VM folder and run `vagrant up --provider=hyperv` from an elevated command prompt.  This will create and provision your new vm

### Todo: 
* create script to automate all the steps above
* organize the `setup-scripts` folder 












