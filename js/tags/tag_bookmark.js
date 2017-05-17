var script = document.createElement('script'); script.setAttribute('src','https://code.jquery.com/jquery-3.2.1.min.js'); document.body.appendChild(script);

var set_default = (o, key, val) => o.hasOwnProperty(key) ? o[key] : o[key] = val;

var Tags = ()=>{
    var o = []; o.by_item = {}; o.by_name = {};

    o.tag_els = (els, tag)=>{ $.map( els.length ? els : [els], el =>{
        if( !el.id ) el.id = 'a' + Math.floor( Math.random() * 100000000 );

        var t = o.by_name[tag];
        if( ! t ){
            t = o.length;
            o.push({ name:tag, els:[], id:o.length });
            o.by_name[tag] = t;
        }

        if( ! (el.id in o[t].els ) )
            o[t].els.push(el.id);

        var l = set_default(o.by_item, el.id, [])
        if( ! (t in l) )
            l.push(t);
    }) };

    o.tags = id =>
        o.by_item[id].map(i => o[i]);
    o.els = tag =>
        o[o.by_name[tag]].els.map(id => document.getElementById(id));

    o.by_count = ()=>{
        var sorted = db.map((t,i) => [t.els.length, i]).sort((a,b) => (a[0] > b[0]) ? ( (a[0] == b[0]) ? 0 : -1 ) : 1);
        return sorted.map(i => o[i[1]]);
    };

    o.tag_span = ()=>{
        // return list of minimum set of tags ordered by freq of use that
        // encompasses all items
        var all_els = Object.keys(o.by_item), els_left = all_els.length,
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

    o.also = t =>{
        if( typeof t == 'number' ) t = o[t];
        return [...new Set( [].concat.apply([], t.els.map(i => db.by_item[i])) )].map(i => db[i])
    };

    o.intersect = tag_ids =>{
        var el_sets = ts.map(t => new Set(t.els))
        [...el_sets[0]].filter(x => el_sets.slice(1).map(s => s.has(x)).every(x=>x))
    };

    return o;
};
db = Tags();

var getCategories = $a =>{
    var $node = $a.closest("DL").prev();
    var title = $node.text();
    if ($node.length > 0 && title.length > 0) {
        return [title].concat(getCategories($node));
    } else {
        return [];
    }
};

script.onload = ()=>{
    $('a').each((index, a) =>{
        var words = getCategories($(a)).slice(0, -2);
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
