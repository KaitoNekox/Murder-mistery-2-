--[[
    [🔥 Sheriff Auto-Aim & Auto-Shoot 🔥]
    - Detecta automáticamente si eres el sheriff.
    - Si no tienes el arma equipada, la equipa.
    - Escanea constantemente al asesino.
    - Dispara automáticamente cuando está en rango.
    - Precisión ajustable y anti-detección.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local isSheriff = false
local gunEquipped = false
local murder = nil
local scanInterval = 0.3 -- Intervalo de detección (más bajo = más rápido)
local maxShootDistance = 50 -- Máxima distancia para disparar
local aimOffset = Vector3.new(0, 1.5, 0) -- Ajuste de altura de la mira
local bulletSpeed = 1000 -- Velocidad de bala (simulada)

-- 🔍 Verificar si el jugador es el sheriff
local function checkSheriffRole()
    if localPlayer:FindFirstChild("Role") and localPlayer.Role.Value == "Sheriff" then
        isSheriff = true
        return true
    end
    return false
end

-- 🔫 Equipar el arma si no está en la mano
local function equipGun()
    if not localPlayer.Character then return false end
    
    local gun = localPlayer.Character:FindFirstChild("Gun") or localPlayer.Backpack:FindFirstChild("Gun")
    if not gun then return false end
    
    local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
    if not humanoid then return false end
    
    humanoid:EquipTool(gun)
    gunEquipped = true
    return true
end

-- 🎯 Encontrar al asesino en el servidor
local function findMurderer()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player:FindFirstChild("Role") and player.Role.Value == "Murderer" then
            murder = player
            return player
        end
    end
    return nil
end

-- 🔥 Disparar automáticamente al asesino
local function autoShoot(target)
    if not target or not target.Character then return false end
    if not localPlayer.Character then return false end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    local gun = localPlayer.Character:FindFirstChild("Gun")
    
    if not targetRoot or not localRoot or not gun then return false end
    
    -- 📏 Calcular distancia
    local distance = (targetRoot.Position - localRoot.Position).Magnitude
    if distance > maxShootDistance then return false end
    
    -- 🎯 Calcular dirección del disparo
    local direction = (targetRoot.Position + aimOffset - localRoot.Position).Unit
    
    -- 🔫 Simular disparo (usando RemoteEvents si es posible)
    local args = {
        [1] = direction * bulletSpeed,
        [2] = Workspace.CurrentCamera.CFrame.Position,
        [3] = tick()
    }
    
    -- 🚀 Disparar usando el evento del arma
    local success, err = pcall(function()
        local gunScript = gun:FindFirstChild("GunScript")
        if gunScript and gunScript:FindFirstChild("ShootGun") then
            gunScript.ShootGun:FireServer(unpack(args))
            return true
        end
    end)
    
    if not success then
        warn("Error al disparar: " .. tostring(err))
        return false
    end
    
    return true
end

-- 🔄 Bucle principal de detección y disparo
local function mainLoop()
    while true do
        task.wait(scanInterval)
        
        -- 🚔 Verificar si somos sheriff
        if not isSheriff then
            if checkSheriffRole() then
                print("🔫 ¡Modo Sheriff Activado! 🔫")
            else
                continue
            end
        end
        
        -- 🔍 Buscar al asesino
        if not murder or not murder.Character or murder.Character.Humanoid.Health <= 0 then
            murder = findMurderer()
            if not murder then
                continue
            end
        end
        
        -- 🔫 Equipar arma si no está en mano
        if not gunEquipped then
            equipGun()
        end
        
        -- 🔥 Disparar si el asesino está en rango
        autoShoot(murder)
    end
end

-- 🚀 Iniciar el script
if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end

mainLoop()
