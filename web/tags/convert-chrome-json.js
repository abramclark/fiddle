const fs = require('fs')

chrome_to_tagged = (bookmark, tags) =>{
    var opened = (bookmark.meta_info || {}).last_visited_desktop
    return {
        time_created: bookmark.date_added,
        times_opened: opened ? [opened] : [],
        name: bookmark.name,
        tags: tags,
        url: bookmark.url,
    }
}

get_items = bookmarks =>{
    var items = [], walk = (folder, parents) =>{
        if( folder.children ) folder.children.forEach(child =>
            walk(child, parents.concat(folder.name)))
        if( folder.url ) items.push(chrome_to_tagged(folder, parents))
    }
    Object.values(bookmarks.roots).forEach(x => walk(x, []))
    return items
}

convert = bookmarks =>{
    console.log(json.stringify(get_items(bookmarks), null, 4))
}    

fs.readFile(process.argv.slice(-1)[0], (err, data) =>{
    convert(JSON.parse(data))
})
