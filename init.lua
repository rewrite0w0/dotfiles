-- lazy.nvim 부트스트래핑: lazy.nvim 플러그인 매니저가 설치되어 있는지 확인하고, 없으면 Git을 통해 설치
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

-- lazy.nvim 초기화 및 플러그인 목록
require('lazy').setup({  -- lazy.nvim의 플러그인 목록과 설정을 정의
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
		  vim.cmd([[colorscheme tokyonight]])
		end,
	
	},
    -- 자동 완성 및 LSP: coc.nvim
    { 'neoclide/coc.nvim', branch = 'release' },  -- coc.nvim 플러그인
    -- Rust 언어 지원
    'rust-lang/rust.vim',  -- Rust 파일에 대한 구문 강조 및 포맷팅 지원
    -- 코드 포맷팅: vim-prettier
    { 'prettier/vim-prettier', ft = {'javascript', 'typescript', 'css', 'json', 'markdown', 'vue', 'svelte', 'yaml', 'html', 'javascriptreact', 'typescriptreact'} },  -- Prettier 플러그인
    -- Lua 유틸리티: plenary.nvim
    'nvim-lua/plenary.nvim',  -- telescope.nvim 등 Lua 플러그인의 공통 유틸리티
    -- 파일/텍스트 검색: telescope.nvim
    { 'nvim-telescope/telescope.nvim', tag = '0.1.3' },  -- Telescope 플러그인
    -- 구문 파싱: nvim-treesitter
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },  -- Treesitter 플러그인
    -- 터미널 관리: toggleterm.nvim
    { 'akinsho/toggleterm.nvim', tag = '*' },  -- ToggleTerm 플러그인
    -- Git 통합: neogit
    'NeogitOrg/neogit',  -- Neogit 플러그인
    -- 괄호 자동 완성: nvim-autopairs
    'windwp/nvim-autopairs',  -- 자동으로 괄호 쌍을 완성
    -- 상태바: vim-airline
    'vim-airline/vim-airline',  -- Airline 플러그인
    -- 상태바 테마: vim-airline-themes
    'vim-airline/vim-airline-themes',  -- Airline 테마 모음
    -- Git 변경 표시: vim-gitgutter
    'airblade/vim-gitgutter',  -- Git 변경 내역을 라인 옆에 표시
	{ 'preservim/nerdtree' },
    { 'ryanoasis/vim-devicons' },
}, {
    -- lazy.nvim 추가 설정
    performance = {
        rtp = {
            disabled_plugins = { 'netrwPlugin' },  -- 기본 파일 탐색기(netrw) 비활성화
        },
    },
    git = {
        cmd = 'git',  -- MSYS2 셸 문제 방지를 위해 기본 Git 명령 사용
    },
})

-- 자동 컴파일: init.lua 저장 시 파일을 다시 로드하고 플러그인 동기화
vim.api.nvim_create_autocmd('BufWritePost', {  -- init.lua 저장 시 자동 명령 설정
    group = vim.api.nvim_create_augroup('LAZY', { clear = true }),  -- LAZY라는 이름의 자동 명령 그룹 생성
    pattern = 'init.lua',  -- init.lua 파일에만 적용
    callback = function()  -- 저장 후 실행할 콜백 함수
        vim.cmd('source <afile>')  -- 현재 파일(init.lua)을 다시 로드
        require('lazy').sync()  -- lazy.nvim 플러그인 동기화
    end,
})

-- Python3 경로: coc.nvim이 Python 실행 파일을 찾도록 설정
vim.g.python3_host_prog = 'C:/Users/tjoh/AppData/Local/Programs/Python/Python313/python.EXE'  -- Python 3.13 경로 지정

-- 필요 없는 provider 비활성화
vim.g.loaded_ruby_provider = 0  -- Ruby provider 비활성화
vim.g.loaded_perl_provider = 0  -- Perl provider 비활성화

-- 전역 변수: 플러그인별 설정
vim.g.coc_global_extensions = { 'coc-json', 'coc-prettier', 'coc-tsserver' }  -- coc.nvim 확장 목록
vim.g.prettier_autoformat = 1  -- Prettier로 자동 포맷팅 활성화
vim.g['airline#extensions#tabline#enabled'] = 1  -- vim-airline의 탭라인 기능 활성화
vim.g['airline#extensions#tabline#fnamemod'] = ':t'  -- 탭라인에 파일 이름만 표시

-- 옵션: Neovim의 기본 편집 설정
vim.opt.termguicolors = true  -- 트루컬러 지원 활성화
vim.cmd('syntax enable')  -- 구문 강조 활성화
-- vim.cmd('colorscheme default')  -- 기본 테마 적용
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

-- 키 매핑: 사용자 정의 단축키 설정
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>')  -- <Leader>ff: Telescope로 파일 검색
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>')  -- <Leader>fg: Telescope로 텍스트 검색
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>')  -- <Leader>fb: Telescope로 버퍼 목록
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>')  -- <Leader>fh: Telescope로 도움말 검색
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

-- vim.keymap.set('n', '<C-b>', '<cmd>Telescope find_files<cr>')  -- <C-b>: NERDTree 대신 Telescope로 파일 검색
-- vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>')  -- <C-p>: FZF 대신 Telescope로 파일 검색

-- 터미널 설정: toggleterm.nvim으로 터미널 창 관리
require('toggleterm').setup({  -- toggleterm 플러그인 설정
    size = 10,  -- 터미널 창 크기
    open_mapping = [[<C-t>]],  -- <C-t>로 터미널 열기/닫기 (<C-n> 충돌 방지)
    direction = 'horizontal',  -- 터미널을 수평으로 열기
})

-- 자동 명령: 특정 조건에서 자동 실행
vim.api.nvim_create_autocmd('BufWritePre', {  -- 파일 저장 전 자동 명령
    pattern = { '*.js', '*.jsx', '*.json', '*.css', '*.md', '*.ts', '*.tsx' },  -- 지정된 파일 형식에 적용
    command = 'PrettierAsync',  -- 저장 전 Prettier로 비동기 포맷팅
})

-- 하이라이트: vim-gitgutter의 Git 변경 표시 색상 설정
vim.api.nvim_set_hl(0, 'GitGutterAdd', { fg = '#00FF00' })  -- 추가된 줄: 초록색
vim.api.nvim_set_hl(0, 'GitGutterChange', { fg = '#0000FF' })  -- 수정된 줄: 파란색
vim.api.nvim_set_hl(0, 'GitGutterDelete', { fg = '#FF0000' })  -- 삭제된 줄: 빨간색

-- Lua 플러그인: nvim-autopairs 초기화
require('nvim-autopairs').setup()  -- 괄호 자동 완성 기능 활성화
