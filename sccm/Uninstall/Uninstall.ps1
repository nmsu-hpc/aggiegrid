#Requires -Version 3.0 -Modules Hyper-V -RunAsAdministrator

# Remove Scheduled Tasks
If (Get-ScheduledTask | Where-Object { $_.TaskName -eq "Start-AggieGrid" }) {
    Unregister-ScheduledTask -TaskName "Start-AggieGrid" -Confirm:$false
}
If (Get-ScheduledTask | Where-Object { $_.TaskName -eq "Stop-AggieGrid" }) {
    Unregister-ScheduledTask -TaskName "Stop-AggieGrid" -Confirm:$false
}

# Cleanup Scheduled Task Scripts
If (Test-Path "C:\ProgramData\AggieGrid") {
    Remove-Item -Path "C:\ProgramData\AggieGrid" -Recurse -Force
}

# Remove Scheduled Task Folder
$scheduleObject = New-Object -ComObject schedule.service
$scheduleObject.connect()
$rootFolder = $scheduleObject.GetFolder("\")
If ($rootFolder.GetFolders(0) | Where-Object { $_.Path -like "\AggieGrid" }) {
    $rootFolder.DeleteFolder("AggieGrid", $null)
}

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
