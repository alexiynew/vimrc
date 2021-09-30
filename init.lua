--------------------------------------------------------------------------------
-- Aliases
--------------------------------------------------------------------------------

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    if (objects ~= nil) then
        print(unpack(objects))
    end
end

function _G.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- Options
--------------------------------------------------------------------------------

function _G.set_general_options()
    vim.cmd('filetype plugin indent on')

    -- Show line numbers
    vim.opt.number = true

    -- Always show signcolumn
    vim.opt.signcolumn = 'yes'

    -- Show typed command
    vim.opt.showcmd = true

    -- Height of the command bar
    vim.opt.cmdheight = 2

    -- Shows the effects of a command
    vim.opt.inccommand = 'split'

    -- Show current mode
    vim.opt.showmode = true

    -- Show text width columns
    vim.opt.colorcolumn = {81, 121}

    -- Command-line completion
    vim.opt.wildmenu = true
    vim.opt.wildmode = 'longest:full,full'

    -- Ignore compiled files and vcs
    vim.opt.wildignore = '*.o,*.obj,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store'

    -- Complete options
    vim.opt.completeopt = 'menuone,noselect,noinsert'

    -- Don't redraw while executing macros (good performance config)
    vim.opt.lazyredraw = true

    -- A buffer becomes hidden when it is abandoned
    vim.opt.hidden = true

    -- Short messages
    vim.opt.shortmess = 'filnxtToOIc'

    -- Mouse support
    vim.opt.mouse = 'a'

    -- Copy\paste to OS
    vim.opt.clipboard = 'unnamedplus'

    -- Prevents inserting two spaces after punctuation on a join (J)
    vim.opt.joinspaces = false

    -- Horizontal split below current
    vim.opt.splitbelow = true

    -- Vertical split to right of current
    vim.opt.splitright = true

    -- Show next 7 lines while scrolling
    vim.opt.scrolloff = 7

    -- Show next 5 columns while side-scrolling
    vim.opt.sidescrolloff = 5

    -- Display part of long lines
    vim.opt.wrap = false

    -- Do not save loacal mappings
    vim.opt.viewoptions:remove("options")

    -- Show tab line
    vim.opt.showtabline = 2

    -- Remember info about open buffers on close
    vim.opt.shada:append('%')

    -- Use Unix as the standard file type
    vim.opt.fileformats = 'unix,dos,mac'
end

--------------------------------------------------------------------------------
-- Serch
--------------------------------------------------------------------------------

function _G.custom_find(pattern)
    local p = ':cexpr system("fd -g \'' .. pattern .. '\'")'
    print(p)
    vim.cmd(p)
end

function _G.set_search_options()
    -- Ignore case when searching
    vim.opt.ignorecase = true

    -- When searching try to be smart about cases
    vim.opt.smartcase = true

    -- Highlight search results
    vim.opt.hlsearch = true

    -- Makes search act like search in modern browsers
    vim.opt.incsearch = true

    -- Show matching brackets when text indicator is over them
    vim.opt.showmatch = true

    -- How many tenths of a second to blink when matching brackets
    vim.opt.matchtime = 2

    -- Add matchpairs
    vim.opt.matchpairs:append('<:>')

    vim.opt.grepprg = 'rg -n'

    vim.cmd('command! -nargs=1 Find call v:lua.custom_find(<f-args>)<cr>')
end


--------------------------------------------------------------------------------
-- Files, backups
--------------------------------------------------------------------------------

function _G.set_files_backups_options()
    -- Turn backup off, since most stuff is in SVN, git etc. anyway...
    vim.opt.backup = false
    vim.opt.writebackup = false
    vim.opt.swapfile = false

    -- Fix filetypes
    vim.cmd('augroup FiletypeFix')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufNewFile,BufReadPost *.mm set filetype=objcpp')
    vim.cmd('   autocmd BufNewFile,BufReadPost *.m set filetype=objc')
    vim.cmd('augroup END')

    -- Finding files - Search down into subfolders
    vim.opt.path:append(vim.fn.getcwd() .. '/**')
