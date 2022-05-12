Plug 'vim-test/vim-test'

let test#strategy = "dispatch"
if filereadable(glob("dev.yml"))
    let test#ruby#rspec#executable = 'dev test'
    let test#ruby#minitest = 'dev test'
    let test#rails#executable = 'dev test'
endif
