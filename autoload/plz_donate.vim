" Please donate for Vim!
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim

if !exists('g:plz_donate#disabled_time')
  let g:plz_donate#disabled_time = 3 * 60 * 60
endif
if !exists('g:plz_donate#writing_count')
  let g:plz_donate#writing_count = 10
endif
if !exists('g:plz_donate#last_check')
  let g:plz_donate#last_check = localtime()
endif

let s:V = vital#of('plz_donate')
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
  let result = confirm(message, "OK\nCancel", 1)
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

let &cpo = s:save_cpo
unlet s:save_cpo
