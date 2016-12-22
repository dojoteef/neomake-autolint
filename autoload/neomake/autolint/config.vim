"=============================================================================
" FILE: autoload/neomake/autolint/config.vim
" AUTHOR: dojoteef
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpoptions
set cpoptions&vim

"=============================================================================
" CONFIGURATION: Global configuration values
"=============================================================================
" OPTION: g:neomake_autolint_enabled
" DEFAULT: neomake#has_async_support()
" By default Neomake Autolint is only enabled if Neomake has asynchronous job
" support which makes the lint as you type approach work without constant
" pauses. If you want it to be enabled whether you have asynchronous job
" support or not just set this to 1.
let s:neomake_autolint_enabled = neomake#has_async_support()

" OPTION: g:neomake_autolint_cachedir
" DEFAULT: ''
" Where to cache temporary files used for linting unwritten buffers. If
" g:neomake_autolint_cachedir is not specified, Neomake Autolint checks for
" $XDG_CACHE_HOME then $HOME/.cache. If no valid cache directory can be found
" the plugin will be disabled.
let s:neomake_autolint_cachedir = ''

" OPTION: g:neomake_autolint_updatetime
" DEFAULT: 500
" The number of milliseconds to wait before running another Neomake lint over
" the file.
let s:neomake_autolint_updatetime = 500

" OPTION: g:neomake_autolint_sign_column_always
" DEFAULT: 0
" Whether to keep the sign column showing all the time. If you find it
" annoying that the sign column flashes open/closed during autolinting set
" this to 1.
let s:neomake_autolint_sign_column_always = 0

" OPTION: g:neomake_autolint_events
" DEFAULT: {
"   'BufWinEnter': {'delay': 0},
"   'TextChanged': {},
"   'TextChangedI': {},
" }
" What events should trigger linting and what additional configuration options
" should be specified for the linting. For now the only option is a 'delay'
" which is how long after the event to wait before triggering the linting. If
" provided this overrides the global g:neomake_autolint_updatetime option.
let s:neomake_autolint_events = {
      \ 'BufWinEnter': {'delay': 0},
      \ 'TextChanged': {},
      \ 'TextChangedI': {},
      \ }

"=============================================================================
" Public Functions: Functions intended for use by users
"=============================================================================
function! neomake#autolint#config#Default(option) abort
  try
    let l:option_value = s:neomake_autolint_{a:option}
    return l:option_value
  catch /^Vim\%((\a\+)\)\=:E121:/
    call neomake#utils#LoudMessage(
          \ printf('%s is not a configuration option', a:option))
  endtry
endfunction

function! neomake#autolint#config#Get(option) abort
  return get(g:, printf('neomake_autolint_%s', a:option),
        \ neomake#autolint#config#Default(a:option))
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
