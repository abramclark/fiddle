from itertools import islice


def all_states():
    alls = set()
    def walk_states(state, play):
        if 0 not in state: return [state]
        states = [update(state, i, play) for i, v in enumerate(state) if not v]
        states = dedup(states, alls)
        play2 = 1 if play == 2 else 2
        for s in states:
            walk_states(s, play2)

    walk_states((0,)*9, 1)
    return alls


def threes(s):
    return [
        s[0:3],
        s[3:6],
        s[6:9],
        s[0::3],
        s[1::3],
        s[2::3],
        (s[0], s[4], s[8]),
        (s[2], s[4], s[6]),
    ]


def finished(s):
    wins = threes(s)
    return (1,1,1) in wins or (2,2,2) in wins


def imap(s, *ixs):
    return tuple(map(s.__getitem__, ixs))


def symetries(s):
    return [
        s,
        imap(s, 0, 3, 6, 1, 4, 7, 2, 5, 8),
        imap(s, 2, 1, 0, 5, 4, 3, 8, 7, 6),
        imap(s, 2, 5, 8, 1, 4, 7, 0, 3, 6),
        imap(s, 6, 3, 0, 7, 4, 1, 8, 5, 2),
        imap(s, 6, 7, 8, 3, 4, 5, 0, 1, 2),
        imap(s, 8, 5, 2, 7, 4, 1, 6, 3, 0),
        imap(s, 8, 7, 6, 5, 4, 3, 2, 1, 0),
    ]


def dedup(states, uniq=set()):
    new_uniq = set()
    for s in states:
        if finished(s) or any([sym in uniq for sym in symetries(s)]):
            continue
        new_uniq.add(s)
        uniq.add(s)
    return new_uniq


def show(s):
    print('\n'.join([' '.join(r) for r in chunks(map(str, s), 3)]) + '\n')


def chunks(l, n):
    n = max(1, n)
    return (l[i:i+n] for i in xrange(0, len(l), n))

def update(t, i, v):
    return t[:i] + (v,) + t[i+1:]


print(len(all_states()))
