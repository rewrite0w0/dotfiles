-- ==========================================================================
-- 1. 기본 옵션
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
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.clipboard = "unnamedplus"

-- UI 및 동작 설정
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- 줄 바꿈 관련 세트 (이 부분이 추가/수정되었습니다)
vim.opt.wrap = true            -- 줄 바꿈 사용
vim.opt.linebreak = true       -- 단어 단위로 줄 바꿈 (단어 중간 끊김 방지)
vim.opt.breakindent = true     -- 줄 바꿈된 줄도 들여쓰기 유지
vim.opt.showbreak = "↳ "       -- 줄 바꿈된 곳 앞에 표시할 기호 (취향껏 변경 가능)

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.clipboard = "unnamedplus"

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
-- 3. 플러그인 목록
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

    -- [탐색]
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

    -- [구문 강조] Treesitter (React, HTML, CSS, JSON 포함)
    { 
        "nvim-treesitter/nvim-treesitter", 
        build = ":TSUpdate", 
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvim-treesitter.install").compilers = { "zig" }
    
            require("nvim-treesitter.configs").setup({
                ensure_installed = { 
                    "rust", "lua", "javascript", "typescript", "tsx", 
                    "json", "html", "css", "markdown", "markdown_inline" 
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

    -- [Git]
    { "lewis6991/gitsigns.nvim", event = "BufReadPre", config = true },
    { 
        "NeogitOrg/neogit", 
        dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" }, 
        cmd = "Neogit",
        config = true
    },

    -- [상태바]
    { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" }, config = true },

    -- [편의성]
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
    { "echasnovski/mini.surround", config = true },
    { "numToStr/Comment.nvim", config = true },
    { "echasnovski/mini.indentscope", config = true, event = "BufReadPre" },
    { 
        "folke/todo-comments.nvim", 
        dependencies = { "nvim-lua/plenary.nvim" }, 
        event = "BufReadPre",
        config = true 
    },
    { "folke/which-key.nvim", config = true },
    { 
        "folke/flash.nvim", 
        event = "VeryLazy", 
        opts = {}, 
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
        },
    },

    -- [에러 목록]
    { 
        "folke/trouble.nvim", 
        config = true,
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
        },
    },

    -- [UI]
    { "shortcuts/no-neck-pain.nvim", cmd = "NoNeckPain", config = true },

    -- [자동완성]
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

    -- [LSP]
    { 
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        }
    },

    -- [Formatting]
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
    -- React Native는 주로 vtsls나 ts_ls(구 tsserver)를 사용하며, 
    -- Biome은 포맷팅과 린팅을 담당합니다.
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

        -- TS/JS/React/React Native를 위한 설정
        ["ts_ls"] = function()
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
                -- 프로젝트 상황에 따라 추가 설정 가능
            })
        end,
    }
})

-- ==========================================================================
-- 5. Formatting 설정 (Conform)
-- ==========================================================================
require("conform").setup({
    formatters_by_ft = {
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        html = { "biome" }, -- Biome 혹은 필요시 다른 포맷터 사용 가능
        css = { "biome" },
        rust = { "rustfmt" },
    },
    format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
    },
})

-- ==========================================================================
-- 6. 키맵 설정 (동일)
-- ==========================================================================
local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })

vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })

vim.keymap.set("n", "<A-h>", "<C-w>h", { noremap = true })
vim.keymap.set("n", "<A-j>", "<C-w>j", { noremap = true })
vim.keymap.set("n", "<A-k>", "<C-w>k", { noremap = true })
vim.keymap.set("n", "<A-l>", "<C-w>l", { noremap = true })

vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], { noremap = true })
vim.keymap.set("t", "<A-j>", [[<C-\><C-n><C-w>j]], { noremap = true })
vim.keymap.set("t", "<A-k>", [[<C-\><C-n><C-w>k]], { noremap = true })
vim.keymap.set("t", "<A-l>", [[<C-\><C-n><C-w>l]], { noremap = true })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>n", "<cmd>NoNeckPain<cr>", { desc = "Toggle NoNeckPain" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File Explorer" })
