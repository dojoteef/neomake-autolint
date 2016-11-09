"=============================================================================
" FILE: plugin/neomake/autolint.vim
" AUTHOR: dojoteef
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpoptions
set cpoptions&vim

"=============================================================================
" CONFIGURATION: Global configuration values
"=============================================================================
" By default Neomake Autolint is only enabled if Neomake has asynchronous job
" support which makes the lint as you type approach work without constant
" pauses. If you want it to be enabled whether you have asynchronous job
" support or not just set this to 1.
let g:neomake_autolint_enabled = get(g:,
      \ 'neomake_autolint_enabled',
      \ neomake#has_async_support())

" Where to cache temporary files used for linting unwritten buffers. Defaults
" to checking for $XDG_CACHE_HOME then $HOME/.cache. If no valid cache
" directory can be found the plugin will be disabled.
let g:neomake_autolint_cachedir = get(g:,
      \ 'neomake_autolint_cachedir',
      \ '')

" The number of milliseconds to wait before running another Neomake lint over
" the file. Default to 500.
let g:neomake_autolint_updatetime = get(g:, 
      \ 'neomake_autolint_updatetime',
      \ 500)

" Whether to keep the sign column showing all the time. If you find it
" annoying that the sign column flashes open/closed during autolinting set
" this to 1. Defaults to 0.
let g:neomake_autolint_sign_column_always = get(g:,
      \ 'neomake_autolint_sign_column_always',
      \ 0)

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

if g:neomake_autolint_enabled
  " Define an invisible sign that can keep the sign column always showing
  execute 'sign define neomake_autolint_invisible'

  " Need to wait until VimEnter has been called before setting up the
  " autolinting otherwise it may interfere with other plugins on startup.
  autocmd neomake_autolint VimEnter * call neomake#autolint#Startup()
endif

let &cpoptions = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
