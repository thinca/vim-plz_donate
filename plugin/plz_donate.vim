if exists('g:loaded_plz_donate')
  finish
endif
let g:loaded_plz_donate = 1

augroup plugin-plz_donate
  autocmd!
  autocmd BufWritePost * call plz_donate#check()
augroup END

let g:plz_donate#last_check = localtime()
