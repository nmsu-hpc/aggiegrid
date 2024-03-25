# chrony

Chrony is a versatile implementation of the Network Time Protocol (NTP).

- Up to 3 time servers to pull from can be set.
- If you want chrony to update the hardware clock (bios?) then set "chrony_hwclock_sync" to "yes".

## Default Variables
```yaml
---
chrony_server_primary: "time.nmsu.edu" # first time server
chrony_server_backup: "ntp.nmsu.edu" # second time server
chrony_server_tertiary: "0.centos.pool.ntp.org iburst" # third time server
chrony_hwtimestamp: "" # Hardware Time Stamping (hwtimestamp *)
chrony_minsources: "" # Minimum Source to Adjust System Clock
chrony_local_clients: "" # Network Clients Allowed To Get Time From Host
chrony_keyfile: "" # File With Keys for NTP Auth
chrony_log_info: "" # Select Which Information Is Logged

chrony_hwclock_sync: "no"
```

## Limitations
- If running in server mode "chrony_local_clients" be sure to open the relevant ports in the firewall role.
