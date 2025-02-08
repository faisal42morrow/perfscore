# Run this in PowerShell to get a performance score
$score = 0

# CPU Score (base score from CPU frequency and cores)
$cpu = Get-WmiObject -Class Win32_Processor
$cpuScore = $cpu.MaxClockSpeed * $cpu.NumberOfCores / 1000
$score += $cpuScore

# Memory Score (GB of RAM * speed if available)
$ram = Get-WmiObject -Class Win32_PhysicalMemory
$ramGB = ($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB
$ramScore = $ramGB * 10
$score += $ramScore

# Storage Score (based on type and speed)
$disks = Get-PhysicalDisk | Select-Object MediaType, Size
$diskScore = 0

# Take the fastest disk type as primary score
foreach ($disk in $disks) {
    $currentScore = 0
    if ($disk.MediaType -eq "SSD") {
        $currentScore = 100
    } elseif ($disk.MediaType -eq "NVMe") {
        $currentScore = 150
    } else {
        $currentScore = 50
    }
    
    # Get size in GB (handling array properly)
    $diskSizeGB = [math]::Round($disk.Size / 1GB, 2)
    $currentScore += [Math]::Min($diskSizeGB / 10, 50)  # Cap storage points at 50
    
    # Keep the highest score if multiple disks
    if ($currentScore -gt $diskScore) {
        $diskScore = $currentScore
    }
}
$score += $diskScore

# Final weighted score
$finalScore = [Math]::Round($score, 2)

# Output results
Write-Host "`nPerformance Metrics:"
Write-Host "CPU: $($cpu.Name)"
Write-Host "CPU Score: $cpuScore"
Write-Host "RAM: $ramGB GB"
Write-Host "RAM Score: $ramScore"
Write-Host "`nStorage Information:"
foreach ($disk in $disks) {
    $diskSizeGB = [math]::Round($disk.Size / 1GB, 2)
    Write-Host "Disk Type: $($disk.MediaType), Size: $diskSizeGB GB"
}
Write-Host "Storage Score: $diskScore"
Write-Host "`nFinal Performance Score: $finalScore"
