
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

    -- Do not hide buffers
    vim.opt.hidden = false

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
end


--------------------------------------------------------------------------------
-- Files, backups
--------------------------------------------------------------------------------

function _G.delete_commit_editmsg_buffer()
    local buffers = vim.fn.getbufinfo('COMMIT_EDITMSG')
    for _, buf in pairs(buffers) do
        vim.cmd('bd ' .. buf.bufnr)
    end
end

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

    -- Auto remove COMMIT_EDITMSG buffers
    vim.cmd('augroup ClearBuffersList')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd VimLeavePre * :silent! lua delete_commit_editmsg_buffer()')
    vim.cmd('augroup END')

    -- Restore cursor position
    vim.api.nvim_create_autocmd({ "BufReadPost" }, {
        pattern = { "*" },
        callback = function()
            vim.api.nvim_exec('silent! normal! g`"zv', false)
        end,
    })

    vim.o.autoread = true
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
      command = "if mode() != 'c' | checktime | endif",
      pattern = { "*" },
    })
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

        -- TODO: Setup LSP if we need it
        -- LSP
        -- use 'neovim/nvim-lspconfig'
        -- use 'kabouzeid/nvim-lspinstall'
        -- use 'williamboman/nvim-lsp-installer'
        -- use 'nvim-lua/completion-nvim'

        -- Treesitter
        use {
            'nvim-treesitter/nvim-treesitter',
            run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
        }

        --Colorschemes 
        use 'sainnhe/sonokai' 

        --File tree 
        use {
            'kyazdani42/nvim-tree.lua',
            -- file icons
            requires = { 'kyazdani42/nvim-web-devicons' },
        }

        --Git
        use{
            'lewis6991/gitsigns.nvim',
            requires = {'nvim-lua/plenary.nvim'},
        } 
        end

        install_packer()

        -- Setup packer 
        local packer = require 'packer' 
        packer.startup(add_plugins) 
        packer.install() 
        packer.compile()

        require('gitsigns').setup()

        require("nvim-tree") .setup {
            sync_root_with_cwd = true, 
            respect_buf_cwd = true,
            update_focused_file =
            {
                enable = true,
            },
            git = {
                enable = true,
                ignore = false,
            }
        }
end

