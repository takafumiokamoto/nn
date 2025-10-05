. "$PSScriptRoot/base.ps1"

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$keyName = "AllowDevelopmentWithoutDevLicense"
try {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $value = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction SilentlyContinue
    if ($value.AllowDevelopmentWithoutDevLicense -eq 1) {
        Write-Host "✓ Developer Mode is already enabled" -ForegroundColor Green
        exit
    }
} catch {}
"`nEnabling Developer Mode..."
Set-ItemProperty -Path $regPath -Name $keyName -Value 1
Write-Host "`n✓ Complete" -ForegroundColor Green
