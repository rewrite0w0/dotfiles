-- =============================================
-- Neovim 설정 파일 (init.lua)
-- =============================================
-- 
-- 📂 이 파일을 아래 경로에 저장하세요:
-- 
--   macOS / Linux:
--     ~/.config/nvim/init.lua
--     mkdir -p ~/.config/nvim
--     cp init.lua ~/.config/nvim/
-- 
--   Windows (PowerShell):
--     $PROFILE\nvim\init.lua
--     또는 %APPDATA%\nvim\init.lua
--     New-Item -Path $env:APPDATA\nvim -ItemType Directory -Force
-- 
-- 저장 후 nvim을 재시작하면 자동으로 적용됩니다!
-- =============================================

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_mac = vim.fn.has("macunix") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_mac

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Neovim Setup" })
end

-- =============================================
-- ⚙️ 필수 도구 설치 (먼저 설치해야 함!)
-- =============================================
-- 이 부분에서 필수 도구들을 체크합니다.
-- 누락된 도구가 있으면 아래 명령어를 터미널에서 실행하세요:
-- 
-- 📦 설치 명령어:
-- 
--   macOS (Homebrew):
--     brew install git node biome oxlint
-- 
--   Windows (npm):
--     npm install -g @biomejs/biome
--     npm install -g oxlint
-- 
--   Linux - Fedora:
--     sudo dnf install -y git nodejs npm
--     npm install -g @biomejs/biome oxlint
-- 
--   Linux - Ubuntu/Debian:
--     sudo apt update && sudo apt install -y git nodejs npm
--     npm install -g @biomejs/biome oxlint
-- =============================================

local required_tools = {
    { name = "git",   cmd = "git",   important = true },
    { name = "node",  cmd = "node",  important = true },
    { name = "npm",   cmd = "npm",   important = true },
    { name = "biome", cmd = "biome", important = true },
    { name = "oxlint",cmd = "oxlint",important = false }, -- oxc 린팅 CLI
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
        notify(" • " .. m.name .. (m.important and " (필수)" or ""), 
               m.important and vim.log.levels.ERROR or vim.log.levels.WARN)
    end
end

-- =============================================
-- 2. lazy.nvim 설치 (플러그인 매니저)
-- =============================================
-- lazy.nvim은 자동으로 설치됩니다.
-- 처음 실행 시 플러그인들도 자동 다운로드됩니다.
-- 
-- Neovim을 열고 다음 커맨드로 수동 설치도 가능:
--   :Lazy sync
-- =============================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    notify("lazy.nvim 설치 중...")
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================
-- 3. 기본 설정
-- =============================================
-- 탭, 들여쓰기, 색상, 줄 번호 등의 기본 설정
-- =============================================

vim.g.mapleader = " "              -- 리더 키를 스페이스로 설정
vim.g.maplocalleader = "\\"

vim.opt.termguicolors = true       -- 256색 지원
vim.opt.tabstop = 2                -- 탭 크기
vim.opt.shiftwidth = 2             -- 들여쓰기 크기
vim.opt.expandtab = true           -- 탭을 스페이스로 변환
vim.opt.smartindent = true         -- 스마트 들여쓰기
vim.opt.number = true              -- 줄 번호
vim.opt.relativenumber = true      -- 상대 줄 번호
vim.opt.cursorline = true          -- 현재 줄 강조

-- Windows에서 PowerShell 설정
if is_windows then
    vim.opt.shell = "powershell"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
end

-- =============================================
-- 4. 플러그인 설정 (자동 설치)
-- =============================================
-- lazy.nvim이 자동으로 플러그인을 관리합니다.
-- 처음 실행 시 모든 플러그인이 자동으로 설치됩니다.
-- 
-- 주요 플러그인:
--   • tokyonight: 컬러 테마
--   • telescope: 파일/텍스트 검색
--   • treesitter: 문법 하이라이팅 및 파싱
--   • toggleterm: 터미널 토글
--   • nvim-cmp: 자동완성
--   • nvim-lspconfig: LSP 설정 (Biome + oxlint)
--   • nvim-autopairs: 괄호 자동 완성
--   • vim-gitgutter: Git diff 표시
--   • nerdtree: 파일 트리
--   • vim-devicons: 파일 아이콘
-- =============================================

require("lazy").setup({
    { "folke/tokyonight.nvim", lazy = false, priority = 1000,
      config = function() vim.cmd("colorscheme tokyonight-storm") end },

    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope.nvim", tag = "0.1.8", dependencies = { "nvim-lua/plenary.nvim" } },

    -- Treesitter: 문법 강조 및 구조 분석
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "javascript", "typescript", "tsx", "html", "css", "json", "rust", "vim", "vimdoc" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    "akinsho/toggleterm.nvim",
    "windwp/nvim-autopairs",
    "airblade/vim-gitgutter",
    { "preservim/nerdtree" },
    { "ryanoasis/vim-devicons" },

    -- nvim-cmp: 자동 완성 엔진
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
                snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                mapping = {
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                },
            })
        end,
    },

    -- nvim-lspconfig: LSP 설정 (Biome + oxlint)
    {
        "neovim/nvim-lspconfig",
        config = function()
            -- =============================================
            -- 📦 LSP 서버 설치 (선택사항)
            -- =============================================
            -- LSP 서버는 자동으로 감지되지만, 설치되지 않으면 작동하지 않습니다.
            -- 필요에 따라 아래 명령어로 설치하세요:
            -- 
            -- npm으로 설치:
            --   npm install -g typescript typescript-language-server
            --   npm install -g vscode-langservers-extracted  (html, css, json)
            -- 
            -- Rust (선택):
            --   rustup component add rust-analyzer
            -- 
            -- Lua (선택):
            --   npm install -g lua-language-server
            -- =============================================

            local servers = {
                "ts_ls",           -- TypeScript/JavaScript
                "html",            -- HTML
                "cssls",           -- CSS
                "jsonls",          -- JSON
                "rust_analyzer",   -- Rust
            }

            -- 기본 LSP 서버 설정
            for _, server in ipairs(servers) do
                vim.lsp.config(server, {})
            end

            -- Biome 설정 (포매팅 + 린팅 통합)
            if vim.fn.executable("biome") == 1 then
                vim.lsp.config("biome", { cmd = { "biome", "lsp-proxy" } })
            end

            -- oxlint 설정 (추가 고성능 린팅)
            if vim.fn.executable("oxlint") == 1 then
                vim.lsp.config("oxlint", {
                    capabilities = { textDocument = { diagnostic = vim.NIL } },
                    settings = { run = "onSave" },
                })
            end

            -- Neovim 0.12 호환: 서버 활성화
            vim.lsp.enable(servers)
            if vim.fn.executable("biome") == 1 then vim.lsp.enable("biome") end
            if vim.fn.executable("oxlint") == 1 then vim.lsp.enable("oxlint") end

            -- LspAttach 이벤트 - 키매핑 및 기능 설정
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
                callback = function(ev)
                    local buf = ev.buf
                    local opts = { buffer = buf, silent = true }

                    -- 네비게이션
                    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
                    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                    
                    -- 정보 및 수정
                    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
                    
                    -- 포매팅 (Biome)
                    vim.keymap.set("n", "<leader>fm", function() vim.lsp.buf.format({ async = true }) end, opts)
                end,
            })
        end,
    }, 
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
        formatters_by_ft = {
            javascript = { "biome" },
            typescript = { "biome" },
            javascriptreact = { "biome" },
            typescriptreact = { "biome" },
            json = { "biome" },
            html = { "biome" },
            css = { "biome" },
            rust = { "rustfmt" },
        },
        format_on_save = {
            timeout_ms = 500,
            lsp_fallback = true,
        },
    },
},






