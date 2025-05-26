-- lazy.nvim 부트스트래핑
local lazypath = vim.fn.stdpath('data') .. '/site/pack/lazy/start/lazy.nvim'  -- lazy.nvim의 설치 경로 설정
if not vim.loop.fs_stat(lazypath) then  -- lazy.nvim이 설치되어 있지 않은 경우
    vim.fn.system({  -- Git 명령을 실행하여 lazy.nvim 리포지토리를 클론
        'git',  -- Git 명령
        'clone',  -- 리포지토리 복제
        '--filter=blob:none',  -- 불필요한 데이터를 제외하여 빠르게 클론
        'https://github.com/folke/lazy.nvim.git',  -- lazy.nvim 리포지토리 URL
        '--branch=stable',  -- 안정적인 최신 브랜치 사용
        lazypath,  -- 설치 경로
    })
    print('Installing lazy.nvim, please close and reopen Neovim...')  -- 설치 중 메시지 출력
end
vim.opt.rtp:prepend(lazypath)  -- Neovim의 런타임 경로에 lazy.nvim을 추가하여 플러그인 로드 가능하게 함

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- lazy.nvim 초기화 및 플러그인 목록
require('lazy').setup({  -- lazy.nvim의 플러그인 목록과 설정을 정의
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight-storm]])
        end,
    },
    -- 코드 포맷팅: vim-prettier
    { 'prettier/vim-prettier', ft = {'javascript', 'typescript', 'css', 'json', 'markdown', 'html', 'javascriptreact', 'typescriptreact'}},
    -- Lua 유틸리티: plenary.nvim
    {'nvim-lua/plenary.nvim'},  -- telescope.nvim 등 Lua 플러그인의 공통 유틸리티
    -- 파일/텍스트 검색: telescope.nvim
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8', -- 또는 branch = '0.1.x'
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = 'Telescope', -- lazy load: :Telescope 명령어를 쓸 때 로드
        opts = {
            -- telescope 설정
        },
    },
    -- 구문 파싱: nvim-treesitter
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },  -- Treesitter 플러그인
    -- 터미널 관리: toggleterm.nvim
    { 'akinsho/toggleterm.nvim', tag = '*' },  -- ToggleTerm 플러그인
    -- Git 통합: neogit
	{
	"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",         -- required
			"sindrets/diffview.nvim",        -- optional - Diff integration

		-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
			"ibhagwan/fzf-lua",              -- optional
			"echasnovski/mini.pick",         -- optional
			"folke/snacks.nvim",             -- optional
		},
	},
    -- 괄호 자동 완성: nvim-autopairs
    {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
	},  -- 자동으로 괄호 쌍을 완성
    -- 상태바: vim-airline
    {
	"vim-airline/vim-airline",
	lazy = false,
	dependencies = {
		"vim-airline/vim-airline-themes",
		"ryanoasis/vim-devicons",
		},
	},  -- Airline 플러그인
    -- Git 변경 표시: vim-gitgutter
    {
		"airblade/vim-gitgutter",
		lazy = false, -- load eagerly to ensure signs appear immediately
		-- No special config needed unless you want to customize behavior
	},  -- Git 변경 내역을 라인 옆에 표시    
    
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove", "GDelete", "GBrowse", "GRemove", "GRename" },
	},
    
	{ "preservim/nerdtree", lazy = false, config = function()
      vim.api.nvim_set_keymap('n', '<C-n>', ':NERDTreeToggle<CR>', { noremap = true, silent = true })
    end
	},
	
	{ "Xuyuanp/nerdtree-git-plugin", lazy = false, dependencies = { "preservim/nerdtree" } },
	
	 { "lewis6991/gitsigns.nvim", event = "BufReadPre", config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "✅" },
          change = { text = "🪄" },
          delete = { text = "❌" },
          untracked = { text = "👻" },
        },
      })
    end
	},
	
    { 'ryanoasis/vim-devicons', lazy = false},
	{ 'kdheepak/lazygit.nvim', dependencies = { 'nvim-telescope/telescope.nvim' } },
	
	
	 {
        'hrsh7th/nvim-cmp', -- The main completion plugin
        dependencies = {
            'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
            'hrsh7th/cmp-buffer', -- Buffer completions
            'hrsh7th/cmp-path', -- Path completions
            'hrsh7th/cmp-cmdline', -- Command line completions
            'L3MON4D3/LuaSnip', -- Snippet engine
            'saadparwaiz1/cmp_luasnip', -- Snippet completions
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body) -- For snippet support
                    end,
                },
                mapping = {
                    ['<C-n>'] = cmp.mapping.select_next_item(),
                    ['<C-p>'] = cmp.mapping.select_prev_item(),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.close(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'buffer' },
                    { name = 'path' },
                    { name = 'cmdline' },
                },
            })
        end,
    },
    {'neovim/nvim-lspconfig'}, -- LSP configuration	
	
	{ "lewis6991/gitsigns.nvim", event = "BufReadPre", config = function()
    require("gitsigns").setup({
      signs = {
        change = { hl = "GitSignsChange", text = "│", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
        delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
        -- Add other signs as needed
		},
      -- Additional configuration options can go here
		})
	end,
	},
	
	{ "sindrets/diffview.nvim", 
	dependencies = { "nvim-tree/nvim-web-devicons" }, 
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
	config = function()
    require("diffview").setup({
      -- Additional configuration options can be added here
    })
	end,
	},
	
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        version = false, -- Never set this value to "*"! Never!
        opts = {
            provider = "ollama",
            ollama = {
                endpoint = "http://localhost:11434",  -- Ollama 서버 주소
                model = "gemma3", -- 원하는 모델명 (오타 확인 필요)
            },
        },
        build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false", -- for windows
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "echasnovski/mini.pick", -- for file_selector provider mini.pick
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua", -- for file_selector provider fzf
            "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
            "zbirenbaum/copilot.lua", -- for providers='copilot'
            {
                "HakonHarnes/img-clip.nvim",
                event = "VeryLazy",
                opts = {
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        use_absolute_path = true,  -- Windows 사용자 필수
                    },
                },
            },
            {
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { "markdown", "Avante" },
                },
                ft = { "markdown", "Avante" },
            },
        },
    },
  -- automatically check for plugin updates
  checker = { enabled = true },    
})

