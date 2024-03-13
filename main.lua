require "camera"

lovr.graphics.setBackgroundColor(.1, .1, .1)

function lovr.load()

end

function lovr.update(dt)
  updateCamera(dt)
end

function lovr.draw(pass)
  drawCamera(pass)


  -- Plane
  local x, y, z = -0, 0, 0
  local t = lovr.timer.getTime() * 1
  -- box
  local boxSize = 1
  pass:setColor(.49, .34, .76)
  pass:box(vec3(0, boxSize / 2, 0), vec3(boxSize))

  --box is like a filled in so using it instead of plane
  pass:setColor(.94, .33, .31)
  pass:box(vec3(0, 0, 0), vec3(10, 0.01, 10))


  pass:setShader()
end
