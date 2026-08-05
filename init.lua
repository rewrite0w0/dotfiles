-- ============================================================================
-- Neovim 설정 (init.lua) — Vim-only 워크플로 가이드
-- ============================================================================
--
-- 📂 저장 위치
--   macOS / Linux : ~/.config/nvim/init.lua
--   Windows       : %APPDATA%\nvim\init.lua
--
-- 저장 후 nvim 재시작 → 필요 시 :Lazy sync
--
-- 강제 리셋
-- macOS / Linux : 
--   rm -rf ~/.local/share/nvim
--   rm -rf ~/.cache/nvim
-- Windows       : 
--   Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim-data
-- ============================================================================
-- 0. 전체 활용법 (VS Code 습관 → Vim 습관)
-- ============================================================================
--
-- ■ 파일 찾기 / 이동
--   <Space>ff     파일 이름 검색 (Telescope)        ← Ctrl+P
--   <Space>fg     프로젝트 전체 텍스트 검색         ← Ctrl+Shift+F
--   <Space>e      현재 파일 폴더를 oil로 열기       ← 사이드바 탐색기
--   -             oil 안에서 상위 폴더로            (oil 버퍼일 때)
--
-- ■ 파일 시스템 조작 (oil 버퍼에서)
--   이름 변경     글자 수정 후 :w
--   삭제          줄 삭제 후 :w
--   새 파일       빈 줄에 이름 적고 :w
--   새 폴더       빈 줄에 dirname/ 적고 :w
--   열기          <CR>
--   분할 열기     <C-s> (horizontal) / <C-v> (vertical)
--   닫기          <C-c> 또는 :bd
--
-- ■ 창(윈도우) 관리
--   Ctrl + h/j/k/l     창 이동
--   Alt  + h/j/k/l     창 이동 (Windows / Linux)
--   + / -              창 높이 조절
--   <Space>+ / <Space>- 창 너비 조절
--
-- ■ 터미널
--   <C-t>         하단 터미널 토글
--
-- ■ Git
--   <Space>gg     Neogit (스테이징·커밋·푸시)
--   <Space>gd     Diffview 열기
--   <Space>gq     Diffview 닫기
--   (줄 옆 표시는 vim-gitgutter가 자동)
--
-- ■ LSP / 진단 / 리팩터
--   gd            정의로 이동
--   gr            참조 찾기
--   gi            구현으로 이동
--   K             호버 문서
--   <Space>rn     이름 변경
--   <Space>ca     코드 액션
--   <Space>fm     수동 포맷
--   <Space>xx     전체 진단 (Trouble)
--   <Space>xX     현재 버퍼 진단
--   <Space>xs     심볼 목록
--   <Space>xl     LSP 정의/참조 목록
--
-- ■ 편집 보조
--   <Space>n      No Neck Pain (집중 모드, 좌우 여백)
--   저장 시       Biome / rustfmt 자동 포맷 (conform)
--   Insert 모드   nvim-cmp 자동완성 (<C-n>/<C-p>/<CR>)
--
-- ■ 기타
--   :OxcLint      현재 파일 oxlint 수동 실행
--   :ConformInfo  어떤 포매터가 붙는지 확인
--   :Lazy         플러그인 관리
--
-- ============================================================================

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_mac     = vim.fn.has("macunix") == 1
local is_linux   = vim.fn.has("unix") == 1 and not is_mac

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Neovim Setup" })
end

-- ============================================================================
-- 1. 필수 CLI 도구 체크
-- ============================================================================
-- git, node, biome 등이 PATH에 없으면 알려 줍니다.
-- 없어도 Neovim은 뜨지만, LSP/포맷/트리는 해당 기능이 동작하지 않습니다.
-- ============================================================================
local required_tools = {
  { name = "git",         cmd = "git",         important = true },
  { name = "node",        cmd = "node",        important = true },
  { name = "npm",         cmd = "npm",         important = true },
  { name = "biome",       cmd = "biome",       important = true },
  { name = "oxlint",      cmd = "oxlint",      important = false },
  { name = "tree-sitter", cmd = "tree-sitter", important = true },
}

