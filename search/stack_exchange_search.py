from collections import namedtuple
from itertools import islice
import pickle

import numpy as np
import spacy_universal_sentence_encoder

from stack_exchange import doc_to_text, get_docs, format_doc

Doc = namedtuple('Doc', ['id', 'title', 'text', 'created', 'vec'])
nlp = spacy_universal_sentence_encoder.load_model('en_use_md')
docs = None

def vec(txt): return nlp(txt).vector

def print_progress(i):
    if not i % 100: print(i)
    return True

def index_docs():
    return [Doc(*doc, vec(doc_to_text(doc))) for i, doc in enumerate(get_docs()) if print_progress(i)]

def sim_doc_ixs(text, n=5, reverse=False):
    v = vec(text)
    nearest = [(np.dot(v, doc.vec), i) for i, doc in enumerate(docs)]
    nearest.sort(reverse=not reverse)
    return list(islice((i for _, i in nearest), n))

def search(*ws, **kws):
    return (docs[ix] for ix in sim_doc_ixs(*ws, **kws))

def search_and_format(*ws, **kws):
    docs = search(*ws, **kws)
    print(f'\n{"-" * 80}\n'.join(format_doc(doc) for doc in docs))

def write_index(file_name='stack_exchange.pickle'):
    pickle.dump(index_docs(), open(file_name, 'wb'))

def load_index(file_name='stack_exchange.pickle'):
    global docs
    docs = pickle.load(open(file_name, 'rb'))
