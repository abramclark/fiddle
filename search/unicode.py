import unicodedata

def get_name(cp):
    try:
        return unicodedata.name(cp).lower()
    except ValueError:
        return None

chars = [chr(i) for i in range(0, 2**20) if get_name(chr(i))]
icons = [(c, get_name(c)) for c in chars if unicodedata.category(c) == 'So']
