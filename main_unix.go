//go:build darwin || linux

package main

import (
	_ "embed"
	"encoding/json"
	"log"
	"os"
	"path/filepath"

	webview "github.com/webview/webview_go"
)

//go:embed ui.html
var uiHTML string

func configFile() string {
	base, err := os.UserConfigDir()
	if err != nil || base == "" {
		base = "."
	}
	return filepath.Join(base, "JsonForge", "config.json")
}

func main() {
	configPath := configFile()
	if err := os.MkdirAll(filepath.Dir(configPath), 0o755); err != nil {
		log.Fatal(err)
	}

	w := webview.New(false)
	if w == nil {
		log.Fatal("无法创建系统 WebView，请检查 macOS WebKit 或 Linux WebKitGTK 依赖")
	}
	defer w.Destroy()

	w.SetTitle("JSON Forge")
	w.SetSize(1320, 860, webview.HintNone)
	w.SetSize(1100, 700, webview.HintMin)

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

	w.SetHtml(uiHTML)
	w.Run()
}
