-- =============================================
-- 1. 플랫폼 감지 & 도구 체크
-- =============================================
local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_linux = vim.fn.has("unix") == 1 and not vim.fn.has("macunix") == 1

local distro = "unknown"
if is_linux then
    local f = io.open("/etc/os-release", "r")
    if f then
        local content = f:read("*all")
        f:close()
        if content:match("fedora") or content:match("Fedora") then distro = "fedora"
        elseif content:match("debian") or content:match("ubuntu") then distro = "debian" end
    end
end

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Neovim Setup" })
end

-- 필수 도구 체크
local required_tools = {
    { name = "git",       cmd = "git",      important = true },
    { name = "node",      cmd = "node",     important = true },
    { name = "npm",       cmd = "npm",      important = true },
    { name = "rustc",     cmd = "rustc",    important = false },
    { name = "prettier",  cmd = "prettier", important = true },
}

local missing = {}
for _, tool in ipairs(required_tools) do
    if vim.fn.executable(tool.cmd) == 0 then
        table.insert(missing, tool)
    end
end

if #missing > 0 then
    notify("⚠️  일부 도구가 설치되지 않았습니다:", vim.log.levels.WARN)
    for _, m in ipairs(missing) do
        notify("   • " .. m.name .. (m.important and " (필수)" or ""), 
               m.important and vim.log.levels.ERROR or vim.log.levels.WARN)
    end

    notify("설치 명령어:", vim.log.levels.INFO)
    if is_windows then
        notify("scoop install git nodejs", vim.log.levels.INFO)
        notify("scoop install rustup", vim.log.levels.INFO)
        notify("npm install -g prettier", vim.log.levels.INFO)
    elseif distro == "fedora" then
        notify("sudo dnf install -y git nodejs npm rustup", vim.log.levels.INFO)
        notify("npm install -g prettier", vim.log.levels.INFO)
    elseif distro == "debian" then
        notify("sudo apt update && sudo apt install -y git nodejs npm curl", vim.log.levels.INFO)
        notify("curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh", vim.log.levels.INFO)
        notify("npm install -g prettier", vim.log.levels.INFO)
    end
end

-- =============================================
-- 2. lazy.nvim
-- =============================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    notify("lazy.nvim 설치 중...")
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================
-- 3. 기본 설정
-- =============================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.termguicolors = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

if is_windows then
    vim.opt.shell = "powershell"
    vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
else
    vim.opt.shell = "bash"
end

-- =============================================
-- 4. 플러그인 설정
-- =============================================
require("lazy").setup({
    { "folke/tokyonight.nvim", lazy = false, priority = 1000,
      config = function() vim.cmd("colorscheme tokyonight-storm") end },

    "nvim-lua/plenary.nvim",

    { "nvim-telescope/telescope.nvim", tag = "0.1.8", dependencies = { "nvim-lua/plenary.nvim" } },

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",   -- 안정적으로 가려면 master, 최신 쓰려면 제거
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua", "javascript", "typescript", "tsx",
					"html", "css", "json", "rust", "vim", "vimdoc"
				},
				highlight = { enable = true },
				indent = { enable = true },
				-- incremental_selection = { enable = true },  -- 필요하면 추가
			})
		end,
	},

    "akinsho/toggleterm.nvim",
    "windwp/nvim-autopairs",
    "airblade/vim-gitgutter",
    { "preservim/nerdtree" },
    { "ryanoasis/vim-devicons" },

    { 'prettier/vim-prettier', ft = { "javascript", "typescript", "css", "json", "html", "javascriptreact", "typescriptreact" } },

    -- nvim-cmp
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

	{
    "neovim/nvim-lspconfig",
    config = function()
        local servers = {
            "ts_ls",
            "html",
            "cssls",
            "jsonls",
            "rust_analyzer",
            -- 필요하면 더 추가: "lua_ls", "pyright" 등
        }

        for _, server in ipairs(servers) do
            vim.lsp.enable(server)
        end

        -- 공통 on_attach 설정 (키매핑 등)
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                -- 기타 원하는 키매핑 추가
            end,
        })
    end,
	},
	
	
})

-- =============================================
-- 5. 추가 설정 및 키매핑
-- =============================================
require("nvim-autopairs").setup()
require("toggleterm").setup({ size = 12, open_mapping = [[<C-t>]], direction = "horizontal" })

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<C-b>", ":NERDTreeToggle<CR>:NERDTreeRefreshRoot<CR>", { silent = true })

-- Prettier 자동 실행
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.html", "*.css", "*.json" },
    command = "Prettier",
})

notify("Neovim 설정 로드 완료! (JS/TS/React/Rust)", vim.log.levels.INFO)