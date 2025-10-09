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

## TODO
- cmake for building luasnip in blink.cmp
- env for handling whether enable animation in Neovide 
