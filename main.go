//go:build windows

package main

import (
	_ "embed"
	"encoding/json"
	"log"
	"os"
	"path/filepath"
	"strings"
	"syscall"

	"github.com/jchv/go-webview2"
)

//go:embed ui.html
var uiHTML string

// setDpiAwareness 必须在创建窗口前调用，否则系统会把 WebView2 内容按 DPI 缩放拉伸，文字会模糊。
func setDpiAwareness() {
	user32 := syscall.NewLazyDLL("user32.dll")
	proc := user32.NewProc("SetProcessDpiAwarenessContext")
	// DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2 = (HANDLE)-4
	if r, _, _ := proc.Call(^uintptr(3)); r == 0 {
		// 旧系统回退到系统级 DPI awareness。
		user32.NewProc("SetProcessDPIAware").Call()
	}
}

func main() {
	setDpiAwareness()

	// UI 写到 %APPDATA%\JsonForge\ui.html 后用 file:// 加载。
	// SetHtml 的 origin 是 about:blank，WebView2 不会可靠持久化它的 localStorage，
	// 导致风格设置重启丢失；file:// 的固定路径 origin 可以正常保存。
	configDir := filepath.Join(os.Getenv("APPDATA"), "JsonForge")
	if err := os.MkdirAll(configDir, 0o755); err != nil {
		log.Fatal(err)
	}
	uiPath := filepath.Join(configDir, "ui.html")
	if err := os.WriteFile(uiPath, []byte(uiHTML), 0o644); err != nil {
		log.Fatal(err)
	}

	configPath := filepath.Join(configDir, "config.json")

	w := webview2.NewWithOptions(webview2.WebViewOptions{
		Debug:     false,
		AutoFocus: true,
		WindowOptions: webview2.WindowOptions{
			Title:  "JSON Forge",
			Width:  1500,
			Height: 950,
			IconId: 1, // rsrc_windows_amd64.syso 中嵌入的 icon.ico 资源 ID
			Center: true,
		},
	})
	if w == nil {
		log.Fatal("未找到 Microsoft Edge WebView2 Runtime")
	}
	defer w.Destroy()

	// 风格持久化走本地配置文件，不依赖 WebView2 的 localStorage 行为。
	_ = w.Bind("loadConfig", func() (map[string]interface{}, error) {
		b, err := os.ReadFile(configPath)
		if err != nil {
			return map[string]interface{}{"style": "forge", "zoom": 13.0, "indent": 2.0}, nil
		}
		var cfg struct {
			Style  string  `json:"style"`
			Zoom   float64 `json:"zoom"`
			Indent float64 `json:"indent"`
		}
		if err := json.Unmarshal(b, &cfg); err != nil {
			return map[string]interface{}{"style": "forge", "zoom": 13.0, "indent": 2.0}, nil
		}
		if cfg.Zoom == 0 {
			cfg.Zoom = 13
		}
		if cfg.Indent == 0 {
			cfg.Indent = 2
		}
		return map[string]interface{}{"style": cfg.Style, "zoom": cfg.Zoom, "indent": cfg.Indent}, nil
	})
	_ = w.Bind("saveConfig", func(style string, zoom float64, indent float64) error {
		b, _ := json.MarshalIndent(map[string]interface{}{"style": style, "zoom": zoom, "indent": indent}, "", "  ")
		return os.WriteFile(configPath, b, 0o644)
	})
	_ = w.Bind("resetConfig", func() error {
		err := os.Remove(configPath)
		if err != nil && !os.IsNotExist(err) {
			return err
		}
		return nil
	})

	w.SetSize(1320, 860, webview2.HintNone)
	w.SetSize(1100, 700, webview2.HintMin)
	w.Navigate("file:///" + strings.ReplaceAll(uiPath, "\\", "/"))
	w.Run()
}
