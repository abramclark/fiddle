import csv
from collections import defaultdict, Counter, namedtuple


neurons_0 = list(csv.reader(open('classification.csv')))
neuron_header = neurons_0.pop(0)
neuron_header[3] = 'cls' # tuple field can't be 'class'
Neuron = namedtuple('Neuron', neuron_header[1:])
neuron_ids = { old: new for new, old in enumerate(sorted(r[0] for r in neurons_0))}
neurons = { neuron_ids[r[0]]: Neuron(*r[1:]) for r in neurons_0 }

labels = Neuron(*[defaultdict(set) for _ in range(len(neurons[0]))])
for i in range(len(labels)):
    for nid, n in neurons.items():
        labels[i][n[i]].add(nid)

synapses_iter = iter(l.rstrip().split(',') for l in open('connections_princeton_no_threshold.csv'))
synapse_header = next(synapses_iter)
Synapse = namedtuple('Synapse', synapse_header[2:])
synapses = defaultdict(dict)
for r in synapses_iter:
    r[3] = int(r[3])
    synapses[neuron_ids[r[0]]][neuron_ids[r[1]]] = Synapse(*r[2:])

# analysis tools

def syn_count(nids, category_fn=lambda n, s: n.super_class +'-'+ s.nt_type):
    cnts = Counter()
    for nid0 in nids:
        for nid1, syn in synapses[nid0].items():
            cnts[category_fn(neurons[nid1], syn)] += syn.syn_count
    return cnts

def random_trace(nid):
    nids = [nid]
    while(neurons[nid].flow != 'efferent'):
        cons = synapses[nid]
        if not cons: break
        weighted = sum(([nid] * syn.syn_count for nid, syn in cons.items()), [])
        nid = random.sample(weighted, 1)[0]
        nids.append(nid)
        if nids.count(nid) > 10:
            print('loop', nid)
            return nids
    return nids
