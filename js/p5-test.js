var system

function setup() {
  createCanvas(windowWidth, windowHeight)
  system = new ParticleSystem(createVector(width/2, height/2))
}

function draw() {
  background(51)
  system.run()
  if(system.particles.length < 500)
    system.addParticle()
}

// A simple Particle class
var Particle = function(position){
  var o = {}
  o.velocity = createVector(random(-5, 5), random(-5, 5))
  o.position = position.copy()
  o.lifespan = 255.0

  o.run = function(){
    o.update()
    o.display()
  }
  // Method to update position
  o.update = function(){
    o.velocity.add(system.acceleration)
    o.position.add(o.velocity)
    o.lifespan -= 1.5
  }
  o.display = function() {
    stroke(200, o.lifespan)
    strokeWeight(2)
    fill(127, o.lifespan)
    ellipse(o.position.x, o.position.y, 12, 12)
  }
  o.isDead = function(){
    return (o.lifespan < 0)
  }

  return o
}

var ParticleSystem = function(position){
  var o = {}
  o.origin = position.copy()
  o.particles = []
  o.acceleration = createVector(0, .05)

  o.addParticle = function() {
    o.particles.push(new Particle(o.origin))
  }
  o.run = function(){
    o.acceleration = createVector( ((mouseX / windowWidth) - .5) * .1,
      ((mouseY / windowHeight) - .5) * .1)
    o.particles.map(function(p, i){
      p.run()
      if(p.isDead())
        o.particles.splice(i, 1)
    })
  }

  return o
}