end

--------------------------------------------------------------------------------
-- Tab and indent
--------------------------------------------------------------------------------

function _G.set_indent_options()
    -- Use spaces instead of tabs
    vim.opt.expandtab = true

    -- 1 tab == 4 spaces
    vim.opt.shiftwidth = 4
    vim.opt.tabstop = 4

    -- Copy indent from current line when starting a new line
    vim.opt.autoindent = true

    -- Smart indent
    vim.opt.smartindent = true

    -- Set whitespace chars
    vim.opt.listchars = 'tab:>-,eol:¬,space:·,trail:•'
    vim.opt.list = false
end

--------------------------------------------------------------------------------
-- Folding
--------------------------------------------------------------------------------

-- Foldmethod
function _G.custom_fold_text()
    local line = trim(vim.fn.getline(vim.v.foldstart))
    local line_count = vim.v.foldend - vim.v.foldstart + 1
    local offset = vim.v.foldlevel - 1
    local offset_string = " =   "

    offset_string = offset_string .. (string.rep("    ", offset))

    return offset_string .. line .. ": " .. line_count .. " lines"
end

function _G.set_folding_options()
    vim.opt.foldmethod = 'indent'
    vim.opt.foldlevelstart = 99
    vim.opt.fillchars = { fold = " " }
    vim.opt.foldtext = 'v:lua.custom_fold_text()'

    -- Save fold state
    vim.cmd('augroup AutoSaveFolds')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufWinLeave * silent! mkview')
    vim.cmd('   autocmd BufWinEnter * silent! loadview')
    vim.cmd('augroup END')
end


--------------------------------------------------------------------------------
-- Install plugins
--------------------------------------------------------------------------------

function _G.setup_plugins()
    local function install_packer()
        local install_dir = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
        local repo = 'https://github.com/wbthomason/packer.nvim'
        local install_cmd = string.format('!git clone --depth=1 %s %s', repo, install_dir)

        if vim.fn.empty(vim.fn.glob(install_dir)) > 0 then
            print('Install packer ...')
            vim.cmd(install_cmd)
        end

        vim.cmd('packadd packer.nvim')
    end

    local function add_plugins(use)
        -- Packer itself
        use 'wbthomason/packer.nvim'

        -- LSP
        use 'neovim/nvim-lspconfig'
        use 'kabouzeid/nvim-lspinstall'
        use 'nvim-lua/completion-nvim'

        -- Colorschemes
        use 'sheerun/vim-wombat-scheme'
        use 'folke/lsp-colors.nvim'

        -- Icons
        use 'kyazdani42/nvim-web-devicons'

        -- Formating
        use 'lukas-reineke/format.nvim'

        -- Smooth scroll
        use 'psliwka/vim-smoothie'

        -- Treesitter
        use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    end

    install_packer()

    -- Setup packer
    local packer = require 'packer'
    packer.startup(add_plugins)
    packer.install()
    packer.compile()

    local tsconfig = require 'nvim-treesitter.configs'

    -- TODO: autoinstall TS parsers (bash, c, cpp, cmake, yaml, json, commnet, lua, vim)
    tsconfig.setup {
        highlight = { enable = true },
    }
end


--------------------------------------------------------------------------------
-- Install plugins
--------------------------------------------------------------------------------
function _G.setup_netrw()
    -- Tree style listing
    vim.g.netrw_liststyle = 3

    -- No banner
    vim.g.netrw_banner = 0

    -- Open file in previous window
    vim.g.netrw_browse_split = 4

    -- Window size
    vim.g.netrw_winsize = 25

    vim.g.netrw_special_syntax = 1
end


--------------------------------------------------------------------------------
-- Colorscheme
--------------------------------------------------------------------------------

