import gensim.downloader
import numpy as np

gv = gensim.downloader.load('glove-wiki-gigaword-50')

# experimentory examples
#gv.most_similar(gv['swamp'])
#np.dot(gv['tree'], gv['leaf'])
#np.dot(gv['tree'], gv['ponderosa']) # hmm, seems questionable
#
#gv.most_similar(gv['king'] - gv['man'] + gv['woman']) # the canonical example
#gv.most_similar(gv['liquid'] - gv['solid'] + gv['rock'])


from numpy.linalg import norm
from unicode import icons

def gv_vec(word): return gv[word] if word in gv else None

def word_avg(text):
    words = text.lower().split()
    vecs = list(filter(lambda v: v is not None, map(gv_vec, words)))
    return np.average(vecs, 0)

icon_vecs = [r + (word_avg(r[1]),) for r in icons]
icon_vecs = [r for r in icon_vecs if not np.isscalar(r[2])] # filter NaNs from no words matching

def search_icons(text, n=30, reverse=False):
    v = word_avg(text)
    nearest = [(np.dot(v, r[2]), i) for i, r in enumerate(icon_vecs)]
    nearest.sort(reverse=not reverse)
    return list(islice((icon_vecs[i][:2] + (d,) for d, i in nearest), n))

# (replacing dot with cossim shows worse results)
def cossim(a, b): return np.dot(a, b) / (norm(a) * norm(b))
