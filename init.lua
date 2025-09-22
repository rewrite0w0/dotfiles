-- lazy.nvim 부트스트래핑
local lazypath = vim.fn.stdpath("data") .. "/site/pack/lazy/start/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
    print("Installing lazy.nvim, please close and reopen Neovim...")
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 플러그인 설정
require("lazy").setup({
    -- 색상 테마
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight-storm]])
        end,
    },

    -- Lua 유틸리티
    { "nvim-lua/plenary.nvim" },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = "Telescope",
    },

    -- Treesitter
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", event = { "BufReadPre", "BufNewFile" } },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        event = "BufReadPre",
        config = function()
            require("gitsigns").setup()
        end,
    },

    -- Git UI
    { "tpope/vim-fugitive", cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite" } },
    { "NeogitOrg/neogit", dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" } },
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    },

    -- 상태바 (Airline → Lualine)
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup()
        end,
    },

    -- 파일 탐색기 (NERDTree → nvim-tree)
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup()
            vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
        end,
    },

    -- 자동 괄호
    { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

    -- Completion
    {
        "hrsh7th/nvim-cmp",
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
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require("luasnip").lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- LSP 관리
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim", config = true },
    { "williamboman/mason-lspconfig.nvim" },

    -- Lint / Format
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("lint").linters_by_ft = {
                python = { "ruff" },
                javascript = { "biomejs" },
                typescript = { "biomejs" },
                javascriptreact = { "biomejs" },
                typescriptreact = { "biomejs" },
                json = { "biomejs" },
                html = { "biomejs" },
                css = { "biomejs" },
                rust = { "clippy" },
            }
            
            -- 더 자주 린팅 실행
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                callback = function()
                    -- 현재 버퍼의 파일 타입이 지원되는지 확인
                    local ft = vim.bo.filetype
                    if require("lint").linters_by_ft[ft] then
                        require("lint").try_lint()
                    end
                end,
            })
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        config = function()
            -- conform 설정은 LSP 설정 이후로 이동
        end,
    },

    -- 터미널
    {
        "akinsho/toggleterm.nvim",
        -- version = "*",
        version = "v2.13.0",
        config = function()
            require("toggleterm").setup({
                size = 10,
                open_mapping = [[<C-t>]],
                direction = "horizontal",
                shade_terminals = true,
                persist_mode = true,
                shell = "powershell.exe -NoProfile -ExecutionPolicy RemoteSigned", -- 명시적으로 powershell 지정
            })
        end,
    },

    -- automatically check for plugin updates
    checker = { enabled = true },
})

-- Mason으로 LSP 자동 설치
require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = { "pyright", "ruff", "rust_analyzer" },
    automatic_installation = true,
})

-- LSP 설정 (새로운 vim.lsp.config 사용)
-- Pyright (타입체킹)
vim.lsp.config("pyright", {})

-- Ruff LSP (lint & format)
vim.lsp.config("ruff", {
  on_attach = function(client, bufnr)
    client.server_capabilities.hoverProvider = false -- Ruff는 hover 필요 없음
  end,
})

-- Rust Analyzer
vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
})

-- conform.nvim에서 ruff_format 사용하도록 수정
require("conform").setup({
    formatters_by_ft = {
        python = { "ruff_format", "ruff_fix" },
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        html = { "biome" },
        css = { "biome" },
        rust = { "rustfmt" },
    },
    formatters = {
        ruff_fix = {
            command = "ruff",
            args = { "check", "--fix", "--stdin-filename", "$FILENAME", "-" },
            stdin = true,
        },
        ruff_format = {
            command = "ruff",
            args = { "format", "--stdin-filename", "$FILENAME", "-" },
            stdin = true,
        },
        rustfmt = {
            command = "rustfmt",
            args = { "--edition=2021" },
            stdin = true,
        },
    },
    format_on_save = { 
        timeout_ms = 1000, 
        lsp_fallback = true,
        quiet = false, -- 에러 메시지 표시
    },
})

-- 옵션: Neovim 기본 설정
vim.opt.termguicolors = true
vim.cmd("syntax enable")
vim.opt.autoindent = true
vim.opt.cindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.title = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.shell = "powershell"
vim.opt.shellcmdflag = "-NoProfile -NoLogo -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""
vim.opt.shellpipe = "| Out-File -Encoding UTF8"
vim.opt.shellredir = "| Out-File -Encoding UTF8"

-- Telescope 단축키
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

-- 창 이동 (Alt + 방향키)
vim.api.nvim_set_keymap("t", "<A-h>", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-j>", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-k>", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-l>", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-h>", "<C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-j>", "<C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-k>", "<C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<A-l>", "<C-w>l", { noremap = true, silent = true })

-- Lazygit 실행
vim.api.nvim_set_keymap("n", "<Leader>gg", ":ToggleTerm direction=horizontal cmd=lazygit<CR>", { noremap = true, silent = true })