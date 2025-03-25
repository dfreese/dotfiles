set nocompatible              " be iMproved, required
filetype off                  " required
set splitright
set mouse=

function! FileExists(file)
  " https://stackoverflow.com/a/23496813
  return !empty(glob(a:file))
endfunction

function! SearchUpTreeImpl(dir, file)
  if a:dir == '/'
    return ""
  endif
  if FileExists(a:dir . '/' . a:file)
    return a:dir
  endif
  return SearchUpTreeImpl(fnamemodify(a:dir, ':h'), a:file)
endfunction

function! SearchUpTree(file)
  return SearchUpTreeImpl(expand("%:p:h"), a:file)
endfunction

function! PlugLocation()
  if has('nvim')
    return '~/.local/share/nvim/site/autoload/plug.vim'
  else
    return '~/.vim/autoload/plug.vim'
  endif
endfunction

function! AutoInstallPlug()
  let l:plug_location = PlugLocation()
  if FileExists(l:plug_location)
    return
  endif
  silent execute join(['!curl -fLo', l:plug_location,
        \ '--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'], ' ')
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endfunction

call AutoInstallPlug()

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-git'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --rust-completer' }
Plug 'kana/vim-operator-user'
Plug 'google/vim-maktaba'
Plug 'bazelbuild/vim-ft-bzl'
Plug 'sheerun/vim-polyglot'
Plug 'wesQ3/vim-windowswap'
Plug 'mhinz/vim-signify'
Plug 'lotabout/skim', { 'dir': '~/.skim', 'do': './install' }
Plug 'NLKNguyen/papercolor-theme'
" This, along with the tmux.conf allow ctrl-h/j/k/l between the different
" windows seemlessly.
Plug 'christoomey/vim-tmux-navigator'
" Used to generate a theme, It can cause some issues with separators, so see
" g:tmuxline_preset and g:tmuxline_separators below.  A configuration was
" generated using TmuxlineSnapshot and is source in tmux.conf.  tmuxline still
" overrides what's there, so things could get out of sync.  An alternative
" would be to comment out this plugin if we wanted to stop that behavior.
" Leave it for now, while getting settled.
" The presets were just taken from the README for this plugin.
Plug 'edkolev/tmuxline.vim'
Plug 'google/vim-glaive'
Plug 'google/vim-codefmt'
call plug#end()

call glaive#Install()

let g:tmuxline_preset = {
      \'a'    : '#S',
      \'b'    : '#W',
      \'c'    : '#H',
      \'win'  : '#I #W',
      \'cwin' : '#I #W',
      \'x'    : '%a',
      \'y'    : '#W %R',
      \'z'    : '#H'}

let g:tmuxline_separators = {
    \ 'left' : '',
    \ 'left_alt': '>',
    \ 'right' : '',
    \ 'right_alt' : '<',
    \ 'space' : ' '}

" Set space to the leader by mapping space to backslash
" https://superuser.com/a/693644/342470
let mapleader="\\"
map <Space> \

syntax on
set ruler
set number
set hlsearch
set showcmd
" This was the previous theme that I was using.  Leave it here for reference
" for a while until I'm sure that I'm good with papercolor.
" let g:airline_theme='luna'
let g:airline_theme='papercolor'
" colorscheme desert
set background=dark
colorscheme PaperColor
set cursorline

set expandtab       " Expand TABs to spaces

let g:ycm_confirm_extra_conf=0
let g:ycm_autoclose_preview_window_after_completion=1

" apply ycm fixit
map <C-p> :YcmCompleter FixIt<cr>


set tabstop=2       " The width of a TAB is set to 2.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 2.
set shiftwidth=2    " Indents will have a width of 2
set softtabstop=2   " Sets the number of columns for a TAB

