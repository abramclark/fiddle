var script = document.createElement('script'); script.setAttribute('src','https://code.jquery.com/jquery-3.2.1.min.js'); document.body.appendChild(script);

var set_default = (o, key, val) => o.hasOwnProperty(key) ? o[key] : o[key] = val

var Tags = ()=>{
    var o = []; o.item = {}; o.name = {}; o.filter = []

    o.tag_els = (els, tag) =>{
        $.map( els.length ? els : [els], el =>{
            if( !el.id )
                el.id = 'a' + Math.floor(Math.random() * 100000000)

            var t = o.name[tag]
            if( !t ){
                t = { name:tag, els:[] }
                o.push(t)
                o.name[tag] = t
            }

            if( t.els.indexOf(el.id) == -1 )
                t.els.push(el.id)

            var l = set_default(o.item, el.id, [])
            if( l.indexOf(t) == -1 )
                l.push(t)
        })
    }

    o.tags = id =>
        o.item[id].map(tag => tag.name)

    o.sort_by_count = ()=>
        o.sort((a,b) => b.els.length - a.els.length)

    //o.tag_span = ()=>{
    //    // return list of minimum set of tags ordered by freq of use that
    //    // encompasses all items
    //    var all_els = Object.keys(o.item), els_left = all_els.length,
    //        by_els = {}, all_tags = o.by_count(), tag_span = []
    //    all_els.forEach(k => by_els[k] = true)

    //    all_tags.forEach(t =>{
    //        if( els_left == 0 ) return
    //        tag_span.push(t.name)
    //        t.els.forEach(el =>{
    //            if( by_els[el] ){
    //                els_left -= 1
    //                by_els[el] = false
    //            }
    //        })
    //    })

    //    return tag_span
    //}

    //o.tag_sum = item =>{
    //    var tag_list = item.map(i => o.item[i]).
    //    return freq_sort(tag_list)
    //}

    o.items_intersecting = tags =>{
        if( !tags.length ) return []
        if( tags.length == 1 )
            return tags[0].els
        var el_sets = tags.map(t => new Set(t.els)),
            rest = el_sets.slice(1)
        return [...el_sets[0]].filter(el_id =>
            el_sets.slice(1).map(s => s.has(el_id)).every(x=>x))
    }

    o.tags_from_items = items =>{
        if( !items.length ) return []
        var tag_names = items.map(id => o.item[id]).reduce(
            (a,b) => a.concat(b)).map(t => t.name)
        return freq_sort(tag_names)
    }

    o.all_items = ()=> $('.bucket .item')
    o.all_tags = ()=> $('.tagnav .tag')

    o.render_tag = (t, max_count) =>{
        var el = $('<div>').addClass('tag').html(t.name).css('font-size',
            interp(.8, 1.5, t.els.length / max_count) + 'em'
        ).on('click', ev =>{
            var in_filter = o.filter.indexOf(t),
                enabled = in_filter == -1
            if(enabled) o.filter.push(t)
            else o.filter.splice(in_filter, 1)

            el.toggleClass('filter', enabled)

            // show only items with all tags in filter list
            to_show = o.items_intersecting(o.filter)
            o.all_items().toggleClass('hide', to_show.length != 0)
            to_show.forEach(el => $('#' + el).removeClass('hide'))

            // only show tags for items being shown
            tags_to_show = o.tags_from_items(to_show)
            o.all_tags().toggleClass('hide', tags_to_show.length != 0)
            tags_to_show.forEach(
                name => o.name[name].tag_el.removeClass('hide'))
        }).on('mousedown', ()=> false)
        t.tag_el = el
        return el
    }

    return o
}
db = Tags()

script.onload = ()=>{
    $('a').each((index, a)=>{
        var words = get_categories($(a)).slice(0, -2)
        if( !words.length ) return
        words = words.join(' ').toLowerCase().split(' ')
        words.forEach(t => db.tag_els(a, t))
        console.log($(a).text(), words)
    })
    db.sort_by_count()

    var links = $('a').remove().map((i,el) =>{
        $('<img>').attr('src', el.getAttribute('icon')).prependTo(el)
        $(el).addClass('item').removeAttr('icon')
        return el
    })

    $('body').children().remove()
    $("<div class='bucket'>").appendTo('body').append(links)

    var $nav = $("<div class='tagnav'>").prependTo('body')
    $nav.append(db.map(t => db.render_tag(t, db[0].els.length)))
}


var interp = (start, end, p) => (end - start) * p + start

var freq_sort = xs =>{
    var cm = xs.reduce((map, x) =>{
        map.has(x) ? map.set(x, map.get(x) + 1) : map.set(x, 1)
        return map
    }, new Map())
    return [...cm.keys()].sort((a,b) => cm.get(b) - cm.get(a))
}

var get_categories = $a =>{
    var $node = $a.closest("DL").prev()
    var title = $node.text()
    if( $node.length > 0 && title.length > 0 ){
        return [title].concat(get_categories($node))
    } else {
        return []
    }
}
