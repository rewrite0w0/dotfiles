-- ============================================================================
-- Neovim 설정 (init.lua) — Vim-only 워크플로 가이드
-- ============================================================================
--
-- 📂 저장 위치
--   macOS / Linux : ~/.config/nvim/init.lua
--   Windows       : %APPDATA%\nvim\init.lua
--
-- 저장 후 nvim 재시작 → 필요 시 :Lazy sync
--
-- 강제 리셋
-- :call delete(stdpath('config') . '/lazy-lock.json')
-- macOS / Linux :
--   rm -rf ~/.local/share/nvim
--   rm -rf ~/.cache/nvim
--   rm -f ~/.config/nvim/lazy-lock.json && rm -rf ~/.local/share/nvim ~/.cache/nvim
-- Windows       :
--   Remove-Item -Recurse -Force $env:LOCALAPPDATA\nvim-data
--   Remove-Item -Force "$env:LOCALAPPDATA\nvim\lazy-lock.json" -ErrorAction SilentlyContinue; Remove-Item -Recurse -Force "$env:LOCALAPPDATA\nvim-data" -ErrorAction SilentlyContinue
-- ============================================================================
-- 0. 전체 활용법 (VS Code 습관 → Vim 습관)
-- ============================================================================
--
-- ■ "Leader"(리더 키)란?
--   Vim 단축키는 기본적으로 알파벳 한두 글자(dd, yy, gd...)를 그대로 씁니다.
--   그런데 커스텀 단축키를 아무 글자에나 막 배정하면 기존 Vim 동작(예: d, y, g)과
--   충돌하기 쉽습니다. 그래서 "이 키를 먼저 누르면 그 다음은 내가 만든 커스텀
--   단축키다" 라는 접두사(prefix) 역할을 하는 특수 키 하나를 정해두는데, 그게 리더 키입니다.
--
--   아래 3번 섹션에서 vim.g.mapleader = " " (스페이스바) 로 지정했습니다.
--   즉 이 설정에서 <Space>로 시작하는 모든 단축키(<Space>ff, <Space>e, <Space>gg 등)는
--   전부 "리더 + 다음 글자" 조합이며, 순서대로 스페이스바를 누른 다음 글자를 눌러야 합니다.
--   (동시에 누르는 게 아니라 스페이스 → 떼고 → 다음 글자, 순차 입력입니다)
--
--   예) <Space>ff  =  스페이스바 누르고 뗀 뒤 → f → f  (Telescope 파일 찾기)
--       <Space>gg  =  스페이스바 누르고 뗀 뒤 → g → g  (Neogit 열기)
--
--   문서 안에서 <leader> 라고 적힌 건 전부 이 리더 키(=스페이스)를 가리키는 것이고,
--   <Space>로 표기된 것과 같은 뜻입니다. vim.g.mapleader 값을 바꾸면(예: ",") 이 문서의
--   모든 <Space>OO 단축키가 그 키로 바뀝니다.
--
--   참고로 vim.g.maplocalleader = "\\" (백슬래시)는 "로컬 리더"로, 특정 파일 타입
--   플러그인이 그 파일 종류에서만 쓰는 단축키에 쓰는 별도의 접두사입니다.
--   이 설정에서는 별도 로컬 리더 단축키를 정의하고 있진 않아 당장은 몰라도 무방합니다.
--
-- ■ 파일 찾기 / 이동
--   <Space>ff     파일 이름 검색 (Telescope)        ← Ctrl+P
--   <Space>fg     프로젝트 전체 텍스트 검색         ← Ctrl+Shift+F
--   <Space>e      현재 파일 폴더를 oil로 열기       ← 사이드바 탐색기
--   -             oil 안에서 상위 폴더로            (oil 버퍼일 때, 일반 버퍼에서도 oil 열기)
--
-- ■ 파일 시스템 조작 (oil 버퍼에서)
--   이름 변경     글자 수정 후 :w
--   삭제          줄 삭제 후 :w
--   새 파일       빈 줄에 이름 적고 :w
--   새 폴더       빈 줄에 dirname/ 적고 :w
--   열기          <CR>
--   분할 열기     <C-s> (horizontal) / <C-v> (vertical)
--   닫기          <C-c> 또는 :bd
--
-- ■ 창(윈도우) 관리
--   Ctrl + h/j/k/l     창 이동 (일반 버퍼 + 터미널 모드 둘 다 동작)
--   Alt  + h/j/k/l     창 이동 (Windows / Linux, 터미널 모드도 동작)
--   <leader>+ / <leader>_   창 높이 조절 (+ / - 대신 leader 사용, '-'는 oil 전용이라 겹치지 않게 분리)
--   <leader>+ / <leader>-   창 너비 조절
--   새 분할 창은 항상 아래쪽 / 오른쪽에 열림 (splitbelow/splitright)
--
-- ■ 터미널
--   <C-t>         하단 터미널 토글
--   터미널 안에서도 Ctrl/Alt+hjkl 로 다른 창으로 바로 이동 가능
--
-- ■ 클립보드 / Undo
--   y / p 등      시스템 클립보드와 자동 공유 (clipboard=unnamedplus)
--                 → OS의 다른 앱과 복사/붙여넣기가 그대로 통함
--   undofile      nvim을 껐다 켜도 undo 히스토리가 유지됨 (실수 복구에 유리)
--
-- ■ Git
--   <Space>gg     Neogit (스테이징·커밋·푸시)
--   <Space>gd     Diffview 열기
--   <Space>gq     Diffview 닫기
--   ]h / [h       다음/이전 변경 hunk로 이동      (gitsigns)
--   <Space>hs     현재 hunk 스테이징              (gitsigns)
--   <Space>hu     현재 hunk 스테이징 취소          (gitsigns)
--   <Space>hp     현재 hunk diff 미리보기          (gitsigns)
--   <Space>hb     현재 줄 blame 보기               (gitsigns)
--   (사인 컬럼의 +/~/- 표시는 gitsigns가 자동으로 그림)
--
-- ■ LSP / 진단(에러·워닝) / 호버 / 리팩터
--   ※ "진단(diagnostic)"은 LSP가 잡아내는 에러·워닝·힌트를 통틀어 부르는 이름입니다.
--
--   gd            정의로 이동
--   gr            참조 찾기
--   gi            구현으로 이동
--   K             호버(hover) 문서 — 커서가 있는 심볼의 타입/시그니처/문서를 팝업으로 표시
--                 (같은 위치에서 K를 다시 누르면 팝업 안으로 포커스 이동 → q 또는 <Esc>로 닫기)
--   <Space>rn     이름 변경
--   <Space>ca     코드 액션
--   <Space>fm     수동 포맷
--
--   ── 에러 / 워닝(진단) 확인하는 4가지 방법 ──
--   1) 사인 컬럼(줄 번호 왼쪽)의 아이콘   → 어느 줄에 문제가 있는지 한눈에 표시
--        (E = Error, W = Warn, I = Info, H = Hint 아이콘이 해당 줄 옆에 뜸)
--   2) <Space>d     커서가 있는 줄의 진단 메시지를 팝업(float)으로 바로 보기  ← 가장 자주 씀
--                   (vim.diagnostic.open_float, 아래 6번 섹션에서 keymap 정의)
--   3) ]d / [d      다음 / 이전 진단으로 커서 이동 (파일 전체를 훑을 때)
--   4) <Space>xx    Trouble로 전체 진단을 리스트 창에서 한 번에 보기 (프로젝트 전역)
--      <Space>xX    Trouble로 "현재 버퍼"의 진단만 리스트로 보기
--
--   ── 그 외 메시지 확인 ──
--   :messages     nvim이 띄웠던 알림(vim.notify 등) 히스토리를 전부 다시 보기
--                 (예: Mason 자동 설치 진행 메시지, 저장 시 포맷 에러 등이 스크롤되어 지나갔을 때)
--   :LspLog       LSP 서버 자체의 로그 (서버가 아예 안 붙거나 죽었을 때 원인 확인용)
--   <Space>xs     현재 버퍼의 심볼(함수/변수) 목록 보기 (Trouble)
--   <Space>xl     LSP 정의/참조 결과를 리스트 창으로 보기 (Trouble)
--
-- ■ 편집 보조
--   <Space>n      No Neck Pain (집중 모드, 좌우 여백)
--   저장 시       Biome / rustfmt 자동 포맷 (conform)
--   Insert 모드   nvim-cmp 자동완성 (<C-n>/<C-p>/<CR>)
--                 함수 자동완성 확정 시 괄호까지 자동으로 붙음 (autopairs+cmp 연동)
--   문법 하이라이트  treesitter가 파일 열릴 때 자동으로 켜짐
--
-- ■ 검색 / 기타 옵션
--   /검색어        기본은 대소문자 무시, 대문자가 섞이면 자동으로 구분 (ignorecase+smartcase)
--   scrolloff      커서가 화면 맨 위/아래에 딱 붙지 않고 8줄 여유를 두고 스크롤
--
-- ■ 자동 설치 (Mason)
--   Neovim을 처음 켜면 mason.nvim이 ts_ls / html / cssls / jsonls /
--   rust_analyzer / biome / rustfmt 를 백그라운드에서 자동으로 다운로드합니다.
--   최초 실행 시 몇 초~수십 초 정도 설치가 진행되는 동안은 해당 LSP 기능이
--   아직 안 붙을 수 있습니다. (인터넷 연결 필요)
--   :Mason        설치 상태 확인 / 수동 설치·삭제·업데이트 (i / X / u 키)
--   git, node, npm 은 Mason 자체가 그 위에서 동작하는 도구라 자동 설치가
--   불가능해 시스템에 미리 설치되어 있어야 합니다.
--   oxlint, tree-sitter CLI 는 Mason 레지스트리에 없어 여전히 수동 설치 대상입니다.
--
-- ■ 기타
--   :OxcLint      현재 파일 oxlint 수동 실행
--   :ConformInfo  어떤 포매터가 붙는지 확인
--   :Lazy         플러그인 관리
--
-- ============================================================================

