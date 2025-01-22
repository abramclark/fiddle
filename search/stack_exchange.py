# loads questions and answers in Stack Exchange site, from unzipped data dump in ./ downloaded from:
# https://archive.org/download/stackexchange
from collections import namedtuple
from datetime import datetime

from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET

NETWORK = 'ai'
Doc = namedtuple('Doc', ['id', 'title', 'text', 'created'])

def get_docs():
    xml = ET.parse(NETWORK + '.stackexchange.com/Posts.xml')
    parents_by_id = {el.get('Id') : el for el in xml.getroot().findall('*') if el.get('PostTypeId') == '1'}

    return [Doc(
        el.get('Id'),
        el.get('Title') or parents_by_id[el.get('ParentId')].get('Title'),
        BeautifulSoup(el.get('Body'), 'html.parser').get_text(),
        datetime.fromisoformat(el.get('CreationDate')),
    ) for el in xml.getroot().findall('*') if el.get('PostTypeId') in ['1', '2']]

def doc_to_text(doc):
    text = doc.text
    if doc.title:
        text = doc.title + '\n\n' + doc.text
    return text

def doc_url(doc):
    return f'https://{NETWORK}.stackexchange.com/a/' + doc.id

def format_doc(doc):
    return doc_to_text(doc) + doc_url(doc)
