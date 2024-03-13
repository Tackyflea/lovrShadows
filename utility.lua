function addBox(pass, x, z)
    local boxSize = 1
    pass:setColor(.3, .3, .3)
    pass:box(vec3(x, boxSize / 2, z), vec3(boxSize))
  end
  
  function addBoxes(scene, pass)
      --staggered boxes
  local loops = 18
  for i = 1, loops do
    local offset = (i/loops)* (scene.width/2)
    addBox(pass, scene.width/2-offset, -scene.depth/2+offset)
    addBox(pass, -scene.width/2+offset, -scene.depth/2+offset)
    addBox(pass, -scene.width/2+offset, scene.depth/2-offset)
    addBox(pass, scene.width/2-offset, scene.depth/2-offset)
  
  end
   --edge boxes

   addBox(pass, scene.width/2-1, -scene.depth/2+1)
   addBox(pass, -scene.width/2+1, -scene.depth/2+1)
   addBox(pass, -scene.width/2+1, scene.depth/2-1)
   addBox(pass, scene.width/2-1, scene.depth/2-1)
end