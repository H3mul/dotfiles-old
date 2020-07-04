func! zettel#new(...)
    let cmd = join([g:zet_command, "new", "--noedit", join(a:000, ' ')])
    let note_file = system(cmd)
    silent exec join(["edit", "+$", note_file])
endfunc

let g:zet_command = join(["zet"], '')

command! -nargs=+ Zet call zettel#new(<f-args>)
