param(
    [string]$OutputDir = (Join-Path $PSScriptRoot 'dist')
)

$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$env:CGO_ENABLED = '0'
$env:GOOS = 'windows'

$env:GOARCH = 'amd64'
$x64Output = Join-Path $OutputDir 'JsonForge-windows-x64.exe'
go build -trimpath -ldflags='-s -w -H windowsgui' -o $x64Output $PSScriptRoot

# 根目录程序作为 Windows 默认版本，固定为 x64。
$defaultOutput = Join-Path $PSScriptRoot 'JsonForge.exe'
if ([IO.Path]::GetFullPath($x64Output) -ne [IO.Path]::GetFullPath($defaultOutput)) {
    Copy-Item -LiteralPath $x64Output -Destination $defaultOutput -Force
}

$env:GOARCH = '386'
go build -trimpath -ldflags='-s -w -H windowsgui' -o (Join-Path $OutputDir 'JsonForge-windows-x86.exe') $PSScriptRoot

Write-Host "Built Windows x64 and x86 packages in $OutputDir"
Write-Host 'GitHub Actions builds the Linux and macOS packages automatically on their native runners.'
