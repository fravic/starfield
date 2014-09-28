class App

  constructor: (@container, @stereoscopic = false) ->
    @scene = new THREE.Scene()
    @initRenderer()
    @initCamera()

    @stereoEffect = new THREE.StereoEffect @renderer

    @addGroundToScene(@scene)
    @addLightToScene(@scene)

    @gameLoop()

    window.addEventListener 'resize', @onResize, false
    setTimeout @onResize, 1

  initRenderer: ->
    @renderer = new THREE.WebGLRenderer()
    element = @renderer.domElement
    @container.appendChild element

  initCamera: ->
    @camera = new THREE.PerspectiveCamera 90, 1, 0.001, 700
    @camera.position.set 0, 10, 0
    @scene.add @camera;

  onResize: =>
    width = @container.offsetWidth
    height = @container.offsetHeight

    @camera.aspect = width / height
    @camera.updateProjectionMatrix()

    @stereoEffect.setSize width, height
    @renderer.setSize width, height

  addGroundToScene: (scene) ->
    material = new THREE.MeshPhongMaterial
      color: 0xffffff,
      specular: 0xffffff,
      shininess: 20,
      shading: THREE.FlatShading,
      map: @getGroundTexture()

    unless material.map instanceof THREE.Texture
      throw "Warning: no ground texture found!"

    geometry = new THREE.PlaneGeometry 1000, 1000

    mesh = new THREE.Mesh geometry, material
    mesh.rotation.x = -Math.PI / 2
    scene.add mesh

  addLightToScene: (scene) ->
    light = new THREE.HemisphereLight 0x777777, 0x000000, 0.6
    scene.add light

  getGroundTexture: ->
    texture = THREE.ImageUtils.loadTexture './textures/patterns/checker.png'
    texture.wrapS = THREE.RepeatWrapping
    texture.wrapT = THREE.RepeatWrapping
    texture.repeat = new THREE.Vector2 50, 50
    texture.anisotropy = @renderer.getMaxAnisotropy()
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

app = new App document.getElementById('threejs-container')
