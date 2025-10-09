. "$PSScriptRoot/base.ps1"

$extensionFilePath = "$PSScriptRoot/../../configs/vscode/extensions.txt"
$extensions = Get-Content $extensionFilePath
foreach ($extension in $extensions) {
    code --install-extension $extension
}