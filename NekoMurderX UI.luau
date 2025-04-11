-- Configuración inicial
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Variables de estado
local dragging, dragInput, dragStart, startPos
local activeToggles = {
    aimbot = false,
    noclip = false,
    locate = false,
    killAll = false,
    grabGun = false,
    autofarm = false
}
local currentSection = "Scripts"

-- Crear la interfaz principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NekoMurderXUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Icono flotante
local Icon = Instance.new("ImageButton")
Icon.Name = "MainIcon"
Icon.Image = "https://i.ibb.co/ds7YXFFR/1743621747202.png"
Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
Icon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Icon.BackgroundTransparency = 0.5
Icon.Size = UDim2.new(0, 60, 0, 60)
Icon.Position = UDim2.new(0.5, -30, 0.5, -30)
Icon.AutoButtonColor = false
Icon.BorderSizePixel = 0
Icon.ZIndex = 10
Icon.Parent = ScreenGui

-- Función para hacer el icono arrastrable
local function updateIconPosition(input)
    local delta = input.Position - dragStart
    Icon.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

Icon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Icon.Position
        
        -- Efecto de pulsación
        local tween = TweenService:Create(
            Icon,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 55, 0, 55)}
        )
        tween:Play()
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                
                -- Restaurar tamaño
                local tween = TweenService:Create(
                    Icon,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = UDim2.new(0, 60, 0, 60)}
                )
                tween:Play()
            end
        end)
    end
end)

Icon.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateIconPosition(input)
    end
end)

-- Ventana principal
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainWindow.BorderSizePixel = 0
MainWindow.Size = UDim2.new(0, 300, 0, 400)
MainWindow.Position = UDim2.new(0.5, -150, 0.5, -200)
MainWindow.Visible = false
MainWindow.ZIndex = 5
MainWindow.Parent = ScreenGui

-- Efecto de sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.ZIndex = 4
Shadow.Parent = MainWindow

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.ZIndex = 6
TitleBar.Parent = MainWindow

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Text = "NekoMurderX"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 7
Title.Parent = TitleBar

-- Botón de cerrar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 18
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.ZIndex = 7
CloseButton.Parent = TitleBar

-- Efecto hover para el botón de cerrar
CloseButton.MouseEnter:Connect(function()
    TweenService:Create(
        CloseButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(220, 70, 70)}
    ):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(
        CloseButton,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}
    ):Play()
end)

-- Secciones
local Sections = Instance.new("Frame")
Sections.Name = "Sections"
Sections.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Sections.BorderSizePixel = 0
Sections.Size = UDim2.new(0, 80, 1, -40)
Sections.Position = UDim2.new(0, 0, 0, 40)
Sections.ZIndex = 6
Sections.Parent = MainWindow

local ScriptsButton = Instance.new("TextButton")
ScriptsButton.Name = "ScriptsButton"
ScriptsButton.Text = "Scripts"
ScriptsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ScriptsButton.TextSize = 14
ScriptsButton.Font = Enum.Font.Gotham
ScriptsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScriptsButton.BorderSizePixel = 0
ScriptsButton.Size = UDim2.new(1, -10, 0, 30)
ScriptsButton.Position = UDim2.new(0, 5, 0, 5)
ScriptsButton.ZIndex = 7
ScriptsButton.Parent = Sections

local SupportButton = Instance.new("TextButton")
SupportButton.Name = "SupportButton"
SupportButton.Text = "Support"
SupportButton.TextColor3 = Color3.fromRGB(200, 200, 200)
SupportButton.TextSize = 14
SupportButton.Font = Enum.Font.Gotham
SupportButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SupportButton.BorderSizePixel = 0
SupportButton.Size = UDim2.new(1, -10, 0, 30)
SupportButton.Position = UDim2.new(0, 5, 0, 40)
SupportButton.ZIndex = 7
SupportButton.Parent = Sections

-- Contenido principal
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Content.BorderSizePixel = 0
Content.Size = UDim2.new(1, -80, 1, -40)
Content.Position = UDim2.new(0, 80, 0, 40)
Content.ZIndex = 6
Content.Parent = MainWindow

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.Parent = Content

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = Content

