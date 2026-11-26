param(
  [switch]$SkipBuild,
  [int]$Port = 8080,
  [string]$GoogleMapsEmbedKey = ''
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$webRoot = Join-Path $projectRoot 'build\web'
if (-not $SkipBuild -or -not (Test-Path (Join-Path $webRoot 'flutter_bootstrap.js'))) {
  Write-Host 'Building Flutter Web release...' -ForegroundColor Cyan
  $buildArgs = @('build', 'web', '--release', '--no-pub')
  if ($GoogleMapsEmbedKey.Trim()) {
    $buildArgs += "--dart-define=GOOGLE_MAPS_EMBED_KEY=$($GoogleMapsEmbedKey.Trim())"
  }
  flutter @buildArgs
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

Write-Host "Serving $webRoot at http://0.0.0.0:$Port" -ForegroundColor Green
Set-Location $webRoot
py -m http.server $Port --bind 0.0.0.0
