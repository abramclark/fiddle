var d, t, pi = Math.PI, palette = [], palette_index = 0,
    sin = Math.sin, cos = Math.cos, pow = Math.pow, canvas

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

var cury = function(func){
    var partial_args = Array.prototype.slice.call(arguments, 1);
    return function(){
        func.apply(null, partial_args.concat(arguments));
    }
};

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
    canvas = document.getElementsByTagName('canvas')[0]
    d = canvas.getContext('2d')
    window.onresize = function(){ resize(canvas) }
    window.onresize()

    palette = [
        [5  , 180, 20 , 0.2],
        [40 , 10 , 240, 0.2]
    ]

    palette = [
        [255, 0  , 0  , .2],
        [0  , 0  , 255, .2],
        [255, 255, 0  , .2],
        [255, 0  , 255, .2],
        [0  , 255, 255, .2]
    ]

    palette = [
         [100,20 ,40 ,0.1]
        ,[255,80 ,0  ,0.1]
        ,[220,220,70 ,0.1]
        ,[0  ,100,20 ,0.1]
        ,[0  ,100,220,0.1]
    ]

    //squares_in_sixes.start()
}

function resize(canvas){
    var pixels = [canvas.clientWidth, canvas.clientHeight],
        s = canvas.clientWidth / 1000
    canvas.setAttribute('width', pixels[0])
    canvas.setAttribute('height', pixels[1])
    d.translate(pixels[0] / 2, pixels[1] / 2)
    d.scale(s, s)
    d.save()
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
        var scale = .25 ** i;
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
    swing(()=> swing(()=> swing(()=> shape(4), 6, 100), 4, 200), 6, 400);
};

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

animate = function(draw){
    animate.animations.push(draw)
    animate.frame()
    animate.t0 = + new Date()
}
animate.frame = function(){
    t = (+ new Date() - animate.t0) / 1000
    for(i in animate.animations) animate.animations[i]()
    if(animate.animations.length) window.requestAnimationFrame(animate.frame)
}
animate.stop = function(draw){
    if(draw) animate.animations.splice(animate.animations.indexOf(draw), 1)
    else animate.animations = []
}
animate.animations = []

var squares_in_sixes = function(){
    a += 1;
    if(a % 2) return
    palette_index = palette_index % 1;
    swing(()=> swing(()=> swing(()=> rotate(()=> shape(4), a / 500), 6, 100), 6, 100), 6, 100)
}
var square_spin = ()=> rotate(()=> shape(4), a)
var squares_in_sixes = ()=>{
    f += 1
    if(f % 2) return
    a = t / 10
    palette_index = a % palette.length
    swing_rec(square_spin, .5, 8, 300, 3)
    swing(()=> swing(()=> swing(square_spin, 6, 100), 6, 100), 6, 100)
}
//    var in_sixes = function(){
//        a += .01
//        swing(()=> swing(() => swing(square_spin, 6, 100), 6, 100), 6, 100)
//    }
//    animate(in_sixes)
squares_in_sixes.start = function(){
    window.f = 0
    animate(squares_in_sixes)
}

var square_bang = function(){
    rotate(cury(swing, function(){
        swing(cury(tri, 8, 1000), 8, 0)
    }, pi/8, 0, 2), pi/8);
    swing(cury(lseg, 1000, 0), 8, 0);

    spar4 = ()=> spar(2, 10, 4)
    spar4()
    swing(spar4, 4, 200);
};

swing_bang = (n, a) =>{
    rays(n)
    sparn = ()=> spar(a, 10, n)
    sparn()
    swing(sparn, n, 200)
}

var spar = (p, n, s) =>{
    range(n).map(i =>{
        rotate(()=> shape(s), pi / p ** i)
        rotate(()=> shape(s), -pi / p ** i)
    })
}

var rays = n =>{
    rotate(()=> swing(()=> tri(n, 1000), n, 0, 30), pi/n)
    swing(()=> lseg(1000, 0), n, 0)
}

var swing_rec = function(draw, scale, n, r, l){
    if(l == 0) return
    rotate(()=> swing(()=>{
        d.save()
        draw()
        d.restore()
        d.scale(scale, scale)
        swing_rec(draw, scale, n, r, l - 1)
    }, n, r), 0)
}

var clamp = (v, min, max) => Math.min(Math.max(v, min), max)

var graph = fn =>{
    var width = 10, height = width * (h / w),
        w = canvas.width, h = canvas.height,
        px = width * 2 / w,
        xo = w / 2, yo = h / 2,
        img = d.createImageData(w, h)

    for(x = 0; x < w; x++){
        for(y = 0; y < h; y++){
            var a = (x - xo) * px, b = (y - yo) * px,
                v = clamp((fn(a, b) + 10) / 20, 0, 1),
                c = vector_interp(v, [255, 0, 0], [0, 0, 255]),
                ix = (y * w + x) * 4
            img.data[ix  ] = c[0]
            img.data[ix+1] = c[1]
            img.data[ix+2] = c[2]
            img.data[ix+3] = 255
        }
    }

    d.putImageData(img, -500, -500)
}
