var http = require('http')
var fs = require('fs')


http.createServer((req, res)=>{
    var index_name = 'index.html', doc = ''
    console.log('serving ' + req.url)

    if(req.method == 'GET'){
        var head = {'Content-Type': 'text/html'},
            doc = path_map(req.url, index_name)

        if(!doc){
            res.writeHead(404, head)
            doc = '404 not found'
        }
        res.writeHead(200, head)
    }

    if(req.method == 'POST'){
        res.writeHead(200, {'Content-Type': 'application/json'})
        doc = '{}'
    }

    res.end(doc)
}).listen(8080)


var path = require('path'), path_map = (name, index)=>{
    var name = path.normalize(name).slice(1)
    name = name ? name : '.'

    try{ stats = fs.lstatSync(name) }
    catch(e){ return null }
    if(stats.isDirectory())
        name = path.join(name, index)

    try{ doc = fs.readFileSync(name) }
    catch(e){ return null }

    return doc
}
