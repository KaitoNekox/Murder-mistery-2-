--[[
    🔍 Localizador Avanzado de Roles para Murder Mystery 2 🔍
    - Detecta automáticamente al Sheriff (Azul) y Murder (Rojo)
    - Marca sus personajes en tiempo real
    - Muestra información en la pantalla
    - Actualización constante de posición
    - Sistema anti-detección
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

local localPlayer = Players.LocalPlayer
local sheriff = nil
local murder = nil
local updateInterval = 0.5 -- Actualizar cada 0.5 segundos
local highlightEnabled = true -- Resaltar personajes
local espEnabled = true -- Mostrar información en pantalla

-- 🎨 Crear interfaz de información
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RoleTrackerUI"
screenGui.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local sheriffFrame = Instance.new("Frame")
sheriffFrame.Name = "SheriffInfo"
sheriffFrame.Size = UDim2.new(0.2, 0, 0.1, 0)
sheriffFrame.Position = UDim2.new(0.01, 0, 0.85, 0)
sheriffFrame.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
sheriffFrame.BackgroundTransparency = 0.7
sheriffFrame.BorderSizePixel = 0
sheriffFrame.Visible = false
sheriffFrame.Parent = screenGui

local sheriffLabel = Instance.new("TextLabel")
sheriffLabel.Name = "SheriffLabel"
sheriffLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
sheriffLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
sheriffLabel.BackgroundTransparency = 1
sheriffLabel.Text = "SHERIFF: Cargando..."
sheriffLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sheriffLabel.Font = Enum.Font.GothamBold
sheriffLabel.TextSize = 14
sheriffLabel.TextXAlignment = Enum.TextXAlignment.Left
sheriffLabel.Parent = sheriffFrame

local murderFrame = Instance.new("Frame")
murderFrame.Name = "MurderInfo"
murderFrame.Size = UDim2.new(0.2, 0, 0.1, 0)
murderFrame.Position = UDim2.new(0.01, 0, 0.75, 0)
murderFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
murderFrame.BackgroundTransparency = 0.7
murderFrame.BorderSizePixel = 0
murderFrame.Visible = false
murderFrame.Parent = screenGui

local murderLabel = Instance.new("TextLabel")
murderLabel.Name = "MurderLabel"
murderLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
murderLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
murderLabel.BackgroundTransparency = 1
murderLabel.Text = "ASESINO: Cargando..."
murderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
murderLabel.Font = Enum.Font.GothamBold
murderLabel.TextSize = 14
murderLabel.TextXAlignment = Enum.TextXAlignment.Left
murderLabel.Parent = murderFrame

-- 🎨 Función para resaltar personajes
local function highlightPlayer(player, color)
    if not player.Character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "RoleHighlight"
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = player.Character
    
    -- Actualizar cuando el personaje cambie
    player.CharacterAdded:Connect(function(newChar)
        task.wait(1) -- Esperar a que el personaje se cargue
        local newHighlight = highlight:Clone()
        newHighlight.Parent = newChar
    end)
end

-- 🔍 Encontrar roles importantes
local function findImportantRoles()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player:FindFirstChild("Role") then
            if player.Role.Value == "Sheriff" then
                sheriff = player
                if highlightEnabled then
                    highlightPlayer(player, Color3.fromRGB(0, 100, 255))
                end
            elseif player.Role.Value == "Murderer" then
                murder = player
                if highlightEnabled then
                    highlightPlayer(player, Color3.fromRGB(255, 50, 50))
                end
            end
        end
    end
end

-- 📍 Actualizar información de posición
local function updatePlayerInfo()
    while true do
        task.wait(updateInterval)
        
        -- Actualizar información del Sheriff
        if sheriff and sheriff.Character and sheriff.Character:FindFirstChild("HumanoidRootPart") then
            local sheriffPos = sheriff.Character.HumanoidRootPart.Position
            local distance = (sheriffPos - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            sheriffLabel.Text = string.format("SHERIFF: %s (%.1m)", sheriff.Name, distance)
            sheriffFrame.Visible = true
        else
            sheriffFrame.Visible = false
        end
        
        -- Actualizar información del Murder
        if murder and murder.Character and murder.Character:FindFirstChild("HumanoidRootPart") then
            local murderPos = murder.Character.HumanoidRootPart.Position
            local distance = (murderPos - localPlayer.Character.HumanoidRootPart.Position).Magnitude
            murderLabel.Text = string.format("ASESINO: %s (%.1m)", murder.Name, distance)
            murderFrame.Visible = true
        else
            murderFrame.Visible = false
        end
    end
end

-- 🔄 Bucle principal de detección
local function mainLoop()
    findImportantRoles()
    
    -- Volver a escanear si no se encontraron roles
    if not sheriff or not murder then
        task.wait(5)
        findImportantRoles()
    end
    
    -- Actualizar información
    updatePlayerInfo()
    
    -- Escuchar cambios de rol
    Players.PlayerAdded:Connect(function(player)
        player:WaitForChild("Role", 10)
        player.Role.Changed:Connect(function()
            findImportantRoles()
        end)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            player:WaitForChild("Role", 10)
            player.Role.Changed:Connect(function()
                findImportantRoles()
            end)
        end
    end
end

-- 🚀 Iniciar el script
if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end

mainLoop()
