$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "please run with administrator rights"
    return
}
$KERNEL_DOWNLOAD_URL='https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi'
$UBUNTU2004_DOWNLOAD_URL='https://wslstorestorage.blob.core.windows.net/wslblob/Ubuntu2404-240425.AppxBundle'
$MSI_FILE='temp.msi'
$APPX_FILE='temp.appx'
# see https://learn.microsoft.com/en-us/windows/wsl/install-manual
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Invoke-WebRequest -Uri $KERNEL_DOWNLOAD_URL -OutFile $MSI_FILE
Start-Process -FilePath $MSI_FILE -ArgumentList "/quiet"
wsl --set-default-version 2
wsl --update --web-download
Invoke-WebRequest -Uri $UBUNTU2004_DOWNLOAD_URL -OutFile $APPX_FILE
# if Add-AppPackage failed, try import Appx module first
# Import-Module Appx 
# if still failing, try using the usewindowspowershell option
# Import-Module Appx -usewindowspowershell
Add-AppPackage $APPX_FILE
Remove-Item -Path $MSI_FILE
Remove-Item -Path $APPX_FILE
winget install -e --id Microsoft.WindowsTerminal
