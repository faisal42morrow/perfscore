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
$disk = Get-PhysicalDisk | Select-Object MediaType, Size
$diskScore = 0
if ($disk.MediaType -eq "SSD") {
    $diskScore = 100
} elseif ($disk.MediaType -eq "NVMe") {
    $diskScore = 150
} else {
    $diskScore = 50
}
$diskSizeGB = $disk.Size / 1GB
$diskScore += [Math]::Min($diskSizeGB / 10, 50)  # Cap storage points at 50
$score += $diskScore

# Final weighted score
$finalScore = [Math]::Round($score, 2)

# Output results
Write-Host "`nPerformance Metrics:"
Write-Host "CPU: $($cpu.Name)"
Write-Host "CPU Score: $cpuScore"
Write-Host "RAM: $ramGB GB"
Write-Host "RAM Score: $ramScore"
Write-Host "Storage Type: $($disk.MediaType)"
Write-Host "Storage Score: $diskScore"
Write-Host "`nFinal Performance Score: $finalScore"
