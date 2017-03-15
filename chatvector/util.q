wv:words[;`v]
len:{sqrt sum x*x}
coss:{(sum x*y)%(len x)*(len y)}
norm:{x%len x}
dist:{len x-y}

kNearest:{select[y;>cs] word,cs from update cs:coss[wv x] each v from words where not word like x}
showWords:{" " sv x `word}

// save map of largest 100 cosine similarities for given word
saveNearest:{words[x;`nearest]: {(`words$(x `word))!(x `cs)}[kNearest[x;100]]; x}
// get most common nearest words that haven't had `nearest added yet
nextNearest:{[]
  ws: (select word from words where 0 < count each nearest) `word;
  nears: {x[iasc x]} (),/ {value key x} each words[;`nearest] each ws;
  nears: nears[where {all x within ("a";"z")} each nears];
  counts: (@[;0] each grouped)!count each grouped: (where differ nears) _ nears;
  counts: (idesc counts)!counts[idesc counts];
  ws _ counts }
saveBatch:{[]{show x;saveNearest x} each key 1000 # nextNearest 0}

makeNode:{`word`links!(x;(value key m)!value m: 20#words[x;`nearest])}