-- Función para crear un toggle
local function createOption(name, description, scriptUrl, toggleKey)
    local OptionFrame = Instance.new("Frame")
    OptionFrame.Name = name .. "Option"
    OptionFrame.BackgroundTransparency = 1
    OptionFrame.Size = UDim2.new(1, -20, 0, 50)
    OptionFrame.LayoutOrder = 1
    OptionFrame.ZIndex = 7
    OptionFrame.Parent = Content
    
    local Description = Instance.new("TextLabel")
    Description.Name = "Description"
    Description.Text = description
    Description.TextColor3 = Color3.fromRGB(255, 255, 255)
    Description.TextSize = 14
    Description.Font = Enum.Font.Gotham
    Description.BackgroundTransparency = 1
    Description.Size = UDim2.new(0.7, 0, 0, 30)
    Description.Position = UDim2.new(0, 0, 0, 0)
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.ZIndex = 8
    Description.Parent = OptionFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Text = ""
    ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -50, 0, 0)
    ToggleButton.ZIndex = 8
    ToggleButton.Parent = OptionFrame
    
    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Name = "ToggleIndicator"
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleIndicator.BorderSizePixel = 0
    ToggleIndicator.Size = UDim2.new(0, 21, 0, 21)
    ToggleIndicator.Position = UDim2.new(0, 2, 0, 2)
    ToggleIndicator.ZIndex = 9
    ToggleIndicator.Parent = ToggleButton
    
    local function updateToggleState()
        if activeToggles[toggleKey] then
            TweenService:Create(
                ToggleButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}
            ):Play()
            TweenService:Create(
                ToggleIndicator,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(1, -23, 0, 2)}
            ):Play()
        else
            TweenService:Create(
                ToggleButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}
            ):Play()
            TweenService:Create(
                ToggleIndicator,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(0, 2, 0, 2)}
            ):Play()
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        activeToggles[toggleKey] = not activeToggles[toggleKey]
        updateToggleState()
        
        if activeToggles[toggleKey] then
            loadstring(game:HttpGet(scriptUrl))()
        end
    end)
    
    -- Efecto hover
    ToggleButton.MouseEnter:Connect(function()
        TweenService:Create(
            ToggleButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = activeToggles[toggleKey] and Color3.fromRGB(70, 220, 70) or Color3.fromRGB(100, 100, 100)}
        ):Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        TweenService:Create(
            ToggleButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = activeToggles[toggleKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(80, 80, 80)}
        ):Play()
    end)
    
    updateToggleState()
end

-- Función para crear un botón de enlace
local function createLinkOption(name, imageUrl, buttonText, linkUrl)
    local OptionFrame = Instance.new("Frame")
    OptionFrame.Name = name .. "Option"
    OptionFrame.BackgroundTransparency = 1
    OptionFrame.Size = UDim2.new(1, -20, 0, 50)
    OptionFrame.LayoutOrder = 1
    OptionFrame.ZIndex = 7
    OptionFrame.Parent = Content
    
    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Image = imageUrl
    Icon.BackgroundTransparency = 1
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0, 0, 0, 0)
    Icon.ZIndex = 8
    Icon.Parent = OptionFrame
    
    local LinkButton = Instance.new("TextButton")
    LinkButton.Name = "LinkButton"
    LinkButton.Text = buttonText
    LinkButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LinkButton.TextSize = 14
    LinkButton.Font = Enum.Font.Gotham
    LinkButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    LinkButton.BorderSizePixel = 0
    LinkButton.Size = UDim2.new(0, 100, 0, 30)
    LinkButton.Position = UDim2.new(1, -100, 0, 0)
    LinkButton.ZIndex = 8
    LinkButton.Parent = OptionFrame
    
    -- Efecto hover
    LinkButton.MouseEnter:Connect(function()
        TweenService:Create(
            LinkButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}
        ):Play()
    end)
    
    LinkButton.MouseLeave:Connect(function()
        TweenService:Create(
            LinkButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}
        ):Play()
    end)
    
    LinkButton.MouseButton1Click:Connect(function()
        if linkUrl then
            local success, err = pcall(function()
                game:GetService("StarterGui"):SetCore("OpenBrowserWindow", {
                    Url = linkUrl
                })
            end)
            
            if not success then
                warn("Error al abrir enlace: " .. err)
            end
        end
    end)