--------------------------------------------------------------------------------
-- Netrw
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

    vim.g.netrw_localrmdir='rm -rf'
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


    -- Sonokai theme setup
    vim.g.sonokai_style = 'default' -- 'default', 'atlantis', 'andromeda', 'shusia', `maia', 'espresso'
    vim.g.sonokai_disable_italic_comment = 1

    vim.cmd('colorscheme sonokai')
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

    -- Not so annoying diagnostics
    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        {
            virtual_text = false,
            signs = true,
            update_in_insert = true,
            underline = false,
        }
    )

    -- Set message icons
    local signs = { Error = ' ', Warning = ' ', Hint = ' ', Information = ' ' }

    for t, icon in pairs(signs) do
      local hl = 'LspDiagnosticsSign' .. t
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Messages highlight
    require 'lsp-colors'.setup()

    -- Completion
    vim.g.completion_trigger_keyword_length = 3
    vim.g.completion_enable_auto_popup = false
end

--------------------------------------------------------------------------------
-- Treesitter
--------------------------------------------------------------------------------

function _G.setup_treesitter()
    local tsconfig = require 'nvim-treesitter.configs'

    tsconfig.setup {
        ensure_installed = {'bash', 'c', 'cpp', 'cmake', 'yaml', 'json', 'comment', 'lua', 'vim'},
        sync_install = true,
        auto_install = false,
        highlight = { enable = true },

    }
end


--------------------------------------------------------------------------------
-- Formating
--------------------------------------------------------------------------------

function _G.clang_format_file()
    local remove_trailing_whitespace = { cmd = {"sed -i '' -e's/[ \t]*$//'"} }
    local filepath = vim.fn.expand('%:p')
    local clang_format = 'clang-format -style=file -i ' .. filepath

    vim.fn.system(clang_format)
    vim.api.nvim_command('checktime')
end


function _G.setup_format()
    -- Run format on save
    vim.cmd('augroup Format')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufWritePost *.c,*.cpp,*.m,*.mm,*.h,*.hpp :silent! lua clang_format_file()')

    -- Don't auto commenting new lines
    vim.cmd('   autocmd BufEnter * set fo-=c fo-=r fo-=o')
    vim.cmd('augroup END')
end


--------------------------------------------------------------------------------
-- Status line
--------------------------------------------------------------------------------

function _G.get_git_status()
    local hunks = {0,0,0} -- vim.api.nvim_eval('GitGutterGetHunkSummary()')

    local hunks_string = ''
    if hunks[1] > 0 or hunks[2] > 0 or hunks[3] > 0 then
        hunks_string = string.format('+%d ~%d -%d', hunks[1], hunks[2], hunks[3])
    end

    return hunks_string
end

function _G.update_git_branch()
    local branch = trim(vim.fn.system("git rev-parse --abbrev-ref HEAD"))
    if branch:find('not a git repository') then
        branch = ''
    end

    vim.g.git_branch = branch
end

function _G.get_git_branch()
    local branch_string = ''
    if vim.g.git_branch:len() > 0 then
        branch_string = ' ' .. vim.g.git_branch
    end

    return branch_string
end

function _G.setup_statusline()
    local parts = {
        '%3.(%n%): ',                                -- buffer_number
        '%f ',                                       -- file_name
        '%m%r%h%w',                                  -- modified, readonly, help, preview flags
        ' %{v:lua.get_git_branch()}',                -- git branch
        ' %{v:lua.get_git_status()}',                -- git status
        '%=',                                        -- right_align
        '%{&fileencoding?&fileencoding:&encoding} ', -- encoding
        '%y %q',                                     -- filetype or quickfi
        ' %-3.(%c%)%(%l/%L%) %(%P%)  ',              -- position
    }

    vim.opt.statusline = table.concat(parts)
end

vim.cmd('augroup UpdateGitBranch')
vim.cmd('   autocmd!')
vim.cmd('   autocmd BufEnter * :silent! lua update_git_branch()')
vim.cmd('augroup END')

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
        label = '+ ' .. label
    end

    return label
end

function _G.tabline_getcwd()
    return vim.fn.getcwd()
end

-- "Rename tabs to show tab# and # of viewports
-- if exists("+showtabline")
--     function! MyTabLine()
--         let s = ''
--         let wn = ''
--         let t = tabpagenr()
--         let i = 1
--         while i <= tabpagenr('$')
--             let buflist = tabpagebuflist(i)
--             let winnr = tabpagewinnr(i)
--             let s .= '%' . i . 'T'
--             let s .= (i == t ? '%1*' : '%2*')
--             let s .= ' '
--             let wn = tabpagewinnr(i,'$')
--
--             let s .= (i== t ? '%#TabNumSel#' : '%#TabNum#')
--             let s .= i
--             if tabpagewinnr(i,'$') > 1
--                 let s .= '.'
--                 let s .= (i== t ? '%#TabWinNumSel#' : '%#TabWinNum#')
--                 let s .= (tabpagewinnr(i,'$') > 1 ? wn : '')
--             end
--
--             let s .= ' %*'
--             let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
--             let bufnr = buflist[winnr - 1]
--             let file = bufname(bufnr)
--             let buftype = getbufvar(bufnr, 'buftype')
--             if buftype == 'nofile'
--                 if file =~ '\/.'
--                     let file = substitute(file, '.*\/\ze.', '', '')
--                 endif
--             else
--                 let file = fnamemodify(file, ':p:t')
--             endif
--             if file == ''
--                 let file = '[No Name]'
--             endif
--             let s .= file
--             let s .= (i == t ? '%m' : '')
--             let i = i + 1
--         endwhile
--         let s .= '%T%#TabLineFill#%='
--         return s
--     endfunction
--     set stal=2
--     set tabline=%!MyTabLine()
-- endif

-- set tabpagemax=15
-- hi TabLineSel term=bold cterm=bold ctermfg=16 ctermbg=229
-- hi TabWinNumSel term=bold cterm=bold ctermfg=90 ctermbg=229
-- hi TabNumSel term=bold cterm=bold ctermfg=16 ctermbg=229
--
-- hi TabLine term=underline ctermfg=16 ctermbg=145
-- hi TabWinNum term=bold cterm=bold ctermfg=90 ctermbg=145
-- hi TabNum term=bold cterm=bold ctermfg=16 ctermbg=145

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
    table.insert(parts, '%= %{v:lua.tabline_getcwd()}')

    vim.opt.tabline = table.concat(parts)

    vim.cmd('augroup UpdateTabLine')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufEnter * :redrawtabline')
    vim.cmd('augroup END')
end


--------------------------------------------------------------------------------
-- Quickfix
--------------------------------------------------------------------------------

function _G.setup_quickfix()
    vim.cmd('augroup QuickfixSetup')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufReadPost quickfix setlocal wrap')
    vim.cmd('augroup END')
end


--------------------------------------------------------------------------------
-- Projects
--------------------------------------------------------------------------------

function _G.update_tags_file()
    local ctags = "ctags -R "
    ctags = ctags.."--sort=1 --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ "
    ctags = ctags.."--exclude='.cache/*' --exclude='output/*' --exclude='build/*'"

    print(ctags)
    vim.fn.system(ctags)
end

function _G.run_executable(exe)
    local exe_file = exe
    vim.fn.findfile('./build/test/' .. exe)
    if not (vim.fn.findfile('./build/test/' .. exe) == "") then
        exe_file = './' .. exe
    elseif not (vim.fn.findfile('./build/test/Debug/' .. exe) == "") then
        exe_file = './Debug/' .. exe
    end

    local cmd = "cd ./build/test && " .. exe_file
    print(cmd)

    print(vim.fn.system(cmd))
end


function _G.setup_project()
    local function setup_neutrino_framework()
        vim.opt.makeprg = 'cmake --build ./build'

        vim.opt.wildignore:append('build/*,output/*')

        -- Run command
        vim.cmd('command! -nargs=1 Run call v:lua.run_executable(<f-args>)')

        -- Generate tags file
        vim.cmd('command! Ctags call v:lua.update_tags_file()')
    end
end

function _G.setup_project_commands()
    vim.cmd('augroup ProjectSupport')
    vim.cmd('   autocmd!')
    vim.cmd('   autocmd BufEnter,BufWritePost * :silent! lua setup_project()')
    vim.cmd('   autocmd BufWritePost *.cpp,*.hpp,*mm :silent! lua update_tags_file()')
    vim.cmd('augroup END')
end

vim.cmd('command! SetupProject call v:lua.setup_project()')


--------------------------------------------------------------------------------
-- Mappings
--------------------------------------------------------------------------------

function _G.switch_source_header()
    local fname = vim.fn.expand('%:t:r')
    local ext = vim.fn.expand('%:e')

    local headers = {'h', 'hpp', 'hh', 'hxx', 'h++'}
    local sources = {'c', 'cpp', 'cc', 'cxx', 'c++', 'm', 'mm'}

    local function is_header(e)
        return table.contains(headers, e)
    end

    local function is_source(e)
        return table.contains(sources, e)
    end

    local function find_match_file(name, extensions)
        for _, e in pairs(extensions) do
            local files = vim.fn.findfile(name .. '.' .. e)
            if not (files == "") then
                return files
            end
        end

        return ""
    end

    local match_file = ""
    if is_header(ext) then
        match_file = find_match_file(fname, sources)
    elseif is_source(ext) then
        match_file = find_match_file(fname, headers) 
    end

    if not(match_file == "") then
        vim.cmd('e '..match_file) 
    end 
end


function _G.setup_mappings()
    local options = {noremap = true, silent = false}
    local nmap = function(key, action) vim.api.nvim_set_keymap('n', key, action, options) end
    
    -- Leader 
    vim.g.mapleader = "'"
    
    -- Buffer navigation 
    nmap('<C-l>', ':bn<cr>') nmap('<C-h>', ':bp<cr>')
    
    -- Turn off serch highlight 
    nmap('<esc><esc>', ':noh<CR>')
    
    -- Toggle whitespace showing 
    nmap('<leader>l', ':set list!<cr>')
    
    -- File tree 
    nmap('<leader>v', ':NvimTreeToggle<cr>')
    
    -- LSP
    -- nmap('K', '<cmd>lua vim.lsp.buf.hover()<cr>')
    
    -- nmap('gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')
    -- nmap( 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')
    -- nmap('gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')
    
    -- nmap( '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>')
    
    --Jump by diagnostics
    -- WARNING : DO NOT USE 'd' IN BINDINGS, IT MAY CORRUPT YOU FILE
    -- nmap('[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>')
    -- nmap(']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>')
    
    -- Alt + o 
    nmap('ø', '<cmd>lua _G.switch_source_header()<CR>')
    
    -- Compilation errors 
    nmap('[c', ':cp<cr>')
    nmap(']c', ':cn<cr>')
    
    -- Git hunks
    nmap(']h', '<cmd>lua require"gitsigns.actions".next_hunk()<CR>')
    nmap('[h', '<cmd>lua require"gitsigns.actions".prev_hunk()<CR>')
    
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
-- setup_lsp()
setup_treesitter()
setup_format() 
setup_statusline() 
setup_tabline()
setup_quickfix()
-- setup_project_commands()
setup_mappings()

