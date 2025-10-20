. "$PSScriptRoot/base.ps1"

function reloadEnvPath() {
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
}

function resolveAbsPath($path) {
    return Resolve-Path "$projectRoot/$path" | Select-Object -ExpandProperty Path
}

function addUserEnv($key, $value) {
    [System.Environment]::SetEnvironmentVariable($key, $value, "User")
    # for inside script
    Set-Item "Env:$key" "$value"
}

function addEnvPath($path) {
    "Add $path to PATH"
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    [System.Environment]::SetEnvironmentVariable("PATH", "$currentPath;$path", "User")
    reloadEnvPath
}

function createSymbolicLink($path, $target) {
    Write-Host "Create symbolic link: $path => $target"
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force
    } else {
        New-Item $path -ItemType Directory
    }
    New-Item -ItemType SymbolicLink -Path $path -Target $target -Force
}

function checkAndInstallPackage($packages) {
    foreach ($package in $packages) {
        $commandName = $package.cmd
        $commandExists = $false
        try {
            if(Get-Command $commandName) {
                "$commandName exits"
                $commandExists = $true
            }
        } catch {}
        if (!$commandExists) {
            "$commandName doesn't exists: installing..."
            winget install --silent -e --id $package.id
            reloadEnvPath
            Write-Host "Installation of $commandName Complete" -ForegroundColor Green
        }
    }
}

$packages = @(
    @{
        id="aquaproj.aqua"
        cmd="aqua";
    },
    @{
        id="Neovim.Neovim"
        cmd="nvim";
    },
    @{
        id="Kitware.CMake"
        cmd="cmake";
    }
)

checkAndInstallPackage $packages

# Setup Aqua Global Config
addUserEnv "AQUA_GLOBAL_CONFIG" (resolveAbsPath ".\aqua.yaml")
addUserEnv "AQUA_PROGRESS_BAR" "true"
addEnvPath "$env:LOCALAPPDATA\aquaproj-aqua\bin"
aqua install -l -a
aqua install -a --tags essential

# nvim config
$targetPath = resolveAbsPath "configs/nvim"
$configPath = "$env:LOCALAPPDATA/nvim"
createSymbolicLink $configPath $targetPath

# vscode config
$targetPath = resolveAbsPath "configs/vscode"
$configPath = "$env:APPDATA/Code/User"
createSymbolicLink $configPath $targetPath

# claude config
$targetPath = resolveAbsPath "configs/claude"
$configPath = "$env:LOCALAPPDATA/claude"
createSymbolicLink $configPath $targetPath

# wezterm config
$targetPath = resolveAbsPath "configs/wezterm"
$configPath = "$env:USERPROFILE/.config/wezterm"
createSymbolicLink $configPath $targetPath

# alacritty config
$targetPath = resolveAbsPath "configs/alacritty"
$configPath = "$env:APPDATA/alacritty"
createSymbolicLink $configPath $targetPath

#staship config
$targetPath = resolveAbsPath "configs/starship"
$configPath = "$env:USERPROFILE/.config/starship"
createSymbolicLink $configPath $targetPath
