#Requires -Version 3.0 -Modules Hyper-V -RunAsAdministrator

# Delete VM
if (Get-VM | Where-Object { $_.Name -eq "AggieGrid" }) {

    $VM = Get-VM -Name "AggieGrid"
    $VHDs = $VM.HardDrives.Path

    # Stop VM If It Is Running
    if ($VM.State -ne "Off") { $VM | Stop-VM -TurnOff -Force }

# Remove VM
$VM | Remove-VM -Force

# Delete Hard Drives (Remove-VM leaves the VHD files behind)
$VHDs | Remove-Item -Force -ErrorAction SilentlyContinue
}

# Delete Hyper-V Switch & Nat
Get-NetNat | Where-Object { $_.Name -eq "AggieGrid" } | Remove-NetNat -Confirm:$false
Get-VMSwitch | Where-Object { $_.Name -eq "AggieGrid" } | Remove-VMSwitch -Force
Get-NetNatStaticMapping | Where-Object { $_.NatName -eq "AggieGrid" } | Remove-NetNatStaticMapping -Confirm:$false