function _G.setup_colorscheme()
    -- Enable syntax highlighting
    vim.opt.syntax = 'ON'

    -- Set terminal color mode
    vim.opt.termguicolors = true
    vim.opt.background = 'dark'

    -- Enables pseudo-transparency for the popup-menu
    vim.opt.pumblend = 15

    -- Fancy wombat based colors
    vim.cmd('hi clear')
    vim.cmd('syntax reset')

    -- General colors
    vim.cmd('hi Normal ctermfg=252 ctermbg=234 cterm=none guifg=#e3e0d7 guibg=#242424 gui=none')
    vim.cmd('hi Cursor ctermfg=234 ctermbg=228 cterm=none guifg=#242424 guibg=#eae788 gui=none')
    vim.cmd('hi Visual ctermfg=251 ctermbg=239 cterm=none guifg=#c3c6ca guibg=#554d4b gui=none')
    vim.cmd('hi VisualNOS ctermfg=251 ctermbg=236 cterm=none guifg=#c3c6ca guibg=#303030 gui=none')
    vim.cmd('hi Search ctermfg=177 ctermbg=241 cterm=none guifg=#d787ff guibg=#636066 gui=none')
    vim.cmd('hi Folded ctermfg=103 ctermbg=237 cterm=none guifg=#a0a8b0 guibg=#3a4046 gui=none')
    vim.cmd('hi Title ctermfg=230 cterm=bold guifg=#ffffd7 gui=bold')
    vim.cmd('hi StatusLine ctermfg=230 ctermbg=238 cterm=none guifg=#ffffd7 guibg=#444444 gui=none')
    vim.cmd('hi VertSplit ctermfg=238 ctermbg=238 cterm=none guifg=#444444 guibg=#444444 gui=none')
    vim.cmd('hi StatusLineNC ctermfg=241 ctermbg=238 cterm=none guifg=#857b6f guibg=#444444 gui=none')
    vim.cmd('hi LineNr ctermfg=241 ctermbg=232 cterm=none guifg=#857b6f guibg=#080808 gui=none')
    vim.cmd('hi SpecialKey ctermfg=241 ctermbg=235 cterm=none guifg=#626262 guibg=#2b2b2b gui=none')
    vim.cmd('hi WarningMsg ctermfg=203 guifg=#ff5f55')
    vim.cmd('hi ErrorMsg ctermfg=196 ctermbg=234 cterm=bold guifg=#e3e0d7 guibg=#3a3a3a gui=bold')
    vim.cmd('hi SpellBad ctermfg=196 ctermbg=234 cterm=bold guifg=#e3e0d7 guibg=#3a3a3a gui=bold')
    vim.cmd('hi SpellCap ctermfg=196 ctermbg=234 cterm=bold guifg=#e3e0d7 guibg=#3a3a3a gui=bold')

    vim.cmd('hi CursorLine ctermbg=236 cterm=none guibg=#32322f')
    vim.cmd('hi MatchParen ctermfg=228 ctermbg=101 cterm=bold guifg=#eae788 guibg=#857b6f gui=bold')
    vim.cmd('hi Pmenu ctermfg=230 ctermbg=238 guifg=#ffffd7 guibg=#444444')
    vim.cmd('hi PmenuSel ctermfg=232 ctermbg=192 guifg=#080808 guibg=#cae982')

    vim.cmd('hi ColorColumn guibg=#262626 ctermbg=235')

    -- Tabline
    vim.cmd('hi! link TabLine StatusLineNC')
    vim.cmd('hi! link TabLineFill StatusLine')
    vim.cmd('hi TabLineSel cterm=bold gui=bold')

    -- Diff highlighting
    vim.cmd('hi DiffAdd ctermbg=17 guibg=#2a0d6a')
    vim.cmd('hi DiffDelete ctermfg=234 ctermbg=60 cterm=none guifg=#242424 guibg=#3e3969 gui=none')
    vim.cmd('hi DiffText ctermbg=53 cterm=none guibg=#73186e gui=none')
    vim.cmd('hi DiffChange ctermbg=237 guibg=#382a37')

    -- Syntax
    vim.cmd('hi Keyword ctermfg=111 cterm=none guifg=#88b8f6 gui=none')
    vim.cmd('hi Statement ctermfg=111 cterm=none guifg=#88b8f6 gui=none')
    vim.cmd('hi Constant ctermfg=173 cterm=none guifg=#e5786d gui=none')
    vim.cmd('hi Number ctermfg=173 cterm=none guifg=#e5786d gui=none')
    vim.cmd('hi PreProc ctermfg=173 cterm=none guifg=#e5786d gui=none')
    vim.cmd('hi Function ctermfg=192 cterm=none guifg=#cae982 gui=none')
    vim.cmd('hi Identifier ctermfg=192 cterm=none guifg=#cae982 gui=none')
    vim.cmd('hi Type ctermfg=186 cterm=none guifg=#d4d987 gui=none')
    vim.cmd('hi Special ctermfg=229 cterm=none guifg=#eadead gui=none')
    vim.cmd('hi String ctermfg=113 cterm=none guifg=#95e454 gui=none')
    vim.cmd('hi Comment ctermfg=246 cterm=none guifg=#9c998e gui=none')
    vim.cmd('hi Todo ctermfg=101 cterm=none guifg=#857b6f gui=none')

    -- Links
    vim.cmd('hi! link FoldColumn Folded')
    vim.cmd('hi! link CursorColumn CursorLine')
    vim.cmd('hi! link NonText LineNr')

