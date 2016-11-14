"=============================================================================
" FILE: autoload/neomake/autolint.vim
" AUTHOR: dojoteef
" License: MIT license
"=============================================================================
scriptencoding utf-8
let s:save_cpo = &cpoptions
set cpoptions&vim

function! neomake#autolint#update(bufinfo, ...) abort
  " Need the original filetype in order to set the new buffer to the
  " correct filetype (it might not be automatically detected)
  let l:ft = &filetype

  " Write the temporary file
  silent! keepalt noautocmd call writefile(
        \ getline(1, '$'),
        \ neomake#autolint#utils#tempfile('%'))

  " Run neomake in file mode with the autolint makers
  call neomake#Make(1, a:bufinfo.makers)
endfunction

function! s:neomake_onchange(bufnr) abort
  let l:bufinfo = neomake#autolint#buffer#get(a:bufnr)
  if empty(l:bufinfo)
    return
  endif

  let l:lasttimerid = l:bufinfo.timerid
  let l:bufinfo.timerid = -1
  if l:lasttimerid != -1
    call timer_stop(l:lasttimerid)
  endif

  let l:bufinfo.timerid = timer_start(get(g:, 'neomake_autolint_updatetime'),
        \ neomake#autolint#utils#function('s:neomake_tryupdate'))
endfunction

function! s:neomake_tryupdate(timerid) abort
  " Get the buffer info
  let l:bufinfo = neomake#autolint#buffer#get_from_timer(a:timerid)

  " Could not find the buffer associated with the timer
  if empty(l:bufinfo)
    return
  endif

  call neomake#autolint#update(l:bufinfo)
endfunction

"=============================================================================
" Public Functions: Functions that are called by plugin (auto)commands
"=============================================================================
function! neomake#autolint#Startup() abort
  " Define an invisible sign that can keep the sign column always showing
  execute 'sign define neomake_autolint_invisible'

  " Setup auto commands for managing the autolinting
  autocmd neomake_autolint BufWinEnter * call neomake#autolint#Setup()
  autocmd neomake_autolint VimLeavePre * call neomake#autolint#Removeall()
  autocmd neomake_autolint BufWipeout * call neomake#autolint#Remove(expand('<abuf>'))

  " Call setup on all the currently visible buffers
  let l:buflist = uniq(sort(tabpagebuflist()))
  for l:bufnr in l:buflist
    call neomake#autolint#Setup(l:bufnr)
  endfor
endfunction

function! neomake#autolint#Setup(...) abort
  " Must have a cache directory
  if empty(neomake#autolint#utils#cachedir())
    return
  endif

  let l:bufnr = a:0 ? a:1 : bufnr('%')
  if neomake#autolint#buffer#has(l:bufnr)
    return
  endif

  let l:makers = neomake#autolint#buffer#makers(l:bufnr)
  if len(l:makers) > 0
    " Create the autolint buffer
    let l:bufinfo = neomake#autolint#buffer#create(l:bufnr, l:makers)

    " Run neomake on the initial load of the buffer to check for errors
    call neomake#autolint#update(l:bufinfo)

    if get(g:, 'neomake_autolint_sign_column_always')
      execute 'sign place 999999 line=1 name=neomake_autolint_invisible buffer='.l:bufnr
    endif

    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Text Changed Handling
    """"""""""""""""""""""""""""""""""""""""""""""""""""""""
    autocmd! neomake_autolint * <buffer>
    call neomake#autolint#Toggle(0, bufnr('%'))
  endif
endfunction

function! neomake#autolint#Toggle(all, ...) abort
  let l:group = 'neomake_autolint'
  let l:cmd = [l:group, 'BufWinEnter', '*']
  let l:enabled = exists('#'.join(l:cmd, '#'))

  if a:all
    if l:enabled
      call insert(l:cmd, 'autocmd!')
    else
      call insert(l:cmd, 'autocmd')
      call add(l:cmd, 'call neomake#autolint#Setup()')
    endif
    execute join(l:cmd)

    let l:bufnrs = neomake#autolint#buffer#bufnrs()
  elseif a:0
    let l:bufnrs = type(a:1) == type([]) ? a:1 : a:000

    " Convert to bufnr
    let l:bufnrs = map(copy(l:bufnrs), 'bufnr(v:val)')

    " Filter non-tracked/invalid buffers
    let l:expr = 'v:val > -1 && neomake#autolint#buffer#has(v:val)'
    let l:bufnrs = filter(l:bufnrs, l:expr)
  else
    return
  endif

  call neomake#utils#LoudMessage(printf(
        \ 'Toggling buffers: %s',
        \ join(l:bufnrs, ',')))

  let l:events = 'TextChanged,TextChangedI'
  for l:bufnr in l:bufnrs
    let l:buffer = printf('<buffer=%d>', l:bufnr)
    let l:cmd = [l:group, l:events, l:buffer]
    if (a:all && l:enabled) || exists(printf('#%s', join(l:cmd, '#')))
      call insert(l:cmd, 'autocmd!')
    else
      call insert(l:cmd, 'autocmd')
      call add(l:cmd, printf('call s:neomake_onchange(%d)', l:bufnr))
    endif

    call neomake#utils#DebugMessage(printf(
          \ 'Executing: %s',
          \ join(l:cmd)))

    execute join(l:cmd)
  endfor
endfunction

function! neomake#autolint#Remove(bufnr) abort
  call neomake#utils#QuietMessage(printf('Removing buffer: %s', string(a:bufnr)))
  call neomake#autolint#buffer#clear(a:bufnr)
endfunction

function! neomake#autolint#Removeall() abort
  call neomake#autolint#buffer#clear()
endfunction

let &cpoptions = s:save_cpo
unlet s:save_cpo
" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
