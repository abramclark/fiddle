var d, mth = more_math();

init_card_stack = ($parent, texts) =>{
    var mousemove = ev =>{
        if(! ev.which) mouseup();

        var x = Math.max(0, (ev.clientX - $parent.offset().left) / width),
            x = Math.min(1, x),
            y = (ev.clientX - $parent.offset().top) / $parent.height(),
            n = (card_count - 1) * x
        ;    
        console.log(n);
        $cards.each((i, el) =>{
            $(el).css({
                left: min_space * i + spacings(i - n) * card_width,
                'z-index': Math.floor(card_count - Math.abs(i - n))
            });
            console.log($(el).css('z-index'));
        });
    }, mousedown = ev =>{
        down = true;
    }, mouseup = ev =>{
        down = false;
    }, down = false;

    var card_count = $parent.children().length;
    if(texts){
        card_count += texts.length
        var new_cards = texts.map((d, i) =>(
            $('<div>').append(d).css('z-index', card_count - i)
        ), texts);
        $parent.append(new_cards);
    }

    var width = $parent.width(),
        $cards = $parent.children(),
        card_width = $cards.eq(0).width(),
        min_space = (width - card_width) / card_count
    ;

    var spacings_discrete = i_off => (Math.sign(i_off) * (
        [0, .9, 1.7, 2.2, 2.5, 2.7][Math.min(Math.abs(i_off), 5)] +
        Math.max(0, Math.abs(i_off) - 5) * .2
    ));
    var spacings = i_off =>{
        var i = Math.floor(i_off),
            left = spacings_discrete(i),
            right = spacings_discrete(i + 1)
        ;
        return mth.interp(i_off - i, left, right);
    };

    $cards.each((i, el) => $(el).css({left: card_width * spacings(i), bottom: 0}));
    $parent.on('mousedown', mousedown);
    $(window).on('mousemove', mousemove);
    $(window).on('mouseup', mouseup);
};

init = ()=>{
    init_card_stack($('.cards'), mth.range(150))
};

function more_math(){
    var o = {}

    o.range = (start, end) =>{
        if(typeof(end) == 'undefined'){ end=start; start=0; }
        var l = []
        for(var i = start; i < end; i++) l.push(i)
        return l
    }

    o.interp = (p, start, end) => (end - start) * p + start;

    o.op = {
        '+' : (a, b) =>{ return a + b },
        '-' : (a, b) =>{ return a - b },
        '*' : (a, b) =>{ return a * b },
        '/' : (a, b) =>{ return a / b },
        '%' : (a, b) =>{ return a % b }
    };

    o.sign = x => {
        return typeof x === 'number' ? x ? x < 0 ? -1 : 1 : x === x ? 0 : NaN : NaN;
    };

    o.apply = (func, scale) =>{
        var scalar_functor = l =>{
            if (typeof(l) == "number") return func(scale, l);
            return $.map(l, x => func(scale, x));
        }
        var vector_functor = l =>{
            // TODO: error handling?
            if(typeof(l) == "number"){
                return $.map(scale, (x, i) => func(x, l));
            }else{
                return $.map(l, (x, i) => func(scale[i], x));
            }
        };
        var variadic_functor = s =>{
            return (typeof(s) == "number") ? scalar_functor : vector_functor;
        };
        if(arguments.length < 3)
            return variadic_functor(scale);
        for(var i = 2; i < arguments.length; ++i){
            scale = variadic_functor(scale)(arguments[i]);
        }
        return scale;
    };

    o.mul = ()=> o.apply.apply(null, [o.op['*']].concat(Array.prototype.slice.call(arguments, 0)));
    o.add = ()=> o.apply.apply(null, [o.op['+']].concat(Array.prototype.slice.call(arguments, 0)));
    o.div = ()=> o.apply.apply(null, [o.op['/']].concat(Array.prototype.slice.call(arguments, 0)));
    o.sub = ()=> o.apply.apply(null, [o.op['-']].concat(Array.prototype.slice.call(arguments, 0)));
    o.inv = v => v.map(x => 1/x);
    o.min = ()=> o.apply.apply(null, [Math.min].concat(Array.prototype.slice.call(arguments, 0)));
    o.max = ()=> o.apply.apply(null, [Math.max].concat(Array.prototype.slice.call(arguments, 0)));
    o.floor = v => v.map(Math.floor);

    return o
};
