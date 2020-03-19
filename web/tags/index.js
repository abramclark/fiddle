var Tags = ()=>{ var o = {
    items: [], names: {}, tags: [],

    add_item: item =>{
        if(!item.id)
            item.id = o.items.length
        o.items[item.id] = item

        item.tags = item.tags.map(tag_name =>{
            var tag = o.names[tag_name]
            if(!tag){
                tag = { name: tag_name, items: [], id: o.tags.length }
                o.tags.push(tag)
                o.names[tag_name] = tag
            }

            tag.items.push(item)
            return tag
        })
        return item.id
    },

    delete_item: item =>{
        list_remove(o.items, item)
        var deleted_tags = []
        item.tags.forEach(t =>{
            list_remove(t.items, item)
            if(!t.items.length){
                deleted_tags.push(t)
                o.delete_tag(t)
            }
        })
        return deleted_tags
    },

    delete_tag: tag =>{
        delete o.names[tag.name]
        list_remove(o.tags, tag)
    },

    get_tags: id => o.items[id].tags,

    sort_by_count: ()=> o.tags.sort((a, b)=> b.items.length - a.items.length),

    items_intersecting: tags =>{
        if(!tags.length) return []
        if(tags.length == 1)
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
        if(!items.length) return []
        return freq_sort(items.map(x => x.tags).reduce((a, b)=> a.concat(b)))
    },

    serialize_item: item =>{
        var serialized = Object.assign({}, item)
        serialized.tags = item.tags.map(t => t.name)
        delete serialized.id
        return serialized
    },
    serialize: ()=> o.items.map(o.serialize_item),
}; return o }