end


--------------------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------------------

function _G.setup_lsp()
    -- vim.lsp.set_log_level 'trace'

    local function install_lsp_servers(lspinstall, servers)
        local installed = lspinstall.installed_servers()

        for _, server in pairs(servers) do
            if not table.contains(installed, server) then
                lspinstall.install_server(server)
            end
        end
    end

    -- Install LSP servers
    local lspinstall = require 'lspinstall'
    lspinstall.setup()
    install_lsp_servers(lspinstall, {'cpp', 'cmake', 'lua'})

    -- Setup servers
    local lspconfig = require 'lspconfig'
    for _, server in pairs(lspinstall.installed_servers()) do
        lspconfig[server].setup {
            on_attach = require'completion'.on_attach
        }
    end

    -- Set message icons
    local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }

    for t, icon in pairs(signs) do
      local hl = "LspDiagnosticsSign" .. t
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Messages highlight
    require 'lsp-colors'.setup()

    -- Completion
    vim.g.completion_trigger_keyword_length = 3
    vim.g.completion_enable_auto_popup = false
end


--------------------------------------------------------------------------------
-- Formating
--------------------------------------------------------------------------------

function _G.setup_format()
    local remove_trailing_whitespace = { cmd = {"sed -i '' -e's/[ \t]*$//'"} }
    local clang_format = { cmd = {'clang-format -style=file -i' } }

    require "format".setup {
        ["*"]  = { remove_trailing_whitespace },
        cpp    = { clang_format },
        c      = { clang_format },
        objcpp = { clang_format },
        objc   = { clang_format },
    }

    -- Run format on save
    vim.cmd('augroup Format')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufWritePost * FormatWrite')
    vim.cmd('   autocmd BufEnter * set fo-=c fo-=r fo-=o')        -- don't auto commenting new lines
    vim.cmd('augroup END')
end


--------------------------------------------------------------------------------
-- Status line
--------------------------------------------------------------------------------

function _G.get_diagnostics()
    local errors_count = vim.lsp.diagnostic.get_count(0, 'Error')
    local warnings_count = vim.lsp.diagnostic.get_count(0, 'Warning')

    -- TODO: get signs from sign_getdefined
    local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }
    --local err = vim.fn.sign_getdefined('LspDiagnosticsSignError')
    --local war = vim.fn.sign_getdefined('LspDiagnosticsSignWarning')

    local diagnostics_string = ''
    if errors_count > 0 or warnings_count > 0 then
        diagnostics_string = signs.Error .. errors_count .. ' ' .. signs.Warning .. warnings_count
    end

    return diagnostics_string
end

