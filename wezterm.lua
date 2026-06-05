local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- 1. 기본 셸 설정 (보내주신 PowerShell Core 설정 적용)
config.default_prog = { 
    'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe', 
    '-NoLogo', 
    '-NoExit', 
    '-Command', 
    "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; [Console]::InputEncoding = [System.Text.Encoding]::UTF8;" 
}

-- 2. Ghostty 감성의 미니멀 UI 튜닝 (로망 채우기)
config.color_scheme = 'Tokyo Night Storm' -- 네오빔 테마와 깔맞춤!
config.font = wezterm.font('JetBrainsMono Nerd Font', { weight = 'Regular' })
config.font_size = 11.0

config.window_decorations = "RESIZE" -- 타이틀바 제거 (진정한 미니멀리즘)
config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 } -- Ghostty 특유의 여백 감성
config.window_background_opacity = 0.95 -- 살짝 투명하게

-- 3. 성능 최적화 (Rust GPU 가속 체감용)
config.front_end = "WebGpu" 
config.animation_fps = 60

-- 4. 단축키 설정 (tmux의 핵심 기능인 '화면 쪼개기'를 WezTerm 단축키로 이식)
config.keys = {
    -- 새 탭 열기 (보내주신 기능 유지)
    { key = "p", mods = "CTRL|ALT", action = wezterm.action.SpawnCommandInNewTab{ args = config.default_prog } },
    
    -- [tmux 대용] 화면 세로 쪼개기 (Alt + v)
    { key = 'v', mods = 'ALT', action = wezterm.action.SplitHorizontal{ domain = 'CurrentPaneDomain' } },
    -- [tmux 대용] 화면 가로 쪼개기 (Alt + s)
    { key = 's', mods = 'ALT', action = wezterm.action.SplitVertical{ domain = 'CurrentPaneDomain' } },
    
    -- 화면 쪼갠 후 방향키나 마우스 없이 넘나들기 (Alt + Shift + hjkl)
    { key = 'h', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Left' },
    { key = 'l', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Right' },
    { key = 'k', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Up' },
    { key = 'j', mods = 'ALT|SHIFT', action = wezterm.action.ActivatePaneDirection 'Down' },
    
    -- 쪼갠 창 크기 조절 (Ctrl + Alt + 방향키)
    { key = 'LeftArrow', mods = 'CTRL|ALT', action = wezterm.action.AdjustPaneSize{ 'Left', 3 } },
    { key = 'RightArrow', mods = 'CTRL|ALT', action = wezterm.action.AdjustPaneSize{ 'Right', 3 } },
    { key = 'UpArrow', mods = 'CTRL|ALT', action = wezterm.action.AdjustPaneSize{ 'Up', 3 } },
    { key = 'DownArrow', mods = 'CTRL|ALT', action = wezterm.action.AdjustPaneSize{ 'Down', 3 } },
	
	-- config.keys 내부에 슬쩍 추가
	{ key = 'Space', mods = 'CTRL|SHIFT', action = wezterm.action.QuickSelect },
	
	-- Alt + 1 ~ 0 단축키로 탭 0~9 바로 이동하기
	{ key = '1', mods = 'ALT', action = wezterm.action.ActivateTab(0) },
	{ key = '2', mods = 'ALT', action = wezterm.action.ActivateTab(1) },
	{ key = '3', mods = 'ALT', action = wezterm.action.ActivateTab(2) },
	{ key = '4', mods = 'ALT', action = wezterm.action.ActivateTab(3) },
	{ key = '5', mods = 'ALT', action = wezterm.action.ActivateTab(4) },
	{ key = '6', mods = 'ALT', action = wezterm.action.ActivateTab(5) },
	{ key = '7', mods = 'ALT', action = wezterm.action.ActivateTab(6) },
	{ key = '8', mods = 'ALT', action = wezterm.action.ActivateTab(7) },
	{ key = '9', mods = 'ALT', action = wezterm.action.ActivateTab(8) },
	{ key = '0', mods = 'ALT', action = wezterm.action.ActivateTab(9) },
}

return config