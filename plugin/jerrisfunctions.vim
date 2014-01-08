" This file contains some useful functions I use and used now and then.

" This small function simplifies the addition of links to an html-Page. The
" title of the linked page automagically is requested and added to the output
" The line is added after the current line.
map <leader>al :call AddLinkToText()<CR>

function! AddLinkToText()
  let url = input("URL to add? ", "")
  if strlen(url) == 0
    return
  endif

  " Save b register
  let saveB = @b

  " Get the target
  let target = input("Target for this link? ", "_blank")
  if strlen(target) > ""
    let target = " target=\"" . target . "\""
  endif

  " Get the source of the page
  let code = system("lynx -dump -source " . url)

  " Find the title of the page
  let title = substitute(code, '.*head.*<title[^>]*>\(.*\)<\/title>.*head.*', '\1', '')
  if title == code
    " If nothing changed we couldn't find the regular expression
    let title = "Unknown"
  endif
  " Remove newline-characters (not yet tested!)
  let title = substitute(title, "\n", " ", "g")

  " Output the code
  let @b = "<a href=\"" . url . "\"" . target . ">" . title . "</a>"
  put b

  " Restore b register
  let @b = saveB
endfunction

map <leader>apg :call AutomaticPasswordGenerate()<CR>

" the following  function uses apg (automatic password generator) to insert an
" new password at the current cursor position.
function! AutomaticPasswordGenerate()
  let password = system("apg -m 8 -x 12 -n 1")
  exec "normal a".substitute(password, "\n", '', '')."\<esc>"
endfunction

" here are some settings to work with simple password-safe-files. :) shamelessly
" stolen from des3.vim (from Noah Spurrier <noah@noah.org>) Uses the
" gnupg.vim-Plugin to encrypt the files.
" The following implements a simple password safe for any file named *.pws.gpg
" folding support for == headlines ==
augroup jerris_pws_extension
function! HeadlineDelimiterExpression(lnum)
    if a:lnum == 1
        return ">1"
    endif
    return (getline(a:lnum)=~"^\\s*==.*==\\s*$") ? ">1" : "="
endfunction
autocmd BufReadPost,FileReadPost   *.pws.gpg set foldexpr=HeadlineDelimiterExpression(v:lnum)
autocmd BufReadPost,FileReadPost   *.pws.gpg set foldlevel=0
autocmd BufReadPost,FileReadPost   *.pws.gpg set foldcolumn=0
autocmd BufReadPost,FileReadPost   *.pws.gpg set foldmethod=expr
autocmd BufReadPost,FileReadPost   *.pws.gpg set foldtext=getline(v:foldstart)
autocmd BufReadPost,FileReadPost   *.pws.gpg nnoremap <silent><space> :exe 'silent! normal! za'.(foldlevel('.')?'':'l')<CR>
autocmd BufReadPost,FileReadPost   *.pws.gpg nnoremap <silent>q :q<CR>
autocmd BufReadPost,FileReadPost   *.pws.gpg highlight Folded ctermbg=red ctermfg=black
autocmd BufReadPost,FileReadPost   *.pws.gpg set updatetime=300000
autocmd CursorHold                 *.pws.gpg quit
augroup END

" The following is a function to be used together with calendar.vim. Add the
" following to line to call this function, if the user presses return on a
" date.
"
" let calendar_action = 'JerriCalendarAction'
function! JerriCalendarAction (day, month, year, week, dir)
    let l:day = a:day<10 ? '0'.a:day : a:day
    let l:month = a:month<10 ? '0'.a:month : a:month
    let l:tag = a:year.'-'.l:month.'-'.l:day
    wincmd p
    exec "normal a".l:tag."\<esc>"
endfunction

" The following is a function to diff the current file with the serverside one
" using difftolive.sh
"
" Any parameters to the difftolive.sh can be given in a string.
function! DiffFile (arguments) abort
    write
    let l:currentPath = getcwd()
    lcd %:p:h
    let l:dcommand = '!/home/gerhard/bin/difftolive.sh "'.expand('%').'" -i '.a:arguments
    "echo 'COMMAND: '.l:dcommand
    exec l:dcommand
    exec 'lcd '.l:currentPath
endfunction

command! -nargs=* DI call DiffFile(<q-args>)
