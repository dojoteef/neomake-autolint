"=============================================================================
" FILE: autoload/neomake/autolint/buffer.vim
" AUTHOR: dojoteef
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpoptions
set cpoptions&vim

let s:neomake_autolint_buffers = {}
let s:neomake_makers_for_buffer = {}

" Setup per buffer makers that use a temporary file for auto linting
function! neomake#autolint#buffer#makers(bufnr) abort
  if !has_key(s:neomake_makers_for_buffer, a:bufnr)
    let s:neomake_makers_for_buffer[a:bufnr] = {}
  endif
  let l:makers_for_buffer = s:neomake_makers_for_buffer[a:bufnr]

  let l:ft = &filetype
  let l:makers = []
  let l:maker_names = neomake#GetEnabledMakers(l:ft)
  let l:tmpfile = neomake#autolint#utils#tempfile('%')
  for l:maker_name in l:maker_names
    let l:maker = neomake#GetMaker(l:maker_name, l:ft)
    let l:full_maker_name = l:ft.'_'.l:maker_name

    " Some makers (like the default go makers) operate on an entire
    " directory which breaks for this file based linting approach. If
    " 'append_file' exists and is 0 then this is a maker which operates on
    " the directory rather than the file so skip it.
    if exists('l:maker') && get(l:maker, 'append_file', 1)
      if !exists('l:makers_for_buffer[l:full_maker_name]')
        " Make sure we lint the tempfile
        let l:maker.append_file = 0
        let l:index = index(l:maker.args, '%:p')
        if l:index > -1
          let l:maker.args[l:index] = l:tmpfile
        else
          call add(l:maker.args, l:tmpfile)
        endif

        " Wrap the existing mapexpr to do extra processing
        " after it completes
        let l:maker.mapexpr = printf('substitute(%s, "%s", "%s", "g")',
              \ get(l:maker, 'mapexpr', 'v:val'),
              \ l:tmpfile, expand('%'))

        let l:maker.name = l:full_maker_name
        let l:makers_for_buffer[l:full_maker_name] = l:maker
      endif

      call add(l:makers, l:maker)
    endif
  endfor

  return l:makers
endfunction

function! neomake#autolint#buffer#create(bufnr, makers) abort
  if neomake#autolint#buffer#has(a:bufnr)
    call neomake#utils#DebugMessage(printf(
          \ 'Autolint buffer for bufnr %d already exists!', a:bufnr))
    return s:neomake_autolint_buffers[a:bufnr]
  endif

  " This is a filetype with makers
  let s:neomake_autolint_buffers[a:bufnr] = {
        \ 'bufnr': a:bufnr,
        \ 'makers': a:makers,
        \ 'tmpfile': neomake#autolint#utils#tempfile('%'),
        \ 'timerid': -1
        \ }

  return s:neomake_autolint_buffers[a:bufnr]
endfunction

function! neomake#autolint#buffer#has(bufnr) abort
  return has_key(s:neomake_autolint_buffers, a:bufnr)
endfunction

function! neomake#autolint#buffer#bufnrs() abort
  return keys(s:neomake_autolint_buffers)
endfunction

function! neomake#autolint#buffer#get(bufnr) abort
  let l:bufinfo = get(s:neomake_autolint_buffers, a:bufnr, {})
  return get(l:bufinfo, 'enabled', 1) ? l:bufinfo : {}
endfunction

function! neomake#autolint#buffer#get_from_timer(timerid) abort
  let l:bufinfo = {}
  for l:info in values(s:neomake_autolint_buffers)
    if l:info.timerid == a:timerid
      let l:bufinfo = l:info
      let l:bufinfo.timerid = -1
      break
    endif
  endfor

  return l:bufinfo
endfunction

function! neomake#autolint#buffer#clear(...) abort
  if a:0
    if type(a:1) == type([])
      let l:bufnrs = a:1
    else
      let l:bufnrs = a:000
    endif
  else
    let l:bufnrs = keys(s:neomake_autolint_buffers)
  endif

  for l:bufnr in l:bufnrs
    let l:bufinfo = neomake#autolint#buffer#get(l:bufnr)
    if !empty(l:bufinfo)
      call delete(l:bufinfo.tmpfile)
      call remove(s:neomake_autolint_buffers, l:bufnr)
    endif
  endfor
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
" __END__
