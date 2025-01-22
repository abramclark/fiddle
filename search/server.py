import pickle

from flask import Flask, request, render_template
import numpy as np

import stack_exchange
from stack_exchange_search import load_index, search

load_index()
app = Flask(__name__, static_url_path='/', static_folder='static')

# unused json endpoint
@app.route('/docs')
def search_docs():
    query = request.args.get('q')
    return [doc_to_json(doc) for doc in search(query, n=10)]

@app.route('/')
def index():
    query = request.args.get('q')
    docs = []
    if query:
        docs = [doc_to_json(doc) for doc in search(query, n=10)]
    return render_template('index.html', docs=docs, q=query)

def doc_to_json(doc):
    return dict(
        url=stack_exchange.doc_url(doc),
        title=doc.title,
        text=doc.text,
        created=str(doc.created.date()),
    )
