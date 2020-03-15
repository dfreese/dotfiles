" https://www.reddit.com/r/vim/comments/43sfkm/vim_auto_wrap_long_lines_when_writing/czkwnyb/
highlight colorcolumn ctermbg=235 guibg=#2c2d27

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

" set cursorline
" :hi CursorLine cterm=NONE ctermbg=darkgray
" :hi CursorColumn cterm=NONE ctermbg=darygray ctermfg=white guibg=darkred guifg=white
" :nnoremap <Leader>c :set cursorline! cursorcolumn!<CR>

set cursorline
highlight CursorLine ctermfg=None ctermbg=233 guifg=fg guibg=None cterm=None

highlight YcmErrorSection ctermbg=235
highlight YcmErrorSign ctermbg=124

" highlight DiffAdd ctermbg=17
" highlight DiffChange ctermbg=17
" highlight DiffText ctermbg=18
" highlight DiffDel ctermbg=52
