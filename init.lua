--------------------------------------------------------------------------------
-- Aliases
--------------------------------------------------------------------------------

local cmd = vim.cmd
local fn  = vim.fn
local g   = vim.g
local opt = vim.opt
local map = vim.api.nvim_set_keymap

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(table.unpack(objects))
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
    cmd('filetype plugin indent on')

    -- Show line numbers
    opt.number = true

    -- Always show signcolumn
    opt.signcolumn = 'yes'

    -- Show typed command
    opt.showcmd = true

    -- Height of the command bar
    opt.cmdheight = 2

    -- Shows the effects of a command
    opt.inccommand = 'split'

    -- Show current mode
    opt.showmode = true

    -- Show text width columns
    opt.colorcolumn = {81, 121}

    -- Command-line completion
    opt.wildmenu = true
    opt.wildmode = 'longest:full,full'

    -- Ignore compiled files and vcs
    opt.wildignore = '*.o,*.obj,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store'

    -- Complete options
    opt.completeopt = 'menuone,noselect,noinsert'

    -- Don't redraw while executing macros (good performance config)
    opt.lazyredraw = true

    -- A buffer becomes hidden when it is abandoned
    opt.hidden = true

    -- Short messages
    opt.shortmess = 'filnxtToOIc'

    -- Mouse support
    opt.mouse = 'a'

    -- Copy\paste to OS
    opt.clipboard = 'unnamedplus'

    -- Prevents inserting two spaces after punctuation on a join (J)
    opt.joinspaces = false

    -- Horizontal split below current
    opt.splitbelow = true

    -- Vertical split to right of current
    opt.splitright = true

    -- Show next 7 lines while scrolling
    opt.scrolloff = 7

    -- Show next 5 columns while side-scrolling
    opt.sidescrolloff = 5

    -- Display part of long lines
    opt.wrap = false

    -- Do not save loacal mappings
    opt.viewoptions:remove("options")

    -- Show tab line
    opt.showtabline = 2

    -- Remember info about open buffers on close
    opt.shada:append('%')

    -- Use Unix as the standard file type
    opt.fileformats = 'unix,dos,mac'
end

--------------------------------------------------------------------------------
-- Serch
--------------------------------------------------------------------------------

function _G.set_search_options()
    -- Ignore case when searching
    opt.ignorecase = true

    -- When searching try to be smart about cases
    opt.smartcase = true

    -- Highlight search results
    opt.hlsearch = true

    -- Makes search act like search in modern browsers
    opt.incsearch = true

    -- Show matching brackets when text indicator is over them
    opt.showmatch = true

    -- How many tenths of a second to blink when matching brackets
    opt.matchtime = 2

    -- Add matchpairs
    opt.matchpairs:append('<:>')
end

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

function _G.set_colorscheme()
    -- Enable syntax highlighting
    opt.syntax = 'ON'

    -- Set terminal color mode
    opt.termguicolors = true
    opt.background = 'dark'

    -- Enables pseudo-transparency for the popup-menu
    opt.pumblend = 15


    -- Fancy colors
    local schemes = fn.getcompletion('', 'color')
    if table.contains(schemes, 'gruvbox8') then
        cmd('colorscheme gruvbox8')
    else
        cmd('colorscheme desert')
    end
end

--------------------------------------------------------------------------------
-- Files, backups
--------------------------------------------------------------------------------

function _G.set_files_backups_options()
    -- Turn backup off, since most stuff is in SVN, git etc. anyway...
    opt.backup = false
    opt.writebackup = false
    opt.swapfile = false

    -- Fix filetypes
    cmd('augroup FiletypeFix')
    cmd('   autocmd!')
    cmd('   autocmd BufNewFile,BufRead *.mm set filetype=objcpp')
    cmd('   autocmd BufNewFile,BufRead *.m set filetype=objc')
    cmd('augroup END')

    -- Finding files - Search down into subfolders
    opt.path:append('$PWD/*')
end

--------------------------------------------------------------------------------
-- Tab and indent
--------------------------------------------------------------------------------

function _G.set_indent_options()
    -- Use spaces instead of tabs
    opt.expandtab = true

    -- 1 tab == 4 spaces
    opt.shiftwidth = 4
    opt.tabstop = 4

    -- Copy indent from current line when starting a new line
    opt.autoindent = true

    -- Smart indent
    opt.smartindent = true

    -- Set whitespace chars
    opt.listchars = 'tab:>-,eol:¬¨,space:¬∑,trail:‚Ä¢'
    opt.list = false
end

--------------------------------------------------------------------------------
-- Folding
--------------------------------------------------------------------------------

