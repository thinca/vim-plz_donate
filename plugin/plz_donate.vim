" Please donate for Vim!
" Version: 1.0
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_plz_donate')
  finish
endif
let g:loaded_plz_donate = 1

let s:save_cpo = &cpo
set cpo&vim

augroup plugin-plz_donate
  autocmd!
  autocmd BufWritePost * call plz_donate#check()
augroup END

let g:plz_donate#last_check = localtime()

let &cpo = s:save_cpo
unlet s:save_cpo
