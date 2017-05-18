load `words
\l util.q

/ examples
showVal:{1 x,"\n";value x}
showVal "coss[(wv \"einstein\") - (wv \"scientist\"); (wv \"picasso\") - (wv \"painter\")]"
showVal "coss[(wv \"einstein\") - (wv \"scientist\"); (wv \"picasso\") - (wv \"carpenter\")]"
showVal "coss[(wv \"human\") - (wv \"walk\"); (wv \"insect\") - (wv \"crawl\")]"
showVal "1 showWords kNearest[\"meditation\";100]"
