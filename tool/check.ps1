$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

Write-Host '== Dart analyzer ==' -ForegroundColor Cyan
dart analyze lib test
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== Proxy syntax ==' -ForegroundColor Cyan
node --check proxy/server.mjs
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host '== Flutter tests ==' -ForegroundColor Cyan
flutter test --no-pub
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host 'All checks passed.' -ForegroundColor Green
