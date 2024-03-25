# Aggie Grid Automation

This repo contains the scripts and automation to manage the AggieGrid VM from the template creation, and configuration, to deployment.

To give some background the AggieGrid Worker Node is designed to run on Hyper-V for easy deployment to NMSU lab machines through System Center Configuration Manager (SCCM).  The virtual machine is started when no users are logged into the computer (and at boot), then stooped when a users signs in (remote and local).

## Template VM Creation

A template VM, or golden image, is needed to deploy a AggieGrid worker to the desired windows workstations.

### Setup Hyper-V

- Run setup.ps1
  - creates network switch 'aggiegrid'
  - creates nat 'aggiegrid' and attached to network switch 'aggiegrid'
  - assigns static ip address for host OS 
  - creates port forwards
    - host 1122 -> guest(IP) 22
    - host 9618 -> guest(IP) 9618

### Create Virtual Machine

- Create VM
  - Generation = 2 (UEFI/EFI)
  - CPUs = 2
  - Memory = 2 GB (2048 MB)
    - This is startup memory.
    - DISABLE dynamic memory!
  - Secure Boot = Disabled
  - Disk = 30 GB
    - Name = AggieGrid.vhdx
    - Dynamically Expanding Disk
  - Network Switch = AggieGrid
  - Integration Services = ALL
  - Checkpoints = Disabled
    - This is important because automatic checkpoints will mess with the export size.
- Install CentOS 7
  - Download and use the latest CentOS 7 "Minimal" ISO.
    - Do not use out of date iso!
  - Language/Keyboard = English (United States)
  - Date & Time = Americas/Denver timezone
  - Software Selection = Minimal
  - Partition layout (Custom)
    - NO /boot
    - /boot/efi = 200 MB
    - / = 5 GB
    - /tmp = 800 MB
    - /var/lib/cvmfs = 13 GB
    - /var/lib/condor/execute = 9 GB
    - swap = 2 GB
    - Filesystem should be ext4 when possible and not xfs
    - Use Standard Partitions NOT LVM!!
  - KDump = Disabled
  - Network (Static!) & Hostname
    - hostname = aggiegrid
    - ip address = IP
    - netmask cidr = 30
    - gateway = IP
    - dns = IP/IPs
    - search = domain.edu
  - Security Policy = No profile selected
  - Root Password = See HPC Password Documentation
  - User Creation = No user will be created

### Configure CentOS

- SSH to ansible controler
  - SSH into the template vm `ssh -p 1122 root@hypervhost` 
    - Add an SSH Key to the root account's authorized_keys file
      - See HPC Password Documentation
  - git clone this git repository (ansible controler)
  - cd into 'ansible'
    - run `make vault-setup`
      - See HPC Password Documentation for the vault key
    - adjust the ansible inventory (./hosts) to point to your hyper-v host
    - run `make update`
    - run `make site`
  - SSH into the template vm `ssh -p 1122 root@hypervhost` (from ansible controler)
    - run `yum clean all`
    - run `rm -rf /tmp/*`
    - run `rm -rf /root/.ansible`
    - run `shutdown now`

### Export and Bundle the Template VM

- Ensure template vm is off
- Create versioned directory (1.2/1.3/etc..)
- Copy contents of the 'sccm' directory, in the git repo, to the versioned directory.
- Export the template vm, through hyper-v, to the versioned directory.
- In the versioned directory:
  - edit detect.ps1
    - adjust the VM.ID check with the new virtual machine id
      - you can get this from the exported vm's '.vmcx/.vmgs/.vmrs' file name (without extension), in 'versioned direction/AggieGrid/Virtual Machines'
      - This must be unique and cannot not match previous versions of the AggieGrid VM!
