function! s:filename_map(prefix, file) abort
  let l:abbr = fnamemodify(a:file, ':t')
  let l:word = a:prefix . l:abbr

  if isdirectory(a:file)
    let l:menu = '[dir]'
    let l:abbr = '/' . l:abbr
  else
    let l:menu = '[file]'
    let l:abbr = l:abbr
  endif

  return {
        \ 'menu': l:menu,
        \ 'word': l:word,
        \ 'abbr': l:abbr,
        \ 'icase': 1,
        \ 'dup': 0
        \ }
endfunction

function! asyncomplete#sources#file#completor(opt, ctx)
  let l:bufnr = a:ctx['bufnr']
  let l:typed = a:ctx['typed']
  let l:col   = a:ctx['col']

  let l:kw    = matchstr(l:typed, '<\@<!\(\.\{0,2}/\|\~\).*$')
  let l:kwlen = len(l:kw)

  if l:kwlen < 1
    return
  endif

  if l:kw !~ '^\(/\|\~\)'
    let l:cwd = expand('#' . l:bufnr . ':p:h') . '/' . l:kw
  else
    let l:cwd = l:kw
  endif

  let l:glob = fnamemodify(l:cwd, ':t') . '.\=[^.]*'
  let l:cwd  = fnamemodify(l:cwd, ':p:h')
  let l:pre  = fnamemodify(l:kw, ':h')

  if l:pre !~ '/$'
    let l:pre = l:pre . '/'
  endif

  let l:cwdlen   = strlen(l:cwd)
  let l:startcol = l:col - l:kwlen
  let l:files    = split(globpath(l:cwd, l:glob), '\n')
  let l:matches  = map(l:files, {key, val -> s:filename_map(l:pre, val)})
  let l:matches  = sort(l:matches, function('s:sort'))

  call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol, l:matches)
endfunction

function! asyncomplete#sources#file#get_source_options(opts)
  return extend(extend({}, a:opts), {
        \ 'triggers': {'*': ['/']},
        \ })
endfunction

function! s:sort(item1, item2) abort
  if a:item1.menu ==# '[dir]' && a:item2.menu !=# '[dir]'
    return -1
  endif
  if a:item1.menu !=# '[dir]' && a:item2.menu ==# '[dir]'
    return 1
  endif
  return 0
endfunction

