var Tags = ()=>{ var o = {
    items: [], names: {}, tags: [],

    add_item: item =>{
        if( !item.id )
            item.id = o.items.length
        o.items[item.id] = item

        item.tags = item.tags.map(tag_name =>{
            var tag = o.names[tag_name]
            if( !tag ){
                tag = { name: tag_name, items: [], id: o.tags.length }
                o.tags.push(tag)
                o.names[tag_name] = tag
            }

            tag.items.push(item)
            return tag
        })
        return item.id
    },

    get_tags: id => o.items[id].tags,

    sort_by_count: ()=> o.tags.sort((a,b)=> b.items.length - a.items.length),

    items_intersecting: tags =>{
        if( !tags.length ) return []
        if( tags.length == 1 )
            return tags[0].items
        var item_sets = tags.map(t => new Set(t.items)),
            rest = item_sets.slice(1)
        return [...item_sets[0]].filter(item =>
            rest.map(s => s.has(item)).every(x=>x))
    },

    // TODO: implement sort_key and page args
    query_items: (with_tags, without_tags, sort_key, page) =>{
        var items = with_tags.size > 0 ? [...with_tags][0].items : o.items
        return items.filter(item =>{
            var tags = new Set(item.tags)
            return (
                [...with_tags].map(t => tags.has(t)).every(x=>x) &&
                [...without_tags].map(t => !tags.has(t)).every(x=>x)
            )
        })
    },

    tags_from_items: items =>{
        if( !items.length ) return []
        return freq_sort(items.map(x => x.tags).reduce((a,b)=> a.concat(b)))
    },
}; return o }


var TagsView = (tags_el, items_el)=>{ var o = {
    db: Tags(),
    tags_el: $(tags_el), items_el: $(items_el),
    with_tags: new Set(), without_tags: new Set(),
    active_tag: false, tags_visible: new Set(),
    selected_items: new Set(), active_item: false,
    refresh_items_timer: false,

    min_tag_size: .8, max_tag_size: 1.5,

    item_els: ()=> o.items_el.children(),
    tag_els: ()=> o.tags_el.children(),

    item_el: x => document.getElementById('i' + x.id),
    tag_el: x => document.getElementById('t' + x.id),

    render_tag: (tag, max_count)=>{
        var el = $('<div>').addClass('tag').html(tag.name).css('font-size',
            interp(o.min_tag_size, o.max_tag_size, tag.items.length / max_count)
                + 'em'
        ).on('click', ev =>{
            var pick_set = 'with_tags', other_set = 'without_tags'
            if( ev.shiftKey )
                [pick_set, other_set] = ['without_tags', 'with_tags']

            if( !o.tags_visible.has(tag) ){
                o[pick_set] = new Set([tag])
                o[other_set] = new Set()
            }
            else{
                toggle_element(o[pick_set], tag)
                o[other_set].delete(tag)
            }

            o.refresh()
        }).on('mouseover', ev =>{
            if( !o.tags_visible.has(tag) ) return
            o.active_tag = tag
            o.refresh()
        }).on('mouseout', ev =>{
            if( !o.active_tag ) return
            o.active_tag = false
            o.refresh()
        }).on('mousedown', ()=> false)

        el[0].id = 't' + tag.id
        return el
    },

    refresh: ()=>{
        o.tag_els().removeClass('selected').removeClass('inverse')
        o.with_tags.forEach(t => o.tag_el(t).classList.add('selected'))
        o.without_tags.forEach(t => o.tag_el(t).classList.add('inverse'))

        var items = []
        if( o.active_item ) o.tags_visible = new Set(o.active_item.tags)
        else{
            var tags = new Set(o.with_tags)
            if( o.active_tag ) tags.add(o.active_tag)
            items = o.db.query_items(tags, o.without_tags)
            o.tags_visible = new Set(o.db.tags_from_items(items))
        }

        o.without_tags.forEach(t => o.tags_visible.add(t))
        o.tag_els().toggleClass('hide', o.tags_visible.size > 0)
        o.tags_visible.forEach(t => o.tag_el(t).classList.remove('hide'))

        if(o.refresh_items_timer) clearTimeout(o.refresh_items_timer)
        o.refresh_items_timer = setTimeout(()=>{
            if( !o.active_item ){
                o.item_els().toggleClass('hide', items.length != 0)
                items.forEach(item => o.item_el(item).classList.remove('hide'))
            }
        }, 50)
    },

    render_item: item =>{
        var el = $('<div class=item>')
        el[0].id = 'i' + o.db.add_item(item)
        $('<img>').attr('src', item.icon).appendTo(el)
        $('<a>').attr('href', item.url).text(item.name).appendTo(el)

        $('<div class=selector>').appendTo(el).on('click', ev =>{
            $(o.item_el(item)).toggleClass('selected',
                toggle_element(o.selected_items, item))
        })

        return el.on('mouseover', ev =>{
            o.active_item = item
            o.refresh()
        }).on('mouseout', ev =>{
            if( !o.active_item ) return
            o.active_item = false
            o.refresh()
        })
    },

    handle_keys: ev =>{
        console.log(ev.which)
    },

    add_items: items =>{
        o.items_el.append(items.map(o.render_item))
        o.db.sort_by_count()
        o.tags_el.append(o.db.tags.map(t =>
            o.render_tag(t, o.db.tags[0].items.length)))
        window.onkeydown = o.handle_keys
    }
}; return o }


var set_default = (o, key, val)=> o.hasOwnProperty(key) ? o[key] : o[key] = val
        
var interp = (start, end, p)=> (end - start) * p + start

var freq_sort = xs =>{
    var cm = xs.reduce((map, x)=>{
        map.has(x) ? map.set(x, map.get(x) + 1) : map.set(x, 1)
        return map
    }, new Map())
    return [...cm.keys()].sort((a,b)=> cm.get(b) - cm.get(a))
}

var toggle_element = (s, x)=>{
    if( !s.delete(x) ){
        s.add(x)
        return true
    }
    return false
}


load = ()=>{
    window.tv = TagsView('#tags', '#items')
    $.getJSON('index.json', bookmarks => window.tv.add_items(bookmarks))
}
