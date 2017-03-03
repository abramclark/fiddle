var d, mth = more_math()

trace = false
mousedown = function(ev){
    trace = [ev.clientX, ev.clientY]
    console.log('down')
}
mousemove = function(ev){
    if(!ev.which) mouseup()
    if(!trace) return
    d.moveTo(trace[0], trace[1])
    var trace_to = [ev.clientX, ev.clientY]
    d.lineTo(trace_to[0], trace_to[1])
    d.stroke()
    trace = trace_to
    console.log(trace, trace_to, ev)
}
mouseup = function(ev){
    trace = false
}

function init_card_stack($parent, data){
    var width = $parent.width(), card_count = $parent.children().length

    if(data && data.map) {
        card_count += data.length
        var new_cards = data.map(function(d, i){ return (
            $('<div>').append(d).css('z-index', card_count-i)
        ) }, data)
        $parent.append(new_cards)
    }

    var $cards = $parent.children(),
        card_width = $cards.eq(0).width(),
        spacing = (width - card_width) / card_count
    $cards.each(function(i, el){ $(el).css('left', spacing * i) })

    $parent.on('mousemove', function(ev){
        var pos = card_count * (ev.clientX
                - $parent.offset().left - card_width) / width
        $cards.each(function(i, el){
            var offset = Math.exp(-.5 * Math.pow(i - pos, 2)) * card_width * 2
            $(el).css('left', offset + spacing * i)
        })
    })
}

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

function more_math(){
    var o = {} 

    o.range = function(start, end) {
        if(typeof(end) == 'undefined') { end=start; start=0; }
        var l = []
        for(var i = start; i < end; i++) l.push(i)
        return l
    }

    o.op = {
        '+' : function(a, b) { return a + b },
        '-' : function(a, b) { return a - b },
        '*' : function(a, b) { return a * b },
        '/' : function(a, b) { return a / b },
        '%' : function(a, b) { return a % b }
    }

    o.sign = function(x) {
        return typeof x === 'number' ? x ? x < 0 ? -1 : 1 : x === x ? 0 : NaN : NaN;
    }

    o.apply = function(func, scale) {
        var scalar_functor = function(l) {
            if (typeof(l) == "number") return func(scale, l);
            return $.map(l, function(x) { return func(scale, x); });
        }
        var vector_functor = function(l) {
            // TODO: error handling?
            if (typeof(l) == "number") {
                return $.map(scale, function(x, i) { return func(x, l); });
            } else {
                return $.map(l, function(x, i) { return func(scale[i], x); });
            }
        }
        var variadic_functor = function(s) {
            return (typeof(s) == "number") ? scalar_functor : vector_functor;
        }
        if (arguments.length < 3)
            return variadic_functor(scale);
        for (var i = 2; i < arguments.length; ++i) {
            scale = variadic_functor(scale)(arguments[i]);
        }
        return scale;
    };

    o.mul = function(){ return o.apply.apply(null, 
        [o.op['*']].concat(Array.prototype.slice.call(arguments, 0))) }
    o.add = function(){ return o.apply.apply(null, 
        [o.op['+']].concat(Array.prototype.slice.call(arguments, 0))) }
    o.div = function(){ return o.apply.apply(null, 
        [o.op['/']].concat(Array.prototype.slice.call(arguments, 0))) }
    o.sub = function(){ return o.apply.apply(null, 
        [o.op['-']].concat(Array.prototype.slice.call(arguments, 0))) }
    o.inv = function(v){ return v.map(function(x){ return 1/x; }) }
    o.min = function(){ return o.apply.apply(null, 
        [Math.min].concat(Array.prototype.slice.call(arguments, 0))) }
    o.max = function(){ return o.apply.apply(null, 
        [Math.max].concat(Array.prototype.slice.call(arguments, 0))) }
    o.floor = function(v){ return v.map(Math.floor) }

    return o
}