-- Foldmethod
function _G.custom_fold_text()
    local line = trim(fn.getline(vim.v.foldstart))
    local line_count = vim.v.foldend - vim.v.foldstart + 1
    local offset = vim.v.foldlevel - 1
    local offset_string = " =   "

    offset_string = offset_string .. (string.rep("    ", offset))

    return offset_string .. line .. ": " .. line_count .. " lines"
end

function _G.set_folding_options()
    opt.foldmethod = 'indent'
    opt.foldlevelstart = 99
    opt.fillchars = { fold = " " }
    opt.foldtext = 'v:lua.custom_fold_text()'

    -- Save fold state
    cmd('augroup AutoSaveFolds')
    cmd('   autocmd!')
    cmd('   autocmd BufWinLeave * silent! mkview')
    cmd('   autocmd BufWinEnter * silent! loadview')
    cmd('augroup END')
end

--------------------------------------------------------------------------------
-- Status line
--------------------------------------------------------------------------------

function _G.set_statusline_options()
    local part1 = ' %3.(%n%): %f %y %m%r%h %w'
    local part2 = '%=%{&fileencoding?&fileencoding:&encoding}'
    local part3 = ' %-3.(%c%)%(%l/%L%) %(%P%)  '

    opt.statusline = part1 .. part2 .. part3
end

--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------

function _G.set_mappings()
    local options = {noremap = true, silent = true}

    -- Leader
    g.mapleader = "'"

    -- Copy and paste with system clipboard
    map('v', '<C-c>', '"+y',   options)
    map('i', '<C-v>', '<C-r>+', options)

    -- Buffer navigation
    map('n', '<C-l>', ':bn<cr>', options)
    map('n', '<C-h>', ':bp<cr>', options)

    -- Turn off serch highlight
    map('n', '<esc><esc>', ':<C-u>nohlsearch<cr>', options)

    -- Toggle whitespace showing
    map('n', '<leader>l', ':set list!<cr>', options)

    map('n', '<leader>v', ':Lexplore<cr>', options)
end

--------------------------------------------------------------------------------
-- Misc
--------------------------------------------------------------------------------

function _G.apply_settings()
    cmd('source $MYVIMRC')
end

function _G.misc_setup()
    -- Autoreload settings
    cmd('augroup AutoReloadSettings')
    cmd('   autocmd!')
    cmd('   autocmd BufWritePost $MYVIMRC call v:lua.apply_settings()')
    cmd('augroup END')
end

--------------------------------------------------------------------------------
-- Plugins
--------------------------------------------------------------------------------

function _G.setup_lsp()
    vim.lsp.set_log_level 'trace'

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

    local signs = { Error = "ÔÉß ", Warning = "ÔÑ™ ", Hint = "Ô†¥ ", Information = "ÔÑ© " }

    for t, icon in pairs(signs) do
      local hl = "LspDiagnosticsSign" .. t
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

end

function _G.setup_plugins()
    local function install_packer()
        local install_dir = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
        local repo = 'https://github.com/wbthomason/packer.nvim'
        local install_cmd = string.format('!git clone --depth=1 %s %s', repo, install_dir)

        if fn.empty(fn.glob(install_dir)) > 0 then
            print('Install packer ...')
            cmd(install_cmd)
        end

        cmd('packadd packer.nvim')
    end

    local function add_plugins(use)
        -- Packer itself
        use 'wbthomason/packer.nvim'

        -- LSP
        use 'neovim/nvim-lspconfig'
        use 'kabouzeid/nvim-lspinstall'
        use 'nvim-lua/completion-nvim'

        -- Colorschemes
        use 'tjdevries/colorbuddy.nvim'
        use 'Th3Whit3Wolf/onebuddy'
        use 'marko-cerovac/material.nvim'
        use 'rafamadriz/neon'
        use 'lifepillar/vim-gruvbox8'
        use 'folke/lsp-colors.nvim'

        -- Icons
        use 'kyazdani42/nvim-web-devicons'

        -- Statusline
        use 'beauwilliams/statusline.lua'
    end

    install_packer()

    local packer = require'packer'
    packer.startup(add_plugins)
    packer.install()
    packer.compile()

    setup_lsp()

    require 'lsp-colors'.setup()
end

--------------------------------------------------------------------------------
-- Apply all setup
--------------------------------------------------------------------------------

set_general_options()
set_search_options()
set_files_backups_options()
set_indent_options()
set_folding_options()
set_statusline_options()

setup_plugins()

set_colorscheme()
set_mappings()
misc_setup()


