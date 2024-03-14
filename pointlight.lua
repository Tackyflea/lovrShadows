--[[ Point light shaddow mapping
point light by JMiskovic - https://gist.github.com/jmiskovic
 --new how to , unsure yet
 ...


-- change light parameters
  point_light.position:set(1, 2, -1)
  point_light.light_color:set(1, 0, 0) -- rgb, can go over 1 for stronger lights
  point_light.ambient = 0.02
  point_light.shadow_strength = 0.1
  point_light.diffuse_strength = 0.8
  point_light.falloff = 0.08
--]]

local m = {}

local depthwritter = lovr.graphics.newShader('unlit', [[//glsl
layout( push_constant ) uniform constants {
  float LightFarPlane;
  vec3 LightWorld;
} Push;

vec4 lovrmain() {
  FragDepth = distance(Push.LightWorld, PositionWorld) / Push.LightFarPlane;
  if (Color.a <= 0) {
    FragDepth = Push.LightFarPlane;
    discard;
  }
  return DefaultColor;
}
]])

local shadowmapper = lovr.graphics.newShader('unlit', [[//glsl
layout(set = 2, binding = 0) uniform textureCube DepthBuffer;
layout( push_constant ) uniform constants {
  vec3 LightWorld;
  vec3 LightColor;
  float Ambient;
  float Shading;
  float Falloff;
  float ShadowStrength;
  float DiffuseStrength;
  float LightFarPlane;
} Push;

vec3 pcf_offset[20] = vec3[](
  vec3( 1,  1,  1), vec3( 1, -1,  1), vec3(-1, -1,  1), vec3(-1,  1,  1),
  vec3( 1,  1, -1), vec3( 1, -1, -1), vec3(-1, -1, -1), vec3(-1,  1, -1),
  vec3( 1,  1,  0), vec3( 1, -1,  0), vec3(-1, -1,  0), vec3(-1,  1,  0),
  vec3( 1,  0,  1), vec3(-1,  0,  1), vec3( 1,  0, -1), vec3(-1,  0, -1),
  vec3( 0,  1,  1), vec3( 0, -1,  1), vec3( 0, -1, -1), vec3( 0,  1, -1));

vec3 lightProbe[9] = { // extracted from yellowish surrounding and purple floor
  vec3(0.3264819085598, 0.3535004556179, 0.21810184419155),
  vec3(0.45082664489746, 0.49788716435432, 0.31052857637405),
  vec3(-0.050872970372438, -0.031880494207144, 0.007200816180557),
  vec3(-0.11037144809961, -0.069166347384453, 0.015622524544597),
  vec3(-0.1914529800415, -0.11997760087252, 0.027099214494228),
  vec3(-0.094650238752365, -0.059314340353012, 0.013397279195487),
  vec3(-0.17679689824581, -0.20411671698093, -0.13814227283001),
  vec3(0, 0, 0),
  vec3(-0.30622118711472, -0.35354053974152, -0.23926958441734),
};

vec3 evaluateLightProbe(vec3 probe[9], vec3 dir) {
  return
    .88622692545276 * probe[0] +

    1.0233267079465 * probe[1] * dir.y +
    1.0233267079465 * probe[2] * dir.z +
    1.0233267079465 * probe[3] * dir.x +

    .85808553080978 * probe[4] * dir.x * dir.y +
    .85808553080978 * probe[5] * dir.y * dir.z +
    .24770795610038 * probe[6] * (3. * dir.z * dir.z - 1.) +
    .85808553080978 * probe[7] * dir.x * dir.z +
    .42904276540489 * probe[8] * (dir.x * dir.x - dir.y * dir.y);
}

vec4 lovrmain() {

  const int pcf_samples = 20; // only up to 20

  vec4 color = Color;

  vec3 lightDir = normalize(Push.LightWorld.xyz);

  //still referencing the old distance
  float dist = distance(Push.LightWorld, PositionWorld);
  vec3 lightVec = PositionWorld - Push.LightWorld;


  float bias =0.002;
   bias = max(0.005 * (1.0 - dot(Normal, lightDir)), 0.0005);
  float shadowing = 0.;
  float radius = 0.05 ;
  for (int i = 0; i < pcf_samples; ++i) {
    float closest_dist = getPixel(DepthBuffer, vec3(-lightVec.x, lightVec.y, lightVec.z) + pcf_offset[i] * radius).r * Push.LightFarPlane;
    shadowing += (dist + bias > closest_dist) ? 0. : Push.ShadowStrength / pcf_samples;
  }
  // shadowing is 1 where fully lit and 0 in complete shadow
  shadowing = clamp(shadowing, 0.0, 1.0);
  color.rgb *= (Push.Ambient + shadowing * Push.LightColor);
  color.rgb *= Push.Shading * (evaluateLightProbe(lightProbe, normalize(Normal)) - 1.) + 1.;

  return color;
}
]])

