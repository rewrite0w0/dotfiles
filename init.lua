-- ==========================================================================
-- 1. 기본 옵션 (플러그인 로드 전에 설정하는 것이 좋습니다)
-- ==========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 윈도우 11 PowerShell 설정 (필수: 속도 및 호환성)
vim.opt.shell = "powershell.exe"
vim.opt.shellcmdflag = "-NoProfile -NoLogo -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
vim.opt.shellpipe = "| Out-File -Encoding UTF8"
vim.opt.shellredir = "| Out-File -Encoding UTF8"

-- UI 및 동작 설정
vim.opt.termguicolors = true   -- 트루컬러 지원
vim.opt.number = true          -- 줄 번호
vim.opt.relativenumber = true  -- 상대 줄 번호 (이동 시 편함)
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true       -- 탭을 스페이스로 변환
vim.opt.wrap = false           -- 줄 바꿈 안 함 (취향따라 true로 변경)
vim.opt.scrolloff = 8          -- 커서 위아래 여백 확보
vim.opt.signcolumn = "yes"     -- 깃 사인 등이 올 때 흔들림 방지
vim.opt.updatetime = 250       -- 반응 속도
vim.opt.clipboard = "unnamedplus" -- 윈도우 클립보드와 연동 (Ctrl+V 가능)

-- ==========================================================================
-- 2. Lazy.nvim 부트스트래핑
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/site/pack/lazy/start/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath,
    })
    print("Installing lazy.nvim...")
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 3. 플러그인 목록
-- ==========================================================================
require("lazy").setup({
    -- [테마] TokyoNight
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight-storm]])
        end,
    },

    -- [탐색] Telescope + UI Select (추천)
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { 
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim" -- 코드 액션 등을 예쁘게
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                extensions = {
                    ["ui-select"] = { require("telescope.themes").get_dropdown {} }
                }
            })
            telescope.load_extension("ui-select")
        end
    },

    -- [구문 강조] Treesitter
    { 
        "nvim-treesitter/nvim-treesitter", 
        build = ":TSUpdate", 
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            -- [중요] 컴파일러 강제 설정 (Windows 오류 해결 핵심)
            require("nvim-treesitter.install").compilers = { "zig" }
    
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "rust", "lua", "javascript", "typescript", "tsx", "json", "html", "css", "bash", "markdown", "markdown_inline" },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
    

   
    -- [파일 탐색기] Oil.nvim (강력 추천)
    { 
        "stevearc/oil.nvim", 
        config = true, 
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } } 
    },

    -- [Git] GitSigns + Neogit
    { "lewis6991/gitsigns.nvim", event = "BufReadPre", config = true },
    { 
        "NeogitOrg/neogit", 
        dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" }, 
        cmd = "Neogit",
        config = true
    },

    -- [상태바] Lualine
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },

    -- [편의성] Auto Pairs, Surround, Comment
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "echasnovski/mini.surround", config = true },
    { "numToStr/Comment.nvim", config = true },
    { "echasnovski/mini.indentscope", config = true, event = "BufReadPre" }, -- 들여쓰기 가이드

    -- [편의성] Todo Comments (추천!) - TODO, FIXME 등을 하이라이팅
    { 
        "folke/todo-comments.nvim", 
        dependencies = { "nvim-lua/plenary.nvim" }, 
        event = "BufReadPre",
        config = true 
    },

    -- [가이드] Which Key
    { "folke/which-key.nvim", config = true },

    -- [이동] Flash
    { 
        "folke/flash.nvim", 
        event = "VeryLazy", 
        opts = {}, 
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        },
    },

    -- [에러 목록] Trouble
    { 
        "folke/trouble.nvim", 
        config = true,
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        },
    },

    -- [UI] No Neck Pain (중앙 정렬)
    { "shortcuts/no-neck-pain.nvim", cmd = "NoNeckPain", config = true },

    -- [자동완성] CMP
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- [LSP] Config & Mason
    { 
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        }
    },

    -- [Formatting] Conform
    { "stevearc/conform.nvim", event = "BufWritePre" },

    -- [터미널] Toggleterm
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 15,
                open_mapping = [[<C-t>]],
                direction = "horizontal",
                -- 윈도우 PowerShell 설정
                shell = "powershell.exe",
            })
        end,
    },
    
    -- 업데이트 확인
    checker = { enabled = true, notify = false },
})

-- ==========================================================================
-- 4. LSP 설정 (여기가 제일 중요합니다)
-- ==========================================================================
-- ==========================================================================
-- 4. LSP 설정 (수정됨: handlers를 setup 안으로 통합)
-- ==========================================================================
require("mason").setup()

local lspconfig = require("lspconfig")
-- cmp-nvim-lsp가 설치되어 있다면 capabilities 가져오기, 아니면 기본값
local capabilities = vim.lsp.protocol.make_client_capabilities()
if pcall(require, "cmp_nvim_lsp") then
    capabilities = require("cmp_nvim_lsp").default_capabilities()
end

require("mason-lspconfig").setup({
    ensure_installed = { "pyright", "ruff", "rust_analyzer", "biome" },
    automatic_installation = true,
    
    -- 여기서 핸들러를 정의합니다 (setup_handlers 대신 사용)
    handlers = {
        -- 1. 기본 핸들러 (모든 서버에 공통 적용)
        function(server_name)
            lspconfig[server_name].setup({
                capabilities = capabilities,
            })
        end,

        -- 2. Ruff 설정 (Hover 끄기)
        ["ruff"] = function()
            lspconfig.ruff.setup({
                capabilities = capabilities,
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                end,
            })
        end,

        -- 3. Rust Analyzer 설정 (Clippy)
        ["rust_analyzer"] = function()
            lspconfig.rust_analyzer.setup({
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        check = { command = "clippy" },
                    },
                },
            })
        end,
    }
})

-- ==========================================================================
-- 5. Formatting 설정 (Conform)
-- ==========================================================================
require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_format", "ruff_fix" },
        javascript = { "biome" },
        typescript = { "biome" },
        json = { "biome" },
        rust = { "rustfmt" },
    },
    format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
    },
})

-- ==========================================================================
-- 6. 키맵 설정
-- ==========================================================================
local builtin = require("telescope.builtin")

-- Telescope
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })

-- Git
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })

-- Window Navigation (Alt + hjkl)
vim.keymap.set("n", "<A-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<A-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<A-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<A-l>", "<C-w>l", { noremap = true })

-- Terminal Window Navigation (터미널 모드에서 나갈 때)
vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], { noremap = true })
vim.keymap.set("t", "<A-j>", [[<C-\><C-n><C-w>j]], { noremap = true })
vim.keymap.set("t", "<A-k>", [[<C-\><C-n><C-w>k]], { noremap = true })
vim.keymap.set("t", "<A-l>", [[<C-\><C-n><C-w>l]], { noremap = true })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- 기타 편의
vim.keymap.set("n", "<leader>n", "<cmd>NoNeckPain<cr>", { desc = "Toggle NoNeckPain" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File Explorer" }) -- Oil 단축키 하나 더 추가
