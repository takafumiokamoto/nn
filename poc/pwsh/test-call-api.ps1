param(
  [string]$SuccessUri = 'https://httpbin.org/post',
  [string]$ErrorUri = 'https://httpbin.org/status/418',
  [string]$UserAgent = 'pwsh-test/1.0',
  [string]$TraceParent = '00-11111111111111111111111111111111-2222222222222222-01'
)

$scriptPath = Join-Path $PSScriptRoot 'call-api.ps1'
if (-not (Test-Path $scriptPath)) {
  Write-Error "call-api.ps1 not found at $scriptPath"
  exit 1
}

$payload = '{"text":"\\u65e5\\u672c"}'

Write-Output '--- Success case (200) ---'
& $scriptPath -Uri $SuccessUri -JsonBody $payload -UserAgent $UserAgent -TraceParent $TraceParent -Method 'POST'

Write-Output ''
Write-Output '--- Error case (non-200) ---'
& $scriptPath -Uri $ErrorUri -JsonBody $payload -UserAgent $UserAgent -TraceParent $TraceParent -Method 'POST'
