$ErrorActionPreference = "Stop"
$projectRoot = Resolve-Path "$PSScriptRoot/../" | Select-Object -ExpandProperty Path

function reloadPathEnv() {
    "reloading Path"
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
}

function resolveAbsPath($path) {
    return Resolve-Path "$projectRoot/$path" | Select-Object -ExpandProperty Path
}

function addUserEnv($key, $value) {
    [System.Environment]::SetEnvironmentVariable($key, $value, "User")
}

function addEnvPath($path) {
    "Add $path to PATH"
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    [System.Environment]::SetEnvironmentVariable("PATH", "$currentPath;$path", "User")
}

function createSymbolicLink($path, $target) {
    Write-Host "Create symbolic link: $path => $target"
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Confirm
    }
    New-Item -ItemType SymbolicLink -Path $path -Target $target
}

function checkAndInstallPackage($commandName) {
}

$aquaCommand = "aqua"
$aquaExists = $false
try {
    if(Get-Command $aquaCommand){
        "$aquaCommand exists"
        $aquaExists = $true
    }
} catch {}

if (!$aquaExists) {
    "$aquaCommand doesn't exist: installing..."
    winget install aquaproj.aqua
    relaodPathEnv
    Write-Host "✅ Installation Complete" -ForegroundColor Green
}

# Setup Aqua Global Config
addUserEnv "AQUA_GLOBAL_CONFIG" (resolveAbsPath ".\aqua.yaml")
addEnvPath "$env:LOCALAPPDATA\aquaproj-aqua\bin"
reloadPathEnv
aqua install -a

##FIXME: install cmake through winget

# $targetPath = resolveAbsPath ".config/nvim"
# $configPath = "$env:LOCALAPPDATA/nvim"
# createSymbolicLink $configPath $targetPath

# $targetPath = resolveAbsPath ".config/claude"
# $configPath = "$env:LOCALAPPDATA/claude"
# createSymbolicLink $configPath $targetPath



