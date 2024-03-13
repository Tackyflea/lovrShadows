local flux = require "libs.flux"

local camera = lovr.math.newMat4()
local defaultY = 22
local target = { x = 0, y = defaultY, z = 0 }
local scene = { width = 10, depth = 10 }
function loadCamera(sceneImport)
    scene = sceneImport
end

function aimCameraXZ(x, z)
    target.x = x or 0
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
    local light_projection = lovr.math.mat4():perspective(math.rad(20), ratio * 1.13, 0.01)

    pass:setProjection(1, light_projection)
    pass:setViewPose(1, camera)
end

function moveCamera(key)
    local newPos = nil
    local distanceFromEdge = 4
    if key == "a" or key == "left" then
        newPos = { x = -scene.width / 2+distanceFromEdge, y = defaultY, z = -scene.depth / 2 +distanceFromEdge}
    end
    if key == "d" or key == "right" then
        newPos = { x = scene.width / 2 -distanceFromEdge, y = defaultY, z = scene.depth / 2 -distanceFromEdge }
    end
    if key == "w" or key == "up" then
        newPos = { x = scene.width / 2 -distanceFromEdge, y = defaultY, z = -scene.depth / 2  +distanceFromEdge}
    end
    if key == "s" or key == "down" then
        newPos = { x = -scene.width / 2 +distanceFromEdge, y = defaultY, z = scene.depth / 2 -distanceFromEdge }
    end
    if key == "space" then
        newPos = { x = 0, y = defaultY, z = 0 }
    end
    if key == "q" then
        newPos = { x = 0, y = scene.width * 3, z = 0 }
    end
    if newPos then
        local speed = 44
        local distance = vec3(target.x, target.y, target.z):distance(newPos.x,newPos.y,newPos.z)
        flux.to(target, speed/distance, newPos)
    end
end
