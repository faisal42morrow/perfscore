# Run this in PowerShell to get a performance score
$score = 0

# Get price input
Write-Host -NoNewline "Price: "
$price = Read-Host

# CPU Score
$cpu = Get-WmiObject -Class Win32_Processor
$cpuScore = $cpu.MaxClockSpeed * $cpu.NumberOfCores / 1000
$score += $cpuScore

# Memory Score
$ram = Get-WmiObject -Class Win32_PhysicalMemory
$ramGB = ($ram | Measure-Object -Property Capacity -Sum).Sum / 1GB
$ramScore = $ramGB * 10
$score += $ramScore

# Storage Score
$disks = Get-PhysicalDisk | Select-Object MediaType
$diskScore = 0
foreach ($disk in $disks) {
    $currentScore = 0
    if ($disk.MediaType -eq "SSD") {
        $currentScore = 100
    } elseif ($disk.MediaType -eq "NVMe") {
        $currentScore = 150
    } else {
        $currentScore = 50
    }
    if ($currentScore -gt $diskScore) {
        $diskScore = $currentScore
    }
}
$score += $diskScore

# Final score
$finalScore = [Math]::Round($score, 2)
Write-Host "Performance Score: $finalScore"

# Calculate ratio if price provided
if ($price -ne "na") {
    try {
        $priceNum = [double]$price
        $ratio = [Math]::Round($finalScore / $priceNum, 4)
        Write-Host "Score/Price Ratio: $ratio"
    }
    catch {
        Write-Host "Invalid price input. Enter a number or 'na'."
    }
}
