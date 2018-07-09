var express = require('express'),
    body_parser = require('body-parser'),
    fs = require('fs')
    app = express(),

app.use(express.static('.'))
app.use(body_parser.json({limit: '50mb'}))
app.post('/clobber', (req, res)=>{
    console.log('writing ' + req.body.length + ' items')
    data_str = JSON.stringify(req.body, null, 4)
    fs.writeFile('data.json', data_str, err => console.log(err))
    res.json('"OK"')
})

app.listen(8080)
