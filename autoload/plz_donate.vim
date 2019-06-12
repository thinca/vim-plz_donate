if !exists('g:plz_donate#disabled_time')
  let g:plz_donate#disabled_time = 3 * 60 * 60
endif
if !exists('g:plz_donate#writing_count')
  let g:plz_donate#writing_count = 10
endif
if !exists('g:plz_donate#last_check')
  let g:plz_donate#last_check = localtime()
endif

let s:V = vital#plz_donate#new()
let s:File = s:V.import('System.File')
let s:Message = s:V.import('Locale.Message').new('plz_donate')

let s:url = 'http://www.vim.org/sponsor/index.php'
let s:confirm_message = join([
\   "Hello! Thanks for using Vim.\n",
\   "\n",
\   "Vim is Charityware.  ",
\   "You can use and copy it as much as you like, ",
\   "but you are encouraged to make a donation for needy children in Uganda.\n",
\   "\n",
\   "Would you like donation now?",
\ ], '')


function! plz_donate#open()
  call s:File.open(s:url)
endfunction

function! plz_donate#confirm()
  let message = s:Message.get(s:confirm_message)
  let items = [
  \   s:Message.get('Yes'),
  \   s:Message.get('No'),
  \ ]
  if exists('*popup_create') && !has('gui_running')
    call s:open_popup(message, items)
    return
  endif
  let result = confirm(message, join(items, "\n"), 1)
  if result == 1
    call plz_donate#open()
  endif
endfunction

let s:writing_count = 0
let s:last_time = 0
function! plz_donate#check()
  let now = localtime()
  if s:last_time + g:plz_donate#disabled_time <= now
    let s:writing_count += 1
    if g:plz_donate#writing_count <= s:writing_count
      let s:last_time = now
      let s:writing_count = 0
      call plz_donate#confirm()
    endif
  endif
endfunction

function s:open_popup(message, items) abort
  let context = {
  \   'message': a:message,
  \   'selected': 0,
  \   'items': a:items,
  \ }
  let winid = popup_create(s:make_popup_content(context), {
  \   'pos': 'center',
  \   'zindex': 200,
  \   'border': [],
  \   'padding': [],
  \   'filter': function('s:popup_filter', [context]),
  \ })
endfunction

function s:make_popup_content(context) abort
  let items = map(copy(a:context.items), { index, item ->
  \   (index == a:context.selected ? '-> ' : '   ') .. item
  \ })
  return split(a:context.message, "\n") + [''] + items
endfunction

function s:update_popup(winid, context) abort
  let bufnr = winbufnr(a:winid)
  let content = s:make_popup_content(a:context)
  call setbufline(bufnr, 1, content)
endfunction

function s:popup_filter(context, winid, key) abort
  if 0 <= index(['x', 'q', "\<Esc>"], a:key)
    call popup_close(a:winid)
    return 1
  endif
  if 0 <= index(["\<Tab>", "\<CR>"], a:key)
    if a:context.selected == 0
      call plz_donate#open()
    endif
    call popup_close(a:winid)
    return 1
  endif
  if 0 <= index(['j', "\<Down>"], a:key)
    let a:context.selected += 1
    if len(a:context.items) <= a:context.selected
      let a:context.selected = 0
    endif
  endif
  if 0 <= index(['k', "\<Up>"], a:key)
    let a:context.selected -= 1
    if a:context.selected < 0
      let a:context.selected = len(a:context.items) - 1
    endif
  endif
  call s:update_popup(a:winid, a:context)
  return 1
endfunction