local missing = {}
for _, tool in ipairs(required_tools) do
  if vim.fn.executable(tool.cmd) == 0 then
    table.insert(missing, tool)
  end
end

if #missing > 0 then
  notify("⚠️ 일부 도구가 설치되지 않았습니다:", vim.log.levels.WARN)
  for _, m in ipairs(missing) do
    notify(
      " • " .. m.name .. (m.important and " (필수)" or ""),
      m.important and vim.log.levels.ERROR or vim.log.levels.WARN
    )
  end
end

-- ============================================================================
-- 2. lazy.nvim (플러그인 매니저)
-- ============================================================================
-- 없으면 자동 clone. 이후 :Lazy sync 로 플러그인 설치/업데이트.
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  notify("lazy.nvim 설치 중...")
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 3. 기본 에디터 옵션
-- ============================================================================
vim.g.mapleader      = " "   -- 리더 키 = Space (거의 모든 커스텀 단축키의 시작)
vim.g.maplocalleader = "\\"

vim.opt.termguicolors  = true  -- true color
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true  -- 탭 → 스페이스
vim.opt.smartindent    = true
vim.opt.number         = true
vim.opt.relativenumber = true  -- 상대 번호 (움직임 계산에 유리)
vim.opt.cursorline     = true
vim.opt.hidden         = true  -- 버퍼 숨김 허용 (toggleterm 등에 필요)
vim.opt.signcolumn     = "yes" -- git/LSP 사인 공간 고정 (레이아웃 흔들림 방지)
vim.opt.updatetime     = 250

-- ============================================================================
-- 4. OS별 셸
-- ============================================================================
-- Windows : PowerShell (toggleterm 안정성 위해 옵션 전부 설정)
-- macOS   : zsh
-- Linux   : bash
-- ============================================================================
if is_windows then
  local powershell_options = {
    shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
    shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;",
    shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait",
    shellpipe  = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode",
    shellquote = "",
    shellxquote = "",
  }
  for option, value in pairs(powershell_options) do
    vim.opt[option] = value
  end
elseif is_mac then
  vim.opt.shell = "zsh"
elseif is_linux then
  vim.opt.shell = "bash"
end

