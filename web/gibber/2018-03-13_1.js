Clock.bpm = 110
Clock.beatsPerMeasure = 30
Gibber.scale.mode = 'Chromatic'
a = Drums('x.....x.....x..x........x.....', 1/30, 1.5).seq.stop()
b = Drums('x.....*........*.......-......', 1/30, 1.5).seq.stop()
c = Drums('-.....-.....*..*........-.....', 1/30, 1.5).seq.stop()
i = FM('brass', {amp:.2,decay:ms(2180)}).note.seq([7,5,0,2,3,3], 1).seq.stop()
j = Pluck({amp:.6}).note.seq([0,2,3,7, 0,2,3,7, 19,17], 1/10).seq.stop()
k = Pluck({amp:1}).note.seq([
  0,2,3,7, 0,2,3,7, 15,15,
  -100,-100, 2,2,2,-2,7,3, -100,-100,
  0,2,3,7, 0,2,3,7, 19,17,
  -100,-100, 2,2,2,-2,7,3, -100,-100,
  0,2,3,7, 0,2,3,7, 12,14,
  -100,-100, 2,2,2,-2,7,3, -100,-100,
], 1/10).seq.stop()
L = FM('brass', {amp:.3,decay:ms(333)}).note.seq([-5,-2,2,3,2,-2], 1/6)
l = L.seq.stop()
M = FM('brass', {amp:.4,decay:ms(2000)}).chord.seq([[-5,-2,2]], 1)
m = M.seq.stop()

i.start()

a.start()

b.start()

j.start()

j.stop()
k.start()

i.stop()
k.stop()
L.note.values.transpose.seq([0,-2,-5,2,3,2], 1)

M.chord.values.transpose.seq([0,-2,-5,2,3,2], 1)

l.stop()
i.start()

m.stop()

a.stop()
b.stop()
c.start()

c.stop()

i.stop()
