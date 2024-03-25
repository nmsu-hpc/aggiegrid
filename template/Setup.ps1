#Requires -Version 3.0 -Modules Hyper-V -RunAsAdministrator

param(
    [switch]$GenNewId = $false
)

$ErrorActionPreference = "Stop"

# Set VM Network Switch
if ( !(Get-VMSwitch | Where-Object { $_.Name -eq "AggieGrid" }) ) {
    New-VMSwitch -Name "AggieGrid" -SwitchType Internal
}

# Setup NAT and Attach To VM Switch
if ( !(Get-NetNat | Where-Object { $_.Name -eq "AggieGrid" }) ) {
    $NetAdapter = Get-NetAdapter "vEthernet (AggieGrid)"
    New-NetIPAddress -IPAddress IP -PrefixLength 30 -InterfaceIndex $NetAdapter.ifIndex
    New-NetNat -Name "AggieGrid" -InternalIPInterfaceAddressPrefix IPrange
}

# Setup Port Forward (SSH)
if ( !(Get-NetNatStaticMapping | Where-Object { ($_.NatName -eq "AggieGrid") -and ($_.ExternalPort -eq 1022) }) ) {
    Add-NetNatStaticMapping -ExternalIPAddress "0.0.0.0/24" -ExternalPort 1122 -Protocol TCP -InternalIPAddress "IP" -InternalPort 22 -NatName "AggieGrid"
}

# Setup Port Forward (Condor)
if ( !(Get-NetNatStaticMapping | Where-Object { ($_.NatName -eq "AggieGrid") -and ($_.ExternalPort -eq 9618) }) ) {
    Add-NetNatStaticMapping -ExternalIPAddress "0.0.0.0/24" -ExternalPort 9618 -Protocol TCP -InternalIPAddress "IP" -InternalPort 9618 -NatName "AggieGrid"
}

<#
# Import & Copy VM Into Hyper-V
Get-Item -Path "$PSScriptRoot\ExportedVM\Virtual Machines\*.vmcx" | ForEach-Object {
    if ($GenNewId) {
        Import-VM -Path "$($_.FullName)" -Copy -GenerateNewId -ErrorAction Stop
    } else {
        Import-VM -Path "$($_.FullName)" -Copy -ErrorAction Stop
    }
}

# Connect VM To Network Switch
Connect-VMNetworkAdapter -VMName AggieGrid -Name "Network Adapter" -SwitchName "AggieGrid"
#>
