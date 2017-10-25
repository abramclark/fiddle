var trace = false;
mousedown = ev =>{
    trace = [ev.clientX, ev.clientY]
    console.log('down')
};
mousemove = ev =>{
    if(!ev.which) mouseup()
    if(!trace) return
    d.moveTo(trace[0], trace[1])
    var trace_to = [ev.clientX, ev.clientY]
    d.lineTo(trace_to[0], trace_to[1])
    d.stroke()
    trace = trace_to
    console.log(trace, trace_to, ev)
};
mouseup = ev =>{
    trace = false
};

function init(){
    var canvas = $('canvas').eq(0)
    d = canvas[0].getContext('2d')
    $(window).on('resize', function(){ resize(canvas, 0) }) 
    resize(canvas, 0)

    palette = [
        [255, 0  , 0  , .2],
        [0  , 0  , 255, .2],
        [255, 255, 0  , .2],
        [255, 0  , 255, .2],
        [0  , 255, 255, .2]
    ]

    canvas.on('mousedown', mousedown).on('mousemove', mousemove
        ).on('mouseup', mouseup)

    init_card_stack($('.cards'), mth.range(30))
}

function resize(canvas){
    var pixels = [canvas.width(), canvas.height()]
        // ,s = Math.max.apply(null, pixels) / 1000
    canvas.attr('width', pixels[0]).attr('height', pixels[1])
    // d.translate(pixels[0] / 2, pixels[1] / 2)
    // d.scale(s, s)
    // d.save()
}
