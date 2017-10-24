var script = document.createElement('script'); script.setAttribute('src','https://code.jquery.com/jquery-3.2.1.min.js'); document.body.appendChild(script);

var set_default = (o, key, val) => o.hasOwnProperty(key) ? o[key] : o[key] = val;

var Tags = ()=>{
    var o = []; o.items = {}; o.named = {};

    o.tag_els = (els, tag) =>{
        $.map( els.length ? els : [els], el =>{
            if(! el.id) el.id = 'a' + Math.floor(Math.random() * 100000000);

            var t = o.named[tag];
            if(! t){
                t = o.length;
                o.push({ name:tag, els:[], id:o.length });
                o.named[tag] = t;
            }

            if(o[t].els.indexOf(el.id) == -1)
                o[t].els.push(el.id);

            var l = set_default(o.items, el.id, [])
            if(! (t in l))
                l.push(t);
        })
    };

    o.tags = id =>
        o.items[id].map(i => o[i]);
    o.els = tag =>
        o[o.named[tag]].els.map(id => document.getElementById(id));

    o.by_count = ()=>{
        var lengths = o.map((t,i) => [t.els.length, i]),
            sorted = lengths.sort((a,b) => b[0] - a[0])
        ;
        return sorted.map(i => o[i[1]]);
    };

    o.tag_span = ()=>{
        // return list of minimum set of tags ordered by freq of use that
        // encompasses all items
        var all_els = Object.keys(o.items), els_left = all_els.length,
            by_els = {}, all_tags = o.by_count(), tag_span = [];
        all_els.forEach(k => by_els[k] = true);

        all_tags.forEach(t =>{
            if( els_left == 0 ) return;
            tag_span.push(t.name);
            t.els.forEach(el =>{
                if( by_els[el] ){
                    els_left -= 1;
                    by_els[el] = false;
                }
            });
        });

        return tag_span;
    };

    o.tag_sum = items =>{
        var tag_list = items.map(i => o.items[i]).reduce((a,b) => a.concat(b))
        return freq_sort(tag_list);
    };

    o.intersect = tag_ids =>{
        if(tag_ids.length == 1) return o[tag_ids[0]].els;
        var el_sets = tag_ids.map(i => new Set(o[i].els));
        return [...el_sets[0]].filter(x => el_sets.slice(1).map(s => s.has(x)).every(x=>x))
    };

    return o;
};
db = Tags();

function freq_sort(xs) {
    var cm = xs.reduce((m, x) =>{
        m.has(x) ? m.set(x, m.get(x) + 1) : m.set(x, 1);
        return m;
    }, new Map());
    return [...cm.keys()].sort((a,b) => cm.get(b) - cm.get(a));
}

function get_categories($a) {
    var $node = $a.closest("DL").prev();
    var title = $node.text();
    if ($node.length > 0 && title.length > 0) {
        return [title].concat(get_categories($node));
    } else {
        return [];
    }
};

script.onload = ()=>{
    $('a').each((index, a) =>{
        var words = get_categories($(a)).slice(0, -2);
        if(!words.length) return;
        words = words.join(' ').toLowerCase().split(' ');
        words.forEach(t => db.tag_els(a, t));
        console.log($(a).text(), words);
    });

    var links = $('a').remove().map((i,el) =>{
        $('<img>').attr('src', el.getAttribute('icon')).prependTo(el);
        el.removeAttribute('icon');
        return el;
    })
    $('body').children().remove();
    $("<div class='bucket'>").appendTo('body').append(links);

    var $nav = $("<div class='tagnav'>").prependTo('body')
    db.tag_span().map(t =>{
        return $("<div class='tag'>").text(t)
    })
}
