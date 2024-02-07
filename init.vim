call plug#begin('~/.config/nvim/plugged')

Plug 'dracula/vim'
Plug 'folke/tokyonight.nvim'

" Use release branch
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Or latest tag
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}

let g:coc_global_extensions = ['coc-json', 'coc-prettier', 'coc-tsserver', 'coc-deno']


" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', {
  \ 'do': 'yarn install --frozen-lockfile --production',
  \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html'] }

Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.3' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'NeogitOrg/neogit'

Plug 'windwp/nvim-autopairs'


" ctrl + b => file explorer

Plug 'scrooloose/nerdtree'
Plug 'ryanoasis/vim-devicons'

let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
" Toggle
nnoremap <silent> <C-b> :NERDTreeToggle<CR>

let g:prettier#autoformat = 1

" File Search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1

"" vim-airline
" 상태 라인 게시하는 항목 변경
let g:airline#extensions#default#layout = [
  \ [ 'a', 'b', 'c' ],
  \ ['z']
  \ ]
let g:airline_section_c = '%t %M'
let g:airline_section_z = get(g:, 'airline_linecolumn_prefix', '').'%3l:%-2v'
" 변경이 없으면 diff 행수 보이지 않게
let g:airline#extensions#hunks#non_zero_only = 1 

" 탭 라인 표기 변경
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tabline#show_close_button = 0

Plug 'airblade/vim-gitgutter'


call plug#end()

if (has("termguicolors"))
 set termguicolors
endif
syntax enable
" colorscheme dracula
colorscheme tokyonight-moon



set autoindent
set cindent
set smartindent
set tabstop=4
set shiftwidth=4
set title
set wrap
set linebreak
set showmatch                            
set laststatus=2

" open new split panes to right and below
set splitright
set splitbelow
" turn terminal to normal mode with escape
tnoremap <Esc> <C-\><C-n>
" start terminal in insert mode
au BufEnter * if &buftype == 'terminal' | :startinsert | endif
" open terminal on ctrl+n
function! OpenTerminal()
  split term://powershell
  resize 10
endfunction
nnoremap <c-n> :call OpenTerminal()<CR>

" use alt+hjkl to move between split/vsplit panels
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

nnoremap <C-p> :FZF<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}
let $FZF_DEFAULT_COMMAND = 'ag -g ""'





" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Using Lua functions
nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>


lua require("toggleterm").setup()

lua require("nvim-autopairs").setup {}

" Formatting in normal mode
nmap <Leader>f <Plug>(prettier-format)
" Range formatting in visual mode
xmap <Leader>f <Plug>(prettier-format)

"" git 조작
" g] 변경된 곳으로 이동
nnoremap g[ :GitGutterPrevHunk<CR>
" g[ 다음 장소로 이동
nnoremap g] :GitGutterNextHunk<CR>
" gh diff 하이라이트
nnoremap gh :GitGutterLineHighlightsToggle<CR>
" gp 커서 diff 표시
nnoremap gp :GitGutterPreviewHunk<CR>
" 기호 색 변경
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=blue
highlight GitGutterDelete ctermfg=red

"" 반영 속도 빠르게 (기본은 4000ms)
set updatetime=250
