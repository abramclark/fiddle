const cheerio = require('cheerio');
const fs = require('fs');

fs.readFile(process.argv[1], (err, data) =>{
    var d = cheerio.load(data);
    
});

function get_categories($a) {
    var $node = $a.closest("DL").prev();
    var title = $node.text();
    if ($node.length > 0 && title.length > 0) {
        return [title].concat(get_categories($node));
    } else {
        return [];
    }
};
