"=============================================================================
" FILE: autoload/neomake/autolint/utils.vim
" AUTHOR: dojoteef
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpoptions
set cpoptions&vim

function! s:determine_slash() abort
  let s:slash = &shellslash || !exists('+shellslash') ? '/' : '\'
endfunction
call s:determine_slash()

function! s:normalize_path(path) abort
  return substitute(a:path, '[\/]*$', '', '')
endfunction

function! s:join_path(...)
  if a:0
    if type(a:1) == type([])
      let l:path_list = a:1
    else
      let l:path_list = a:000
    endif
  else
    return ''
  endif

  return join(map(copy(l:path_list), 's:normalize_path(v:val)'), s:slash)
endfunction

function! s:usrcachedir() abort
  let l:usrcachedir = ''
  if exists('$XDG_CACHE_HOME') && isdirectory($XDG_CACHE_HOME)
    let l:usrcachedir = $XDG_CACHE_HOME
  endif

  if empty(l:usrcachedir) && isdirectory(s:join_path($HOME, '.cache'))
    let l:usrcachedir = s:join_path($HOME, '.cache')
  endif

  return l:usrcachedir
endfunction

function! neomake#autolint#utils#cachedir() abort
  if get(s:, 'cachedir')
    return s:cachedir
  endif

  let l:cachedir = get(g:, 'neomake_autolint_cachedir')
  let l:usrcachedir = s:usrcachedir()
  if empty(l:cachedir) && !empty(l:usrcachedir)
      let l:cachedir = l:usrcachedir
  endif

  if empty(l:cachedir)
    return ''
  endif

  let l:cachedir = s:join_path(l:cachedir, '.neomake_autolint_cache')
  if !isdirectory(l:cachedir)
    call mkdir(l:cachedir)
  endif

  let s:cachedir = l:cachedir
  return s:cachedir
endfunction

function! neomake#autolint#utils#tempfile(basename) abort
    let l:fname = expand(a:basename.':p:t')
    let l:tmpdir = fnamemodify(neomake#autolint#utils#cachedir(), ':p:h')
    return fnameescape(join([l:tmpdir, l:fname], '/'))
endfunction

function! neomake#autolint#utils#function(func) abort
  " See http://stackoverflow.com/a/17184285
  return substitute(a:func, '^s:', matchstr(expand('<sfile>'), '<SNR>\d\+_'),'')
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
