# Linux OS Hardening

Harden OS settings/configuration that is not handled by other roles.

This role is split into multiple catagories that can be individually enabled or disabled.

## Kernel

This catagory will blacklist/disable kernel modules such as filesystem types and other drivers.  Modules disabled in this way are disabled not only from boot but from being manually loaded aswell.

- Catagory is enabled by default.
  - to disable set `hrd_kernel: false`
- By default, mounted filesystems types are automatically removed from the blacklist.
  - This is controlled by two boolean variables.
    - `hrd_kernel_check_mnt_fstab: true`
      - searches for used filesystem types in '/etc/fstab'
    - `hrd_kernel_check_mnt_all: true`
      - searches for all used filesystem types using `findmnt`
- two variables are used to control what to blacklist
  - `hrd_kernel_blacklist`
    - sets which modules to disable.
    - see default role variables for list.
  - `hrd_kernel_whitelist`
    - prevents the above blacklist from disabling specified modules.
    - empty list by default.
  - both variables must be lists!

## Coredump

This catagory will prevent users from generating coredumps.

- Catagory is enabled by default.
  - to disable set `hrd_coredump: false`

## Nofloppy

This catagory will disable the Floppy driver by blacklisting it with modprobe and disabling it in dracut.

- Catagory is enabled by default.
  - to disable set `hrd_nofloppy: false`

## FStmp

This catagory will create '/tmp', '/dev/shm', and '/var/tmp' entries in '/etc/fstab' if they do not exist.  If entries for these mountpoints already exists no changes are made (see 'FSopt' catagory for hardening existing mountpoints).

- Catagory is enabled by default.
  - to disable set `hrd_fstmp: false`
- '/tmp' is mounted as tmpfs
- '/dev/shm' is mounted as tmpfs
- '/var/tmp' is bind mounted to '/tmp'
- All three mounts are created with 'nodev', 'noexec', and 'nosuid' options.

## FSopt

This catagory will enable file system mount flags 'nodev', 'noexec', and 'nosuid' for specific mountpoints.

- Catagory is enabled by default.
  - to disable set `hrd_fsopt: false`
- Filesystem mounts that get changed/hardened are controlled by three variables.
  - `hrd_fsopt_nodev`
  - `hrd_fsopt_noexec`
  - `hrd_fsopt_nosuid`
  - See defaults/main.yaml file for the default values.

## Log File Permissions

This catagory will adjust log file permissions in '/var/log' to remove write access from group and all access from other users.  'other' will retain access to the the '/var/log' folder itself so that non-root service can retain access to the files or folders underneeth.

- Catagory is disabled by default.
  - to enable set `hrd_logperm: true`
  - Permissions conflict with what is set by logrotate/rsyslog.
  - Current implimentation is extremely slow.
  - Needs to be review as it will change '0600' perms to '0640' which may not be desirable.
- No other variables are used.

## Login Definitions '/etc/login.defs'

This catagory will set the '/etc/login.defs' file which controls parts of shadow and password aging.

- Catagory is enabled by default.
  - to disable set `hrd_logindef: false`
- Min and Max password ages get set.
  - `hrd_logindef_passMaxDays: '365'`
    - To prevent max password aging set the variable back to the default '99999'.
  - `hrd_logindef_passMinDays: '7'`

## useradd defaults

This catagory will set the defaults for the useradd command accourding to Cis-Cat reccommendations.

- Catagory is enabled by default.
  - to disable set `hrd_useradd: false`
- Accepted Variables
  - `hrd_useradd_inactive: '30'`
    - This sets the default inactive period for created users.
    - To disable set value to '-1'.

## Authselect

This catagory will, accourding to Cis-Cat Reccommendations, create a custom authselect profile based on the default sssd/winbind and set reccommended values. Only RHEL/CentOS 8 Server will run this catagory. The catagory will also set password complexity policies.

- Catagory is enabled by default.
  - to disable set `hrd_authselect: false`
- Accepted Variables
  - `hrd_authselect_pwquality_minlen`
    - This sets the minimum password length for user accounts

## SU Access

This catagory will restrict access to the 'su' utility to a specific set of users.

- Catagory is enabled by default.
  - to disable set `hrd_su: false`
- Accepted Variables
  - `hrd_su_restrict`
    - Accepts 'true/false' non-quoted
    - Controls wether 'su' access is restricted or not (can undo lockdown)
  - `hrd_su_admins`
    - list of users to give access to 'su'.
    - Must be a list variable.
    - Cannot include groups.

## No Wifi

This catagory will use Network Manager to disable Wifi functionality accourding to Cis-Cat reccommendations.

- Catagory is enabled by default.
  - to disable set `hrd_nowifi: false`
- No changes will be made if Network Manager is disabled or not installed.
  - More functionality is needed to fix this.

## Sysctl Settings

This catagory will set varioius sysctl kernel settings based on Cis-Cat reccommendations.  Settings can be individually enabled or disabled through ansible variables.  Currently only network settings are being adjusted.

- Catagory is enabled by default.
  - to disable set `hrd_sysctl: false`
  - disabling catagory does not revert changes!
    - disabling individual settings will.
- Accepted Variables ('true/false' boolean)(defaulted to 'true')
  - `hrd_sysctl_net_no_ipForwarding`
    - Disables all IP forwarding to prevent server from acting as a router.
  - `hrd_sysctl_net_no_packetRedirectSending`
    - Prevents the server from sending ICMP Redirects to other hosts.
  - `hrd_sysctl_net_no_sourceRoutedPackets`
    - Disable source packet routing and enforces routing by the router.
  - `hrd_sysctl_net_no_icmpRedirects`
    - Block ICMP redirect messages thus preventing non-default route source from changing the host routing table.
  - `hrd_sysctl_net_no_secureIcmpRedirects`
    - Block ICMP redirect messages from the default gateway.
  - `hrd_sysctl_net_logSuspiciousPackets`
    - Log suspicious packets that may be spoofed.
  - `hrd_sysctl_net_no_broadcastIcmpRequests`
    - Do not reply to ICMP echo and timestamp requests with broadcast or multicast destination.
  - `hrd_sysctl_net_no_bogusIcmpResponses`
    - Prevent the kernal from logging bogus responses (RFC-122 non-compliant).
  - `hrd_sysctl_net_yes_reversePathFiltering`
    - Drop packets that do not return through the same interface they were recieved on.
  - `hrd_sysctl_net_yes_tcpSynCookies`
    - Prevent SYN flood attacks that perform a denial of service attack on a system by sending many SYN packets without completing the three way handshake.
  - `hrd_sysctl_net_no_ip6RouterAdverts`
    - Do not accept IPv6 router advertisements.
