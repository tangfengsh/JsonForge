# JSON Forge

JSON Forge 是一个本地 JSON 工具，支持：

- 格式化、校验、修复、压缩
- 键名升序、降序和还原排序
- JSON 语法高亮、折叠展开、行号和字号缩放
- JSON 树形展示，点击节点定位到左侧文本
- 搜索键和值、复制路径和值、下载 JSON
- Windows x64/x86、Linux amd64/arm64、macOS Intel/Apple Silicon 构建

## Windows 本地构建

```powershell
./build.ps1
```

根目录的 `JsonForge.exe` 是默认 Windows x64 版本，同时会在 `dist/` 生成 x64 和 x86 版本。

## GitHub Release

推送版本 tag 后，GitHub Actions 会自动构建并发布全平台 Release：

```bash
git tag v1.0.0
git push origin v1.0.0
```

详细构建、Docker 和 macOS 签名配置见 [BUILD.md](BUILD.md)。
