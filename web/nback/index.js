game = ()=>{

var o = {}, $ = q => document.querySelector(q)

o.x = o.frames = []
o.frame = o.bframe = {}
o.speed = 2000
o.nback = 2
o.evilness = 0
o.select = { x:true, symbol:false, color:false, sound:false }
o.symbol = '123456789'.split('') // ABCDEFGHIJKLMNOPQRSTUVXYZ' 
o.color = ['#000', '#009', '#900', '#960', '#430', '#A3D', '#555',
    '#099', '#990'] 
o.color_names = ['black', 'blue', 'red', 'orange', 'brown', 'pink', 'grey',
    'cyan', 'yellow']
o.sound = ['duck', 'star', 'pie', 'drop', 'ball', 'keys', 'wave', 'gear',
    'tree'] // 🦆 ⭐️ 🍰 💧 ⚽️ 🎹 🌊 ⚙️  🌳
o.sound_sets = []
o.size = 3

o.match = key => o.frame[key] == o.bframe[key]

o.draw_frame = ()=>{
    var el = o.x[o.frame.x != null ? o.frame.x : 4]
    if(o.frame.symbol != null) el.innerText = o.symbol[o.frame.symbol]
    el.style.backgroundColor = o.color[
        o.frame.color != null ? o.frame.color : 1]
    if(o.frame.sound != null)
        window.speechSynthesis.speak(o.sound_sets[0][o.frame.sound])

    setTimeout(()=>{
        el.innerText = ''
        el.style.backgroundColor = o.color[0]
    }, o.speed * .9)
}

o.next_frame = ()=>{
    // var prev_frame = o.frame
    var frame = {}
    if(!o.evilness) for(var k in o.select) if(o.select[k])
        frame[k] = (o.bframe[k] && Math.random() < .333 ? o.bframe[k] :
            Math.floor(Math.random() * o[k].length))
    o.frames.push(o.frame)
    o.bframe = o.frames.length >= o.nback ? o.frames.slice(-o.nback)[0] : {}
    o.frame = frame
    if(o.frames.length > 10) o.frames.unshift()
}

o.step = ()=>{
    o.next_frame()
    o.draw_frame()
}

o.render_board = size =>{
    var div = ()=> document.createElement('div'), board = div()
    o.x = Array(size**2).fill(0).map(()=>{
        var square = div()
        board.append(square)
        return square
    })
    $('#board').replaceWith(board)
    board.id = 'board'
}

o.button_down = (key, el)=>{
    el.classList.add(o.match(key) ? 'yes' : 'no')
}
o.button_up = (key, el)=>{
    el.classList.remove('yes', 'no')
}

var new_sound = s => new SpeechSynthesisUtterance(s)
o.sound_sets = [o.sound, o.symbol, o.color].map(l => l.map(new_sound))
o.render_board(o.size)
o.buttons = {}
Object.keys(o.select).forEach(k =>{
    var el = $('#' + k); o.buttons[k] = el
    el.onmousedown = el.ontouchstart = ()=> o.button_down(k, el)
    el.onmouseup = el.ontouchend = ()=> o.button_up(k, el)
})
o.stop = setInterval(o.step, o.speed)

return o
}
