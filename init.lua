-- =============================================
-- Neovim 설정 파일 (init.lua)
-- =============================================
--
-- 📂 저장 경로:
--   macOS / Linux : ~/.config/nvim/init.lua
--   Windows       : %APPDATA%\nvim\init.lua
-- =============================================

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_mac     = vim.fn.has("macunix") == 1
local is_linux   = vim.fn.has("unix") == 1 and not is_mac

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Neovim Setup" })
end

-- =============================================
-- 1. 필수 도구 체크
-- =============================================
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
    notify(" • " .. m.name .. (m.important and " (필수)" or ""),
           m.important and vim.log.levels.ERROR or vim.log.levels.WARN)
  end
end

-- =============================================
-- 2. lazy.nvim
-- =============================================
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

-- =============================================
-- 3. 기본 설정
-- =============================================
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

vim.opt.termguicolors  = true
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.smartindent    = true
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.cursorline     = true
vim.opt.hidden         = true

-- =============================================
-- 4. OS별 셸 설정
-- =============================================
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

-- =============================================
-- 5. 플러그인
-- =============================================
require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-storm")
    end,
  },

  "nvim-lua/plenary.nvim",
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

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

  "akinsho/toggleterm.nvim",
  "windwp/nvim-autopairs",
  "airblade/vim-gitgutter",
  { "preservim/nerdtree" },
  { "ryanoasis/vim-devicons" },

  -- No Neck Pain
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

  -- Trouble: LSP 진단 / 참조 / Quickfix 리스트
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / References" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List" },
    },
  },

  -- Neogit + Diffview (Git UI)
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

  -- LSP
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

  -- conform
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

-- =============================================
-- 6. 플러그인 초기화
-- =============================================
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

-- =============================================
-- 7. OS별 창 이동 / 크기 조절
-- =============================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "왼쪽 창" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "아래 창" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "위 창" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "오른쪽 창" })

vim.keymap.set("n", "+",         "<C-w>+", { desc = "높이 확대" })
vim.keymap.set("n", "-",         "<C-w>-", { desc = "높이 축소" })
vim.keymap.set("n", "<leader>+", "<C-w>>", { desc = "너비 확대" })
vim.keymap.set("n", "<leader>-", "<C-w><", { desc = "너비 축소" })

if is_windows or is_linux then
  vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "왼쪽 창 (Alt)" })
  vim.keymap.set("n", "<A-j>", "<C-w>j", { desc = "아래 창 (Alt)" })
  vim.keymap.set("n", "<A-k>", "<C-w>k", { desc = "위 창 (Alt)" })
  vim.keymap.set("n", "<A-l>", "<C-w>l", { desc = "오른쪽 창 (Alt)" })
end
-- macOS: Option 충돌 때문에 Ctrl만 사용 (WezTerm에서 Option=Meta 설정 시 Alt 추가 가능)

-- =============================================
-- 8. 공통 단축키
-- =============================================
vim.keymap.set("n", "<leader>e", ":NERDTreeToggle<CR>:NERDTreeRefreshRoot<CR>", {
  silent = true, desc = "File Explorer",
})
vim.keymap.set("n", "<C-b>", ":NERDTreeToggle<CR>:NERDTreeRefreshRoot<CR>", {
  silent = true, desc = "File Explorer",
})
vim.keymap.set("n", "<leader>n", ":NoNeckPain<CR>", {
  silent = true, desc = "No Neck Pain",
})

-- =============================================
-- 9. oxlint
-- =============================================
vim.api.nvim_create_user_command("OxcLint", function()
  if vim.fn.executable("oxlint") == 1 then
    local file = vim.fn.expand("%")
    vim.fn.jobstart({ "oxlint", file }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then vim.notify(table.concat(data, "\n")) end
      end,
    })
  else
    notify("oxlint이 설치되지 않았습니다. (npm install -g oxlint)", vim.log.levels.WARN)
  end
end, {})

notify("✅ Neovim 설정 로드 완료!", vim.log.levels.INFO)