# JSON Forge

[English](README.md) | [简体中文](README.zh-CN.md)

JSON Forge is a desktop JSON utility for formatting, validating, repairing, sorting, compressing, searching, and exploring JSON in a synchronized editor and tree view.

## Features

- Format, validate, repair, and minify JSON.
- Sort object keys in ascending or descending order and restore the original order.
- Search keys and values, with matching nodes highlighted in the tree.
- Browse a collapsible JSON tree and jump from a tree node to its source line.
- Use syntax highlighting, line numbers, folding, automatic line wrapping, and adjustable font size.
- Copy keys, values, paths, or nodes; open and save JSON files.
- Choose a visual theme and keep the preference between launches.

The tree refreshes automatically while you type and after JSON operations such as formatting, validation, repair, sorting, and compression.

## Download

Get the latest builds from [GitHub Releases](https://github.com/tangfengsh/JsonForge/releases):

- Windows x64 and x86
- Linux amd64 and arm64
- macOS Intel (amd64) and Apple Silicon (arm64)

## Run requirements

- Windows: Microsoft Edge WebView2 Runtime.
- Linux: GTK 3 and WebKitGTK runtime libraries. On supported Ubuntu/Debian versions, install them with `sudo apt install libgtk-3-0 libwebkit2gtk-4.0-37`. Package names may differ by distribution release.
- macOS: macOS WebKit is included with the operating system. Current release builds are unsigned unless Apple signing and notarization secrets are configured for the GitHub Actions workflow. macOS may ask you to approve an unsigned app the first time it opens.

## Build on Windows

Install Go, then run:

```powershell
./build.ps1
```

This creates `JsonForge.exe` in the project directory as the default x64 build, plus x64 and x86 builds under `dist/`.

## Build all platforms on GitHub

The GitHub Actions workflow builds each platform on a suitable runner. Push a version tag to create a release:

```bash
git tag v1.0.1
git push origin v1.0.1
```

The workflow builds Windows x64/x86, Linux amd64/arm64, and macOS amd64/arm64, then attaches the six artifacts to the tagged GitHub Release. Linux uses Docker inside the GitHub Actions job; Docker is not needed on your Windows machine.

See [BUILD.md](BUILD.md) for local build details and optional macOS signing setup.