au BufNewFile,BufFilePre,BufRead *.h set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.hh set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.cpp set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.cc set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.proto set filetype=proto
au BufNewFile,BufFilePre,BufRead *.py set filetype=python
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
au BufNewFile,BufFilePre,BufRead *.rs set filetype=rust
" au BufNewFile,BufFilePre,BufRead BUILD set filetype=bazel
" au BufNewFile,BufFilePre,BufRead WORKSPACE set filetype=bazel
" au BufNewFile,BufFilePre,BufRead *.BUILD set filetype=bazel
" au BufNewFile,BufFilePre,BufRead *.bazel set filetype=bazel
" au BufNewFile,BufFilePre,BufRead *.bzl set filetype=bazel

au filetype bzl set tw=80 fo+=t colorcolumn=81 tabstop=4 shiftwidth=4 softtabstop=4
au filetype cpp set tw=80 fo+=t colorcolumn=81 tabstop=2 shiftwidth=2 softtabstop=2
au filetype qml set tw=80 fo+=t colorcolumn=81 tabstop=2 shiftwidth=2 softtabstop=2
au filetype cuda set tw=80 fo+=t colorcolumn=81 tabstop=2 shiftwidth=2 softtabstop=2
au filetype rust set tw=100 fo+=t colorcolumn=101 tabstop=4 shiftwidth=4 softtabstop=4
au filetype python set tw=80 fo+=t colorcolumn=81 tabstop=4 shiftwidth=4 softtabstop=4
au filetype gitcommit set tw=72 tabstop=2 fo+=t colorcolumn=73
au filetype markdown set tw=80 fo+=t colorcolumn=81

function! PotentialHeaderSourcePair()
 let l:filebase = expand("%:p:r")
 let l:fileext = expand("%:e")
 let l:ext_pair = {"h": "cc", "cc": "h"}
 let l:suggested = get(ext_pair, l:fileext, l:fileext)
 return join([l:filebase, l:suggested], ".")
endfunction

function! ParentFolder()
 return expand("%:p:h")
endfunction

function! HeaderGuardMacro()
 let l:macro = expand("%:p")
 " remove the the workspace path and its associated slash
 let l:macro = substitute(l:macro, ProjectRoot() . "/", "", "")
 " replace all of the folder slashes with underscores
 let l:macro = substitute(l:macro, "/", "_", "g")
 " and replace the last file extension period with an underscore, but make sure
 " to escape it.  Otherwise, vim thinks it's a wildcard.j
 let l:macro = substitute(l:macro, "\\.", "_", "g")
 " add the trailing underscore
 let l:macro = l:macro . "_"
 " and switch it all to uppercase
 let l:macro = toupper(l:macro)
 return l:macro
endfunction

function! AddHeaderGuards()
  let l:macro = HeaderGuardMacro()
  let l:failed = append(0, ["#ifndef " . l:macro, "#define " . l:macro, ""])
  let l:failed = append(line('$'), ["", "#endif  // " . l:macro])
endfunction

function! UpdateHeaderGuards()
  let l:macro = HeaderGuardMacro()
  let l:failed = setline(1, "#ifndef " . l:macro)
  let l:failed = setline(2, "#define " . l:macro)
  let l:failed = setline(line('$'), "#endif  // " . l:macro)
endfunction

function! AddPairHeader()
 let l:header = expand("%:p:r") . ".h"
 " remove the the workspace path and its associated slash
 let l:header = substitute(l:header, ProjectRoot() . "/", "", "")
 let l:header = "#include \"" . l:header
 let l:header = l:header . "\""
 return append(0, l:header)
endfunction

function! UpdatePairHeader()
 let l:header = expand("%:p:r") . ".h"
 " remove the the workspace path and its associated slash
 let l:header = substitute(l:header, ProjectRoot() . "/", "", "")
 let l:header = "#include \"" . l:header
 let l:header = l:header . "\""
 return setline(1, l:header)
endfunction

function! AddNamespace(namespace)
  let l:startline = line("'<")
  let l:endline = line("'>")
  let l:header = "namespace " . a:namespace . " {"
  let l:footer= "} //  " . a:namespace

  let l:failed = append(l:endline, [l:footer])
  let l:failed = append(l:startline, [l:header])
endfunction

