function CopyPathLine()
	let @+=expand("%:h") . '/' . expand("%:t") . ':' . line(".")
endfunction
command! -nargs=0 CopyPathLine call CopyPathLine()
