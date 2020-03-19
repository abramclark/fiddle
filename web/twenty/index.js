$ = q => document.querySelector(q)
a = null
spacing = 12

block = (color, glue_down, glue_right)=>{
    var o = {color:color, glue_down:glue_down, glue_right:glue_right}
    o.el = div('block c' + color)
    o.el.textContent = color + 1
    o.pos = [0, 0]

    if(glue_down) o.el.appendChild(div('glue down'))
    if(glue_right) o.el.appendChild(div('glue right'))

    $('.arena').appendChild(o.el)

    o.pos_set = p =>{
        o.pos = p
        o.el.style.left = (p[0] * spacing) + 'vh'
        o.el.style.top = (p[1] * spacing) + 'vh'
    }
    return o
}

arena = ()=>{
    var o = {grid:new Array(8).fill([])}

    o.add_block = pos =>{
        o.grid[pos[0]][pos[1]] = block(

    o.grid.forEach((row, i)=>{
        row[0] = block(i, 0, 0)
        row[0].pos_set([0, i])
        console.log(i, row)
    })

    return o
}

init = ()=>{
    a = arena()
}

range = (start, end)=>{
    if(typeof(end) == "undefined") { end=start; start=0; }
    var l = [];
    for (var i = start; i < end; i++){
        l.push(i)
    }
    return l
}

div = class_name =>{
    var el = document.createElement('div')
    el.className = class_name
    return el
}
