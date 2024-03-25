#Requires -Version 3.0 -Modules Hyper-V -RunAsAdministrator

$ErrorActionPreference = "Stop"

# Set VM Network Switch
if ( !(Get-VMSwitch | Where-Object { $_.Name -eq "AggieGrid" }) ) {
    New-VMSwitch -Name "AggieGrid" -SwitchType Internal
}

# Setup NAT and Attach To VM Switch
if ( !(Get-NetNat | Where-Object { $_.Name -eq "AggieGrid" }) ) {
    $NetAdapter = Get-NetAdapter "vEthernet (AggieGrid)"
    New-NetIPAddress -IPAddress IP -PrefixLength 30 -InterfaceIndex $NetAdapter.ifIndex
    New-NetNat -Name "AggieGrid" -InternalIPInterfaceAddressPrefix IP
}

# Setup Port Forward (SSH)
if ( !(Get-NetNatStaticMapping | Where-Object { ($_.NatName -eq "AggieGrid") -and ($_.ExternalPort -eq 1122) }) ) {
    Add-NetNatStaticMapping -ExternalIPAddress "IPrange" -ExternalPort 1122 -Protocol TCP -InternalIPAddress "IP" -InternalPort 22 -NatName "AggieGrid"
}

# Setup Port Forward (Condor)
if ( !(Get-NetNatStaticMapping | Where-Object { ($_.NatName -eq "AggieGrid") -and ($_.ExternalPort -eq 9618) }) ) {
    Add-NetNatStaticMapping -ExternalIPAddress "IPrange" -ExternalPort 9618 -Protocol TCP -InternalIPAddress "IP" -InternalPort 9618 -NatName "AggieGrid"
}

# Import & Copy VM Into Hyper-V
if ( !(Get-VM | Where-Object { $_.Name -eq "AggieGrid" }) ) {

    # Find Exported VM
    $epath = Get-ChildItem -Path "$PSScriptRoot" -Filter *.vmcx -Recurse -File -Name | Select-Object -First 1

    Import-VM -Path "$PSScriptRoot\$epath" -Copy -ErrorAction Stop

    # Set VM CPU Cores
    $procs = (Get-CimInstance -ClassName 'Win32_Processor' | Measure-Object -Property 'NumberOfCores' -Sum).sum
    if ($procs -gt 4) { Set-VMProcessor -VMName AggieGrid -Count 4 }
    else { Set-VMProcessor -VMName AggieGrid -Count $procs }

    # Set VM Memory (Memory Size Is Changed When The Scheduled Task Starts The VM Based On Available Memory and Max Allowed For The VM)
    Set-VMMemory AggieGrid -DynamicMemoryEnabled $false -StartupBytes 2GB

    # Connect VM To Network Switch
    Connect-VMNetworkAdapter -VMName AggieGrid -Name "Network Adapter" -SwitchName "AggieGrid"

    # Set Integration Services
    $Services = "Guest Service Interface", "Heartbeat", "Key-Value Pair Exchange", "Shutdown", "Time Synchronization", "VSS"
    Enable-VMIntegrationService -Name $Services -VMName "AggieGrid"

    # Set Automatic Start/Stop Options
    Set-VM -VMName "AggieGrid" -AutomaticStartAction Nothing -AutomaticStopAction ShutDown

    # Disable Checkpoints
    Set-VM -VMName "AggieGrid" -CheckpointType Disabled
}

# Copy Needed Files For Scheduled Tasks
New-Item -Path "C:\ProgramData\AggieGrid" -ItemType Directory -Force
Copy-Item -Path "$PSScriptRoot\StartVM.ps1" -Destination "C:\ProgramData\AggieGrid\" -Force
Copy-Item -Path "$PSScriptRoot\StopVM.ps1" -Destination "C:\ProgramData\AggieGrid\" -Force

# Import Start/Stop Scheduled Tasks
Register-ScheduledTask -Xml (Get-Content "$PSScriptRoot\Start-AggieGrid.xml" | Out-String) -TaskName "Start-AggieGrid" -TaskPath "\AggieGrid" -Force
Register-ScheduledTask -Xml (Get-Content "$PSScriptRoot\Stop-AggieGrid.xml" | Out-String) -TaskName "Stop-AggieGrid" -TaskPath "\AggieGrid" -Force

# Start VM if No Users Are Currently Logged In
$ActiveUsers = (Get-CimInstance Win32_LoggedOnUser).antecedent.name | Select-Object -Unique
if ([bool](-not $ActiveUsers)) {
    Start-ScheduledTask -TaskName "Start-AggieGrid" -TaskPath "\AggieGrid" -ErrorAction SilentlyContinue
}
