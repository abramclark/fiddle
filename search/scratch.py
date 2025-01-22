import gensim.downloader
import numpy as np

gv = gensim.downloader.load('glove-wiki-gigaword-50')

gv.most_similar(gv['swamp'])
np.dot(gv['tree'], gv['leaf'])
np.dot(gv['tree'], gv['ponderosa']) # hmm, seems questionable

gv.most_similar(gv['king'] - gv['man'] + gv['woman']) # the canonical example
gv.most_similar(gv['liquid'] - gv['solid'] + gv['rock'])


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


#import spacy
#nlp = spacy.load('en_core_web_lg')
#
#def vec(txt): return nlp(txt).vector
#
#icon_vecs = [r + (vec(r[1]),) for r in icons]
#
#def close_icons(text, n=30, reverse=False):
#    vec = nlp(text).vector
#    nearest = [(np.dot(vec, r[2]), i) for i, r in enumerate(icon_vecs)]
#    nearest.sort(reverse=not reverse)
#    return list(islice((icon_vecs[i][:2] + (d,) for d, i in nearest), n))


#from numba import jit
#@jit(nopython=True)
#def cosine_numba(u:np.ndarray, v:np.ndarray):
#    assert(u.shape[0] == v.shape[0])
#    uv = 0
#    uu = 0
#    vv = 0
#    for i in range(u.shape[0]):
#        uv += u[i]*v[i]
#        uu += u[i]*u[i]
#        vv += v[i]*v[i]
#    cos_theta = 1
#    if uu != 0 and vv != 0:
#        cos_theta = uv/np.sqrt(uu*vv)
#    return cos_theta
#
#
##import spacy_sentence_bert
##nlp = spacy_sentence_bert.load_model('en_stsb_roberta_base')
#import spacy_universal_sentence_encoder
#nlp = spacy_universal_sentence_encoder.load_model('en_use_md')
#
#def vec(txt): return nlp(txt).vector
#icon_vecs = [r + (vec(r[1]),) for r in icons]
#
#def sym_icons(text, n=30, reverse=False):
#    v = vec(text)
#    nearest = [(cosine_numba(v, r[2]), i) for i, r in enumerate(icon_vecs)]
#    nearest.sort(reverse=not reverse)
#    return list(islice((icons[i] + (d,) for d, i in nearest), n))
