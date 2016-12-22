"=============================================================================
" FILE: plugin/neomake/autolint.vim
" AUTHOR: dojoteef
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpoptions
set cpoptions&vim

"=============================================================================
" COMMANDS: Neomake Autolint commands
"=============================================================================
command! -nargs=* -bang -complete=buffer
      \ NeomakeAutolintToggle call neomake#autolint#Toggle(<bang>0, [<f-args>])

"=============================================================================
" AUTOCOMMANDS: Neomake Autolint autocommands
"=============================================================================
" Create autocmd group and remove any existing autocmds, in case the script is
" re-sourced.
augroup neomake_autolint
  autocmd!
augroup END

if neomake#autolint#config#Get('enabled')
  if has('vim_starting')
    " Need to wait until VimEnter has been called before setting up the
    " autolinting otherwise it may interfere with other plugins on startup.
    autocmd neomake_autolint VimEnter * call neomake#autolint#Startup()
  else
    call neomake#autolint#Startup()
  endif
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
