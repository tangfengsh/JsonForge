param(
    [ValidateSet('amd64', 'arm64', 'all')]
    [string]$Architecture = 'all',
    [string]$OutputDir = (Join-Path $PSScriptRoot 'dist')
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw '未找到 Docker。请先安装 Docker Desktop。'
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw 'Docker daemon 未运行。请启动 Docker Desktop 后再执行。'
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$architectures = if ($Architecture -eq 'all') { @('amd64', 'arm64') } else { @($Architecture) }

foreach ($arch in $architectures) {
    $destination = Join-Path $OutputDir "linux-$arch"
    New-Item -ItemType Directory -Force -Path $destination | Out-Null
    $platform = "linux/$arch"

    docker buildx build `
        --platform $platform `
        --file (Join-Path $PSScriptRoot 'Dockerfile.linux') `
        --target artifact `
        --output "type=local,dest=$destination" `
        $PSScriptRoot

    if ($LASTEXITCODE -ne 0) {
        throw "Linux $arch 构建失败。"
    }
}

Write-Host "Linux binaries exported to $OutputDir"
Write-Host '运行目标机还需要安装 GTK3 和 WebKitGTK runtime。'
