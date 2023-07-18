from collections import defaultdict
import unicodedata


def get_name(cp):
    try:
        return unicodedata.name(cp)
    except ValueError:
        return None


def unicode_index():
    code_names = ((get_name(chr(i)), i) for i in range(0, 2**20))
    code_words = ((n.lower().split(), i) for n, i in code_names if n)

    index = defaultdict(str)
    for words, i in code_words:
        for w in words:
            index[w] += chr(i)
    return index
