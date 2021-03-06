class App

  particleCount: 700

  constructor: (@container, isMobile = false) ->
    @scene = new THREE.Scene()
    @scene.fog = new THREE.FogExp2 0x000000, 0.07

    @clock = new THREE.Clock()

    @initRenderer()
    @initCamera()

    if isMobile
      @stereoEffect = new THREE.StereoEffect @renderer
      @stereoEffect.separation = 1
      @initDeviceOrientationControls()
    else
      @initOrbitControls()

    @addGroundToScene(@scene)
    @addLightToScene(@scene)
    @addSkydomeToScene(@scene)
    @addGlowDotsToScene @scene

    @gameLoop()

    window.addEventListener 'resize', @onResize, false
    setTimeout @onResize, 1

  initRenderer: ->
    @renderer = new THREE.WebGLRenderer()
    element = @renderer.domElement
    @container.appendChild element

  initCamera: ->
    @camera = new THREE.PerspectiveCamera 90, 1, 0.001, 700
    @camera.position.set 0, 15, 0
    @scene.add @camera

  initOrbitControls: ->
    @controls = new THREE.OrbitControls @camera, @container
    @controls.rotateUp Math.PI / 4
    @controls.target.set(
      @camera.position.x + .1,
      @camera.position.y,
      @camera.position.z
    )
    @controls.noZoom = true
    @controls.noPan = true

  initDeviceOrientationControls: ->
    @controls = new THREE.DeviceOrientationControls @camera, true
    @controls.connect()

  onResize: (e) =>
    width = @container.offsetWidth
    height = @container.offsetHeight

    @camera.aspect = width / height
    @camera.updateProjectionMatrix()

    @stereoEffect.setSize width, height if @stereoEffect
    @renderer.setSize width, height

  addGroundToScene: (scene) ->
    geometry = new THREE.PlaneGeometry 1000, 1000

    material = new THREE.MeshPhongMaterial
      color: 0xffffff,
      specular: 0x000000,
      shininess: 10,
      shading: THREE.FlatShading,
      blending: THREE.AdditiveBlending,
      transparent: true,
      fog: false,
      map: @getGroundTexture()

    unless material.map instanceof THREE.Texture
      throw "Warning: no ground texture found!"

    mesh = new THREE.Mesh geometry, material
    mesh.rotation.x = -Math.PI / 2
    scene.add mesh

  addLightToScene: (scene) ->
    light = new THREE.HemisphereLight 0x777777, 0x000000, 0.6
    scene.add light

  addSkydomeToScene: (scene) ->
    geometry = new THREE.SphereGeometry 600, 60, 40

    material = new THREE.MeshBasicMaterial
      map: @getSkyTexture()
      side: THREE.BackSide,
      fog: false

    mesh = new THREE.Mesh geometry, material
    scene.add mesh

  addGlowDotsToScene: (scene) ->
    particles = new THREE.Geometry()

    material = new THREE.PointCloudMaterial
      map: @getGlowDotTexture(),
      color: 0xffffff,
      blending: THREE.AdditiveBlending,
      depthWrite: false,
      transparent: true

    for i in [0..@particleCount]
      x = Math.random() * 40 - 20
      x += (x > 0 ? 15 : -15)
      z = Math.random() * 40 - 20
      z += (z > 0 ? 15 : -15)

      particle = new THREE.Vector3(x, @camera.position.y, z)
      particle.phi = Math.random() * 1000
      particle.amp = Math.random() * 2 + 1
      particles.vertices.push particle

    @pointCloud = new THREE.PointCloud particles, material
    scene.add @pointCloud

  getGroundTexture: ->
    texture = THREE.ImageUtils.loadTexture './textures/patterns/grid.png'
    texture.wrapS = THREE.RepeatWrapping
    texture.wrapT = THREE.RepeatWrapping
    texture.repeat = new THREE.Vector2 50, 50
    texture.anisotropy = @renderer.getMaxAnisotropy()
    return texture

  getSkyTexture: ->
    texture = THREE.ImageUtils.loadTexture './textures/environments/milky_way.jpg'
    return texture

  getGlowDotTexture: ->
    texture = THREE.ImageUtils.loadTexture './textures/lensflare/lensflare.png'
    return texture

  gameLoop: =>
    requestAnimationFrame @gameLoop

    dt = @clock.getDelta()
    et = @clock.getElapsedTime()
    @update dt, et
    @render dt, et

  update: (dt, et) ->
    @controls.update(dt) if @controls

    for vertex in @pointCloud.geometry.vertices
      vertex.y = @camera.position.y +
        Math.sin(et - vertex.phi) * vertex.amp
    @pointCloud.geometry.verticesNeedUpdate = true

  render: (dt, et) ->
    if @stereoEffect
      @stereoEffect.render @scene, @camera
    else
      @renderer.render @scene, @camera


# onLoad

isMobile = ->
  return (/Android|iPhone|iPad|iPod|BlackBerry|Windows Phone/i).test(
    navigator.userAgent || navigator.vendor || window.opera
  )

app = new App document.getElementById('threejs-container'), isMobile()
