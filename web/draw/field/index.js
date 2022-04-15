pi = Math.PI;
$ = q => document.querySelector(q);
canvas = $('canvas');
aspect = canvas.offsetHeight / canvas.offsetWidth;
canvas.height = canvas.width * aspect;
d = $('canvas').getContext('2d');
m = [];
size = [200, 200];
m_scale = [size[0] / (canvas.width * 1.5), size[1] / (canvas.height * 1.5)];
m_off = [canvas.width * 0.25, canvas.height * 0.25];

var init_m = ()=>{
    for(var x = 0; x <= size[0]; x++) {
        m[x] = [];
        for(var y = 0; y <= size[1]; y++) {
            var i = x - size[0] / 2, j = y - 100;
            var d = i ** 2 + j ** 2;
            var s = Math.max(0.07, d / 6000) ** 2 * 5;
            var a = Math.random() * pi / 2 + d / 800;
            m[x][y] = [Math.cos(a) * s, Math.sin(a) * s];

            //var d = 1.0, d2 = 100 / Math.max(1, (i ** 2 + j ** 2));
            // var a2 = Math.atan2(i, j) + pi;
            //var a = x * pi / size[0] + y * 1.5 * pi / size[1] + (Math.random() * 0.125 - 0.0625) * pi;
            //m[x][y] = [Math.cos(a) * d / d2 + Math.cos(a2) * d2, Math.sin(a) * d / d2 + Math.sin(a2) * d2];
        }
    }
};

const clamp = (v, min, max)=> Math.min(Math.max(min, v), max);

const color4i = l =>('rgb(' +
    l.slice(0, 3).map(v => v >> 0).concat(l[3]).join(',') + ')');

get_val = (x, y)=> m
    [clamp(Math.floor((x + m_off[0]) * m_scale[0]), 0, size[0])]
    [clamp(Math.floor((y + m_off[1]) * m_scale[1]), 0, size[1])];

trace = (x, y, steps, color)=>{
    if(color) d.strokeStyle = color4i(color);
    d.beginPath();
    d.moveTo(x, y);
    var dx = 0, dy = 0;
    for(var i = 0; i < steps; i++) {
       var v = get_val(x, y);
       x += v[0];
       y += v[1];
       //dx += v[0];
       //dy += v[1];
       //x += dx;
       //y += dy;
       d.lineTo(x, y);
    }
    d.stroke()
}

init_m();

var color_scale = 255 / canvas.height;
var delta = 10;

trace_random = ()=>{
    var x = Math.random() * canvas.width * 1.5 - canvas.width * 0.25;
    var y = Math.random() * canvas.height * 1.5 - canvas.height * 0.25;
    trace(x, y, 200, [0, (canvas.height - y) * color_scale, y * color_scale, 0.8]);
};

var go = 1;
frame = ()=>{
    for(var i = 0; i < 100; i++) trace_random();
    if(go) requestAnimationFrame(frame);
};

frame();

window.onkeydown = ev =>{
    if(ev.key == ' ') {
        if(go) go = 0;
        else {
            go = 1;
            frame();
        }
    }
};

//trace_row = y =>{
//  for(var x = -canvas.width * 0.25; x < canvas.width * 1.25; x += delta)
//    trace(x, y, 200, [0, (canvas.height - y) * color_scale, y * color_scale, 0.8])
//};

//for(y = -canvas.height * 0.25; y < canvas.height * 1.25; y += delta) trace_row(y);