function _G.setup_statusline()
    local parts = {
        '%3.(%n%): ',                                -- buffer_number
        '%f ',                                       -- file_name
        '%m%r%h%w',                                  -- modified, readonly, help, preview flags
        ' %{v:lua.get_diagnostics()}',               -- diagnostics count
        '%=',                                        -- right_align
        '%{&fileencoding?&fileencoding:&encoding} ', -- encoding
        '%y %q',                                     -- filetype or quickfi
        ' %-3.(%c%)%(%l/%L%) %(%P%)  ',              -- position
    }

    vim.opt.statusline = table.concat(parts)
end


--------------------------------------------------------------------------------
-- Tabline
--------------------------------------------------------------------------------

-- Return list of buffer numbers for each window open in tab.
function _G.tab_label(tabnr)
    local buflist = vim.fn.tabpagebuflist(tabnr)
    local winnr = vim.fn.tabpagewinnr(tabnr)
    local bufnr = buflist[winnr]
    local buftype = vim.fn.getbufvar(bufnr, '&buftype')
    local changed = vim.fn.getbufinfo(bufnr)[1].changed

    local label = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')

    if label == '' then
        if buftype == 'quickfix' then
            label = '[Quickfix List]'
        else
            label = '[No Name]'
        end
    end

    if changed > 0 then
        label = label .. ' +'
    end

    return bufnr .. ': ' .. label
end


function _G.setup_tabline()
    local parts = {}
    for i = 1, vim.fn.tabpagenr('$') do
        local highlight = '%#TabLine#'
        if i == vim.fn.tabpagenr() then
            highlight = '%#TabLineSel#'
        end

        table.insert(parts, highlight)
        table.insert(parts, '%' .. i .. 'T')
        table.insert(parts, ' %{v:lua.tab_label(' .. i .. ')} ')
    end

    table.insert(parts, '%#TabLineFill#')
    table.insert(parts, '%= %{$PWD}')

    vim.opt.tabline = table.concat(parts)


    vim.cmd('augroup UpdateTabLine')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufEnter * :redrawtabline')
    vim.cmd('augroup END')
end


--------------------------------------------------------------------------------
-- Projects
--------------------------------------------------------------------------------

function _G.load_project_init()
    local init_file = vim.fn.fnamemodify(vim.fn.findfile('.project_init.lua', vim.fn.expand('%:p') .. ';'), ':p')

    if init_file and vim.fn.filereadable(init_file) > 0 then
        local m = dofile(init_file)
        m.setup()
    end
end

function _G.setup_project_init()
    vim.cmd('augroup AutoLoadProjectSettings')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufEnter * call v:lua.load_project_init()')
    vim.cmd('augroup END')
end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------

function _G.setup_mappings()
    local options = {noremap = true, silent = false}

    local nmap = function(key, action) vim.api.nvim_set_keymap('n', key, action, options) end

    -- Leader
    vim.g.mapleader = "'"

    -- Buffer navigation
    nmap('<C-l>', ':bn<cr>')
    nmap('<C-h>', ':bp<cr>')

    -- Turn off serch highlight
    nmap('<esc><esc>', ':<C-u>nohlsearch<cr>')

    -- Toggle whitespace showing
    nmap('<leader>l', ':set list!<cr>')

    -- netrw
    nmap('<leader>v', ':Lexplore %:h<cr>')

    -- LSP
    nmap('K',  '<cmd>lua vim.lsp.buf.hover()<cr>')

    nmap('gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
    nmap('gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
    nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    nmap('<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>')

    nmap('[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
    nmap(']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')

    -- Alt+o
    nmap('ø', ':ClangdSwitchSourceHeader<cr>')

end


--------------------------------------------------------------------------------
-- Aply settings
--------------------------------------------------------------------------------

set_general_options()
set_search_options()
set_files_backups_options()
set_indent_options()
set_folding_options()

setup_plugins()

setup_netrw()
setup_colorscheme()
setup_lsp()
setup_format()
setup_statusline()
setup_tabline()
setup_project_init()
setup_mappings()


