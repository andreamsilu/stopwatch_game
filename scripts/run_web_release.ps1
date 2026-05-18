# Run Stopwatch Challenge on web using Flutter only (no Python / external servers).
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

Write-Host "Stopping stray Flutter tool processes from prior crashed runs..."
Get-CimInstance Win32_Process -Filter "Name='dart.exe'" -ErrorAction SilentlyContinue |
  Where-Object { $_.CommandLine -match 'flutter_tools' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

if (-not (Test-Path ".env")) {
  Copy-Item ".env.example" ".env"
  Write-Host "Created .env from .env.example"
}

flutter pub get

# Preferred: launches Chrome with the release build.
Write-Host "Starting: flutter run -d chrome --release"
flutter run -d chrome --release
