local m = {}

m.view = Mat4()
m.projection = Mat4()
m.lightMatrix = Mat4()
m.direction = Vec3()

local vS = "/directionalLight/glsl/dirLightVert.glsl"
local fS = "/directionalLight/glsl/dirLightFrag.glsl"
local shadowmapper = lovr.graphics.newShader(vS,fS)

function m.load(resolution)
  m.resolution = resolution or 1024
  m.texture = lovr.graphics.newTexture(m.resolution, m.resolution, { format = 'd32f' })
  m.pass = lovr.graphics.newPass({ depth = m.texture, samples = 1 })
  m.sampler = lovr.graphics.newSampler({ wrap = 'clamp', compare = 'gequal' })
end

function m.getPass()
  -- render to depth buffer from light perspective
  m.pass:setClear({ depth = 1 })
  m.pass:reset()
  m.pass:setCullMode('front')
  m.pass:setDepthTest('lequal')
  m.pass:setProjection(1, m.projection)
  m.pass:setViewPose(1, m.view, true)
  return m.pass
end

function m.setShader(pass)
  pass:setShader(shadowmapper)
  pass:send('LightSpaceMatrix', m.lightMatrix)
  pass:send('shadowSampler', m.sampler)
  pass:send('LightDirection', m.direction)
  pass:send('DepthBuffer', m.texture)
end

function m.debugDraw(pass)
  if lovr.system.isKeyDown('`') then
    pass:push('state')
    pass:setShader()
    pass:setDepthTest()
    pass:setColor(1, 1, 1)
    pass:fill(m.texture)
    pass:pop('state')
  end
end

function m.setLightMatrix(lightDirection, cameraView, cameraProjection)
  m.direction:set(lightDirection):normalize()

  -- Get the 8 points of the camera's frustum in NDC space
  m.points = {
    vec3(-1, -1, 0),
    vec3( 1, -1, 0),
    vec3(-1,  1, 0),
    vec3( 1,  1, 0),

    vec3(-1, -1, 1),
    vec3( 1, -1, 1),
    vec3(-1,  1, 1),
    vec3( 1,  1, 1)
  }

  local viewProjection = cameraProjection * cameraView
  local worldFromClip = mat4(viewProjection):invert()

  -- Convert the NDC points to world space frustum vertices
  for i, point in ipairs(m.points) do
    point:transform(worldFromClip)
  end

  -- Get the center of the frustum
  local frustumCenter = vec3()
  for i, point in ipairs(m.points) do
    frustumCenter:add(point)
  end
  frustumCenter:mul(1 / #m.points)

  -- Make a temp lookAt matrix that can be used to rotate points into the light's coordinate space
  local tempMatrix = mat4():lookAt(frustumCenter, frustumCenter + m.direction)

  -- Convert all the points into light space
  for i, point in ipairs(m.points) do
    point:transform(tempMatrix)
  end

  -- Find AABB around camera corners, from light's perspective
  local minx, miny, minz = math.huge, math.huge, math.huge
  local maxx, maxy, maxz = -math.huge, -math.huge, -math.huge

  for i = 1, #m.points do
    local x, y, z = m.points[i]:unpack()
    minx, miny, minz = math.min(minx, x), math.min(miny, y), math.min(minz, z)
    maxx, maxy, maxz = math.max(maxx, x), math.max(maxy, y), math.max(maxz, z)
  end

  local lightPosition = frustumCenter

  m.view:lookAt(frustumCenter, frustumCenter + m.direction)
  m.projection:orthographic(minx, maxx, maxy, miny, -maxz, -minz)
  m.lightMatrix:set(m.projection * m.view)
end

return m
