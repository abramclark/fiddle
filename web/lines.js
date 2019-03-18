var d, pi = Math.PI, palette = [], palette_index = 0,
    sin = Math.sin, cos = Math.cos, pow = Math.pow,
    sqrt = function(v){ return pow(v, .5) },
    square = function(v){ return pow(v, 2) };

var range = function(start, end) {
    if (typeof(end) == "undefined") { end=start; start=0; }
    var l = [];
    for (var i = start; i < end; i++){
        l.push(i);
    }
    return l;
};

var zip = function(list1, list2) {
    var ret = [];
    for(var i = 0; i < list1.length; i++) ret.push([list1[i], list2[i]]);
    return ret;
};

var partial = function(func){
    var partial_args = Array.prototype.slice.call(arguments, 1);
    return function(){
        func.apply(null, partial_args.concat(arguments));
    }
};

var move = function(p){ d.moveTo(p[0], p[1]) }
var line = function(p){ d.lineTo(p[0], p[1]) }
var interp = function(p, start, end){ return (end - start) * p + start };
var vector_interp = function(p, start, end){
    return zip(start, end).map(function(v){ return interp(p, v[0], v[1]) });
};
var css_color = function(l){
    return 'rgba(' + 
        l.slice(0,3).map(function(v){ return v >> 0 }).concat(l[3]).join(',')
        + ')';
};
var next_index = function(list, i){ return (i + 1) % list.length };
var get_color = function(i){
    var index = i >> 0, fraction = i % 1;
    return vector_interp(fraction, palette[index],
        palette[next_index(palette, index)]);
};
var palette_next = function(){
        var color = get_color(palette_index);
        palette_index = next_index(palette, palette_index);
        return css_color(color);
    },
    palette_fill = function(){
        d.fillStyle = palette_next(); },
    palette_stroke = function(){
        d.strokeStyle = palette_next(); };

var init = function(){
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

    lines2()
}

var lines = function(){
    var p1 = [-462, -400], p2 = [462,-400], p3 = [0, 400]

    var splay = function(c1, c2, c3, o){
        d.beginPath()
        var n = 40; range(o, n).map(function(i){
            move(vector_interp(i/n, c1, c3))
            line(vector_interp(i/n, c2, c1))
        })
        d.stroke()
    }

    f = 0
    frame = function(){
        f += .01
        clear()

        move(p1)
        line(p2)
        line(p3)
        d.closePath()
        d.stroke()

        splay(p1, p2, p3, f)
        splay(p2, p3, p1, f)
        splay(p3, p1, p2, f)
        if(f > 1) f = 0
    }
    animate(frame)
}
var lines2 = function(){
    p1 = [-400, 0], p2 = [-200, -346.4], p3 = [200, -346.4]
    p4 = [400, 0], p5 = [200, 346.4], p6 = [-200, 346.4]

    splay = function(c1, c2, c3, c4, o){
        d.beginPath()
        var n = 30; range(o, n).map(function(i){
            move(vector_interp(i/n, c1, c2))
            line(vector_interp(i/n, c3, c4))
        })
        d.stroke()
    }

    f = 0
    frame = function(){
        f += .01
        clear()

        circle(400)
        move(p1); line(p2); line(p3); line(p3); line(p4); line(p5); line(p6)
        d.closePath(); d.stroke()

        splay(p1, p2, p2, p3, f)
        splay(p2, p3, p3, p4, f)
        splay(p3, p4, p4, p5, f)
        splay(p4, p5, p5, p6, f)
        splay(p5, p6, p6, p1, f)
        splay(p6, p1, p1, p2, f)

        splay(p1, p2, p3, p4, f)
        splay(p2, p3, p4, p5, f)
        splay(p3, p4, p5, p6, f)
        splay(p4, p5, p6, p1, f)
        splay(p5, p6, p1, p2, f)
        splay(p6, p1, p2, p3, f)

        splay(p1, p2, p4, p5, f)
        splay(p2, p3, p5, p6, f)
        splay(p3, p4, p6, p1, f)

        if(f >= .99) f = 0
    }
}

var animating = 0, animate = function(f){
    animating = 1
    var do_animate = function(){
        f()
        if(animating) requestAnimationFrame(do_animate)
    }
    do_animate()
}, stop = function(){ animating = 0 }

function resize(canvas, scale_coord){
    var height = 1024 * (canvas.height() / canvas.width())
    canvas.attr('height', height)
    d.translate(512, height / 2)
    d.scale(.8, .8)
    d.save()

    // var pixels = [canvas.width(), canvas.height()]
    //     ,s = pixels[scale_coord] / 1000
    // canvas.attr('width', pixels[0]).attr('height', pixels[1])
    // d.translate(pixels[0] / 2, pixels[1] / 2)
    // d.scale(s, s)
    // d.save()
}

var clear = function(){
    d.restore(); d.save();
    d.clearRect(-1280,-720,2560,1440);
};

var gfx = function(draw){ return function(){
    d.save();
    draw.apply(null, arguments);
    d.restore();
} };

var rotate = gfx(function(draw, a){ d.rotate(a); draw() });

var shape = function(n){
    var seg = function(a){
        d.rotate(pi*2/a);
        d.lineTo(100,0);
    };

    d.save();
    d.beginPath();
    d.moveTo(100,0);
    range(n-1).map(function(){seg(n)});
    d.closePath();
    palette_fill();
    d.stroke();
    d.fill();
    d.restore();
};

