-- ==========================================================================
-- 1. 기본 옵션 (Windows 11 PowerShell & 기본 UI)
-- ==========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 윈도우 11 PowerShell 설정
vim.opt.shell = "powershell.exe"
vim.opt.shellcmdflag = "-NoProfile -NoLogo -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
vim.opt.shellpipe = "| Out-File -Encoding UTF8"
vim.opt.shellredir = "| Out-File -Encoding UTF8"

-- UI 및 동작 설정
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.clipboard = "unnamedplus"

-- 줄 바꿈 설정
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = "↳ "

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
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- 3. 플러그인 목록 (담백한 핵심 구성)
-- ==========================================================================
require("lazy").setup({
    -- [테마]
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight-storm]])
        end,
    },

    -- [탐색] Telescope
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { 
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-ui-select.nvim"
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
            require("nvim-treesitter.configs").setup({
                ensure_installed = { 
                    "rust", "lua", "javascript", "typescript", "tsx", "html", "css", "json"
                },
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },

    -- [파일 탐색기]
    { 
        "stevearc/oil.nvim", 
        config = true, 
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent directory" } } 
    },

    -- [Git 표시]
    { "lewis6991/gitsigns.nvim", event = "BufReadPre", config = true },

    -- [상태바]
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },

    -- [코딩 편의성]
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "echasnovski/mini.surround", config = true },
    { "numToStr/Comment.nvim", config = true },
    { "folke/which-key.nvim", config = true },

    -- [자동완성 엔진]
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
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

    -- [LSP 기본 백본]
    { 
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        }
    },

    -- [포맷터 관리]
    { "stevearc/conform.nvim", event = "BufWritePre" },

   -- [터미널]
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 15,
                open_mapping = [[<C-t>]],
                direction = "horizontal",
                shell = "powershell.exe",
            })
        end,
    },
		}, {
		rocks = { enabled = false },
})

-- ==========================================================================
-- 4. LSP 설정 (JS, TS, Rust, HTML, CSS, JSON)
-- ==========================================================================
require("mason").setup()

local lspconfig = require("lspconfig")
local capabilities = vim.lsp.protocol.make_client_capabilities()
if pcall(require, "cmp_nvim_lsp") then
    capabilities = require("cmp_nvim_lsp").default_capabilities()
end

require("mason-lspconfig").setup({
    ensure_installed = { 
        "rust_analyzer", "biome", "ts_ls", "html", "cssls", "jsonls"
    },
    automatic_installation = true,
    
    handlers = {
        function(server_name)
            lspconfig[server_name].setup({
                capabilities = capabilities,
            })
        end,

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

        ["ts_ls"] = function()
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
            })
        end,
    }
})

-- ==========================================================================
-- 5. Formatting 설정 (Conform - 자동 포맷팅)
-- ==========================================================================
require("conform").setup({
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
        timeout_ms = 1000,
        lsp_fallback = true,
    },
})

-- ==========================================================================
-- 6. 키맵 설정
-- ==========================================================================
local builtin = require("telescope.builtin")

-- Telescope 검색
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })

-- 창 이동 (Alt + h, j, k, l)
vim.keymap.set("n", "<A-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<A-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<A-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<A-l>", "<C-w>l", { noremap = true })

-- 터미널 모드 창 이동 및 탈출
vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], { noremap = true })
vim.keymap.set("t", "<A-j>", [[<C-\><C-n><C-w>j]], { noremap = true })
vim.keymap.set("t", "<A-k>", [[<C-\><C-n><C-w>k]], { noremap = true })
vim.keymap.set("t", "<A-l>", [[<C-\><C-n><C-w>l]], { noremap = true })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Oil.nvim 파일 탐색기 연동
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File Explorer" })