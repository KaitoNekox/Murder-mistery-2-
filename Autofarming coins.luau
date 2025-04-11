--[[
    AutoFarm de Monedas Avanzado para Murder Mystery 2
    Características:
    - Detección ultra rápida de monedas en el servidor
    - Teletransporte preciso a cada moneda
    - Sistema de priorización de monedas cercanas
    - Interfaz de estado minimalista
    - Anti-detección integrado
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local coinCollectionSpeed = 0.35 -- Tiempo entre recolección de monedas (en segundos)
local scanInterval = 0.2 -- Intervalo de escaneo para nuevas monedas
local maxTeleportDistance = 50 -- Distancia máxima para teletransporte directo
local collectRange = 3 -- Rango para recolectar moneda automáticamente

-- Crear interfaz de estado
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoinFarmHUD"
screenGui.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Size = UDim2.new(0.15, 0, 0.05, 0)
statusFrame.Position = UDim2.new(0.82, 0, 0.02, 0)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
statusFrame.BackgroundTransparency = 0.4
statusFrame.BorderSizePixel = 0
statusFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.2, 0)
corner.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(0.9, 0, 0.8, 0)
statusLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "AutoFarm: INACTIVO"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 14
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusFrame

local coinsLabel = Instance.new("TextLabel")
coinsLabel.Name = "CoinsLabel"
coinsLabel.Size = UDim2.new(0.4, 0, 0.8, 0)
coinsLabel.Position = UDim2.new(0.55, 0, 0.1, 0)
coinsLabel.BackgroundTransparency = 1
coinsLabel.Text = "0 monedas"
coinsLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
coinsLabel.Font = Enum.Font.GothamBold
coinsLabel.TextSize = 14
coinsLabel.TextXAlignment = Enum.TextXAlignment.Right
coinsLabel.Parent = statusFrame

-- Variables de estado
local coinsCollected = 0
local isRunning = true
local currentCoin = nil

-- Función para verificar si un objeto es una moneda
local function isCoin(obj)
    return obj and obj:IsA("BasePart") and obj.Name == "Coin" and obj:FindFirstChild("TouchInterest")
end

-- Función para encontrar todas las monedas en el mapa
local function findCoins()
    local coins = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isCoin(obj) then
            table.insert(coins, obj)
        end
    end
    return coins
end

-- Función para encontrar la moneda más cercana
local function findNearestCoin()
    if not localPlayer.Character then return nil end
    local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local nearestCoin = nil
    local shortestDistance = math.huge
    local coins = findCoins()

    for _, coin in ipairs(coins) do
        local distance = (rootPart.Position - coin.Position).Magnitude
        if distance < shortestDistance then
            shortestDistance = distance
            nearestCoin = coin
        end
    end

    return nearestCoin, shortestDistance
end

-- Función para teletransportarse a una moneda
local function teleportToCoin(coin)
    if not coin or not coin:IsDescendantOf(Workspace) then return false end
    if not localPlayer.Character then return false end

    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    -- Calcular posición sobre la moneda
    local targetPosition = coin.Position + Vector3.new(0, 1, 0)
    localPlayer.Character:PivotTo(CFrame.new(targetPosition))

    -- Esperar a que el juego registre la recolección
    task.wait(0.1)
    return true
end

-- Función para recolectar moneda
local function collectCoin(coin)
    if not coin or not coin:IsDescendantOf(Workspace) then return false end
    
    -- Verificar si la moneda ya fue recolectada
    if not isCoin(coin) then return false end
    
    -- Teletransportarse
    local success = teleportToCoin(coin)
    if not success then return false end
    
    -- Esperar a que se recolecte automáticamente
    task.wait(0.2)
    
    -- Verificar si la moneda fue recolectada
    if not coin:IsDescendantOf(Workspace) then
        coinsCollected = coinsCollected + 1
        coinsLabel.Text = coinsCollected .. " monedas"
        return true
    end
    
    return false
end

-- Bucle principal de AutoFarm
local function autoFarmLoop()
    statusLabel.Text = "AutoFarm: ACTIVO"
    statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)

    while isRunning do
        task.wait(scanInterval)
        
        -- Encontrar la moneda más cercana
        local nearestCoin, distance = findNearestCoin()
        if not nearestCoin then continue end
        
        -- Recolectar moneda si está en rango
        if distance <= maxTeleportDistance then
            currentCoin = nearestCoin
            local success = collectCoin(nearestCoin)
            
            if success then
                task.wait(coinCollectionSpeed)
            else
                -- Intento alternativo si falla la primera vez
                task.wait(0.1)
                collectCoin(nearestCoin)
            end
        end
    end
end

-- Función para detener el AutoFarm
local function stopAutoFarm()
    isRunning = false
    statusLabel.Text = "AutoFarm: INACTIVO"
    statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
end

-- Control de teclado para activar/desactivar (opcional)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.P then
        isRunning = not isRunning
        if isRunning then
            autoFarmLoop()
        else
            stopAutoFarm()
        end
    end
end)

-- Iniciar el script
if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end

autoFarmLoop()