var swing = function(draw, slice, r, steps){
    if(!steps) steps = slice;
    d.save();
    range(steps).map(function(){
        d.save();
        d.translate(r, 0);
        draw();
        d.restore();
        d.rotate(2*pi/slice);
    });
    d.restore();
};

var lsegr = function(l, a){
    d.beginPath();
    d.moveTo(0,0);
    d.rotate(a);
    d.translate(l,0);
    d.lineTo(0,0);
    // palette_stroke();
    d.stroke();
}, lseg = gfx(lsegr);

var tri = function(slice, r){
    var a = 2*pi/slice;
    d.save();
    d.beginPath();
    d.moveTo(0,0);
    d.rotate(-a/2);
    d.lineTo(r, 0);
    d.rotate(a);
    d.lineTo(r, 0);
    d.closePath();
    palette_fill();
    d.fill();
    d.restore();
};

var jewel = function(){
    var jewel_1 = function(){
        swing(function(){ shape(6) }, 9, 189);
        swing(function(){ shape(6) }, 9, 195);
        swing(function(){ shape(6) }, 9, 183);

        swing(function(){ shape(4) }, 6, 85);
        swing(function(){ shape(4) }, 6, 91);
        swing(function(){ shape(4) }, 6, 79);
    };

    range(22).map(function(){ swing(function(){ tri(9, 800) }, 18, 0) });

    jewel_1();

    swing(function(){
        d.save(); d.scale(.2,.2); d.rotate(pi/9); jewel_1(); d.restore();
    }, 9, 354);
};

var penta_splay = function(a){
    var splay = function(){
        swing(function(){ shape(5) }, 18, 202);
        swing(function(){ shape(5) }, 18, -402);
    };

    d.strokeStyle = 'rgb(255,255,255)';
    var dir = 1;
    range(5).map(function(i){
        dir *= -1;
        d.save();
        d.rotate(dir * a);
        var scale = Math.pow(.25, i);
        d.scale(scale, scale);
        splay();
        d.restore();
    });

    d.restore(); d.save();
};

var penta_mosaic = function(){
    swing(function(){ swing(function(){ swing(function(){ swing(function(){ swing(function(){ shape(5) }, 5, 100) }, 5, 100) }, 5, 100) }, 5, 100) }, 5, 100);
};

var wild_ride = function(){
    swing(function(){ swing(function(){ swing(function(){ shape(4) }, 6, 100) }, 4, 200) }, 6, 400);
};

var circle = function(r){
    var step = 1/r
    d.beginPath()
    d.moveTo(r, 0);
    for(var n = 0; n <= 2*pi; n += step){
        d.lineTo(r, 0);
        d.rotate(step);
    }
    d.closePath()
    d.stroke()
}

var wobble = function(freq, amp, phase, radius_center){
    var n = 0, r = function(){
        return radius_center + Math.sin(n * freq + phase) * amp; };
    d.save();
    d.beginPath();
    var step = 2*pi / ((radius_center * 2) + 50)
    d.moveTo(r(), 0);
    for(; n <= 2*pi; n += step){
        d.lineTo(r(), 0);
        d.rotate(step);
    }
    d.closePath();
    d.stroke();
    palette_fill();
    d.fill();
    d.restore();
};

var spirate = function(bump, twist){
    range(80).reverse().map(function(i){
        wobble(7, sin(i * pi/50) * bump, twist * i * pi/50, 10 + i * 5)
    })
}
var bump = 40, new_bump = 40, twist = 0, spiration = function(){
    spirate(bump, twist)
    twist += .2
    setTimeout(spiration, 20)
    if(bump != new_bump){
        var diff = new_bump - bump
        bump += 1 * diff / Math.abs(diff)
    }
}

var tri_hexa = function(){
    var triseg = function(){
        swing(function(){
            swing(function(){ shape(6) }, 60, 100, 11);
            d.rotate(pi);
            swing(function(){ shape(6) }, 60, 100, 11)
        }, 3, 200);
    };

    triseg();
    swing(function(){
        d.translate(200,0);
        d.rotate(-pi/3);
        d.translate(400,0);
        triseg();
    }, 3, 0);
};

var squares_in_sixes = function(){
    var a = 0, square_spin = function(){ d.rotate(a); shape(4); };
    return setInterval(function(){
        palette_index = palette_index % 1;
        a += .01;
        swing(function(){
            swing(function(){
                swing(function(){ square_spin() }, 6, 100)
            }, 6, 100)
        }, 6, 100)
    }, 50);
};

var square_bang = function(){
    var spar = function(){
        range(6).map(function(i){
            rotate(partial(shape, 4), pi/pow(2,i+2));
            rotate(partial(shape, 4), -pi/pow(2,i+2));
        })
    };

    rotate(partial(swing, function(){
        swing(partial(tri, 8, 1000), 8, 0)
    }, pi/8, 0, 2), pi/8);
    swing(partial(lseg, 1000, 0), 8, 0);

    spar();
    swing(partial(rotate, spar, pi/4), 4, 200);
};

var spar = function(p, n, s){
    range(n).map(function(i){
        rotate(partial(shape, s), pi/pow(p,i+2));
        rotate(partial(shape, s), -pi/pow(p,i+2));
    })
};
