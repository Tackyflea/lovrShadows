 
function addBox(pass,scene,model, x, z)

    local boxSize = 1
    local boxHeight = scene.height*0.5
    pass:setColor(1,1,1)
    if model then
      pass:monkey(vec3(x, 0.5, z), vec3(boxSize, boxSize, boxSize))
    
    else
    pass:box(vec3(x, boxHeight/2, z), vec3(boxSize, boxHeight, boxSize))

    end
  end
  
  function addBoxes(scene, pass, model)
    local s = scene
      --staggered boxes
  local loops = 18
  for i = 1, loops do
    local offset = (i/loops)* (scene.size/2)
    addBox(pass,scene,model, scene.size/2-offset, -scene.size/2+offset)
    addBox(pass,scene,model, -scene.size/2+offset, -scene.size/2+offset)
    addBox(pass,scene,model, -scene.size/2+offset, scene.size/2-offset)
    addBox(pass,scene,model, scene.size/2-offset, scene.size/2-offset)
  
  end
   --edge boxes

   addBox(pass,scene,model, scene.size/2-1, -scene.size/2+1)
   addBox(pass,scene,model, -scene.size/2+1, -scene.size/2+1)
   addBox(pass, scene,model,-scene.size/2+1, scene.size/2-1)
   addBox(pass,scene, model,scene.size/2-1, scene.size/2-1)
end
function createRotatedBoundingOrthographicView(camAngle, scene,pass)
  local t                  = lovr.timer.getTime() * 0.01
  local tDeg               = math.deg(t)
tDeg = camAngle
  local position           = vec3(0, 0, 0)

  --padding for edges
  local wPadding, hPadding = 1, 1
  --formula for getting a bounding box from
  -- https://stackoverflow.com/questions/51462800/get-bounds-of-rotated-rectangle/51463527#51463527

  --width and height of the scene
  local w, h               = scene.size + wPadding, scene.height + hPadding
  --rotational angle
  local rotatedWidth       = w * math.abs(math.cos(tDeg)) + h * math.abs(math.sin(tDeg))
  local rotatedHeight      = w * math.abs(math.sin(tDeg)) + h * math.abs(math.cos(tDeg))

  local size               = vec3(rotatedWidth, rotatedHeight, scene.size + wPadding)
  local rotation           = quat(tDeg, 0, 0, 1)

  pass:setColor(1, .8, 1,0.3) 
  pass:box(mat4(position, size, rotation))
end