local is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
local is_mac     = vim.fn.has("macunix") == 1
local is_linux   = vim.fn.has("unix") == 1 and not is_mac

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Neovim Setup" })
end

-- ============================================================================
-- 1. 필수 CLI 도구 체크
-- ============================================================================
-- git, node, npm은 Neovim/Mason이 동작하기 위한 "전제 조건"이라 자동 설치가
-- 불가능합니다 (Mason 스스로가 node/npm 위에서 돌아가는 도구이기 때문). 이 3개만
-- 여기서 수동 체크하고, LSP 서버(ts_ls, html, cssls, jsonls, rust_analyzer, biome)와
-- 포매터(rustfmt)는 아래 5번 섹션의 mason.nvim / mason-lspconfig / mason-tool-installer가
-- Neovim을 처음 켤 때 자동으로 다운로드·설치해줍니다. brew/npm -g로 미리 깔아둘 필요가 없어졌습니다.
--
-- [예외] oxlint, tree-sitter CLI는 Mason 공식 레지스트리에 없어서(2026-08 기준) 계속 수동 설치가 필요합니다.
-- ============================================================================
local required_tools = {
  { name = "git",         cmd = "git",         important = true },
  { name = "node",        cmd = "node",        important = true },
  { name = "npm",         cmd = "npm",         important = true },
  { name = "oxlint",      cmd = "oxlint",      important = false }, -- Mason 레지스트리에 없어 수동 설치 필요
  { name = "tree-sitter", cmd = "tree-sitter", important = false }, -- main 브랜치는 대부분 CLI 없이도 :TSUpdate로 동작, 있으면 더 안정적
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
    notify(
      " • " .. m.name .. (m.important and " (필수)" or ""),
      m.important and vim.log.levels.ERROR or vim.log.levels.WARN
    )
  end
end

-- ============================================================================
-- 2. lazy.nvim (플러그인 매니저)
-- ============================================================================
-- 없으면 자동 clone. 이후 :Lazy sync 로 플러그인 설치/업데이트.
-- ============================================================================
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

-- ============================================================================
-- 3. 기본 에디터 옵션
-- ============================================================================

-- oil.nvim이 기본 파일 탐색기(default_file_explorer = true) 역할을 대신하므로
-- 내장 파일 탐색기 netrw는 아예 로드되지 않게 꺼둡니다.
-- (oil 공식 문서 권장 사항: netrw가 살아있으면 일부 동작이 미묘하게 충돌할 수 있음)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader      = " "   -- 리더 키 = Space (거의 모든 커스텀 단축키의 시작)
vim.g.maplocalleader = "\\"

vim.opt.termguicolors  = true  -- true color
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true  -- 탭 → 스페이스
vim.opt.smartindent    = true
vim.opt.number         = true
vim.opt.relativenumber = true  -- 상대 번호 (움직임 계산에 유리)
vim.opt.cursorline     = true
vim.opt.hidden         = true  -- 버퍼 숨김 허용 (toggleterm 등에 필요)
vim.opt.signcolumn     = "yes" -- git/LSP 사인 공간 고정 (레이아웃 흔들림 방지)
vim.opt.updatetime     = 250

-- [추가] 시스템 클립보드 연동
-- 기본값 상태에서는 y/p가 Vim 내부 레지스터만 사용해서, 다른 앱(브라우저, 슬랙 등)과
-- 복사/붙여넣기가 안 통합니다. unnamedplus로 맞추면 y = Cmd/Ctrl+C, p = Cmd/Ctrl+V처럼
-- OS 클립보드와 완전히 동일하게 동작합니다. VS Code에서 넘어온 습관이면 사실상 필수.
vim.opt.clipboard = "unnamedplus"

-- [추가] 분할창이 열리는 방향
-- 기본값은 새 분할이 "왼쪽/위쪽"에 열려서 직관과 반대로 느껴지는 경우가 많습니다.
-- (예: LSP 참조 목록을 세로 분할로 열면 원래 코드가 오른쪽으로 밀려남)
-- true로 두면 oil의 <C-s>/<C-v>, Trouble의 win.position=right 등이 기대한 방향으로 열립니다.
vim.opt.splitright = true
vim.opt.splitbelow = true

-- [추가] 영속 undo
-- 기본은 nvim을 껐다 켜면 undo 히스토리가 사라집니다. undofile을 켜면
-- ~/.local/share/nvim/undo 에 저장되어, 파일을 다시 열어도 이전 undo 기록을 그대로 이어서 쓸 수 있습니다.
vim.opt.undofile = true

-- [추가] 검색 시 대소문자 처리
-- ignorecase: 기본적으로 대소문자 구분 안 함 (foo 검색 시 Foo도 매칭)
-- smartcase : 검색어에 대문자가 하나라도 섞이면 그 순간부터 대소문자 구분 (Foo 검색 시 foo는 매칭 안 함)
-- 두 옵션을 함께 켜는 것이 Vim 커뮤니티의 사실상 표준 조합입니다.
vim.opt.ignorecase = true
vim.opt.smartcase  = true

-- [추가] 스크롤 여백
-- 커서가 화면 맨 위/아래 줄에 붙을 때까지 기다리지 않고, 항상 위아래로 8줄의
-- 여유를 두고 미리 스크롤합니다. 코드 읽을 때 시야가 훨씬 편해집니다.
vim.opt.scrolloff = 8

-- [추가] 진단(에러·워닝) 표시 방식
-- virtual_text: 문제가 있는 줄 오른쪽 끝에 에러/워닝 메시지를 인라인으로 바로 보여줌
--               (전체 메시지가 길면 잘려 보일 수 있어, 전체를 보려면 <Space>d 사용)
-- severity_sort: 여러 진단이 겹칠 때 더 심각한 것(Error)이 사인 컬럼에 우선 표시됨
-- float.border: <Space>d / K 등으로 뜨는 팝업 창에 테두리를 그려서 배경과 구분되게 함
vim.diagnostic.config({
  virtual_text = true,
  severity_sort = true,
  float = { border = "rounded", source = true },
})

-- ============================================================================
-- 4. OS별 셸
-- ============================================================================
-- Windows : PowerShell (toggleterm 안정성 위해 옵션 전부 설정)
-- macOS   : zsh
-- Linux   : bash
-- ============================================================================
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

-- ============================================================================
-- 5. 플러그인 목록 (lazy.nvim)
-- ============================================================================
require("lazy").setup({

  -- --------------------------------------------------------------------------
  -- 테마
  -- --------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme tokyonight-storm")
    end,
  },

  -- --------------------------------------------------------------------------
  -- Mason: LSP 서버 / 포매터 자동 설치 관리자
  --
  -- [추가된 이유] 예전에는 brew/npm으로 biome, ts_ls 등을 "직접" 설치해야 했고,
  -- 설치가 안 돼 있으면 섹션 1의 required_tools 체크에서 경고만 띄우고 끝이었습니다.
  -- Mason을 쓰면 Neovim 안에서 LSP 서버/포매터를 자동으로 다운로드·설치하고,
  -- 설치된 실행파일 경로를 Neovim의 $PATH에 자동으로 추가해줍니다.
  -- priority를 높게 줘서 다른 플러그인보다 먼저 로드되게 해, mason의 bin 경로가
  -- $PATH에 최대한 일찍 등록되도록 합니다.
  --
  -- 사용법: :Mason 을 열면 설치 상태를 GUI 리스트로 보고, i(설치)/X(삭제)/u(업데이트) 가능
  -- --------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 900,
    opts = {},
  },

  -- mason-lspconfig: mason이 설치한 LSP 서버를 vim.lsp.config/enable과 자동으로 연결
  -- ensure_installed에 적어둔 서버는 Neovim을 처음 켤 때 자동으로 설치가 시작됩니다.
  -- (아래 nvim-lspconfig 설정에서 쓰는 서버 이름과 반드시 동일해야 합니다)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "ts_ls", "html", "cssls", "jsonls", "rust_analyzer", "biome" },
      automatic_installation = true,
    },
  },

  -- mason-tool-installer: LSP 서버가 아닌 순수 CLI 도구 자동 설치용 플러그인.
  --
  -- [주의] rustfmt는 여기서 뺐습니다. mason 레지스트리는 npm/pip/cargo/go 등으로
  -- "독립적으로" 설치 가능한 패키지만 등록돼 있는데, rustfmt는 그런 독립 패키지가 아니라
  -- rustup의 "컴포넌트"(rustup component add rustfmt)로 설치되는 방식이라 mason 레지스트리
  -- 자체에 존재하지 않습니다. (rust_analyzer는 레지스트리에 있어서 mason-lspconfig로 정상 설치됨)
  -- rustfmt는 10번 섹션 하단의 안내대로 rustup으로 직접 설치해야 합니다.
  --
  -- 지금은 ensure_installed가 비어 있지만, 이후 npm/cargo/pip로 설치 가능한 다른 포매터나
  -- 린터(예: prettier, shfmt, stylua 등)를 자동 설치하고 싶을 때 이 목록에 이름만 추가하면 됩니다.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {},
    },
  },

  -- --------------------------------------------------------------------------
  -- 공통 의존성 / 검색
  -- --------------------------------------------------------------------------
  "nvim-lua/plenary.nvim",

  -- Telescope: 퍼지 찾기 (파일·문자열)
  --   <Space>ff  파일
  --   <Space>fg  live grep
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- --------------------------------------------------------------------------
  -- Treesitter: 문법 하이라이트·구조 파싱
  -- main 브랜치 + tree-sitter CLI 필요
  --
  -- [수정 이유] main 브랜치는 과거 master 브랜치와 API가 다릅니다.
  -- 예전에는 require('nvim-treesitter.configs').setup({ highlight = { enable = true } })
  -- 한 줄로 파일을 열 때 자동으로 하이라이트가 켜졌지만, main 브랜치는 그 setup 함수 자체가
  -- 없어졌습니다. 파서(install)만 받아놓고 하이라이트를 켜는 코드가 없으면, 파서는 깔려있는데
  -- 정작 색은 하나도 안 입혀지는 상태가 됩니다. 그래서 파일을 열 때마다(FileType 이벤트)
  -- vim.treesitter.start()를 직접 호출해서 하이라이트를 켜주는 autocmd를 추가했습니다.
  -- --------------------------------------------------------------------------
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

      -- [추가] 해당 언어 파일을 열 때마다 하이라이트를 켠다.
      -- pcall로 감싸서, 혹시 파서가 아직 설치 중이거나 없는 파일타입이어도 에러가 나지 않게 함.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "javascript", "typescript", "typescriptreact", "javascriptreact",
          "html", "css", "json", "rust", "lua",
        },
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- 터미널: <C-t> 로 하단 패널 토글
  -- --------------------------------------------------------------------------
  "akinsho/toggleterm.nvim",

  -- --------------------------------------------------------------------------
  -- 괄호 자동 쌍
  -- --------------------------------------------------------------------------
  "windwp/nvim-autopairs",

  -- --------------------------------------------------------------------------
  -- Git 변경사항 사인 컬럼 표시
  --
  -- [교체] 기존 airblade/vim-gitgutter → lewis6991/gitsigns.nvim
  -- vim-gitgutter는 순수 Vimscript로 작성된 오래된 플러그인입니다.
  -- 이미 Neogit/Diffview로 git 관련 플러그인을 Lua 생태계로 통일해뒀는데
  -- 사인 컬럼 표시만 legacy vimscript 플러그인을 쓸 이유가 없습니다.
  -- gitsigns는 더 빠르고, hunk 단위 stage/undo, inline blame, hunk 미리보기 등
  -- vim-gitgutter에는 없는 기능도 기본 제공합니다. 아래 6번 섹션에서 관련 키맵을 설정합니다.
  -- --------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    opts = {}, -- 기본 설정으로 충분 (사인 컬럼 +/~/- 표시는 자동)
  },

  -- --------------------------------------------------------------------------
  -- oil.nvim: 디렉토리를 버퍼처럼 편집 (Vim-only 파일 탐색)
  --
  -- 핵심 개념
  --   폴더를 열면 파일 목록이 "텍스트 버퍼"로 열린다.
  --   이름을 고치고 :w → 실제 rename
  --   줄을 지우고 :w → 실제 삭제
  --   새 줄에 이름을 쓰고 :w → 실제 생성
  --
  -- 단축키 (아래에서 재정의)
  --   <Space>e   현재 파일 기준 oil 열기
  --   -          상위 디렉토리 (oil 버퍼 안에서)
  -- --------------------------------------------------------------------------
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- 아이콘 (선택)
    config = function()
      require("oil").setup({
        -- 기본 파일 탐색기로 사용 ( :e .  등)
        default_file_explorer = true,
        columns = {
          "icon",
          -- "permissions",
          -- "size",
          -- "mtime",
        },
        view_options = {
          show_hidden = true, -- dotfile 표시
        },
        keymaps = {
          ["<CR>"] = "actions.select",
          ["<C-s>"] = { "actions.select", opts = { horizontal = true } },
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-t>"] = false, -- toggleterm과 충돌 방지
          ["-"] = "actions.parent",
          ["_"] = "actions.open_cwd",
          ["`"] = "actions.cd",
          ["~"] = { "actions.cd", opts = { scope = "tab" } },
          ["<C-c>"] = "actions.close",
          ["<C-l>"] = "actions.refresh",
          ["g."] = "actions.toggle_hidden",
          ["g?"] = "actions.show_help",
        },
        use_default_keymaps = false, -- 위 맵만 사용
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- No Neck Pain: 좌우 여백으로 코드 집중
  --   <Space>n  토글
  -- --------------------------------------------------------------------------
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

  -- --------------------------------------------------------------------------
  -- Trouble: 진단·심볼·LSP 결과를 리스트 UI로
  --   <Space>xx  전체 진단
  --   <Space>xX  현재 버퍼 진단
  --   <Space>xs  심볼
  --   <Space>xl  LSP 정의/참조 등
  -- --------------------------------------------------------------------------
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Buffer Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Symbols" },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP defs/refs" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                            desc = "Location List" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                             desc = "Quickfix List" },
    },
  },

  -- --------------------------------------------------------------------------
  -- Neogit + Diffview: 에디터 안 Git UI
  --   <Space>gg  Neogit
  --   <Space>gd  Diffview 열기
  --   <Space>gq  Diffview 닫기
  -- --------------------------------------------------------------------------
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

  -- --------------------------------------------------------------------------
  -- nvim-cmp: 자동완성
  --   Insert에서 <C-n>/<C-p> 선택, <CR> 확정, <C-Space> 수동 트리거
  -- --------------------------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "windwp/nvim-autopairs", -- [추가] cmp 확정 이벤트에 autopairs를 연결하기 위해 의존성으로 명시
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

      -- [추가] nvim-autopairs ↔ nvim-cmp 연동
      -- 지금까지는 두 플러그인이 서로 독립적으로만 동작해서, 예를 들어
      -- 함수 이름을 자동완성으로 확정(<CR>)해도 여는 괄호 "("만 붙고
      -- 닫는 괄호가 자동으로 따라오지 않는 경우가 있었습니다.
      -- cmp의 확정 이벤트에 autopairs 핸들러를 연결하면, 함수/메서드 완성 시
      -- 괄호 쌍이 자동으로 같이 입력되고 커서가 괄호 안쪽에 위치합니다.
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- --------------------------------------------------------------------------
  -- LSP (언어 서버)
  --   ts_ls / html / css / json / rust_analyzer
  --   biome (있으면), oxlint (있으면)
  --
  -- 버퍼에 LSP가 붙으면:
  --   gd gr gi K  <Space>rn  <Space>ca  <Space>fm
  --   에러/워닝(진단) 보기:  <Space>d (현재 줄) / ]d [d (다음·이전 진단으로 이동)
  -- --------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    -- [추가] mason-lspconfig에 의존성을 걸어, 이 config 함수가 실행되기 전에
    -- mason-lspconfig의 ensure_installed 설치가 먼저 트리거되도록 순서를 보장합니다.
    dependencies = { "hrsh7th/cmp-nvim-lsp", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local servers = { "ts_ls", "html", "cssls", "jsonls", "rust_analyzer" }

      -- [추가] cmp-nvim-lsp의 확장 capabilities를 서버에 전달
      -- 이전에는 cmp-nvim-lsp를 nvim-cmp 쪽 의존성으로만 설치해두고
      -- 정작 LSP 서버 설정(vim.lsp.config)에는 넘겨주지 않고 있었습니다.
      -- 그 결과 서버는 Neovim 기본 capabilities만 보고 동작해서, 스니펫 지원 여부나
      -- 일부 고급 completion(예: 자동 import) 관련 기능이 서버 쪽에서 비활성화된 채로
      -- 동작했을 수 있습니다. default_capabilities()로 만든 확장판을 각 서버에 전달합니다.
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
      end

      -- [추가] ts_ls 자체 포맷 기능 끄기
      -- 저장 시 포맷은 conform(6번 항목)을 통해 biome이 전담하고 있습니다.
      -- ts_ls도 자체적으로 포맷 능력(documentFormattingProvider)을 갖고 있어서,
      -- 그대로 두면 <Space>ca(코드 액션) 등에서 biome과 ts_ls 양쪽의 포맷/액션이
      -- 중복으로 뜰 수 있습니다. ts_ls의 포맷 관련 capability만 꺼서 biome으로 역할을 통일합니다.
      vim.lsp.config("ts_ls", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          documentFormattingProvider = false,
          documentRangeFormattingProvider = false,
        }),
      })

      -- [수정] biome은 이제 mason-lspconfig의 ensure_installed에 들어있어서
      -- Neovim이 처음 켜질 때 자동으로 설치됩니다. 예전처럼 vim.fn.executable("biome")로
      -- 시스템에 수동 설치돼 있는지 체크할 필요 없이 바로 설정하면 됩니다.
      -- (단, 최초 설치 중에는 잠깐 biome LSP가 안 붙을 수 있음 — :Mason에서 진행 상황 확인 가능)
      vim.lsp.config("biome", { cmd = { "biome", "lsp-proxy" }, capabilities = capabilities })

      -- [설명 보강] oxlint 진단(diagnostic) capability를 의도적으로 끈 이유
      -- biome과 oxlint를 동시에 LSP로 붙이면 같은 문제에 대해 진단 메시지가
      -- 두 번씩 뜨는 경우가 있어서, 진단 표시는 biome 하나로 통일하고
      -- oxlint는 :OxcLint 커맨드로 필요할 때만 수동 실행하는 용도로 남겨뒀습니다.
      -- 만약 oxlint를 실시간 진단용으로도 쓰고 싶다면, 아래 diagnostic 라인을 지우고
      -- 대신 biome 설정에서 겹치는 lint 규칙을 꺼서 역할을 분리하는 걸 권장합니다.
      if vim.fn.executable("oxlint") == 1 then
        vim.lsp.config("oxlint", {
          capabilities = vim.tbl_deep_extend("force", capabilities, {
            textDocument = { diagnostic = vim.NIL },
          }),
          settings = { run = "onSave" },
        })
      end

      vim.lsp.enable(servers)
      vim.lsp.enable("biome") -- mason이 설치를 보장하므로 executable 체크 불필요
      if vim.fn.executable("oxlint") == 1 then vim.lsp.enable("oxlint") end -- oxlint는 여전히 수동 설치 대상

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

          -- [추가] 에러/워닝(진단) 확인용 키맵
          -- 사인 컬럼 아이콘만으로는 "무슨 에러인지" 메시지 전체를 볼 수 없어서,
          -- 커서가 있는 줄의 진단 메시지를 팝업으로 띄우는 키맵을 별도로 추가합니다.
          -- (virtual_text로도 인라인 표시는 되지만, 메시지가 길면 잘리기 때문에 이 팝업이 더 확실함)
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float,
            vim.tbl_extend("force", opts, { desc = "현재 줄 진단(에러/워닝) 보기" }))
          -- ]d / [d : 파일 안에서 다음/이전 진단 위치로 커서를 바로 이동
          -- (버퍼 전체를 <Space>xx로 리스트로 보는 대신, 훑으면서 하나씩 확인하고 싶을 때 사용)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,
            vim.tbl_extend("force", opts, { desc = "다음 진단으로 이동" }))
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end,
            vim.tbl_extend("force", opts, { desc = "이전 진단으로 이동" }))
        end,
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- conform: 저장 시 포맷
  --   JS/TS/JSON/HTML/CSS → biome
  --   Rust → rustfmt
  -- --------------------------------------------------------------------------
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

