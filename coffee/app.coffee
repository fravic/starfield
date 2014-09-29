class App

  constructor: (@container, @stereoscopic = false) ->
    @scene = new THREE.Scene()
    @scene.fog = new THREE.FogExp2 0x000000, 0.002

    @initRenderer()
    @initCamera()
    @initControls()

    @stereoEffect = new THREE.StereoEffect @renderer

    @addGroundToScene(@scene)
    @addLightToScene(@scene)
    @addSkydomeToScene(@scene)

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

  initControls: ->
    @controls = new THREE.OrbitControls @camera, @container
    @controls.rotateUp Math.PI / 4
    @controls.target.set(
      @camera.position.x + .1,
      @camera.position.y,
      @camera.position.z
    )
    @controls.noZoom = true
    @controls.noPan = true
    @controls.update()

  onResize: =>
    width = @container.offsetWidth
    height = @container.offsetHeight

    @camera.aspect = width / height
    @camera.updateProjectionMatrix()

    @stereoEffect.setSize width, height
    @renderer.setSize width, height

  addGroundToScene: (scene) ->
    geometry = new THREE.PlaneGeometry 1000, 1000

    material = new THREE.MeshPhongMaterial
      color: 0xffffff,
      specular: 0xffffff,
      shininess: 20,
      shading: THREE.FlatShading,
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
      side: THREE.BackSide

    mesh = new THREE.Mesh geometry, material
    scene.add mesh

  getGroundTexture: ->
    texture = THREE.ImageUtils.loadTexture './textures/patterns/checker.png'
    texture.wrapS = THREE.RepeatWrapping
    texture.wrapT = THREE.RepeatWrapping
    texture.repeat = new THREE.Vector2 50, 50
    texture.anisotropy = @renderer.getMaxAnisotropy()
    return texture

  getSkyTexture: ->
    texture = THREE.ImageUtils.loadTexture './textures/environments/milky_way.jpg'
    return texture

  gameLoop: =>
    requestAnimationFrame @gameLoop
    @update()
    @render()

  update: ->

  render: ->
    if @stereoscopic
      @stereoEffect.render @scene, @camera
    else
      @renderer.render @scene, @camera


# onLoad

isMobile = ->
  return (/Android|iPhone|iPad|iPod|BlackBerry|Windows Phone/i).test(
    navigator.userAgent || navigator.vendor || window.opera
  )

app = new App document.getElementById('threejs-container'), isMobile()
