const cheerio = require('cheerio');
const fs = require('fs');


get_categories = $a =>{
    var $node = $a.closest("DL").prev();
    var title = $node.text();

    if ($node.length > 0 && title.length > 0) {
        return [title].concat(get_categories($node));
    } else {
        return [];
    }
};

entry = link, tags =>{
    url: link.attr('href'),
    imgs: [{ src: link.attr('icon'), dims: [16,16], rel: 'icon' }],
    tags: tags,
    created: (new Date()).getTime(),
    accessed: null,
    name: '',
    description: '',
}

convert = $ =>{
    var saved = [];

    $('a').each((index, a) =>{
        var words = get_categories($(a)).slice(0, -2);
        if(!words.length) return;
        words = words.join(' ').toLowerCase().split(' ');

        console.log($(a).text(), words);
    });
};

fs.readFile(process.argv.slice(-1)[0], (err, data) =>{
    convert(cheerio.load(data));
});
