set clipboard=unnamed

" Make `,` available as a leader key
unmap ,

" Editor
nmap j gj
nmap k gk

" Quickly remove search highlights
" Note: This does not remove the highlight when jumping to a link header.
nmap <Esc> :nohl<CR>

" Navigate
exmap back obcommand app:go-back
nmap <C-o> :back<CR>

exmap forward obcommand app:go-forward
nmap <C-i> :forward<CR>

exmap reload obcommand app:reload
exmap changelog obcommand app:show-release-notes

" Split
exmap vs obcommand workspace:split-vertical
exmap sp obcommand workspace:split-horizontal

" Save
exmap w obcommand editor:save-file
exmap wa obcommand editor:save-file

" Close and Quit
exmap q obcommand workspace:close
exmap qg obcommand workspace:close-tab-group
exmap qw obcommand workspace:close-window
exmap only obcommand workspace:close-others

" Theme
exmap theme obcommand theme-picker:open-theme-picker
exmap light obcommand theme:use-light
exmap dark obcommand theme:use-dark

" Folding
exmap togglefold obcommand editor:toggle-fold
nmap zo :togglefold<CR>
nmap zc :togglefold<CR>
nmap za :togglefold<CR>

exmap foldall obcommand editor:fold-all
nmap zM :foldall<CR>

exmap foldmore obcommand creases:decrease-fold-level
nmap zm :foldmore<CR>

exmap unfoldall obcommand editor:unfold-all
nmap zR :unfoldall<CR>

" Double tab space to enter command mode
nmap ,, :

exmap findFiles obcommand obsidian-better-command-palette:open-better-commmand-palette-file-search
nmap ,wd :findFiles<CR>

exmap fileExplorer obcommand quick-explorer:browse-current
nmap ,we :fileExplorer<CR>

" Actions
exmap renameHeading obcommand editor:rename-heading
nmap ,sn :renameHeading<CR>

exmap moveFile obcommand file-explorer:move-file
nmap ,dm :moveFile<CR>

" Go
exmap followlink obcommand editor:follow-link
nmap ,sd :followlink<CR>

exmap followlinkinnewpane obcommand editor:open-link-in-new-leaf
nmap ,sD :followlinkinnewpane<CR>

exmap goToSymbol obcommand darlal-switcher-plus:switcher-plus:open-symbols
nmap ,ds :goToSymbol<CR>

" Daily Notes
exmap dd obcommand daily-notes
exmap dp obcommand daily-notes:goto-prev
exmap dn obcommand daily-notes:goto-next
exmap dc obcommand obsidian-jump-to-date-plugin:open-JumpToDate-calendar

" Jump
exmap jumpToLink obcommand mrj-jump-to-link:activate-jump-to-link
exmap jumpAnywhere obcommand mrj-jump-to-link:activate-jump-to-anywhere
nmap s :jumpAnywhere<CR>
