" File: objc_cocoa_mappings.vim
" Author: Michael Sanders (msanders42 [at] gmail [dot] com)
" Description: Sets up mappings for cocoa.vim.
" Last Updated: December 26, 2009

" settings {{{
if !exists('b:undo_ftplugin')
    let b:undo_ftplugin = ''
endif

setlocal expandtab shiftwidth=4 softtabstop=4 tabstop=8


" use xcodebuild as make program
if globpath(expand('<afile>:p:h'), '*.xcodeproj') != ''
    setlocal makeprg=open\ -a\ xcode\ &&\ osascript\ -e\ 'tell\ app\ \"Xcode\"\ to\ build'
else
    setlocal makeprg=xcodebuild\ -sdk\ iphonesimulator5.0
endif
setl include=^\s*#\s*import

let b:match_words = '@\(implementation\|interface\):@end'

setlocal omnifunc=objc#cocoacomplete#Complete

if &ft != 'objc'
    let b:undo_ftplugin .= '
        \ | setlocal expandtab< shiftwidth< softtabstop< tabstop<
        \ makeprg< include< omnifunc<
        \'
endif
"}}}


" mappings {{{
" use custom man
nn <buffer> <silent> K :<c-u>call objc#man#ShowDoc()<cr>

" Xcode bindings
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

nn <buffer> <silent> <d-0> :call system('open -a Xcode '.b:cocoa_proj)<cr>

nn <buffer> <d-r> :w<bar>call g:RunInXcode()<cr>
nn <buffer> <d-b> :w<bar>call g:BuildInXcode()<cr>
nn <buffer> <d-u> :w<bar>call g:TestInXcode()<cr>
nn <buffer> <d-i> :w<bar>call g:ProfileInXcode()<cr>
nn <buffer> <d-B> :w<bar>call g:AnalyzeInXcode()<cr>
nn <buffer> <d-K> :w<bar>call g:CleanInXcode()<cr>

" execute only once after this line
if exists('*s:ExecInXcode') | finish | endif

function g:RunInXcode()
	call s:ExecInXcode('Run')
endfunction

function g:BuildInXcode()
	call s:ExecInXcode('Build')
endfunction

function g:TestInXcode()
	call s:ExecInXcode('Test')
endfunction

function g:ProfileInXcode()
	call s:ExecInXcode('Profile')
endfunction

function g:AnalyzeInXcode()
	call s:ExecInXcode('Analyze')
endfunction

function g:CleanInXcode()
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
