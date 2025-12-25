param(
  [Parameter(Mandatory=$true)]
  [string]$Uri,

  [Parameter(Mandatory=$true)]
  [string]$JsonBody,

  [ValidateSet('GET','POST','PUT','PATCH','DELETE')]
  [string]$Method = 'POST',

  [string]$UserAgent = 'pwsh-client/1.0',
  [string]$TraceParent = '00-00000000000000000000000000000000-0000000000000000-01'
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Convert-JsonUnicodeEscapes {
  param([string]$Text)
  if ([string]::IsNullOrEmpty($Text)) { return $Text }

  $decoded = $Text

  $decoded = [regex]::Replace($decoded, '\\\\u([0-9a-fA-F]{4})', {
    param($match)
    [char]([Convert]::ToInt32($match.Groups[1].Value, 16))
  })

  $decoded = [regex]::Replace($decoded, '\\u([0-9a-fA-F]{4})', {
    param($match)
    [char]([Convert]::ToInt32($match.Groups[1].Value, 16))
  })

  return $decoded
}

$headers = @{
  traceparent = $TraceParent
}

$invokeParams = @{
  Uri = $Uri
  Method = $Method
  Headers = $headers
  UserAgent = $UserAgent
  UseBasicParsing = $true
  ErrorAction = 'Stop'
}

$bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($JsonBody)
$invokeParams['Body'] = $bodyBytes
$invokeParams['ContentType'] = 'application/json; charset=utf-8'

$statusCode = $null
$rawBody = $null

try {
  $response = Invoke-WebRequest @invokeParams
  $statusCode = $response.StatusCode
  $rawBody = $response.Content
} catch [System.Net.WebException] {
  $resp = $_.Exception.Response
  if ($resp -ne $null) {
    $statusCode = [int]$resp.StatusCode
    $stream = $resp.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::UTF8)
    $rawBody = $reader.ReadToEnd()
    $reader.Close()
  } else {
    $rawBody = $_.Exception.Message
  }
} catch {
  $rawBody = $_.Exception.Message
}

$decodedBody = Convert-JsonUnicodeEscapes -Text $rawBody

Write-Output ("StatusCode: {0}" -f $statusCode)
if ($decodedBody -ne $null) {
  Write-Output $decodedBody
}
