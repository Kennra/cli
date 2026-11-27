# Installs the Kennra CLI on Windows from https://github.com/Kennra/cli/releases.
#
#   irm https://raw.githubusercontent.com/Kennra/cli/main/install.ps1 | iex
#
# Options (environment): KENNRA_VERSION (default: latest), KENNRA_INSTALL_DIR (default: %LOCALAPPDATA%\Kennra\bin)
$ErrorActionPreference = 'Stop'

$repo = 'Kennra/cli'
$asset = 'kennra-windows-x64.exe'
if ($env:KENNRA_VERSION) {
  $base = "https://github.com/$repo/releases/download/v$($env:KENNRA_VERSION.TrimStart('v'))"
} else {
  $base = "https://github.com/$repo/releases/latest/download"
}
$dir = if ($env:KENNRA_INSTALL_DIR) { $env:KENNRA_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA 'Kennra\bin' }
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
try {
  Write-Host "Downloading $asset ..."
  Invoke-WebRequest -UseBasicParsing -Uri "$base/$asset" -OutFile (Join-Path $tmp $asset)
  Invoke-WebRequest -UseBasicParsing -Uri "$base/SHA256SUMS" -OutFile (Join-Path $tmp 'SHA256SUMS')

  $line = Get-Content (Join-Path $tmp 'SHA256SUMS') | Where-Object { ($_ -split '\s+')[1].TrimStart('*') -eq $asset }
  if (-not $line) { throw "No checksum for $asset in this release." }
  $expected = ($line -split '\s+')[0].ToLower()
  $actual = (Get-FileHash -Algorithm SHA256 (Join-Path $tmp $asset)).Hash.ToLower()
  if ($expected -ne $actual) { throw "Checksum mismatch for $asset; nothing was installed." }

  Move-Item -Force (Join-Path $tmp $asset) (Join-Path $dir 'kennra.exe')
} finally {
  Remove-Item -Recurse -Force $tmp
}

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (-not ($userPath -split ';' | Where-Object { $_ -eq $dir })) {
  [Environment]::SetEnvironmentVariable('Path', "$userPath;$dir", 'User')
  Write-Host "Added $dir to your PATH. Open a new terminal to use it."
}
Write-Host "Installed $(Join-Path $dir 'kennra.exe')"
Write-Host 'Next: kennra login'