-- ============================================================================
-- 6. 플러그인 즉시 초기화 + 검색 키
-- ============================================================================
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

-- [추가] gitsigns 키맵
-- vim-gitgutter는 사인 컬럼 표시만 자동으로 해줬을 뿐 별도 키맵이 없었지만,
-- gitsigns는 hunk 단위 조작(stage/undo/preview/blame)까지 지원하므로 관련 키맵을 추가합니다.
-- 사인 컬럼(+/~/-) 표시 자체는 opts = {} 기본 설정만으로 자동으로 동작합니다.
do
  local gitsigns = require("gitsigns")
  vim.keymap.set("n", "]h", gitsigns.next_hunk, { desc = "다음 git hunk" })
  vim.keymap.set("n", "[h", gitsigns.prev_hunk, { desc = "이전 git hunk" })
  vim.keymap.set("n", "<leader>hs", gitsigns.stage_hunk,   { desc = "hunk 스테이징" })
  vim.keymap.set("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "hunk 스테이징 취소" })
  vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, { desc = "hunk 미리보기" })
  vim.keymap.set("n", "<leader>hb", function()
    gitsigns.blame_line({ full = true })
  end, { desc = "현재 줄 blame" })
end

-- ============================================================================
-- 7. oil 키맵 (파일 탐색)
-- ============================================================================
-- <Space>e  현재 파일의 디렉토리를 oil로 연다
-- -         oil 권장 관례: 상위 폴더 (oil 버퍼가 아닐 때는 현재 파일 기준 상위)
--
-- ⚠️ 주의: 이 전역 "-" 매핑은 반드시 섹션 8의 창 크기 조절 매핑보다
--          "나중에" 정의되어야 살아남습니다 (Lua는 나중 매핑이 이전 것을 덮어씀).
--          그래서 섹션 8에서는 "-"를 창 높이 축소에 쓰지 않고 <leader>_ 를 대신 사용합니다.
-- ============================================================================
vim.keymap.set("n", "<leader>e", function()
  require("oil").open()
end, { desc = "Open oil (file explorer)" })

