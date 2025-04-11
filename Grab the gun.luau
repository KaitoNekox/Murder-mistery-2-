--[[
    Script avanzado para Murder Mystery 2:
    - Detecta cuando el arma del sheriff cae al suelo
    - Muestra notificación en la parte inferior derecha
    - Se teletransporta automáticamente al arma
    - Sistema configurable
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local notificationDuration = 4 -- Duración de la notificación en segundos
local teleportDelay = 1 -- Espera antes de teletransportarse (para que la notificación sea visible)
local collectRange = 15 -- Rango máximo para recoger el arma automáticamente
local checkInterval = 0.5 -- Intervalo de verificación en segundos

-- Crear GUI para notificaciones
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SheriffGunNotifier"
screenGui.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")

local notificationFrame = Instance.new("Frame")
notificationFrame.Name = "NotificationFrame"
notificationFrame.Size = UDim2.new(0.3, 0, 0.1, 0)
notificationFrame.Position = UDim2.new(0.69, 0, 0.85, 0)
notificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
notificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
notificationFrame.BackgroundTransparency = 0.3
notificationFrame.BorderSizePixel = 0
notificationFrame.Visible = false
notificationFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0.1, 0)
corner.Parent = notificationFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(0.9, 0, 0.3, 0)
titleLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "¡ARMA DE SHERIFF DETECTADA!"
titleLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = notificationFrame

local messageLabel = Instance.new("TextLabel")
messageLabel.Name = "MessageLabel"
messageLabel.Size = UDim2.new(0.9, 0, 0.5, 0)
messageLabel.Position = UDim2.new(0.05, 0, 0.4, 0)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = "Teletransportándose para recoger el arma..."
messageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
messageLabel.Font = Enum.Font.Gotham
messageLabel.TextSize = 14
messageLabel.TextXAlignment = Enum.TextXAlignment.Left
messageLabel.TextWrapped = true
messageLabel.Parent = notificationFrame

-- Función para mostrar notificación
local function showNotification()
    notificationFrame.Visible = true
    
    -- Animación de entrada
    notificationFrame.Position = UDim2.new(0.69, 0, 0.9, 0)
    local tweenIn = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.69, 0, 0.85, 0)}
    )
    tweenIn:Play()
    
    task.wait(notificationDuration)
    
    -- Animación de salida
    local tweenOut = TweenService:Create(
        notificationFrame,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        {Position = UDim2.new(0.69, 0, 0.9, 0)}
    )
    tweenOut:Play()
    
    tweenOut.Completed:Wait()
    notificationFrame.Visible = false
end

-- Función para teletransportarse al arma
local function teleportToGun(gun)
    if not gun or not gun:IsDescendantOf(Workspace) then return end
    if not localPlayer.Character then return end
    
    local humanoidRootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    showNotification()
    task.wait(teleportDelay)
    
    -- Calcular posición cercana al arma
    local gunPosition = gun:GetPivot().Position
    local teleportPosition = gunPosition + Vector3.new(0, 0, 2) -- 2 unidades frente al arma
    
    -- Teletransportarse
    localPlayer.Character:PivotTo(CFrame.new(teleportPosition))
    
    -- Intentar recoger el arma automáticamente si está cerca
    task.wait(0.5)
    if (humanoidRootPart.Position - gunPosition).Magnitude <= collectRange then
        local humanoid = localPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:EquipTool(gun)
        end
    end
end

-- Función para verificar si un objeto es el arma del sheriff
local function isSheriffGun(obj)
    return obj and obj:IsA("Tool") and obj.Name == "Gun" and 
           not obj:FindFirstChild("Handle") and obj:FindFirstChild("GunScript")
end

-- Bucle principal para detectar el arma del sheriff
local function mainLoop()
    while true do
        task.wait(checkInterval)
        
        -- Verificar si el arma del sheriff está en el suelo
        for _, item in ipairs(Workspace:GetDescendants()) do
            if isSheriffGun(item) then
                -- Verificar que no esté en la mochila de un jugador
                local inBackpack = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player:FindFirstChild("Backpack") then
                        if player.Backpack:FindFirstChild("Gun") then
                            inBackpack = true
                            break
                        end
                    end
                end
                
                if not inBackpack then
                    teleportToGun(item)
                    task.wait(notificationDuration + 1) -- Esperar antes de revisar nuevamente
                end
            end
        end
    end
end

-- Iniciar el script
if not localPlayer.Character then
    localPlayer.CharacterAdded:Wait()
end

mainLoop()