end

-- Función para mostrar la sección de scripts
local function showScriptsSection()
    currentSection = "Scripts"
    
    -- Limpiar contenido
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Actualizar botones de sección
    ScriptsButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    SupportButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ScriptsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SupportButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Crear opciones de scripts
    createOption("Aimbot", "Aimbot automático | Disparo a murder", "https://raw.githubusercontent.com/KaitoNekox/Murder-mistery-2-/refs/heads/main/The%20Sheriff's%20Style.luau", "aimbot")
    createOption("Noclip", "Noclip | Transpasar paredes", "https://raw.githubusercontent.com/KaitoNekox/Murder-mistery-2-/refs/heads/main/Noclip.luau", "noclip")
    createOption("Locate", "Localizar murder y sheriff", "https://raw.githubusercontent.com/KaitoNekox/Murder-mistery-2-/refs/heads/main/Location.luau", "locate")
    createOption("KillAll", "Matar a todos (Murder)", "https://raw.githubusercontent.com/KaitoNekox/Murder-mistery-2-/refs/heads/main/Kill%20all%20users.luau", "killAll")
    createOption("GrabGun", "Agarrar el arma", "https://raw.githubusercontent.com/KaitoNekox/Murder-mistery-2-/refs/heads/main/Grab%20the%20gun.luau", "grabGun")
    createOption("Autofarm", "Autofarm coins", "https://raw.githubusercontent.com/KaitoNekox/Murder-mistery-2-/refs/heads/main/Autofarming%20coins.luau", "autofarm")
end

-- Función para mostrar la sección de soporte
local function showSupportSection()
    currentSection = "Support"
    
    -- Limpiar contenido
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Actualizar botones de sección
    SupportButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ScriptsButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SupportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScriptsButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    
    -- Crear opciones de soporte
    createLinkOption("Discord", "http://www.roblox.com/asset/?id=9334666836", "Servidor", "https://discord.gg/nekox")
    createLinkOption("GitHub", "http://www.roblox.com/asset/?id=9334663681", "Apoyar", "https://github.com/KaitoNekox")
end

-- Configurar eventos de los botones de sección
ScriptsButton.MouseButton1Click:Connect(showScriptsSection)
SupportButton.MouseButton1Click:Connect(showSupportSection)

-- Efecto hover para los botones de sección
ScriptsButton.MouseEnter:Connect(function()
    if currentSection ~= "Scripts" then
        TweenService:Create(
            ScriptsButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}
        ):Play()
    end
end)

ScriptsButton.MouseLeave:Connect(function()
    if currentSection ~= "Scripts" then
        TweenService:Create(
            ScriptsButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}
        ):Play()
    end
end)

SupportButton.MouseEnter:Connect(function()
    if currentSection ~= "Support" then
        TweenService:Create(
            SupportButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}
        ):Play()
    end
end)

SupportButton.MouseLeave:Connect(function()
    if currentSection ~= "Support" then
        TweenService:Create(
            SupportButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}
        ):Play()
    end
end)

-- Mostrar la sección de scripts por defecto
showScriptsSection()

-- Configurar evento para abrir/cerrar la ventana
Icon.MouseButton1Click:Connect(function()
    MainWindow.Visible = not MainWindow.Visible
    Shadow.Visible = MainWindow.Visible
    
    if MainWindow.Visible then
        -- Animación de apertura
        MainWindow.Size = UDim2.new(0, 0, 0, 0)
        MainWindow.Position = Icon.Position + UDim2.new(0, 30, 0, 30)
        
        local tween = TweenService:Create(
            MainWindow,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 300, 0, 400), Position = UDim2.new(0.5, -150, 0.5, -200)}
        )
        tween:Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    MainWindow.Visible = false
    Shadow.Visible = false
end)

-- Añadir la interfaz al jugador
if game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:PlayerGui
else
    game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:PlayerGui
end