function! ProjectRoot()
  for l:dir in get(g:, 'project_root_indicators', [])
    let l:root = SearchUpTree(l:dir)
    if !empty(l:root)
      return l:root
    endif
  endfor
  return expand("%:p:h")
endfunction

function! InWorkspace()
 return !empty(SearchUpTree("WORKSPACE")) || !empty(SearchUpTree("MODULE.bazel"))
endfunction

function! BazelParent()
 let l:parent = expand("%:p:h")
 return substitute(l:parent, ProjectRoot(), "/", "")
endfunction

function! BazelPath()
 let l:filename = expand("%:t")
 return BazelParent() . ":" . l:filename
endfunction

function! BazelTargetsForScope(scope)
  if a:scope == "target" || a:scope == "package"
    return join([BazelParent(), "all"], ":")
  elseif a:scope == "global"
    let l:excludes = get(g:, 'bazel_global_excludes', [])
    if len(l:excludes) > 0
      return "//... - set(" . join(l:excludes, " ") . ")"
    endif
    return "//..."
  endif
endfunction

function! BazelDepthForScope(scope)
  if a:scope == "target"
    return 1
  elseif a:scope == "package"
    return 2
  elseif a:scope == "global"
    return -1
  endif
endfunction

let g:bazel_global_excludes = []
let g:bazel_workspace_indicators = [
      \ "MODULE.bazel",
      \ "WORKSPACE",
      \]
let g:project_root_indicators = [
      \ "MODULE.bazel",
      \ "WORKSPACE",
      \ "Cargo.toml",
      \ ".git",
      \]

" add spaces after comment delimiters by default
let g:NERDSpaceDelims = 1
" align line-wise comment delimiters flush left instead of following code
" indentation
let g:NERDDefaultAlign = 'left'
" allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1
" in visual mode, don't try to partially comment lines.
let g:NERDCommentWholeLinesInVmode = 1

let g:skim_layout = { 'down': 8 }
let g:skim_action= {
      \ '': 'vsplit',
      \ 'ctrl-e': 'edit',
      \ 'ctrl-t': 'tab split',
      \ 'ctrl-x': 'split',
      \ 'ctrl-v': 'vsplit',
      \}


nnoremap <leader>s :execute "SK " . ProjectRoot()<CR>

" Add a leader shortcut because key combination was finiky
nnoremap <leader>w <C-w>
nnoremap <leader>t :tabNext<cr>
nnoremap <leader>n :noh<CR>
" make it so escape gets out of terminal mode, instead of whatever it was for
" the default.  Like I'll remember that...
" https://vi.stackexchange.com/a/6966
if has('nvim')
  tnoremap <Esc> <C-\><C-n>
endif

" map ctrl-/ to toggle comments in the strangest way possible.
" https://stackoverflow.com/a/48690620/2465202
nnoremap <c-_> :call nerdcommenter#Comment("n", "toggle")<cr>
vnoremap <c-_> :call nerdcommenter#Comment("n", "toggle")<cr>

nnoremap <leader>hv :execute "vsplit " . PotentialHeaderSourcePair()<cr>
nnoremap <leader>hs :execute "split " . PotentialHeaderSourcePair()<cr>
nnoremap <leader>he :execute "edit " . PotentialHeaderSourcePair()<cr>
nnoremap <leader>ht :execute "tabedit " . PotentialHeaderSourcePair()<cr>

nnoremap <leader>fv :execute "vsplit " . ParentFolder()<cr>
nnoremap <leader>fs :execute "split " . ParentFolder()<cr>
nnoremap <leader>fe :execute "edit " . ParentFolder()<cr>
nnoremap <leader>ft :execute "tabedit " . ParentFolder()<cr>

nnoremap <leader>bv :execute "vsplit " . SearchUpTree("BUILD")<cr>
nnoremap <leader>bs :execute "split " . SearchUpTree("BUILD")<cr>
nnoremap <leader>be :execute "edit " . SearchUpTree("BUILD")<cr>
nnoremap <leader>bt :execute "tabedit " . SearchUpTree("BUILD")<cr>

