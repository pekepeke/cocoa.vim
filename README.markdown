Quickly install with:

	mkdir cocoa.vim
	cd !$
    git clone git://github.com/msanders/cocoa.vim.git
	cp -r . ~/.vim

Remove annoying "is a web application downloaded from the internet" prompt when viewing docs with:

	cd /Library/Developer/Shared/Documentation/DocSets
	sudo xattr -rd com.apple.quarantine *.docset

To allow custom Cmd-b key binding (to issue 'Build' in the Xcode), put the following in the .gvimrc:

if has("gui_macvim")
	macmenu &Tools.Make key=<nop>
endif
