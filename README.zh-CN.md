# JSON Forge

[English](README.md) | [简体中文](README.zh-CN.md)

JSON Forge 是一款桌面 JSON 工具，提供格式化、校验、修复、排序、压缩、搜索，以及文本编辑器和 JSON 树形视图。

## 功能

- 格式化、校验、修复和压缩 JSON。
- 对象键名升序或降序排列，并可还原原始顺序。
- 搜索键和值，并在树形视图中高亮匹配节点。
- 浏览可折叠的 JSON 树；点击节点可定位到左侧源文本。
- 提供语法高亮、行号、折叠、自动换行和字号调整。
- 复制键名、键值、路径或节点，也可以打开和保存 JSON 文件。
- 选择界面风格，并在下次启动时恢复设置。

输入内容以及格式化、校验、修复、排序和压缩后的 JSON 树都会自动同步更新。

## 下载

从 [GitHub Releases](https://github.com/tangfengsh/JsonForge/releases) 下载：

- Windows x64 和 x86
- Linux amd64 和 arm64
- macOS Intel（amd64）和 Apple Silicon（arm64）

## 运行依赖

- Windows：Microsoft Edge WebView2 Runtime。
- Linux：GTK 3 和 WebKitGTK runtime。在支持的 Ubuntu/Debian 版本中可运行 `sudo apt install libgtk-3-0 libwebkit2gtk-4.0-37` 安装；不同发行版版本的软件包名称可能不同。
- macOS：系统自带 WebKit。当前 Release 默认未签名，除非 GitHub Actions 配置了 Apple 签名和公证凭据。首次打开未签名应用时，macOS 可能要求手动允许运行。

## 在 Windows 本机构建

安装 Go 后运行：

```powershell
./build.ps1
```

项目根目录会生成默认 x64 版 `JsonForge.exe`，并在 `dist/` 下生成 x64 和 x86 版本。

## 使用 GitHub 构建全平台版本

GitHub Actions 会在各平台对应的 runner 上构建。推送版本 tag 即可创建 Release：

```bash
git tag v1.0.1
git push origin v1.0.1
```

工作流会构建 Windows x64/x86、Linux amd64/arm64、macOS amd64/arm64，并将 6 个构建产物附加到该版本的 GitHub Release。Linux job 在 GitHub Actions 内部使用 Docker；Windows 本机无需安装或启动 Docker。

本机构建详情和可选的 macOS 签名配置见 [BUILD.md](BUILD.md)。