var TagsView = (tags_el, items_el)=>{ var o = {
    db: Tags(),
    tags_el: $(tags_el), items_el: $(items_el),
    with_tags: new Set(), without_tags: new Set(),
    active_tag: false, visible_tags: new Set(),
    visible_items: [], active_item: false, selected_items: new Set(),

    min_tag_size: .8, max_tag_size: 1.5,

    item_els: ()=> o.items_el.children(),
    tag_els: ()=> o.tags_el.children(),

    item_el:x => document.getElementById('i' + x.id),
    tag_el :x => document.getElementById('t' + x.id),

    render_tag: (tag, max_count)=>{
        var el = $('<div>').addClass('tag').html(tag.name)
        el[0].id = 't' + tag.id

        el.css('font-size', interp(o.min_tag_size, o.max_tag_size,
            tag.items.length / max_count) + 'em')

        el.on('click', ev =>{
            var pick_set = 'with_tags', other_set = 'without_tags'
            if(ev.shiftKey) [pick_set, other_set] = [other_set, pick_set]

            if(!o.visible_tags.has(tag)){
                o[pick_set] = new Set([tag])
                o[other_set] = new Set()
            }
            else{
                toggle_element(o[pick_set], tag)
                o[other_set].delete(tag)
            }

            o.update_tag_selection()
            o.float_visible_tags()
            o.set_active_tag(tag)
            o.refresh()
        }).on('mouseover', ev => o.set_active_tag(tag)
        ).on('mouseout', ev => o.set_active_tag(false)
        ).on('mousedown', ()=> false)

        return el
    },

    update_tag_selection: ()=>{
        o.visible_items = o.db.query_items(o.with_tags, o.without_tags)
        o.visible_tags = new Set(o.db.tags_from_items(o.visible_items))
    },

    set_active_tag: tag =>{
        // don't set active tag filter when it would remove all items
        tag = (!o.visible_tags.has(tag) || o.without_tags.has(tag) ?
            false : tag)
        if(tag == o.active_tag) return
        o.active_tag = tag
        o.refresh()
    },

    float_visible_tags: ()=>{
        var tags_el2 = o.tags_el[0].cloneNode(false)
        o.visible_tags.forEach(t => tags_el2.appendChild(o.tag_el(t)) )
        o.db.tags.forEach(t =>{
            if(!o.visible_tags.has(t)) tags_el2.appendChild(o.tag_el(t)) })
        o.tags_el.replaceWith(tags_el2)
        o.tags_el = $(tags_el2)
    },

    last_selected: false,
    render_item: item =>{
        var el = $('<div class=item>')
        el[0].id = 'i' + o.db.add_item(item)

        $('<img>').attr('src', item.icon).appendTo(el)
        $('<a>').attr('href', item.url).text(item.name).appendTo(el)

        $('<div class=selector>').appendTo(el).on('click', ev =>{
            if(ev.shiftKey && o.last_selected){
                var ix1 = o.visible_items.indexOf(o.last_selected)
                var ix2 = o.visible_items.indexOf(item)
                if(ix1 > ix2) [ix1, ix2] = [ix2, ix1]
                for(var i = ix1; i <= ix2; i++)
                    o.set_item_selection(o.visible_items[i], true)
            } else o.set_item_selection(item)
            if(o.selected_items.has(item)) o.last_selected = item
        })

        return el.on('mouseover', ev =>{
            o.active_item = item
            o.refresh()
        }).on('mouseout', ev =>{
            if(!o.active_item) return
            o.active_item = false
            o.refresh()
        })
    },

    // set, unset, or toggle (selected = undefined) item selection 
    set_item_selection: (item, selected) =>{
        if(selected) o.selected_items.add(item)
        else if(selected == undefined)
            selected = toggle_element(o.selected_items, item)
        else o.selected_items.delete(item)
        $(o.item_el(item)).toggleClass('selected', selected)
    },

    refresh: RateLimited(()=>{
        o.tag_els().removeClass('selected').removeClass('inverse')
        o.with_tags.forEach(t => o.tag_el(t).classList.add('selected'))
        o.without_tags.forEach(t => o.tag_el(t).classList.add('inverse'))

        // local visible_tags includes on-hover o.active_tag filter in with_tags
        var visible_tags = o.visible_tags
        if(o.active_item) visible_tags = new Set(o.active_item.tags)
        else{
            if(o.active_tag){
                var tags = new Set(o.with_tags)
                tags.add(o.active_tag)
                visible_items = o.db.query_items(tags, o.without_tags)
                visible_tags = new Set(o.db.tags_from_items(visible_items))
            } else visible_items = o.visible_items
            
            o.item_els().toggleClass('hide', visible_items.length != 0)
            visible_items.forEach(item =>
                o.item_el(item).classList.remove('hide'))
        }

        o.without_tags.forEach(t => visible_tags.add(t))
        o.tag_els().toggleClass('hide', visible_tags.size > 0)
        visible_tags.forEach(t => o.tag_el(t).classList.remove('hide'))
    }, 50),

    cmd_el:$('#cmd')[0],
    handle_keys: ev =>{
        var kc = ev.which, c = String.fromCharCode(kc)
        if(kc == 27){
            if(o.selected_items.size){
                o.selected_items.forEach(item =>
                    o.set_item_selection(item, false))
                return
            }else if(o.cmd_el.value){
                o.cmd_el.value = ''
                return
            }
        }else if(kc == 8 && ev.ctrlKey){
            o.selected_items.forEach(i => o.delete_item(i))
            o.active_item = false
            o.refresh()
        }else if(( (kc >= 32) && (kc <= 126) ) || (kc == 8) || (kc == 46)){
            o.cmd_el.focus()
        }else console.log('key', kc)
    },

    add_items: items =>{
        o.items_el.append(items.map(o.render_item))
        o.db.sort_by_count()
        o.tags_el.append(o.db.tags.map(t =>
        o.render_tag(t, o.db.tags[0].items.length)))
        o.update_tag_selection()
        window.onkeydown = o.handle_keys
    },

    delete_item: item =>{
        deleted_tags = o.db.delete_item(item)
        o.item_el(item).remove()
        o.selected_items.delete(item)
        deleted_tags.forEach(t =>{
            o.tag_el(t).remove()
            o.with_tags.delete(t)
            o.without_tags.delete(t)
        })
    },

    save_db: ()=>{
        $.ajax('/clobber', {
            type:'POST',
            data:JSON.stringify(tv.db.serialize()),
            success:r=> console.log('HI', r),
            contentType:'application/json'}
        )
    },
}; return o }


var set_default = (o, key, val)=> o.hasOwnProperty(key) ? o[key] : o[key] = val

var interp = (start, end, p)=> (end - start) * p + start

var freq_sort = xs =>{
    var counts = xs.reduce((map, x)=>{
        map.has(x) ? map.set(x, map.get(x) + 1) : map.set(x, 1)
        return map
    }, new Map())
    return [...counts.keys()].sort((a, b)=> counts.get(b) - counts.get(a))
}

var toggle_element = (s, x)=>{ if(!s.delete(x)) return s.add(x) }

var list_remove = (l, x)=>{
    var ix = l.indexOf(x)
    if(ix > -1){
        l.splice(ix, 1)
        return x
    }
}

var RateLimited = (fn, min_wait_ms)=>{
    var timer = false
    return ()=>{
        if(timer) clearTimeout(timer)
        timer = setTimeout(fn, min_wait_ms)
    }
}


load = ()=>{
    window.tv = TagsView('#tags', '#items')
    $.getJSON('index.json', bookmarks => window.tv.add_items(bookmarks))
}
