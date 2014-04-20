" File: objc_cocoa_mappings.vim
" Author: Michael Sanders (msanders42 [at] gmail [dot] com)
" Description: Sets up mappings for cocoa.vim.
" Last Updated: December 26, 2009

" settings {{{1
if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = ''
endif

" setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=8


" make {{{2
" use xcodebuild as make program
if globpath(expand('<afile>:p:h'), '*.xcodeproj') != ''
    setlocal makeprg=open\ -a\ xcode\ &&\ osascript\ -e\ 'tell\ app\ \"Xcode\"\ to\ build'
else
    setlocal makeprg=xcodebuild\ -sdk\ iphonesimulator5.0
endif

" configure {{{2
setlocal include=^\s*#\s*import

let b:match_words = '@\(implementation\|interface\):@end'

if !exists('g:clang_complete_loaded')
  setlocal omnifunc=objc#cocoacomplete#Complete
endif

if &ft != 'objc'
    let b:undo_ftplugin .= '
        \ | setlocal expandtab< shiftwidth< softtabstop< tabstop<
        \ makeprg< include< omnifunc<
        \'
endif
"}}}
" project detection {{{2
let b:cocoa_proj = fnameescape(globpath(expand('<afile>:p:h'), '*.xcworkspace'))
" Search a few levels up to see if we can find the project file
if empty(b:cocoa_proj)
	let b:cocoa_proj  = fnameescape(globpath(expand('<afile>:p:h:h'), '*.xcworkspace'))

	if empty(b:cocoa_proj)
		let b:cocoa_proj = fnameescape(globpath(expand('<afile>:p:h:h:h'), '*.xcworkspace'))
		if empty(b:cocoa_proj)
			let b:cocoa_proj = fnameescape(globpath(expand('<afile>:p:h:h:h:h'), '*.xcworkspace'))
		endif
	endif
endif

if empty(b:cocoa_proj)
    let b:cocoa_proj = fnameescape(globpath(expand('<afile>:p:h'), '*.xcodeproj'))
    " Search a few levels up to see if we can find the project file
    if empty(b:cocoa_proj)
        let b:cocoa_proj  = fnameescape(globpath(expand('<afile>:p:h:h'), '*.xcodeproj'))

        if empty(b:cocoa_proj)
            let b:cocoa_proj = fnameescape(globpath(expand('<afile>:p:h:h:h'), '*.xcodeproj'))
            if empty(b:cocoa_proj)
                let b:cocoa_proj = fnameescape(globpath(expand('<afile>:p:h:h:h:h'), '*.xcodeproj'))
            endif
        endif
    endif
endif

" commands {{{2
command! -buffer CocoaDoc call objc#man#ShowDoc()
command! -buffer XcodeProjOpen call s:XcodeProjOpen()
command! -buffer XcodeRun call s:RunInXcode()
command! -buffer XcodeBuild call s:BuildInXcode()
command! -buffer XcodeTest call s:TestInXcode()
command! -buffer XcodeAnalyze call s:AnalyzeInXcode()
command! -buffer XcodeClean call s:CleanInXcode()

" mappings {{{2
nnoremap <buffer><silent> <Plug>(cocoa-doc) :<C-u>call objc#man#ShowDoc()<CR>
nnoremap <buffer><silent> <Plug>(cocoa-xcode-open) :call <SID>XcodeProjOpen()<cr>
nnoremap <buffer> <Plug>(cocoa-xcode-run) :w<bar>call <SID>RunInXcode()<cr>
nnoremap <buffer> <Plug> cocoa-xcode-build) :w<bar>call <SID>BuildInXcode()<cr>
nnoremap <buffer> <Plug> cocoa-xcode-test) :w<bar>call <SID>TestInXcode()<cr>
nnoremap <buffer> <Plug> cocoa-xcode-profile) :w<bar>call <SID>ProfileInXcode()<cr>
nnoremap <buffer> <Plug> cocoa-xcode-analyze) :w<bar>call <SID>AnalyzeInXcode()<cr>
nnoremap <buffer> <Plug> cocoa-xcode-clean) :w<bar>call <SID>CleanInXcode()<cr>
if !exists('g:cocoa_no_mappings') || !g:cocoa_no_mappings
  " use custom man
  nmap <buffer><silent> K <Plug>(cocoa-doc)
  " Xcode bindings
  nmap <buffer> <silent> <d-0> <Plug>(cocoa-xcode-open)

  nmap <buffer> <d-r> <Plug>(cocoa-xcode-run)
  nmap <buffer> <d-b> <Plug>(cocoa-xcode-build)
  nmap <buffer> <d-u> <Plug>(cocoa-xcode-test)
  nmap <buffer> <d-i> <Plug>(cocoa-xcode-profile)
  nmap <buffer> <d-B> <Plug>(cocoa-xcode-analyze)
  nmap <buffer> <d-K> <Plug>(cocoa-xcode-clean)
endif

" util functions {{{2
" execute only once after this line
if exists('*s:ExecInXcode') | finish | endif

function! s:XcodeProjOpen()
  call system('open -a Xcode '.b:cocoa_proj)
endfunction

function s:RunInXcode()
	call s:ExecInXcode('Run')
endfunction

function s:BuildInXcode()
	call s:ExecInXcode('Build')
endfunction

function s:TestInXcode()
	call s:ExecInXcode('Test')
endfunction

function s:ProfileInXcode()
	call s:ExecInXcode('Profile')
endfunction

function s:AnalyzeInXcode()
	call s:ExecInXcode('Analyze')
endfunction

function s:CleanInXcode()
	call s:ExecInXcode('Clean')
endfunction

function s:ExecInXcode(command)
	" Build   Cmd-B
	" Run     Cmd-R
	" Test    Cmd-U
	" Profile Cmd-I
	" Analyze Cmd-shift-B
	" Clean   Cmd-shift-K

	let cmd = a:command

	let command_map = { 'Build': 11, 'Run': 15, 'Test': 32, 'Profile': 34 }
	let command_shift_map = { 'Analyze': 11, 'Clean': 40 }

	if(get(command_map, cmd, "") != "")
		let code = command_map[cmd]. " using {command down}"
	elseif(get(command_shift_map, cmd, "") != "")
		let code = command_shift_map[cmd]. " using {command down, shift down}"
	end

	call system("open -a Xcode.app " . b:cocoa_proj . " && osascript -e '"
				\ ."tell application \"Xcode\" to activate \r"
				\ ."tell application \"System Events\" \r"
				\ ."     tell process \"Xcode\" \r"
				\ ."          key code " . code . " \r"
				\ ."    end tell \r"
				\ ."end tell'")
endfunction

if exists('*s:AlternateFile') | finish | endif

" Switch from header file to implementation file (and vice versa).
fun s:AlternateFile()
	let path = expand('%:p:r').'.'
	let extensions = expand('%:e') == 'h' ? ['m', 'c', 'cpp'] : ['h']
	if !s:ReadableExtensionIn(path, extensions)
		  echoh ErrorMsg | echo 'Alternate file not readable.' | echoh None
	endif
endf

" Returns true and switches to file if file with extension in any of
" |extensions| is readable, or returns false if not.
fun s:ReadableExtensionIn(path, extensions)
	for ext in a:extensions
		if filereadable(a:path.ext)
			exe 'e'.fnameescape(a:path.ext)
			return 1
		endif
	endfor
	return 0
endf
" }}}
" __END__ {{{1
