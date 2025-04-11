--[[ 
    Murder Mystery 2 Auto-Kill Script (Advanced)
    Características:
    - Detección automática de rol de asesino
    - Teleportación inteligente a cada jugador
    - Eliminación silenciosa o rápida según configuración
    - Evita detección por parte de inocentes
    - Sistema de cooldown configurable
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local murderTag = "None"
local killCooldown = 1.5 -- Tiempo entre asesinatos (en segundos)
local silentMode = true -- Si es true, usa método silencioso (recomendado)
local maxAttempts = 3 -- Intentos máximos por jugador

-- Esperar a que el juego cargue y se asignen roles
while not Workspace:FindFirstChild("Gameplay") or not Workspace.Gameplay:FindFirstChild("Alive") do
    task.wait(1)
end

-- Detectar si somos el asesino
local function checkMurderRole()
    for _, player in ipairs(Players:GetPlayers()) do
        if player:FindFirstChild("Role") and player.Role.Value == "Murderer" and player == localPlayer then
            murderTag = "Murder"
            return true
        end
    end
    return false
end

if not checkMurderRole() then
    warn("No eres el asesino. El script no se ejecutará.")
    return
end

print("Modo Asesino activado. Preparando eliminación sistemática...")

-- Obtener herramientas de asesino
local knife = localPlayer.Character and localPlayer.Character:FindFirstChild("Knife")
if not knife and localPlayer.Character then
    localPlayer.Character:WaitForChild("Knife", 5)
    knife = localPlayer.Character:FindFirstChild("Knife")
end

if not knife then
    warn("No se encontró el cuchillo. Intentando obtenerlo...")
    -- Intento alternativo de obtener el cuchillo
    local backpack = localPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == "Knife" then
                knife = item
                break
            end
        end
    end
end

if not knife then
    warn("No se pudo obtener el cuchillo. El script puede no funcionar correctamente.")
end

-- Función para encontrar jugadores vivos (excepto nosotros)
local function getAlivePlayers()
    local alivePlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and 
           player.Character.Humanoid.Health > 0 and Workspace.Gameplay.Alive:FindFirstChild(player.Name) then
            table.insert(alivePlayers, player)
        end
    end
    return alivePlayers
end

-- Función para teleportarse a un jugador de manera inteligente
local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not targetRoot or not localRoot then return false end
    
    -- Calcular posición óptima detrás del jugador
    local targetCFrame = targetRoot.CFrame
    local behindPosition = targetCFrame * CFrame.new(0, 0, -3)
    
    -- Mover al personaje
    localPlayer.Character:PivotTo(behindPosition)
    
    -- Esperar breve momento para que el juego registre el movimiento
    task.wait(0.2)
    return true
end

-- Función para realizar el asesinato
local function executePlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    -- Verificar si el objetivo sigue vivo
    if targetPlayer.Character.Humanoid.Health <= 0 then return true end
    
    -- Teleportarse al jugador
    if not teleportToPlayer(targetPlayer) then return false end
    
    -- Orientarse hacia el objetivo
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if targetRoot and localRoot then
        localPlayer.Character:SetPrimaryPartCFrame(CFrame.new(localRoot.Position, targetRoot.Position))
    end
    
    -- Método silencioso (usando eventos del juego)
    if silentMode then
        local success, err = pcall(function()
            local gameEvents = ReplicatedStorage:FindFirstChild("Gameplay")
            if gameEvents then
                local knifeEvent = gameEvents:FindFirstChild("KnifeHit")
                if knifeEvent then
                    knifeEvent:FireServer(targetPlayer.Character:FindFirstChild("Humanoid"))
                end
            end
        end)
        
        if not success then
            warn("Error en método silencioso: " .. tostring(err))
            silentMode = false -- Cambiar a método directo si falla
        end
    end
    
    -- Método directo (si el silencioso falla o está desactivado)
    if not silentMode then
        if knife then
            knife:Activate()
            task.wait(0.1)
            knife:Deactivate()
        end
    end
    
    -- Verificar si el objetivo fue eliminado
    task.wait(0.5)
    return targetPlayer.Character.Humanoid.Health <= 0
end

-- Sistema principal de eliminación
local function systematicElimination()
    local alivePlayers = getAlivePlayers()
    if #alivePlayers == 0 then
        print("Todos los jugadores han sido eliminados. Misión cumplida.")
        return
    end
    
    print("Iniciando eliminación sistemática de " .. #alivePlayers .. " jugadores...")
    
    for _, player in ipairs(alivePlayers) do
        if player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            print("Objetivo actual: " .. player.Name)
            
            local success = false
            local attempts = 0
            
            while not success and attempts < maxAttempts do
                attempts += 1
                success = executePlayer(player)
                
                if not success then
                    print("Intento " .. attempts .. " fallido. Reintentando...")
                    task.wait(killCooldown / 2)
                end
            end
            
            if success then
                print(player.Name .. " eliminado con éxito.")
            else
                warn("No se pudo eliminar a " .. player.Name .. " después de " .. maxAttempts .. " intentos.")
            end
            
            task.wait(killCooldown)
        end
    end
    
    -- Verificación final
    alivePlayers = getAlivePlayers()
    if #alivePlayers > 0 then
        warn("Quedan " .. #alivePlayers .. " jugadores vivos. Reiniciando proceso...")
        systematicElimination()
    else
        print("Todos los objetivos han sido eliminados con éxito.")
    end
end

-- Iniciar el proceso
systematicElimination()
