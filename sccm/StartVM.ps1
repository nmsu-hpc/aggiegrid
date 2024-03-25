#Requires -Version 3.0 -Modules Hyper-V -RunAsAdministrator

Function ToEven ($num) {
    if ($num % 2 -ne 0) { $num = $num - 1}
    return $num
}

$VM = Get-VM AggieGrid
$Offset = 256 # Value in MB

while ($VM.State -eq "Off") {

    # Set VM Memory Variables (Hyper-V Requires 2MB Alignment)
    $OS = Get-CimInstance Win32_OperatingSystem
    $DesiredBytes = (ToEven -num ( [math]::Truncate($OS.TotalVisibleMemorySize * 1024 / 3 * 2 / 1MB) )) * 1024 * 1024
    $AvailableBytes = (ToEven -num ( [math]::Truncate($OS.FreePhysicalMemory * 1024 / 1MB - $Offset) )) * 1024 * 1024

    # Set VM Memory
    if ($AvailableBytes -lt $DesiredBytes) {
        Set-VMMemory -VM $VM -DynamicMemoryEnabled $false -StartupBytes $AvailableBytes

        # Increment Offset to Get VM To Start In Low Mem Environment (Incase This Loop Iteration Fails)
        $Offset += 256
    }
    else {
        Set-VMMemory -VM $VM -DynamicMemoryEnabled $false -StartupBytes $DesiredBytes
    }

    # Start VM
    Start-VM -VM $VM -ErrorAction SilentlyContinue
}
