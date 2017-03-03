word: ([] word:(); v:())

scanFile:{[name;chunkSize;fn] reading:1; seek:0; h:hsym `$ name; out:();
  while[reading; data: read0 (h;seek;chunkSize);
    reading: chunkSize < (count data) + sum count each data; show data[0];
    chunk: -1 _ data; seek+: (count chunk) + sum count each chunk;
    out ,: fn chunk
  ]; out }

scanWords:{[name;size] scanFile[name;size;{[lines]
  singleWords: vs[" "] each {x[where {not count x ss "_"} each x]} lines;
  word,: {`word`v!(x[0]; "E"$ 1 _ x)} each singleWords }]}

/scanWords["glove.6B.300d.txt";3000000] // 300d DB too big and "v2: flip" below explodes KDB with "wsfull"
scanWords["glove.6B.50d.txt";3000000]
show "normalizing word dimensions"
v2: flip {x - avg x % sdev x} each flip word `v; update v:v2 from `word
show "saving table"; save `word;

\l test.q

/ food (StandFord GloVe 50d): 0.6751443 0.02509135 -0.4979302 -0.1770844 0.7613584 -0.125569 -1.527683 -1.1...
