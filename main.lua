require "camera"
require "utility"
local dir_light = require "directionalLight.directionalLight"
local scene = {
  size = 150, height = 4
}

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
end

function lovr.draw(pass)
  local t                  = lovr.timer.getTime() * 0.004
  local tDeg               = math.deg(t)-1.78
 --  tDeg = 45
  local xPos = math.sin(tDeg)*scene.size/2
  local yPos = math.cos(tDeg)*scene.size/2

  drawCamera(pass)

    local cameraPosition = vec3(xPos,yPos,0)
    local cameraTarget = vec3(0,0,0) 
    dir_light.setOrthographic(scene,tDeg)

    dir_light.setPose(cameraPosition,cameraTarget)


  --debug mode
--pass:fill(dir_light.texture)

  -- the most important part:
  local gpass = dir_light.getPass()
  --scene(gpass)
  DrawScene(gpass)
  dir_light.debugDraw(pass)
  dir_light.setShader(pass)
  --scene(pass)
  DrawScene(pass)

 -- createRotatedBoundingOrthographicView(tDeg,scene,pass)
  return lovr.graphics.submit(gpass, pass)
end

function lovr.keypressed(key) moveCamera(key) end

-- this would be end of main.lua improting this lib
