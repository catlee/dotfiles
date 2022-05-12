" path text objects
" -----------------
" i/ a/
function! VisualPath()
    " find the end of the current path segment
    call search('[^/: "=]\+', 'ceW')
    silent! normal! v
    " find the beginning of the current path segment
    call search('[^/: "=]\+', 'bW')
endfunction
xnoremap i/ :<C-u>silent! call VisualPath()<CR>
onoremap i/ :<C-u>silent! normal vi/<CR>
xnoremap a/ :<C-u>silent! call VisualPath()<CR>
onoremap a/ :<C-u>silent! normal va/<CR>
