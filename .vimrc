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
Plug 'tpope/vim-git'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'vim-scripts/DoxygenToolkit.vim'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'Valloric/YouCompleteMe'
Plug 'kana/vim-operator-user'
" Plug 'rhysd/vim-clang-format'
Plug 'google/vim-maktaba'
" Plug 'Chiel92/vim-autoformat'
" Plug 'google/vim-glaive'
" Plug 'google/vim-codefmt'
Plug 'bazelbuild/vim-bazel'
Plug 'bazelbuild/vim-ft-bzl'
Plug 'sheerun/vim-polyglot'
Plug 'wesQ3/vim-windowswap'
Plug 'mhinz/vim-signify'
Plug 'lotabout/skim', { 'dir': '~/.skim'}
if has('nvim')
  " Plug 'autozimu/LanguageClient-neovim', {
  "       \ 'branch': 'next',
  "       \ 'do': 'bash install.sh',
  "       \ }
  " " (Optional) Multi-entry selection UI.
  " " Plug 'junegunn/fzf'
  " Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
endif
call plug#end()

let g:airline_theme='luna'
syntax on
set ruler
set number
colorscheme desert

set tabstop=2       " The width of a TAB is set to 2.
                    " Still it is a \t. It is just that
                    " Vim will interpret it to be having
                    " a width of 2.
set shiftwidth=2    " Indents will have a width of 2
set softtabstop=2   " Sets the number of columns for a TAB
set expandtab       " Expand TABs to spaces
set hlsearch
set showcmd
" Set space to the leader by mapping space to backslash
" https://superuser.com/a/693644/342470
let mapleader="\\"
map <Space> \

let g:ycm_confirm_extra_conf=0

au BufNewFile,BufFilePre,BufRead *.h set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.hh set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.cpp set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.cc set filetype=cpp
au BufNewFile,BufFilePre,BufRead *.proto set filetype=proto
" set cuda header files used in cudarecon to be parsed as cpp files
au BufNewFile,BufFilePre,BufRead *.cuh set filetype=cpp
" au BufNewFile,BufFilePre,BufRead BUILD set filetype=build

au BufNewFile,BufFilePre,BufRead *.py set filetype=python

" au BufNewFile,BufFilePre,BufRead COMMIT_EDITMSG set filetype=git

au filetype cpp set tw=80 fo+=t colorcolumn=81
au filetype gitcommit set tw=72 tabstop=2 fo+=t colorcolumn=73

" https://www.reddit.com/r/vim/comments/43sfkm/vim_auto_wrap_long_lines_when_writing/czkwnyb/
au BufNewFile,BufFilePre,BufRead *.md set filetype=markdown tw=80 fo+=t colorcolumn=81
highlight colorcolumn ctermbg=235 guibg=#2c2d27

" apply ycm fixit
map <f9> :YcmCompleter FixIt<cr>

let g:ycm_autoclose_preview_window_after_completion=1

" Default to /// for doxygen comments
let g:DoxygenToolkit_commentType = "C++"


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

" let g:clang_format#command = "clang-format-3.8"
" let g:clang_format#detect_style_file = 1
" let g:clang_format#auto_format = 1
" let g:clang_format#auto_format_on_insert_leave = 1
" let g:clang_format#code_style = "google"

" let g:formatdef_clangformat = '"clang-format-3.8"'
" let g:formatter_yapf_style = 'Google'
" Disable vim's autoformatting
" let g:autoformat_autoindent = 0
" let g:autoformat_retab = 0
" let g:autoformat_remove_trailing_spaces = 0
" au BufWrite * :Autoformat


" Couldn't get autoformat to deal with proto files correctly.  Hack it in
" based on this answer:
" https://vi.stackexchange.com/a/3971
function! ClangFormatBuffer()
  execute system("clang-format-3.8 -style=Google -i ".expand("%"))
  edit
endfunction

function! BuildifierCurrentFile()
  execute system("buildifier ".expand("%"))
  edit
endfunction

augroup FormatOnWrite
  autocmd FileType cpp
    \ autocmd! FormatOnWrite BufWritePost <buffer> call ClangFormatBuffer()
  autocmd FileType proto
    \ autocmd! FormatOnWrite BufWritePost <buffer> call ClangFormatBuffer()
  autocmd FileType bzl
    \ autocmd! FormatOnWrite BufWritePost <buffer> call BuildifierCurrentFile()
augroup END
au FileType proto au BufWrite :call ClangFormatBuffer()<cr>



" nnoremap <leader>= :Autoformat<cr>


" map ctrl-/ to toggle comments in the strangest way possible.
" https://stackoverflow.com/a/48690620/2465202
nnoremap <c-_> :call NERDComment("n", "toggle")<cr>
vnoremap <c-_> :call NERDComment("n", "toggle")<cr>

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

nnoremap <leader>hv :call OpenPair("vsplit")<cr>
nnoremap <leader>hs :call OpenPair("split")<cr>
nnoremap <leader>he :call OpenPair("edit")<cr>
nnoremap <leader>ht :call OpenPair("tabnew")<cr>

function! OpenParentFolder(cmd)
 let l:parent = expand("%:p:h")
 let l:cmd = join([a:cmd, l:parent], " ")
 execute l:cmd
endfunction

nnoremap <leader>fv :call OpenParentFolder("vsplit")<cr>
nnoremap <leader>fs :call OpenParentFolder("split")<cr>
nnoremap <leader>fe :call OpenParentFolder("edit")<cr>
nnoremap <leader>ft :call OpenParentFolder("tabedit")<cr>

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

