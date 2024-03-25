#Requires -Version 3.0 -RunAsAdministrator

<# Info Dump on SCCM Application Detection Script Logic
- Any output or error message will make the detection method show as installed.
- If comparing versions be sure to cast to a [System.Version] object.

- Detected: Write-Host that the software is installed
- Not Detected: Ensure the script has absolutely not output or return value
#>

if (Get-Module -ListAvailable -Name Hyper-V) {
    # Default Vals For Detection Results
    $VMExists = $false
    $TasksExist = $false
    $VMSwitchExist = $false
    $NatExists = $false
    $PortForwardExists = $false

    # Verify Hyper-V VM
    If (Get-VM | Where-Object { $_.Name -eq "AggieGrid" }) {
        $VM = Get-VM -Name "AggieGrid"
        If ($VM.Id -eq "F57100A6-4CC2-43D7-919E-090C4E50A062") {
            $VMExists = $true
        }
    }

    # Verify Scheduled Tasks
    If ( (Get-ScheduledTask | Where-Object { $_.TaskName -like "*-AggieGrid" }).Count -eq 2) {
        $TasksExist = $true
    }

    # Set VM Network Switch
    If (Get-VMSwitch | Where-Object { $_.Name -eq "AggieGrid" }) {
        $VMSwitchExist = $true
    }
    IF (Get-NetNat | Where-Object { $_.Name -eq "AggieGrid" }) {
        $NatExists = $true
    }
    if ((Get-NetNatStaticMapping | Where-Object { ($_.NatName -eq "AggieGrid") -and ($_.ExternalPort -eq 1022 -or $_.ExternalPort -eq 9618) }).Count -eq 2) {
        $PortForwardExists = $true
    }

    # Output Detection Results
    If ($VMExists -and $TasksExist -and $VMSwitchExist -and $NatExists -and $PortForwardExists) {
        Write-Host "Installed and Configured! The AggieGrid VM exists with ID '$($VM.Id)'!! Start/Stop Scheduled Tasks Exist!!!"
    }

}
