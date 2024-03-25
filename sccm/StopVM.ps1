#Requires -Version 3.0 -Modules Hyper-V -RunAsAdministrator

# Stop Start VM Task If Running (Script Is Looping Trying To Start The VM)
Stop-ScheduledTask -TaskName "AggieGrid\Start-AggieGrid" -ErrorAction SilentlyContinue

# Stop VM
$VM = Get-VM AggieGrid
if ($VM.State -eq "Running") {
    Stop-VM -VM $VM -ErrorVariable $TimedOut

    if ($TimedOut) {
        Stop-VM -VM $VM -TurnOff -Force
    }
}
