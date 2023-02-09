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
  let password = system("pwgen --symbols --numerals --capitalize 12 1")
  exec "normal a".substitute(password, "\n", '', '')."\<esc>"
endfunction

" The following is a function to be used together with calendar.vim. Add the
" following to line to call this function, if the user presses return on a
" date.
"
" let calendar_action = 'JerriCalendarAction'
function! JerriCalendarAction (day, month, year, week, dir)
    let l:day = a:day<10 ? '0'.a:day : a:day
    let l:month = a:month<10 ? '0'.a:month : a:month
    let l:tag = a:year.'-'.l:month.'-'.l:day
    exec "normal qa".l:tag."\<esc>"
endfunction

" The following is a function to diff the current file with the serverside one
" using difftolive.sh
"
" Any parameters to the difftolive.sh can be given in a string.
function! DiffFile (arguments) abort
    if ! &readonly
        write
    endif
    let l:currentPath = getcwd()
    let l:line = line(".")
    lcd %:p:h
    let l:dcommand = '!~/bin/difftolive.sh "'.expand('%').'" --line '.l:line.' -i '.a:arguments
    "echo 'COMMAND: '.l:dcommand
    exec l:dcommand
    exec 'lcd '.l:currentPath
endfunction

command! -nargs=* DI call DiffFile(<q-args>)

" Function to create a new tmux-Window with the connection to a server via ssh
function! SSHToServer (arguments)
    silent exec '!~/bin/s '.a:arguments
    redraw!
endfunction

command! -nargs=* S call SSHToServer(<q-args>)
