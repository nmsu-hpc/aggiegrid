# AutoFS Configuration
This role will configure autofs and give the option to allow unmanaged configuration.

## Service Configuration Variables
- /etc/sysconfig/autofs
  - autofs_sysconfig_use_misc_devices
    - "yes"/"no"
  - autofs_sysconfig_options: ""
    - single string containing options to feed the service daemon

## Map Configuration
File system mappings are configured in 2 parts.

The first is the "/etc/auto.master" file, which is the master list for all file system mounts that autofs controls.  When the variable "autofs_unmanged_dropins" is set to true (not string true but boolean true) then a drop in configuration directory is allowed "/etc/auto.master.d/".

The second part is the map file which contains the url and file system type information for the mounted filesystem.  This will also contain either path or name information depending on the type of map (direct/indirect).

- These 2 parts are controlled through two variables "autofs_master" and "autofs_maps"
  - Wildcard variable matching is used to merge extra settings.  Be sure to properly namespace these variables based on group and hostnames.  Both variable types expect a list.
    - "autofs_master_*"
    - "autofs_maps_*"
  - autofs_master
    - This variable expects a list of strings containing a mountpoint and map file assignment.  The syntax should be consistant with what is expected in the "/etc/auto.master" file.
    - The use of this variable is for map file assignments where ansible is not creating or controlling the map file.  Some example of this may be the including map files such as "/etc/auto.misc" of the CVMFS binary "/etc/cvmfs".
  - autofs_maps
    - This variable is used to create a map file assignment then create the actual map file aswell.
    - This is a list with each item expected to have 3-4 named values.
      - name
        - The name you want your map file to have in "/etc/autofs.maps.d/"
      - path
        - The path location you want to be your mount point.
          - For an indirect map use the full path "/home/nfsmount1"
          - For a direct map use "/-"
      - options
        - this is to provide autofs option settings for the map association.  The value is optional and can be left out if not needed.
      - maps
        - this is a single string (can be multi line) that contains all of the content for the map file verbatim.

## Documentation Links
- [Manpage](https://linux.die.net/man/5/autofs)
- [Arch Wiki](https://wiki.archlinux.org/index.php/Autofs)
- [Rhel 7 Doc](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/storage_administration_guide/nfs-autofs)
- [Rhel 8 Doc](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_file_systems/assembly_mounting-file-systems_managing-file-systems#assembly_mounting-file-systems-on-demand_assembly_mounting-file-systems)

## Example
```yaml
autofs_master:
  - "/misc  /etc/auto.misc"
  - "/cvmfs /etc/cvmfs"

autofs_maps:
  - name: "forge.nfs"
    path: "/fs1"
    options: "--timeout=30 --ghost"
    maps: |
      home -fstype=nfs4,rw forge-s1.nmsu.edu:/home
      project -fstype=nfs4,rw forge-s1.nmsu.edu:/project
      scratch -fstype=nfs4,rw forge-s1.nmsu.edu:/scratch
      software -fstype=nfs4,rw forge-s1.nmsu.edu:/software
  - name: "forge.bind"
    path: "/-"
    options: "--timeout=30 --ghost"
    maps: |
      /project -fstype=bind :/fs1/project
      /scratch -fstype=bind :/fs1/scratch
	    /software -fstype=bind :/fs1/software
```
/etc/auto.master
```
# This file is managed by Ansible! All changes will be lost!!

# Items with non-managed map files (auto.misc, auto.net, auto.smb, etc..)
/misc  /etc/auto.misc
/cvmfs /etc/cvmfs


# Items with map files controlled by Ansible
/fs1  /etc/autofs.maps.d/forge.nfs  --timeout=30 --ghost

/-  /etc/autofs.maps.d/forge.bind  --timeout=30 --ghost
```
/etc/autofs.maps.d/forge.bind
```
# This file is managed by Ansible! All changes will be lost!!

/home -fstype=bind :/fs1/home
/project -fstype=bind :/fs1/project
/scratch -fstype=bind :/fs1/scratch
/software -fstype=bind :/fs1/software
```
/etc/autofs.maps.d/forge.nfs
```
# This file is managed by Ansible! All changes will be lost!!

home -fstype=nfs4,rw forge-s1.nmsu.edu:/home
project -fstype=nfs4,rw forge-s1.nmsu.edu:/project
scratch -fstype=nfs4,rw forge-s1.nmsu.edu:/scratch
software -fstype=nfs4,rw forge-s1.nmsu.edu:/software
```
