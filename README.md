# Development Environment

## run

Windows
```pwsh
# run as admin
powershell --executionpolicy bypass .\scripts\enable-devmode.ps1
# run as user
powershell --executionpolicy bypass .\entrypoints\windows.ps1
```
Linux, Mac
```shell
chmod +x entrypoints\linux.sh
.\entrypoints\linux.sh
```
