" File: objc_cocoa_mappings.vim
" Author: Michael Sanders (msanders42 [at] gmail [dot] com)
" Description: Sets up mappings for cocoa.vim.
" Last Updated: December 26, 2009

" use custom man
nn <buffer> <silent> K :<c-u>call objc#man#ShowDoc()<cr>

nn <buffer> <silent> <d-0> :call system('open -a Xcode '.b:cocoa_proj)<cr>
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

" use xcodebuild as make program
setlocal makeprg=xcodebuild\ -sdk\ iphonesimulator5.0

" some Xcode binrings

nn <buffer> <d-b> :make<cr>
nn <buffer> <d-K> :make clean<cr>
