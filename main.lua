require "camera"
local point_light = require('pointlight')
point_light.load(1024, vec3(0, 1, 0))  -- depth texture resolution & position
lovr.graphics.setBackgroundColor(.1, .1, .1)


function lovr.load()
 
end

function lovr.update(dt)
  updateCamera(dt)
end
function drawScene(pass)

  -- box
  local boxSize = 1
  pass:setColor(.3,.3,.3)
  pass:box(vec3(0, boxSize / 2, 0), vec3(boxSize))

  --box is like a filled in so using it instead of plane
  pass:setColor(0.8,0.8,0.8)
  pass:box(vec3(0, 0, 0), vec3(10, 0.01, 10))

end
function lovr.draw(pass)

  
  drawCamera(pass)
  
  --first draw , depth 
  local depthPass = point_light.setPass()
  drawScene(depthPass)
  
  --second draw, normal 
  point_light.setShader(pass)
  drawScene(pass)
  
  --assign point light settings
  pass:sphere(mat4(point_light.position):scale(0.05))
  point_light.position:set(0.4, 2, 0)

  return lovr.graphics.submit({depthPass,pass})
end
