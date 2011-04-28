let profiles = voraxlib#panel#profiles#New()
call profiles.Toggle()
map <F4> :call profiles.SetRoot(profiles.root)
