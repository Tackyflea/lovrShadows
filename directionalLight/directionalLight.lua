
 
local m = {}

m.near = 0.01
m.far = 153
m.orthographic_span = 55
local fS                = lovr.filesystem.read("/directionalLight/glsl/dirLightFrag.glsl")
 
m.target = Vec3()
m.view_pose = lovr.math.newMat4()
    :lookAt(
      vec3(22, 51, -22),
      vec3(0, 1, 0))

m.projection = lovr.math.newMat4():orthographic(-m.orthographic_span, m.orthographic_span, m.orthographic_span,
  -m.orthographic_span, m.near, m.far)

local shadowmapper = lovr.graphics.newShader('unlit',fS)



function m.load(resolution, pose)
  if pose then
    m.view_pose:set(pose):invert()
  end
  m.resolution = resolution or 1024
  m.texture = lovr.graphics.newTexture(m.resolution, m.resolution,
    { format = 'd32f', mipmaps = false, linear = true, usage = { 'render', 'sample' } })
  m.pass = lovr.graphics.newPass { depth = m.texture, samples = 1 }
  m.sampler           = lovr.graphics.newSampler({
    wrap = { 'clamp', 'clamp', 'clamp' },
    compare = 'gequal',
    usage = { 'render', 'sample' }
  })
  
end

function m.setOrthographic(scene,degree)
  local wPadding, hPadding = 1, 1
  local w, h               = scene.size + wPadding, scene.height + hPadding
  --rotational angle
  local rotatedWidth       = w * math.abs(math.cos(degree)) + h * math.abs(math.sin(degree))
  local rotatedHeight      = w * math.abs(math.sin(degree)) + h * math.abs(math.cos(degree)) 
  m.near = scene.size/2-rotatedHeight/2
  m.far = scene.size/2+rotatedHeight/2
  m.projection:set(0):orthographic(-scene.size/2-wPadding/2, scene.size/2+wPadding/2, rotatedWidth/2,
  -rotatedWidth/2, m.near, m.far )
end

function m.getPass()
  -- render to depth buffer from light perspective
  m.pass:setClear({ depth = 1 })
  m.pass:reset()
  m.pass:setCullMode('front')
  m.pass:setDepthTest('lequal')
  m.pass:setProjection(1, m.projection)
  m.pass:setViewPose(1, m.view_pose, true)
  return m.pass
end

function m.setShader(pass)
  pass:setCullMode('back')
  pass:setShader(shadowmapper)
  local light_space_matrix = m.projection * m.view_pose
  pass:send('LightSpaceMatrix', light_space_matrix)
  pass:send('shadowSampler', m.sampler)
  pass:send('LightSource', m.target)
  pass:send('DepthBuffer', m.texture)

end

function m.debugDraw(pass)
  pass:setColor(1, 0.8, 0.5)
  local pose = mat4(m.view_pose):invert()
  pass:cone(vec3(pose:mul(0, 0, -0.3)), vec3(pose), 13)
end

function m.setPose(pose_or_origin, target)
  if not target then
    local pose = pose_or_origin
    m.view_pose:set(pose):invert()
  else
    local origin = pose_or_origin
    m.target:set(pose_or_origin)
    m.view_pose:lookAt(origin, target)
  end
end
return m
-- end of library code; now follows a testing scene, accessed with `lovr dir_light.lua`