vim.keymap.set("n", "-", function()
  require("oil").open()
end, { desc = "Open oil (parent-friendly)" })

-- ============================================================================
-- 8. 창 이동 / 크기 (OS 분기)
-- ============================================================================
-- 공통: Ctrl + hjkl (일반 버퍼)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "창 ←" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "창 ↓" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "창 ↑" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "창 →" })

-- [수정] 터미널 모드에서도 Ctrl + hjkl 로 창 이동
-- toggleterm은 start_in_insert = true라서 열리자마자 "터미널 모드"가 됩니다.
-- 터미널 모드에서는 <C-h> 등이 Neovim 매핑이 아니라 쉘 프로세스로 그대로 전달되기 때문에
-- (예: <C-h>는 백스페이스로 처리됨) 위의 일반 모드 매핑만으로는 터미널 창에서 빠져나올 수 없었습니다.
-- <C-\><C-n> 으로 먼저 터미널 모드 → normal 모드로 탈출한 뒤 <C-w>h/j/k/l 로 창을 이동시킵니다.
local term_opts = { silent = true }
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], term_opts)
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], term_opts)
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], term_opts)
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], term_opts)

-- 공통: 크기
-- [수정] "-" 는 섹션 7에서 oil 전용으로 이미 매핑되어 있습니다.
-- 예전 버전에서는 여기서 "-"를 다시 "창 높이 줄이기"로 매핑해서, Lua가 파일을 순서대로
-- 실행하는 특성상 나중에 정의된 이 매핑이 섹션 7의 oil 매핑을 덮어써버리는 버그가 있었습니다.
-- 그 결과 "-"를 눌러도 항상 창 높이만 줄어들고, oil로 상위 폴더 이동은 동작하지 않았습니다.
-- 지금은 "-"를 여기서 절대 재사용하지 않고, 높이 줄이기는 <leader>_ 로만 제공합니다.
vim.keymap.set("n", "+",         "<C-w>+", { desc = "높이 +" })
vim.keymap.set("n", "<leader>+", "<C-w>>", { desc = "너비 +" })
vim.keymap.set("n", "<leader>-", "<C-w><", { desc = "너비 -" })
vim.keymap.set("n", "<leader>_", "<C-w>-", { desc = "높이 - (대안)" })

