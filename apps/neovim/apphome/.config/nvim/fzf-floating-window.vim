let g:fzf_layout = { 'window': 'call Centered_floating_window()' }

if &termguicolors
    let g:preview_floating_window_winblend = 15
else
    let g:preview_floating_window_winblend = 0
endif

function! Centered_floating_window() abort
    let width = float2nr(&columns * 0.9)
    let height = float2nr(&lines * 0.9)
    let top = ((&lines - height) / 2) - 1
    let left = (&columns - width) / 2
    let opts = {'relative': 'editor', 'row': top, 'col': left, 'width': width, 'height': height, 'style': 'minimal'}

    let top = '╭' . repeat('─', width - 2) . '╮'
    let mid = '│' . repeat(' ', width - 2) . '│'
    let bot = '╰' . repeat('─', width - 2) . '╯'
    let lines = [top] + repeat([mid], height - 2) + [bot]

    let s:b_buf = nvim_create_buf(v:false, v:true)
    call nvim_buf_set_lines(s:b_buf, 0, -1, v:true, lines)
    call nvim_open_win(s:b_buf, v:true, opts)

    set winhl=Normal:Floating
    let opts.row += 1
    let opts.height -= 2
    let opts.col += 2
    let opts.width -= 4
    let s:f_buf = nvim_create_buf(v:false, v:true)
    call nvim_open_win(s:f_buf, v:true, opts)

    setlocal filetype=fzf
    setlocal nocursorcolumn
    execute 'set winblend=' . g:preview_floating_window_winblend

    augroup preview_floating_window
        " autocmd FileType fzf call s:set_fzf_last_query()
        autocmd WinLeave <buffer> silent! execute 'bdelete! ' . s:f_buf . ' ' . s:b_buf
    augroup END
endfunction
