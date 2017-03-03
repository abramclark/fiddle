len:{sqrt sum xexp[;2] x}
coss:{(sum x * y) % (len x) * (len y)}
norm:{x % len x}
dist:{len x - y}
wv:{(exec v from word where word~\:x) 0}

showVal "coss[(wv \"einstein\") - (wv \"scientist\"); (wv \"picasso\") - (wv \"painter\")]"
showVal "coss[(wv \"einstein\") - (wv \"scientist\"); (wv \"picasso\") - (wv \"carpenter\")]"
showVal "coss[(wv \"human\") - (wv \"walk\"); (wv \"insect\") - (wv \"crawl\")]"
