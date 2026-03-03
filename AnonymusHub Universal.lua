local _part_f = {52, 51, 57, 51, 50, 57, 52}
local _part_a = {65, 78, 79}
local _part_b = {78, 89, 77, 85, 83, 95}
local _part_c = {72, 85, 66}
local _part_d = {50, 48, 50, 54, 95}
local _part_e = {75, 69, 89, 95}

local UI_Parent = (gethui and gethui()) or game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local IsMobile = UserInputService.TouchEnabled

_G.Running = true
_G.Prefix = ";"
_G.AimbotEnabled = false
_G.AimPart = "Head"
_G.AimRadius = 150
_G.Smoothness = 0.5
_G.ESPEnabled = false

local Connections = {}

-- FUNCIÓN DE CIERRE TOTAL (BALL)
local function KillGUI()
    _G.Running = false
    _G.AimbotEnabled = false
    _G.ESPEnabled = false
    
    -- 1. Detener todas las conexiones para evitar el error de la imagen
    for i, conn in pairs(Connections) do
        if conn then 
            conn:Disconnect()
            Connections[i] = nil
        end
    end
    
    -- 2. Limpiar dibujos y elementos visuales
    if _G.FOVCircle then 
        _G.FOVCircle.Visible = false 
        _G.FOVCircle:Remove() 
    end

    -- 3. Borrar las GUIs
    for _, g in pairs(UI_Parent:GetChildren()) do
        if g.Name:find("Anonymus") then g:Destroy() end
    end
end

-- COMANDOS DE CHAT
LocalPlayer.Chatted:Connect(function(msg)
    local args = string.split(msg:lower(), " ")
    if args[1] == _G.Prefix.."ball" then KillGUI()
    elseif args[1] == _G.Prefix.."rejoin" then TeleportService:Teleport(game.PlaceId) end
end)

-- AIMBOT LOOP PROTEGIDO
_G.FOVCircle = Drawing.new("Circle")
_G.FOVCircle.Thickness = 1
_G.FOVCircle.Transparency = 0.7
_G.FOVCircle.Color = Color3.new(1,1,1)

local renderConn = RunService.RenderStepped:Connect(function()
    if not _G.Running then return end
    _G.FOVCircle.Visible = _G.AimbotEnabled
    if _G.AimbotEnabled then
        _G.FOVCircle.Radius = _G.AimRadius
        _G.FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end)
table.insert(Connections, renderConn)

local function CreateBtn(txt, col, parent, func)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 35)
    b.BackgroundColor3 = col
    b.Text = txt
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(func)
    return b
end

local function StartHub()
    local sg = Instance.new("ScreenGui", UI_Parent); sg.Name = "AnonymusMain"
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 200, 0, 180); main.Position = UDim2.new(0.1, 0, 0.1, 0); main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    main.Active = true; main.Draggable = true; Instance.new("UICorner", main)
    local list = Instance.new("UIListLayout", main); list.Padding = UDim.new(0, 5); list.HorizontalAlignment = Enum.HorizontalAlignment.Center

    Instance.new("TextLabel", main).Text = "ANONYMUS HUB"
    CreateBtn("REJOIN", Color3.fromRGB(30, 60, 90), main, function() TeleportService:Teleport(game.PlaceId) end)
    CreateBtn("BALL (KILL)", Color3.fromRGB(120, 30, 30), main, KillGUI)

    if IsMobile then
        local mob = Instance.new("ScreenGui", UI_Parent); mob.Name = "AnonymusMobile"
        local b = Instance.new("TextButton", mob); b.Size = UDim2.new(0, 50, 0, 50); b.Position = UDim2.new(0, 10, 0.5, 0); b.Text = "GUI"
        Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
        b.MouseButton1Click:Connect(function() sg.Enabled = not sg.Enabled end)
    end
end

local function ShowKey()
    local sg = Instance.new("ScreenGui", UI_Parent); sg.Name = "AnonymusKey"
    local f = Instance.new("Frame", sg); f.Size = UDim2.new(0, 220, 0, 160); f.Position = UDim2.new(0.5, -110, 0.5, -80); f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Instance.new("UICorner", f)
    
    local ki = Instance.new("TextBox", f); ki.Size = UDim2.new(0.8, 0, 0, 35); ki.Position = UDim2.new(0.1, 0, 0.2, 0); ki.PlaceholderText = "Key..."; ki.BackgroundColor3 = Color3.new(0,0,0); ki.TextColor3 = Color3.new(1,1,1)
    
    local s = CreateBtn("START", Color3.fromRGB(40, 90, 40), f, function()
        if ki.Text == "V1" then sg:Destroy() StartHub() end
    end)
    s.Position = UDim2.new(0.1, 0, 0.5, 0)

    local b = CreateBtn("BALL", Color3.fromRGB(120, 30, 30), f, KillGUI)
    b.Size = UDim2.new(0.35, 0, 0, 30); b.Position = UDim2.new(0.1, 0, 0.8, 0)

    local r = CreateBtn("REJOIN", Color3.fromRGB(30, 60, 90), f, function() TeleportService:Teleport(game.PlaceId) end)
    r.Size = UDim2.new(0.35, 0, 0, 30); r.Position = UDim2.new(0.55, 0, 0.8, 0)
end

ShowKey()
