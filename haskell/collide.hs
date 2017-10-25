import Sound.SC3

rs = withSC3 reset
mono u = mrg2 (out 0 u) (out 1 u)
audm u = audition $ mono u
so f = sinOsc AR f 0