-- ============================================================================
-- 5. 플러그인 목록 (lazy.nvim)
-- ============================================================================
require("lazy").setup({

  -- --------------------------------------------------------------------------
  -- 테마
  -- --------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-storm")
    end,
  },

  -- --------------------------------------------------------------------------
  -- 공통 의존성 / 검색
  -- --------------------------------------------------------------------------
  "nvim-lua/plenary.nvim",

  -- Telescope: 퍼지 찾기 (파일·문자열)
  --   <Space>ff  파일
  --   <Space>fg  live grep
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- --------------------------------------------------------------------------
  -- Treesitter: 문법 하이라이트·구조 파싱
  -- main 브랜치 + tree-sitter CLI 필요
  -- --------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ensure_installed = {
        "javascript", "typescript", "tsx",
        "html", "css", "json", "rust",
      }
      local ok, config = pcall(require, "nvim-treesitter.config")
      local already_installed = ok and config.get_installed() or {}
      local to_install = vim.iter(ensure_installed)
        :filter(function(p) return not vim.tbl_contains(already_installed, p) end)
        :totable()
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end
    end,
  },

  -- --------------------------------------------------------------------------
  -- 터미널: <C-t> 로 하단 패널 토글
  -- --------------------------------------------------------------------------
  "akinsho/toggleterm.nvim",

  -- --------------------------------------------------------------------------
  -- 괄호 자동 쌍
  -- --------------------------------------------------------------------------
  "windwp/nvim-autopairs",

  -- --------------------------------------------------------------------------
  -- Git: 줄 단위 diff 표시 (사인 컬럼)
  -- --------------------------------------------------------------------------
  "airblade/vim-gitgutter",

  -- --------------------------------------------------------------------------
  -- oil.nvim: 디렉토리를 버퍼처럼 편집 (Vim-only 파일 탐색)
  --
  -- 핵심 개념
  --   폴더를 열면 파일 목록이 "텍스트 버퍼"로 열린다.
  --   이름을 고치고 :w → 실제 rename
  --   줄을 지우고 :w → 실제 삭제
  --   새 줄에 이름을 쓰고 :w → 실제 생성
  --
  -- 단축키 (아래에서 재정의)
  --   <Space>e   현재 파일 기준 oil 열기
  --   -          상위 디렉토리 (oil 버퍼 안에서)
  -- --------------------------------------------------------------------------
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- 아이콘 (선택)
    config = function()
      require("oil").setup({
        -- 기본 파일 탐색기로 사용 ( :e .  등)
        default_file_explorer = true,
        columns = {
          "icon",
          -- "permissions",
          -- "size",
          -- "mtime",
        },
        view_options = {
          show_hidden = true, -- dotfile 표시
        },
        keymaps = {
          ["<CR>"] = "actions.select",
          ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-t>"] = false, -- toggleterm과 충돌 방지
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = { "actions.cd", opts = { scope = "tab" } },
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["g."] = "actions.toggle_hidden",
          ["g?"] = "actions.show_help",
        },
        use_default_keymaps = false, -- 위 맵만 사용
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- No Neck Pain: 좌우 여백으로 코드 집중
  --   <Space>n  토글
  -- --------------------------------------------------------------------------
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    opts = {
      width = 120,
      buffers = {
        left  = { enabled = true },
        right = { enabled = true },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- Trouble: 진단·심볼·LSP 결과를 리스트 UI로
  --   <Space>xx  전체 진단
  --   <Space>xX  현재 버퍼 진단
  --   <Space>xs  심볼
  --   <Space>xl  LSP 정의/참조 등
  -- --------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP defs/refs" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List" },
    },
  },

  -- --------------------------------------------------------------------------
  -- Neogit + Diffview: 에디터 안 Git UI
  --   <Space>gg  Neogit
  --   <Space>gd  Diffview 열기
  --   <Space>gq  Diffview 닫기
  -- --------------------------------------------------------------------------
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>",        desc = "Neogit" },
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",  desc = "Diffview Open" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    },
  },

  -- --------------------------------------------------------------------------
  -- nvim-cmp: 자동완성
  --   Insert에서 <C-n>/<C-p> 선택, <CR> 확정, <C-Space> 수동 트리거
  -- --------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-n>"]     = cmp.mapping.select_next_item(),
          ["<C-p>"]     = cmp.mapping.select_prev_item(),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- LSP (언어 서버)
  --   ts_ls / html / css / json / rust_analyzer
  --   biome (있으면), oxlint (있으면)
  --
  -- 버퍼에 LSP가 붙으면:
  --   gd gr gi K  <Space>rn  <Space>ca  <Space>fm
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      local servers = { "ts_ls", "html", "cssls", "jsonls", "rust_analyzer" }

      for _, server in ipairs(servers) do
        vim.lsp.config(server, {})
      end

      if vim.fn.executable("biome") == 1 then
        vim.lsp.config("biome", { cmd = { "biome", "lsp-proxy" } })
      end

      if vim.fn.executable("oxlint") == 1 then
        vim.lsp.config("oxlint", {
          capabilities = { textDocument = { diagnostic = vim.NIL } },
          settings = { run = "onSave" },
        })
      end

      vim.lsp.enable(servers)
      if vim.fn.executable("biome") == 1 then vim.lsp.enable("biome") end
      if vim.fn.executable("oxlint") == 1 then vim.lsp.enable("oxlint") end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local opts = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gr",         vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi",         vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>fm", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
        end,
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- conform: 저장 시 포맷
  --   JS/TS/JSON/HTML/CSS → biome
  --   Rust → rustfmt
  -- --------------------------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        javascript      = { "biome" },
        typescript      = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json            = { "biome" },
        html            = { "biome" },
        css             = { "biome" },
        rust            = { "rustfmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
})