nnoremap <leader>bv :call OpenBuildFile("vsplit")<cr>
nnoremap <leader>bs :call OpenBuildFile("split")<cr>
nnoremap <leader>be :call OpenBuildFile("edit")<cr>
nnoremap <leader>bt :call OpenBuildFile("tabedit")<cr>

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

function! BazelGlobal()
 let l:excludes = join([
       \ "//experimental/...",
       \ "//third_party/google/protobuf/...",
       \], " ")
 return join(["//... - set(", l:excludes, ")"], "")
endfunction

function! BazelBuildQuery(scope)
 let l:rdep = join(["rdeps(", a:scope, ", ", BazelPath(), ")"], "")
 let l:kinds = "(qt5_|linux_|)cc_(library|binary|test|inc_library|proto_library)"
 let l:kind = join(["kind(\"", l:kinds, "\", ", l:rdep, ")"], "")
 let l:query = join(["bazel query '", l:kind, "'"], "")
 return l:query
endfunction

function! BazelTestQuery(scope)
 let l:query = join(["tests(rdeps(", a:scope, ", ", BazelPath(), "))"], "")
 return join(["bazel query '", l:query, "'"], "")
endfunction

function! ShellWrap(cmd)
 return join(["$(", a:cmd, ")"], "")
endfunction

function! BazelOnBuild(cmd, scope)
 return join(
       \["bazel", a:cmd, ShellWrap(BazelBuildQuery(a:scope))],
       \" ")
endfunction

function! BazelOnTest(cmd, scope)
 return join(
       \["bazel", a:cmd, ShellWrap(BazelTestQuery(a:scope))],
       \" ")
endfunction

function! BazelScope(scope)
 if a:scope == "local"
   return BazelLocalAll()
 elseif a:scope == "global"
   return BazelGlobal()
 endif
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
 rightbelow pedit +enew
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
 let l:scope = BazelScope(a:scope)
 if a:cmd == "build"
   let l:cmd = "build".l:opts
   let l:full_cmd = BazelOnBuild(l:cmd, l:scope)
   if has('nvim')
     call RunCommandInPreviewTerminal(l:full_cmd)
   else
     call s:executeinshell(l:full_cmd)
   endif
 elseif a:cmd == "test" || a:cmd == "asan"
   let l:test_args = " --test_summary=terse --test_output=errors"
   if a:cmd == "asan"
     let l:test_args = " --config=asan".l:test_args
   endif
   let l:cmd = "test".l:opts.l:test_args
   let l:full_cmd = BazelOnTest(l:cmd, l:scope)
   if has('nvim')
     call RunCommandInPreviewTerminal(l:full_cmd)
   else
     call s:executeinshell(l:full_cmd)
   endif
 endif
endfunction

nnoremap <leader>lb :call RunBazel("build", "local")<cr>
nnoremap <leader>lt :call RunBazel("test", "local")<cr>
nnoremap <leader>la :call RunBazel("asan", "local")<cr>
nnoremap <leader>kb :call RunBazel("build", "global")<cr>
nnoremap <leader>kt :call RunBazel("test", "global")<cr>
nnoremap <leader>ka :call RunBazel("asan", "global")<cr>

" https://stackoverflow.com/a/10512195/2465202
function! s:ExecuteInShell(command)
 let command = join(map(split(a:command), 'expand(v:val)'))
 let winnr = bufwinnr('^' . command . '$')
 silent! execute  winnr < 0 ? 'botright vnew ' . fnameescape(command) : winnr . 'wincmd w'
 setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber
 silent! execute "noautocmd botright pedit ".tempname()
 echo 'Execute ' . command . '...'
 noautocmd wincmd P
 setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber
 silent! execute 'silent r!'. command
 let l:returncode = v:shell_error
 silent! execute 'silent %!'. command
 silent! redraw
 silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
 silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>:AnsiEsc<CR>'
 silent! execute 'nnoremap <silent> <buffer> q :q<CR>'
 silent! execute 'AnsiEsc'
 wincmd p
 if l:returncode == 0
   noautocmd wincmd z
   echo 'Shell command executed successfully.'
 else
   echo 'Shell command returned '.l:returncode
 endif
endfunction
command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)


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

" set cursorline
" :hi CursorLine cterm=NONE ctermbg=darkgray
" :hi CursorColumn cterm=NONE ctermbg=darygray ctermfg=white guibg=darkred guifg=white
" :nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

set cursorline
highlight CursorLine ctermfg=None ctermbg=233 guifg=fg guibg=None cterm=None
set path+=$VERB_HOME

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

nnoremap <leader>s :call SkimGitTLD()<CR>

let g:skim_height=8

if has('nvim')
  " The empty string overrides the default here, but vim doesn't like an empty
  " key, but nvim is fine with it.
  let g:skim_action= {
        \ '': 'vsplit',
        \ 'ctrl-e': 'edit',
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-x': 'split',
        \ 'ctrl-v': 'vsplit' }
endif


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

highlight YcmErrorSection ctermbg=235
highlight YcmErrorSign ctermbg=124

" highlight DiffAdd ctermbg=17
" highlight DiffChange ctermbg=17
" highlight DiffText ctermbg=18
" highlight DiffDel ctermbg=52

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

" Set clipboard convinience keybindings
" https://vi.stackexchange.com/a/96/20229
noremap <Leader>y "+y
noremap <Leader>p "+p
