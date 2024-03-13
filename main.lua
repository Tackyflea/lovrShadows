require "camera"
require "utility"

local point_light = require('pointlight')
point_light.load(1024) -- depth texture resolution & position
lovr.graphics.setBackgroundColor(.1, .1, .1)

local scene = {
  width = 150, depth = 150
}
function lovr.load()
  loadCamera(scene)
end

function lovr.update(dt)
  updateCamera(dt)
end

function drawScene(pass)
  -- box
  addBoxes(scene, pass)

  --box is like a filled in so using it instead of plane
  pass:setColor(0.8, 0.8, 0.8)
  -- pass:box(vec3(0, 0, 0), vec3(10, 0.01, 10))
  pass:plane(vec3(0, 0, 0), vec2(scene.width, scene.depth), quat(math.pi * 0.5, -1, 0, 0))
end

function lovr.keypressed(key) moveCamera(key) end

function lovr.draw(pass)
  -- aimCameraXZ(4,-4) --set where to look

  drawCamera(pass)

  --first draw , depth
  local depthPass = point_light.setPass()
  drawScene(depthPass)

  --second draw, normal
  point_light.setShader(pass)
  drawScene(pass)

  --assign point light settings
  pass:sphere(mat4(point_light.position):scale(0.5))
  local t = lovr.timer.getTime() * 0.2
  t = 3.12 --remove this to go into flicker land
  point_light.position:set(math.cos(t) * scene.width / 2, math.sin(t) * scene.depth / 2, 0)
  -- point_light.position:set(34, 11, 0)

  return lovr.graphics.submit({ depthPass, pass })
end
