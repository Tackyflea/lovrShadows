require "camera"
require "utility"
local dir_light = require "directionalLight.directionalLight"
local scene = {
  size = 150, height = 4
}
time = 0

-- in main.lua this would be:  local dir_light = require('dir_light')
dir_light.load(2048)

monkey = lovr.graphics.newModel('monkey.obj')

function lovr.load()
  lovr.graphics.setBackgroundColor(.1, .1, .1)
  loadCamera(scene)
  aimCameraXZ(0, 400, 0) --set where to look
end

function DrawScene(pass)
  -- box
  addBoxes(scene, pass, monkey)
  pass:setColor(1, 1, 1)
  pass:box(vec3(0), vec3(1.6))
  local ss = scene.size/2
  local sh = scene.height*.7
  pass:box(vec3(ss-sh,0,0), vec3(sh))
  pass:box(vec3(-ss+sh,0,0), vec3(sh))
  pass:box(vec3(0,0,ss-sh), vec3(sh))
  pass:box(vec3(-0,0,-ss+sh), vec3(sh))
  --box is like a filled in so using it instead of plane
  pass:setColor(0.8, 0.8, 0.8)
  -- pass:box(vec3(0, 0, 0), vec3(10, 0.01, 10))
  pass:plane(vec3(0, 0, 0), vec2(scene.size, scene.size), quat(math.pi * 0.5, -1, 0, 0))
  --pass:plane(vec3(0, -0.1, 0), vec2(scene.size, scene.size), quat(math.pi * 0.5, 1, 0, 0))

 -- pass:box(vec3(0,-1.5,0), vec3(scene.size,0.1,scene.size))

end

function lovr.update(dt)
  updateCamera(dt)
  if lovr.system.isKeyDown('t') then
    time = time + dt
  end
end

function lovr.draw(pass)
  local t                  = time * 0.004
  local tDeg               = math.deg(t)-1.78+math.pi/2
  -- tDeg = 45
  local xPos = math.sin(tDeg)*scene.size/2
  local yPos = math.cos(tDeg)*scene.size/2

  drawCamera(pass)

  -- Flip depth clear/test when using regular perspective matrix for camera
  pass:setClear({ depth = 1 })
  pass:setDepthTest('lequal')

  local lightPosition = vec3(xPos,yPos,0)
  local lightTarget = vec3(0,0,0)
  local lightDirection = (lightTarget - lightPosition):normalize()

  local view = pass:getViewPose(1, mat4(), true)
  local proj = pass:getProjection(1, mat4())
  dir_light.setLightMatrix(lightDirection, view, proj)

  -- the most important part:
  local gpass = dir_light.getPass()
  DrawScene(gpass)
  dir_light.setShader(pass)
  DrawScene(pass)

  pass:setShader()
  pass:setColor(1, 0.8, 0.5)
  pass:cone(lightPosition, lightPosition - lightDirection * 10, 10)

  dir_light.debugDraw(pass)

  return lovr.graphics.submit(gpass, pass)
end

function lovr.keypressed(key)
  moveCamera(key)
end