m.position = lovr.math.newVec3(0, 1, 0)
m.light_color = lovr.math.newVec3(1, 1, 1)
m.draw_distance = 300
m.ambient = 0.05
m.shading = 0.5
m.shadow_strength = 0.8
m.diffuse_strength = 0.4
m.falloff = 0.05

local perspective = lovr.math.newMat4():perspective(math.pi / 2, 1, 0.01, m.draw_distance)
-- local size = 1
--  local perspective = lovr.math.newMat4():orthographic(-size, size, -size, size, 100, -100) -- why is near and far inverted? ¯\_(ツ)_/¯
local transforms = {
  lovr.math.newMat4():lookAt(vec3(), vec3(1, 0, 0), vec3(0, 1, 0)),
  lovr.math.newMat4():lookAt(vec3(), vec3(-1, 0, 0), vec3(0, 1, 0)),
  lovr.math.newMat4():lookAt(vec3(), vec3(0, 1, 0), vec3(0, 0, -1)),
  lovr.math.newMat4():lookAt(vec3(), vec3(0, -1, 0), vec3(0, 0, 1)),
  lovr.math.newMat4():lookAt(vec3(), vec3(0, 0, 1), vec3(0, 1, 0)),
  lovr.math.newMat4():lookAt(vec3(), vec3(0, 0, -1), vec3(0, 1, 0))
}

function m.load(resolution, position)
  m.position:set(position)
  m.resolution = resolution or 1024
  m.texture = lovr.graphics.newTexture(m.resolution, m.resolution, 6,
    { type = 'cube', format = 'd32f', usage = { 'render', 'sample' } })
  m.pass = lovr.graphics.newPass({ depth = m.texture })
end

function m.setPass()
  -- render to depth buffer from light's perspective
  -- texture is set to 1 (infinite distance) and "rendered" geometry increases depth texture towards 0

  m.pass:reset()
  m.pass:setClear({ depth = 1 })

  for i, transform in ipairs(transforms) do
    transform[13], transform[14], transform[15] = m.position:unpack()
    m.pass:setViewPose(i, transform)
    m.pass:setProjection(i, perspective)
  end
  m.pass:setDepthTest('<=')   -- draw only closer (numerically smaller) geometry
  m.pass:setCullMode('front') -- shadow-mapping trick to avoid z-fighting face acne
  m.pass:setShader(depthwritter)
  m.pass:send('LightWorld', m.position)
  m.pass:send('LightFarPlane', m.draw_distance)
  return m.pass -- pass is prepared for receiving geometry, should also be submitted
end

function m.setShader(pass)
  pass:setShader(shadowmapper)
  pass:send('DepthBuffer', m.texture)
  pass:send('LightWorld', m.position)
  pass:send('LightColor', m.light_color)
  pass:send('LightFarPlane', m.draw_distance)
  pass:send('Ambient', m.ambient)
  pass:send('Shading', m.shading)
  pass:send('ShadowStrength', m.shadow_strength)
  pass:send('DiffuseStrength', m.diffuse_strength)
  pass:send('Falloff', m.falloff)
end

return m
