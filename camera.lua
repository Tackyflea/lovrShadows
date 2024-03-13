local camera = lovr.math.newMat4()

function updateCamera()
    camera:identity()
    camera:rotate(math.rad(180), 0, 1, 0)
    camera:rotate(math.rad(45), 0, -1, 0)
    camera:rotate(math.rad(-60), 1, 0, 0)

    camera:translate(lovr.math.vec3(0, 14, 0))
    camera:target(vec3(camera), vec3(0, 0, 0), vec3(0, 1, 0))
end

function drawCamera(pass)
    local width, height         = lovr.system.getWindowDimensions()
    local ratio                     = width / height
    local light_projection = lovr.math.mat4():perspective(math.rad(20), ratio * 1.13, 0.01)
  
    pass:setProjection(1, light_projection)
    pass:setViewPose(1, camera)
end