-- 끝라인
})

-- =============================================
-- 5. 추가 설정 및 키매핑
-- =============================================
-- 플러그인 초기화 및 커스텀 단축키
-- 
-- 주요 단축키:
--   <Space>ff : 파일 찾기 (Telescope)
--   <Space>fg : 텍스트 검색 (Telescope)
--   <Ctrl>b  : 파일 트리 토글 (NERDTree)
--   <Ctrl>t  : 터미널 토글
--   <Space>fm: 코드 포매팅 (Biome)
--   :OxcLint : oxlint 린팅 실행
-- 
-- LSP 단축키:
--   gd       : 정의로 이동
--   gr       : 참조 찾기
--   gi       : 구현 찾기
--   K        : 호버 정보
--   <leader>rn : 이름 변경
--   <leader>ca : 코드 액션
-- =============================================

-- nvim-autopairs: 괄호 자동 완성
require("nvim-autopairs").setup()

-- toggleterm: 터미널 토글
require("toggleterm").setup({
    size = 12,
    open_mapping = [[<C-t>]],
    direction = "horizontal"
})

-- telescope: 파일/텍스트 검색
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })

-- NERDTree: 파일 브라우저
vim.keymap.set("n", "<C-b>", ":NERDTreeToggle<CR>:NERDTreeRefreshRoot<CR>", { silent = true })

-- =============================================
-- Biome 자동 포매팅 (저장 시)
-- =============================================
-- 아래 확장자 파일 저장 시 자동으로 Biome으로 포매팅됩니다.
-- Biome이 설치되어 있어야 합니다: npm install -g @biomejs/biome
-- =============================================

vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.html", "*.css", "*.json" },
    callback = function()
        if vim.fn.executable("biome") == 1 then
            vim.lsp.buf.format({ async = false })
        end
    end,
})

-- =============================================
-- oxlint 수동 린팅 커맨드
-- =============================================
-- Neovim에서 :OxcLint 커맨드로 현재 파일을 oxlint로 검사합니다.
-- oxlint이 설치되어 있어야 합니다: npm install -g oxlint
-- =============================================

vim.api.nvim_create_user_command("OxcLint", function()
    if vim.fn.executable("oxlint") == 1 then
        local file = vim.fn.expand("%")
        vim.fn.jobstart({ "oxlint", file }, {
            stdout_buffered = true,
            on_stdout = function(_, data)
                if data then vim.notify(table.concat(data, "\n")) end
            end
        })
    else
        notify("oxlint이 설치되지 않았습니다. (npm install -g oxlint)", vim.log.levels.WARN)
    end
end, {})

-- 설정 로드 완료
notify("✅ Neovim 설정 로드 완료! (Biome + oxlint + TS/JS/Rust)", vim.log.levels.INFO)