-- 자동 컴파일: init.lua 저장 시 파일을 다시 로드하고 플러그인 동기화
vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('LAZY', { clear = true }),
    pattern = 'init.lua',
    callback = function()
        vim.cmd('source <afile>')
        require('lazy').sync()
    end,
})


-- 필요 없는 provider 비활성화
vim.g.loaded_ruby_provider = 0  -- Ruby provider 비활성화
vim.g.loaded_perl_provider = 0  -- Perl provider 비활성화

-- 전역 변수: 플러그인별 설정
vim.g.prettier_autoformat = 1  -- Prettier로 자동 포맷팅 활성화
vim.g['airline#extensions#tabline#enabled'] = 1  -- vim-airline의 탭라인 기능 활성화
vim.g['airline#extensions#tabline#fnamemod'] = ':t'  -- 탭라인에 파일 이름만 표시
vim.g['airline_powerline_fonts'] = 1
-- vim.g['airline_theme'] = "dark"
vim.g['airline#extensions#whitespace#enabled'] = 0
vim.g['airline#extensions#wordcount#enabled'] = 0
vim.g['airline#extensions#syntastic#enabled'] = 1
vim.g['airline_section_c'] = ""
vim.g['airline_skip_empty_sections'] = 1



-- 옵션: Neovim의 기본 편집 설정
vim.opt.termguicolors = true  -- 트루컬러 지원 활성화
vim.cmd('syntax enable')  -- 구문 강조 활성화
vim.opt.autoindent = true  -- 자동 들여쓰기 활성화
vim.opt.cindent = true  -- C 스타일 언어의 들여쓰기 활성화
vim.opt.smartindent = true  -- 스마트 들여쓰기
vim.opt.tabstop = 4  -- 탭 크기를 4칸으로 설정
vim.opt.shiftwidth = 4  -- 들여쓰기 크기를 4칸으로 설정
vim.opt.title = true  -- 창 제목을 파일 이름으로 설정
vim.opt.wrap = true  -- 긴 줄을 창 너비에 맞춰 줄바꿈
vim.opt.linebreak = true  -- 단어 단위로 줄바꿈
vim.opt.showmatch = true  -- 괄호 쌍을 강조 표시
vim.opt.laststatus = 2  -- 항상 상태바 표시
vim.opt.splitright = true  -- 새 창을 오른쪽에 분할
vim.opt.splitbelow = true  -- 새 창을 아래쪽에 분할
vim.opt.updatetime = 250  -- 커서 업데이트 주기

