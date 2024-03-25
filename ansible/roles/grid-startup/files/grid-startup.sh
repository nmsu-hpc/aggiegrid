#!/bin/bash

# Wait for Hyper-V Key Value Pair to populate!
kvp="/var/lib/hyperv/.kvp_pool_3"
until [ -f "$kvp" ]
do
	echo "Waiting on Hyper-V Key Value Pair: $kvp"
	sleep 15
done

# Get Hypervisor DNS Name
HOST_NAME="$(strings $kvp | sed -n '/PhysicalHostNameFullyQualified/ {n;p}' | sed 's/ACN.ad.//')"
echo "Hyper-V Host Name = $HOST_NAME"
hostnamectl set-hostname $HOST_NAME

# Get External IP (Outside Nat)
HOST_IP="$(dig +short "$HOST_NAME" | tail -n1)"
echo "Hyper-V Host IP = $HOST_IP"

# Ensure Condor Is Stopped
systemctl stop condor

# Delete Condor Logs
/bin/rm -f /var/log/condor/*

# Delete Other Folders That May Have Leftover Files
/bin/rm -rf /home/*
/bin/rm -rf /tmp/*
/bin/rm -rf /var/lib/condor/execute/*

# Modify Local Condor Config
lconf='/etc/condor/condor_config.local'
echo "TCP_FORWARDING_HOST = $HOST_IP" > "$lconf"
chmod '0644' "$lconf"

# Add firewall rules
nft add rule inet filter input tcp dport 9618 ip saddr $HOST_IP accept

# Start Condor
systemctl start condor