augroup autoformat_settings
  autocmd FileType bzl AutoFormatBuffer buildifier
  autocmd FileType go AutoFormatBuffer gofmt
  autocmd FileType rust AutoFormatBuffer rustfmt
  autocmd FileType cpp AutoFormatBuffer clang-format
  autocmd FileType cuda AutoFormatBuffer clang-format
  autocmd FileType proto AutoFormatBuffer clang-format
  autocmd FileType python AutoFormatBuffer yapf
augroup END

function! RustFmtOptions()
  return ["--edition=2018"]
endfunction

Glaive codefmt plugin[mappings] rustfmt_options="RustFmtOptions"
Glaive codefmt plugin[mappings] clang_format_style="Google"

function! BazelBuildQuery(universe, depth)
  let l:depth = a:depth < 0 ? "" : ", " . a:depth
  return "bazel query 'rdeps(" . a:universe . ", " . BazelPath() . l:depth . ")'"
endfunction

function! BazelTestQuery(universe, depth)
  let l:depth = a:depth < 0 ? "" : ", " . a:depth
  return "bazel query 'tests(rdeps(" . a:universe . ", " . BazelPath() . l:depth . "))'"
endfunction

function! ShellWrap(cmd)
 return join(["$(", a:cmd, ")"], "")
endfunction

function! BazelOnBuild(cmd, scope, depth)
 return "cd " . ProjectRoot() . " && " . BazelBuildQuery(a:scope, a:depth) . " | xargs bazel " . a:cmd
endfunction

function! BazelOnTest(cmd, scope, depth)
 return "cd " . ProjectRoot() . " && " . BazelTestQuery(a:scope, a:depth) . " | xargs bazel " . a:cmd
endfunction

function! ClosePreviewWindowOnGoodExit(job_id, data, event)
 if a:event == 'exit' && a:data == 0
   noautocmd wincmd z
 elseif a:event == 'exit' && a:data != 0
   noautocmd wincmd P
   noautocmd 30wincmd +
   noautocmd wincmd p
 endif
endfunction

function! RunCommandInPreviewTerminal(cmd)
 " close the window, if it's open
 noautocmd wincmd z
 " and open it again.
 if winnr('$') == '1'
   " If this is the only window in this tab, open the window on the right,
   " taking up half of the space.
   vertical rightbelow pedit +enew
   noautocmd wincmd =
 else
   rightbelow pedit +enew
 endif
 noautocmd wincmd p
 call termopen(a:cmd, {'on_exit': 'ClosePreviewWindowOnGoodExit'})
 noautocmd wincmd p
endfunction

function! RunBazel(cmd, scope)
 if !InWorkspace()
   echo "not in bazel workspace"
   return
 endif
 let l:opts = ""
 if !has('nvim')
   let l:opts = l:opts." --color=no --curses=no"
 endif
 let l:opts = ""
 let l:universe = BazelTargetsForScope(a:scope)
 let l:depth = BazelDepthForScope(a:scope)
 if a:cmd == "build"
   let l:cmd = "build".l:opts
   let l:full_cmd = BazelOnBuild(l:cmd, l:universe, l:depth)
   if has('nvim')
     call RunCommandInPreviewTerminal(l:full_cmd)
   else
     call s:executeinshell(l:full_cmd)
   endif
 elseif a:cmd == "test"
   let l:test_args = " --test_summary=terse --test_output=errors"
   let l:cmd = "test".l:opts.l:test_args
   let l:full_cmd = BazelOnTest(l:cmd, l:universe, l:depth)
   if has('nvim')
     call RunCommandInPreviewTerminal(l:full_cmd)
   else
     call s:executeinshell(l:full_cmd)
   endif
 endif
endfunction

nnoremap <leader>lb :call RunBazel("build", "target")<cr>
nnoremap <leader>lt :call RunBazel("test", "target")<cr>
nnoremap <leader>kb :call RunBazel("build", "package")<cr>
nnoremap <leader>kt :call RunBazel("test", "package")<cr>

" Force Doxygen triple comments to the front of comments for C/C++ files.
autocmd Filetype c,cpp set comments^=:///