vim.opt.shell = 'powershell'  -- PowerShell을 기본 셸로 설정
vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
vim.opt.shellxquote = ''

-- 키 매핑: 사용자 정의 단축키 설정
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })  -- <Leader>ff: Telescope로 파일 검색
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })  -- <Leader>fg: Telescope로 텍스트 검색
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })  -- <Leader>fb: Telescope로 버퍼 목록
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })  -- <Leader>fh: Telescope로 도움말 검색
vim.keymap.set('n', 'g[', ':GitGutterPrevHunk<CR>')  -- g[: 이전 Git 변경 지점으로 이동
vim.keymap.set('n', 'g]', ':GitGutterNextHunk<CR>')  -- g]: 다음 Git 변경 지점으로 이동
vim.keymap.set('n', 'gh', ':GitGutterLineHighlightsToggle<CR>')  -- gh: Git 변경 하이라이트 토글
vim.keymap.set('n', 'gp', ':GitGutterPreviewHunk<CR>')  -- gp: Git 변경 미리보기
vim.keymap.set('n', '<Leader>f', '<Plug>(prettier-format)')  -- <Leader>f: 현재 파일 Prettier로 포맷
vim.keymap.set('x', '<Leader>f', '<Plug>(prettier-format)')  -- <Leader>f: 선택 영역 Prettier로 포맷
vim.keymap.set('n', '<C-b>', ':NERDTreeToggle<CR>', { silent = true })

-- 터미널 모드에서 Alt + 방향키로 창 이동
vim.api.nvim_set_keymap('t', '<A-h>', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-j>', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-k>', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<A-l>', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })

-- 일반 모드에서 Alt + 방향키로 창 이동
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>l', { noremap = true, silent = true })

-- 터미널 설정: toggleterm.nvim으로 터미널 창 관리
require('toggleterm').setup({  -- toggleterm 플러그인 설정
    size = 10,  -- 터미널 창 크기
    open_mapping = [[<C-t>]],  -- <C-t>로 터미널 열기/닫기 (<C-n> 충돌 방지)
    direction = 'horizontal',  -- 터미널을 수평으로 열기
    shade_terminals = true,  -- 터미널 배경을 어둡게 처리 (시각적 구분)
    persist_mode = true,  -- 터미널 모드 유지로 키 입력 처리 안정화
})

-- 자동 명령: 특정 조건에서 자동 실행
vim.api.nvim_create_autocmd('BufWritePre', {  -- 파일 저장 전 자동 명령
    pattern = {
        '*.js', '*.jsx', '*.json', '*.css', '*.md', '*.ts', '*.tsx', '*.html',
    },  -- 지정된 파일 형식에 적용
    command = 'Prettier',  -- 저장 전 Prettier로 비동기 포맷팅
})

-- 하이라이트: vim-gitgutter의 Git 변경 표시 색상 설정
vim.api.nvim_set_hl(0, 'GitGutterAdd', { fg = '#00FF00' })  -- 추가된 줄: 초록색
vim.api.nvim_set_hl(0, 'GitGutterChange', { fg = '#0000FF' })  -- 수정된 줄: 파란색
vim.api.nvim_set_hl(0, 'GitGutterDelete', { fg = '#FF0000' })  -- 삭제된 줄: 빨간색


-- Lazygit을 열기 위한 키 매핑
vim.api.nvim_set_keymap('n', '<Leader>gg', ':ToggleTerm direction=horizontal cmd=lazygit<CR>', { noremap = true, silent = true })

-- Lua 플러그인: nvim-autopairs 초기화
require('nvim-autopairs').setup()  -- 괄호 자동 완성 기능 활성화
