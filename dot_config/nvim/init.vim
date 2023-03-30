set mouse=vn
set showtabline=2
set laststatus=2
set number
let g:ale_fixers = {
    \    '*': ['remove_trailing_lines', 'trim_whitespace'],
    \    'python': ['black'],
    \ 	 'sh': ['shfmt']
    \}
