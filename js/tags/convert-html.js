const cheerio = require('cheerio')
const fs = require('fs')


html_to_tagged = (link, tags)=>{ return {
    url: link.attr('href'),
    tags: tags.map(s => s.toLowerCase()),
    name: link.text(),
    icon: link.attr('icon'),
    time_created: link.attr('add_date')
} }

convert = $ =>{
    var saved = [];

    $('a').each((index, a) =>{
        var folders = get_categories($(a)).slice(0, -2)
        if(!folders.length) return
        saved.push(html_to_tagged($(a), folders))
    })

    console.log(JSON.stringify(saved, null, 4))
}

get_categories = $a =>{
    var $node = $a.closest("DL").prev()
    var title = $node.text()

    if( $node.length > 0 && title.length > 0 ){
        return [title].concat(get_categories($node))
    }else{
        return []
    }
}

fs.readFile(process.argv.slice(-1)[0], (err, data)=>{
    convert(cheerio.load(data))
})
