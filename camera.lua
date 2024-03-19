local flux = require "libs.flux"

local camera = lovr.math.newMat4()
local defaultY = 22
local target = { x = 0, y = defaultY, z = 0 }
local scene = { width = 10, size = 10 }
local far = 800
function loadCamera(sceneImport)
    scene = sceneImport
end

function aimCameraXZ(x,y, z)
    target.x = x or 0
    target.y = y or 0
    target.z = z or 0
end

function updateCamera(dt)
    flux.update(dt)

    camera:identity()
    camera:translate(lovr.math.vec3(target.x, 0, target.z))
    camera:rotate(math.rad(180), 0, 1, 0)
    camera:rotate(math.rad(45), 0, -1, 0)
    camera:rotate(math.rad(-60), 1, 0, 0)
    camera:translate(lovr.math.vec3(0, target.y, 0))
    camera:target(vec3(camera), vec3(target.x, 0, target.z), vec3(0, 1, 0))
    
end

function drawCamera(pass)
    local width, height    = lovr.system.getWindowDimensions()
    local ratio            = width / height
    local fov = math.rad(20)
    local aspect  = ratio
    local near  =  0.1
    local light_projection = lovr.math.mat4():perspective(fov, aspect,near,far)

    pass:setProjection(1, light_projection)
    pass:setViewPose(1, camera)
end

function moveCamera(key)
    local size = scene.size
    local newPos = nil
    local distanceFromEdge = 4
    if key == "a" or key == "left" then
        newPos = { x = -size / 2+distanceFromEdge, y = defaultY, z = -size / 2 +distanceFromEdge}
        far = 35
    end
    if key == "d" or key == "right" then
        newPos = { x = size / 2 -distanceFromEdge, y = defaultY, z = size / 2 -distanceFromEdge }
        far = 35
    end
    if key == "w" or key == "up" then
        newPos = { x = size / 2 -distanceFromEdge, y = defaultY, z = -size / 2  +distanceFromEdge}
        far = 35
    end
    if key == "s" or key == "down" then
        newPos = { x = -size / 2 +distanceFromEdge, y = defaultY, z = size / 2 -distanceFromEdge }
        far = 35
    end
    if key == "space" then
        newPos = { x = 0, y = defaultY, z = 0 }
        far = 35
    end
    if key == "q" then
        newPos = { x = 0, y = size * 3, z = 0 }
        far = 800
    end
    if newPos then
        local speed = 44
        local distance = vec3(target.x, target.y, target.z):distance(newPos.x,newPos.y,newPos.z)
        flux.to(target, speed/distance, newPos)
    end
end