if is_windows or is_linux then
  -- WezTerm(Windows)은 Alt+Shift+hjkl 을 팬 이동에 쓰므로
  -- 일반 Alt+hjkl 은 Neovim으로 전달됨
  vim.keymap.set("n", "<A-h>", "<C-w>h", { desc = "창 ← Alt" })
  vim.keymap.set("n", "<A-j>", "<C-w>j", { desc = "창 ↓ Alt" })
  vim.keymap.set("n", "<A-k>", "<C-w>k", { desc = "창 ↑ Alt" })
  vim.keymap.set("n", "<A-l>", "<C-w>l", { desc = "창 → Alt" })

  -- [추가] 터미널 모드에서도 Alt+hjkl 지원 (위 Ctrl 버전과 동일한 이유)
  vim.keymap.set("t", "<A-h>", [[<C-\><C-n><C-w>h]], term_opts)
  vim.keymap.set("t", "<A-j>", [[<C-\><C-n><C-w>j]], term_opts)
  vim.keymap.set("t", "<A-k>", [[<C-\><C-n><C-w>k]], term_opts)
  vim.keymap.set("t", "<A-l>", [[<C-\><C-n><C-w>l]], term_opts)
end
-- macOS: Option 키 충돌 때문에 Ctrl만 사용.
-- WezTerm에서 Option을 Meta로 쓰려면 wezterm.lua:
--   config.send_composed_key_when_left_alt_is_pressed = false
--   config.send_composed_key_when_right_alt_is_pressed = false

