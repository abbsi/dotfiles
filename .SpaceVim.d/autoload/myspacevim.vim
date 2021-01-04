function! myspacevim#before() abort
    let g:material_style = 'oceanic'
    let g:vimwiki_list = [{'path': '/env/docs/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
endfunction

function! myspacevim#after() abort
endfunction
