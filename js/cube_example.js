var camera, scene, renderer;
var mesh;

init();
animate();

self.run = function() {
    renderer = new THREE.WebGLRenderer({ canvas: $('.canvas1')[0] });
    renderer.setPixelRatio( window.devicePixelRatio );
    renderer.setSize( window.innerWidth, window.innerHeight );
    document.body.appendChild( renderer.domElement );

    camera = new THREE.PerspectiveCamera( 70,
        window.innerWidth / window.innerHeight, 1, 1000 );
    camera.position.z = 400;

    scene = new THREE.Scene();

    var geometry = new THREE.BoxGeometry( 200, 200, 200 );

    var texture = THREE.ImageUtils.loadTexture(
        'http://d1v8u1ev1s9e4n.cloudfront.net/54e3bc105ccacf40be296b59' );
    texture.anisotropy = renderer.getMaxAnisotropy();

    var material = new THREE.MeshBasicMaterial( { map: texture } );

    mesh = new THREE.Mesh( geometry, material );
    scene.add( mesh );

    window.addEventListener( 'resize', onWindowResize, false );
}

function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();

    renderer.setSize( window.innerWidth, window.innerHeight );
}

self.animate = function() {
    requestAnimationFrame( animate );

    mesh.rotation.x += 0.005;
    mesh.rotation.y += 0.01;

    renderer.render( scene, camera );
}