-- ============================================================================
-- 9. 집중 모드
-- ============================================================================
vim.keymap.set("n", "<leader>n", ":NoNeckPain<CR>", {
  silent = true,
  desc = "No Neck Pain",
})

-- ============================================================================
-- 10. oxlint 수동 실행
-- ============================================================================
vim.api.nvim_create_user_command("OxcLint", function()
  if vim.fn.executable("oxlint") == 1 then
    local file = vim.fn.expand("%")
    vim.fn.jobstart({ "oxlint", file }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if data then
          vim.notify(table.concat(data, "\n"))
        end
      end,
    })
  else
    notify("oxlint이 설치되지 않았습니다. (npm install -g oxlint)", vim.log.levels.WARN)
  end
end, {})

notify("✅ Vim-only 설정 로드 완료 (oil + Trouble + Neogit + gitsigns)", vim.log.levels.INFO)


-- 이 부분에서 필수 도구들을 체크합니다.
-- git / node / npm은 Mason이 동작하기 위한 전제 조건이라 자동 설치가 안 되므로
-- 아래처럼 시스템에 미리 설치해 두어야 합니다. (biome, LSP 서버, rustfmt는
-- 이제 Mason이 Neovim 안에서 알아서 설치하므로 별도 명령어가 필요 없습니다)
--
-- 📦 설치 명령어 (git / node / npm 만 해당):
--
--   macOS (Homebrew):
--     brew install git node
--
--   Windows (winget 또는 공식 설치파일):
--     winget install Git.Git OpenJS.NodeJS.LTS
--
--   Linux - Fedora:
--     sudo dnf install -y git nodejs npm
--
--   Linux - Ubuntu/Debian:
--     sudo apt update && sudo apt install -y git nodejs npm
--
-- oxlint / tree-sitter CLI는 Mason 레지스트리에 없어 필요하면 아래처럼 별도 설치:
--   npm install -g oxlint tree-sitter-cli
-- =============================================