-- ============================================================================
-- 6. 플러그인 즉시 초기화 + 검색 키
-- ============================================================================
require("nvim-autopairs").setup()

require("toggleterm").setup({
  size = 12,
  open_mapping = [[<C-t>]],
  direction = "horizontal",
  start_in_insert = true,
})

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep,  { desc = "Live grep" })

-- ============================================================================
-- 7. oil 키맵 (파일 탐색)
-- ============================================================================
-- <Space>e  현재 파일의 디렉토리를 oil로 연다
-- -         oil 권장 관례: 상위 폴더 (oil 버퍼가 아닐 때는 현재 파일 기준 상위)
-- ============================================================================
vim.keymap.set("n", "<leader>e", function()
  require("oil").open()
end, { desc = "Open oil (file explorer)" })

vim.keymap.set("n", "-", function()
  require("oil").open()
end, { desc = "Open oil (parent-friendly)" })

-- ============================================================================
-- 8. 창 이동 / 크기 (OS 분기)
-- ============================================================================
-- 공통: Ctrl + hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "창 ←" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "창 ↓" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "창 ↑" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "창 →" })

-- 공통: 크기
vim.keymap.set("n", "+",         "<C-w>+", { desc = "높이 +" })
vim.keymap.set("n", "-",         "<C-w>-", { desc = "높이 -" }) -- oil의 - 와 겹침 주의
vim.keymap.set("n", "<leader>+", "<C-w>>", { desc = "너비 +" })
vim.keymap.set("n", "<leader>-", "<C-w><", { desc = "너비 -" })

-- 참고:
--   위에서 normal 모드 "-" 를 oil 열기로 매핑했기 때문에
--   창 높이 관련 "-" 는 가려집니다.
--   높이 관련은 아래 대안을 쓰거나, oil 매핑을 다른 키로 바꾸세요.
--   대안 예: <C--> 또는 <leader>_
vim.keymap.set("n", "<leader>_", "<C-w>-", { desc = "높이 - (대안)" })

if is_windows or is_linux then
  -- WezTerm(Windows)은 Alt+Shift+hjkl 을 팬 이동에 쓰므로
  -- 일반 Alt+hjkl 은 Neovim으로 전달됨
  vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "창 ← Alt" })
  vim.keymap.set("n", "<A-j>", "<C-w>j", { desc = "창 ↓ Alt" })
  vim.keymap.set("n", "<A-k>", "<C-w>k", { desc = "창 ↑ Alt" })
  vim.keymap.set("n", "<A-l>", "<C-w>l", { desc = "창 → Alt" })
end
-- macOS: Option 키 충돌 때문에 Ctrl만 사용.
-- WezTerm에서 Option을 Meta로 쓰려면 wezterm.lua:
--   config.send_composed_key_when_left_alt_is_pressed = false
--   config.send_composed_key_when_right_alt_is_pressed = false

-- ============================================================================
-- 9. 집중 모드
-- ============================================================================
vim.keymap.set("n", "<leader>n", ":NoNeckPain<CR>", {
  silent = true,
  desc = "No Neck Pain",
})

-- ============================================================================
-- 10. oxlint 수동 실행
-- ============================================================================
vim.api.nvim_create_user_command("OxcLint", function()
  if vim.fn.executable("oxlint") == 1 then
    local file = vim.fn.expand("%")
    vim.fn.jobstart({ "oxlint", file }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.notify(table.concat(data, "\n"))
        end
      end,
    })
  else
    notify("oxlint이 설치되지 않았습니다. (npm install -g oxlint)", vim.log.levels.WARN)
  end
end, {})

notify("✅ Vim-only 설정 로드 완료 (oil + Trouble + Neogit)", vim.log.levels.INFO)