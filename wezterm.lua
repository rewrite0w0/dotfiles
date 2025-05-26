local wezterm = require 'wezterm'

return {
    default_prog = { 'C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe', '-NoLogo' },  -- PowerShell Core
    -- default_prog = { 'powershell.exe', '-NoLogo' },  -- 기본 Windows PowerShell
	keys = {
        {key="p", mods="CTRL|ALT", action=wezterm.action.SpawnCommandInNewTab{args={"C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"}}},
    },
}
