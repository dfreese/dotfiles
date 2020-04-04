set nocompatible              " be iMproved, required
filetype off                  " required

function! PlugLocation()
  if has('nvim')
    return '~/.local/share/nvim/site/autoload/plug.vim'
  else
    return '~/.vim/autoload/plug.vim'
  endif
endfunction

function! AutoInstallPlug()
  let l:plug_location = PlugLocation()
  if empty(glob(l:plug_location))
    silent execute join(['!curl -fLo', l:plug_location,
          \ '--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'], ' ')
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
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
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer --rust-completer' }
Plug 'kana/vim-operator-user'
Plug 'google/vim-maktaba'
Plug 'bazelbuild/vim-bazel'
Plug 'bazelbuild/vim-ft-bzl'
Plug 'sheerun/vim-polyglot'
Plug 'wesQ3/vim-windowswap'
Plug 'mhinz/vim-signify'
Plug 'lotabout/skim', { 'dir': '~/.skim', 'do': './install' }
Plug 'jlanzarotta/bufexplorer'
Plug 'NLKNguyen/papercolor-theme'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()

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
" set cuda header files used in cudarecon to be parsed as cpp files
au BufNewFile,BufFilePre,BufRead *.cuh set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.py set filetype=python
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
au BufNewFile,BufFilePre,BufRead *.rs set filetype=rust

au filetype cpp set tw=80 fo+=t colorcolumn=81 tabstop=2 shiftwidth=2 softtabstop=2
au filetype rust set tw=80 fo+=t colorcolumn=81 tabstop=4 shiftwidth=4 softtabstop=4
au filetype python set tw=80 fo+=t colorcolumn=81 tabstop=4 shiftwidth=4 softtabstop=4
au filetype gitcommit set tw=72 tabstop=2 fo+=t colorcolumn=73
au filetype markdown set tw=80 fo+=t colorcolumn=81



" Default to /// for doxygen comments
let g:DoxygenToolkit_commentType = "C++"

function! ChompedSystem( ... )
  return substitute(call('system', a:000), '\n\+$', '', '')
endfunction

function! GitTLD()
  let l:parent = expand('%:h')
  let l:cmd = "git -C " . l:parent . " rev-parse --show-toplevel"
  let l:output = ChompedSystem(l:cmd)
  if v:shell_error != 0
    return ""
  endif
  return l:output
endfunction

function! SkimGitTLD()
  execute "SK " . GitTLD()
endfunction


function! PotentialHeaderSourcePair()
 let l:filebase = expand("%:p:r")
 let l:fileext = expand("%:e")
 let l:ext_pair = {"h": "cc", "cc": "h"}
 let l:suggested = get(ext_pair, l:fileext, l:fileext)
 return join([l:filebase, l:suggested], ".")
endfunction

function! OpenPair(cmd)
 let l:pair = PotentialHeaderSourcePair()
 let l:cmd = join([a:cmd, l:pair], " ")
 execute l:cmd
endfunction

function! OpenParentFolder(cmd)
 let l:parent = expand("%:p:h")
 let l:cmd = join([a:cmd, l:parent], " ")
 execute l:cmd
endfunction

function! GetBuildFile()
 let l:package = system("bazel query --output=package ".expand("%"))
 let l:fullpackage = join([Workspace(), l:package], "/")
 return substitute(l:fullpackage, "\n$", "/BUILD", "")
endfunction

function! OpenBuildFile(cmd)
 " maybe replace with something like
 " $(bazel query main.cc -output=package):build
 " once i can figure out how the relative versus absolute filename convention
 " goes.
 " old version:
 let l:parent = expand("%:p:h")
 let l:build= join([l:parent, "BUILD"], "/")
 " new version:
 " let l:build = GetBuildFile()
 let l:cmd = join([a:cmd, l:build], " ")
 execute l:cmd
endfunction

function! HeaderGuardMacro()
 let l:macro = expand("%:p")
 " remove the the workspace path and its associated slash
 let l:macro = substitute(l:macro, GitTLD() . "/", "", "")
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

function! AddPairHeader()
 let l:header = expand("%:p:r") . ".h"
 " remove the the workspace path and its associated slash
 let l:header = substitute(l:header, Workspace() . "/", "", "")
 let l:header = "#include \"" . l:header
 let l:header = l:header . "\""
 return append(0, l:header)
endfunction

function! FileExists(file)
  " https://stackoverflow.com/a/23496813
  return !empty(glob(a:file))
endfunction

function! WorkspaceInternal(dir)
  let l:parent = fnamemodify(a:dir, ':h')
  if l:parent == '/' || FileExists(l:parent . '/' . 'WORKSPACE')
    return l:parent
  endif
  return WorkspaceInternal(l:parent)
endfunction

function! Workspace()
  let l:parent = expand("%:p:h")
  let l:workspace = WorkspaceInternal(l:parent)
  if l:workspace != '/'
    return l:workspace
  endif
  " just return the git tld if we're not in a bazel workspace
  let l:git = GitTLD()
  if !empty(l:git)
    return l:git
  endif
  " not in a bazel workspace or git directory, just return the current dir.
  " This function doesn't really have a meaning in that case.
  return l:parent
endfunction

function! InWorkspace()
 return expand("%:p") =~ "^".Workspace()
endfunction

function! BazelParent()
 let l:parent = expand("%:p:h")
 return substitute(l:parent, Workspace(), "/", "")
endfunction

function! BazelPath()
 let l:filename = expand("%:t")
 return join([BazelParent(), l:filename], ":")
endfunction

function! BazelLocalAll()
 return join([BazelParent(), "*"], ":")
endfunction

function! BazelBuildCmd()
 let l:target = BazelPath()
 return join(["build", BazelPath()], " ")
endfunction

function! BazelWorldBuild()
 execute join([":bazel", BazelBuildCmd()], " ")
endfunction

function! BazelScope(scope)
 if a:scope == "local"
   return BazelLocalAll()
 elseif a:scope == "global"
   return BazelGlobal()
 endif
endfunction

function! BazelGlobal()
 let l:excludes = join([
       \ "//experimental/...",
       \ "//third_party/google/protobuf/...",
       \], " ")
 return join(["//... - set(", l:excludes, ")"], "")
endfunction


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
      \ 'ctrl-v': 'vsplit' }


nnoremap <leader>s :call SkimGitTLD()<CR>

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
nnoremap <c-_> :call NERDComment("n", "toggle")<cr>
vnoremap <c-_> :call NERDComment("n", "toggle")<cr>

nnoremap <leader>hv :call OpenPair("vsplit")<cr>
nnoremap <leader>hs :call OpenPair("split")<cr>
nnoremap <leader>he :call OpenPair("edit")<cr>
nnoremap <leader>ht :call OpenPair("tabnew")<cr>

nnoremap <leader>fv :call OpenParentFolder("vsplit")<cr>
nnoremap <leader>fs :call OpenParentFolder("split")<cr>
nnoremap <leader>fe :call OpenParentFolder("edit")<cr>
nnoremap <leader>ft :call OpenParentFolder("tabedit")<cr>

" nnoremap <leader>bv :call OpenBuildFile("vsplit")<cr>
" nnoremap <leader>bs :call OpenBuildFile("split")<cr>
" nnoremap <leader>be :call OpenBuildFile("edit")<cr>
" nnoremap <leader>bt :call OpenBuildFile("tabedit")<cr>

" Set clipboard convinience keybindings
" https://vi.stackexchange.com/a/96/20229
noremap <Leader>y "+y
noremap <Leader>p "+p
