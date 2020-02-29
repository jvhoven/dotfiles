set background=dark
set termguicolors
set encoding=utf-8
set number
syntax enable

try 
	colorscheme forest-night
catch
endtry

" Plug configuration

" Automatic installation
if empty (glob('~/.vim/autoload/plug.vim'))
	silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
				\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source '~/.vimrc'
endif

" Install missing plugins on startup
autocmd VimEnter *
	\ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
	\|	PlugInstall --sync | q
	\| endif

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'
Plug 'vim-syntastic/syntastic'
	set statusline+=%#warningmsg#
	set statusline+=%{SyntasticStatuslineFlag()}
	set statusline+=%*

	let g:syntastic_always_populate_loc_list = 1
	let g:syntastic_auto_loc_list = 1
	let g:syntastic_check_on_open = 1
	let g:syntastic_check_on_wq = 0

Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
	augroup nerd_loader
		autocmd!
		autocmd VimEnter * silent! autocmd! FileExplorer
		autocmd BufEnter,BufNew *
			\ if isdirectory(expand('<amatch>'))
			\|	call plug#load('nerdtree')
			\|	execute 'autocmd! nerd_loader'
			\| endif
	augroup END

	" Start NERDTree when no files specified
	autocmd StdinreadPre * let s:std_in = 1
	autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

	" Close vim if NERDTree is the only window open
	autocmd bufenter * if (winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree()) | q | endif

	" Defaults
	let g:NERDTreeDirArrowExpandable = ''
	let g:NERDTreeDirArrowCollapsible = ''

Plug 'godlygeek/tabular', { 'on': 'Goyo' }
Plug 'rust-lang/rust.vim'
	let g:rustfmt_autosave = 1

Plug 'plasticboy/vim-markdown', { 'on': 'Goyo' }
Plug 'ycm-core/YouCompleteMe', { 'do': './install.py' }
Plug 'sainnhe/forest-night'
Plug 'sheerun/vim-polyglot'
Plug 'junegunn/goyo.vim'
	" Goyo configuration
	function! s:goyo_enter()
		if executable("tmux") && strlen($TMUX)
			silent !tmux set status off
			silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
		endif

		" Makes sure that if :q is called, vim quits, not just Goyo
		let b:quitting = 0
		let b:quitting_bang = 0
		autocmd QuitPre <buffer> let b:quitting = 1
		cabbrev <buffer> q! let b:quitting_bang = 1 <bar> q!

		set noshowmode
		set noshowcmd
		set scrolloff=999
	endfunction

	function! s:goyo_leave()
		if executable("tmux") && strlen($TMUX)
			silent !tmux set status on 
			silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
		endif

		" Quit Vim if this is the only remaining buffer
		if b:quitting && len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
			if b:quitting_bang
				qa!
			else
				qa
			endif
		endif

		set showmode
		set showcmd
		set scrolloff=5
	endfunction

	autocmd! User GoyoEnter nested call <SID>goyo_enter()
	autocmd! User GoyoLeave nested call <SID>goyo_leave()

Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf'

call plug#end()
