local camera = lovr.math.newMat4()
local target = {x=0,z=0}
function aimCameraXZ(x,z)
    target.x = x or 0
    target.z = z or 0
end
function updateCamera()
    camera:identity()
    camera:translate(lovr.math.vec3(target.x,0,target.z))
    camera:rotate(math.rad(180), 0, 1, 0)
    camera:rotate(math.rad(45), 0, -1, 0)
    camera:rotate(math.rad(-60), 1, 0, 0)

    camera:translate(lovr.math.vec3(0,14,0))
    camera:target(vec3(camera), vec3(target.x, 0, target.z), vec3(0, 1, 0))
end

function drawCamera(pass)
    local width, height         = lovr.system.getWindowDimensions()
    local ratio                     = width / height
    local light_projection = lovr.math.mat4():perspective(math.rad(20), ratio * 1.13, 0.01)
  
    pass:setProjection(1, light_projection)
    pass:setViewPose(1, camera)
end
