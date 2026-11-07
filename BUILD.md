# JsonForge 构建说明

## Windows

在 Windows、Docker Desktop 未参与的情况下构建 Windows 版本：

```powershell
./build.ps1
```

输出：

- 根目录 `JsonForge.exe`（默认 Windows x64）
- `dist/JsonForge-windows-x64.exe`
- `dist/JsonForge-windows-x86.exe`

## Linux：Docker 构建

Linux 的 CGO 依赖可以放在 Docker 镜像中。先启动 Docker Desktop，再执行：

```powershell
./build-linux-docker.ps1
```

只构建一个架构：

```powershell
./build-linux-docker.ps1 -Architecture amd64
./build-linux-docker.ps1 -Architecture arm64
```

输出目录：

- `dist/linux-amd64/JsonForge-linux-amd64`
- `dist/linux-arm64/JsonForge-linux-arm64`

首次构建 `arm64` 时，Docker Buildx 可能通过 QEMU 模拟运行，速度会慢一些。目标机器仍需要安装 WebKitGTK runtime；Docker 负责编译环境，不会把 Linux 系统库静态塞进二进制。

Ubuntu/Debian 运行时通常需要：

```bash
sudo apt install libgtk-3-0 libwebkit2gtk-4.0-37
```

具体包名随发行版版本变化，以目标系统的软件源为准。

Linux/macOS 也可以直接运行：

```bash
./build-linux-docker.sh all
```

## macOS

macOS 不能用 Linux Docker 容器编译。macOS WebKit 属于 Apple 系统 framework，需要 macOS 的 SDK 和 clang。

在 Mac 本机执行：

```bash
./build.sh
```

要求安装 Xcode Command Line Tools 和 Go。GitHub Actions 使用 `macos-15-intel` runner；Intel 版本原生构建，Apple Silicon 版本通过 Apple clang 的 `-arch arm64` 交叉编译。

本机脚本会输出 `dist/JsonForge-macos-amd64.zip` 或 `dist/JsonForge-macos-arm64.zip`，解压后得到 `JsonForge.app`。

macOS 不生成 32 位版本，现代 macOS 已不支持 32 位应用。

## GitHub 一键 Release

将项目上传到 GitHub 后，不需要在本机安装 Linux 或 macOS 编译环境。

方式一：创建并推送版本 tag：

```bash
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions 会自动生成并发布：

- `JsonForge-windows-x64.exe`
- `JsonForge-windows-x86.exe`
- `JsonForge-linux-amd64`
- `JsonForge-linux-arm64`
- `JsonForge-macos-amd64.zip`
- `JsonForge-macos-arm64.zip`

方式二：在 GitHub 的 Actions 页面手动运行 `Build JsonForge`。不填写 `release_tag` 时只生成构建产物；填写例如 `v1.0.0` 时，会在当前分支基础上自动创建并发布对应 Release。

### macOS 自动签名和公证

不配置 Apple Secrets 时，macOS 包仍会自动构建，但属于未签名包，首次打开可能需要在系统设置中允许运行。

要让 GitHub 自动完成签名、公证和 stapler，需要加入 Apple Developer Program，并在 GitHub 项目的 `Settings -> Secrets and variables -> Actions` 中配置以下 Repository secrets：

- `APPLE_CERTIFICATE_P12_BASE64`：Developer ID Application 证书导出的 `.p12` 文件再转成 Base64
- `APPLE_CERTIFICATE_PASSWORD`：导出 `.p12` 时设置的密码
- `APPLE_SIGNING_IDENTITY`：证书完整名称，例如 `Developer ID Application: Your Name (TEAMID)`
- `APPLE_ID`：Apple Developer 账号邮箱
- `APPLE_TEAM_ID`：Apple Developer Team ID
- `APPLE_APP_PASSWORD`：Apple ID 为公证创建的 App-specific password

在 Mac 上将证书转成 Base64 的命令：

```bash
base64 -i DeveloperIDApplication.p12 | pbcopy
```

粘贴剪贴板内容作为 `APPLE_CERTIFICATE_P12_BASE64`。配置完成后，推送新的 `v*` tag，macOS job 会自动导入证书、签名、提交 Apple notarization、staple 公证票据，再把已签名的 `.zip` 放进 Release。

## 为什么不能一个 Docker 镜像生成所有平台

- Linux Docker 容器可以提供 Linux 的 GTK/WebKitGTK headers、libraries 和 compiler。
- macOS Docker 容器不可用，Docker Desktop 运行的是 Linux 容器，里面没有 Cocoa/WebKit framework 和 Apple SDK。
- Windows 版本依赖 WebView2 和 Windows API，使用 Windows 构建环境最可靠。

在 GitHub Release 流程中，Docker 只作为 Linux job 的内部编译环境使用。你不需要在 Windows 本机启动 Docker；Windows 和 macOS 由各自的 GitHub runner 构建。

如果目标是完全不依赖系统 WebKitGTK/WebView2 的单文件程序，需要更换为内置 Chromium 的方案，包体积和工程结构都会明显增加。
