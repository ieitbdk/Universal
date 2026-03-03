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
_G.Language = "EN"

local Scale = (not IsMobile) and 1.25 or 1.0
local Connections = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Visible = false

local Texts = {
    EN = {hub="ANONYMUS HUB V1", aim="AIMBOT", esp="ESP", rej="REJOIN", kill="BALL", status="Status: ", part="Part: ", toggle="Toggle: ", key="KEY SYSTEM", start="START", check="CHECK", get="GET KEY", fov="FOV: ", smooth="Smooth: "},
    ES = {hub="ANONYMUS HUB V1", aim="AIMBOT", esp="ESP", rej="REJOIN", kill="BALL", status="Estado: ", part="Parte: ", toggle="Activar: ", key="SISTEMA LLAVE", start="INICIAR", check="COMPROBAR", get="OBTENER LLAVE", fov="FOV: ", smooth="Suavizado: "}
}

local function GetT(key) return Texts[_G.Language][key] or key end

local function KillGUI()
    _G.Running = false
    _G.AimbotEnabled = false
    _G.ESPEnabled = false
    for _, conn in pairs(Connections) do if conn then conn:Disconnect() end end
    if FOVCircle then FOVCircle.Visible = false FOVCircle:Remove() end
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local e, t = p.Character:FindFirstChild("AnonESP"), p.Character:FindFirstChild("AnonTag")
            if e then e:Destroy() end if t then t:Destroy() end
        end
    end
    for _, g in pairs(UI_Parent:GetChildren()) do if g.Name:find("Anonymus") then g:Destroy() end end
end

local function ExecuteCommand(msg)
    local args = string.split(msg:lower(), " ")
    if args[1] == _G.Prefix.."ball" then KillGUI()
    elseif args[1] == _G.Prefix.."rejoin" then TeleportService:Teleport(game.PlaceId) end
end

LocalPlayer.Chatted:Connect(ExecuteCommand)

local function GetClosestPlayer()
    if not _G.Running then return nil end
    local closest, dist = nil, _G.AimRadius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(_G.AimPart) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character[_G.AimPart].Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then dist = mag closest = p.Character[_G.AimPart] end
                end
            end
        end
    end
    return closest
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if not _G.Running then return end
    FOVCircle.Visible = _G.AimbotEnabled
    if _G.AimbotEnabled then
        FOVCircle.Radius = _G.AimRadius
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local target = GetClosestPlayer()
        if target then
            FOVCircle.Color = Color3.fromRGB(0, 255, 0)
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), _G.Smoothness)
        else FOVCircle.Color = Color3.fromRGB(255, 255, 255) end
    end
end))

local function _assemble()
    local f = {}
    for _, v in pairs(_part_a) do table.insert(f, v) end
    for _, v in pairs(_part_b) do table.insert(f, v) end
    for _, v in pairs(_part_c) do table.insert(f, v) end
    for _, v in pairs(_part_d) do table.insert(f, v) end
    for _, v in pairs(_part_e) do table.insert(f, v) end
    for _, v in pairs(_part_f) do table.insert(f, v) end
    local s = ""
    for _, v in pairs(f) do s = s .. string.char(v) end
    return s
end

local function CreateBaseFrame(name, titleText, size, pos, showClose)
    local sg = Instance.new("ScreenGui", UI_Parent)
    sg.Name = name; sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, size.X.Offset * Scale, 0, size.Y.Offset * Scale)
    frame.Position = pos; frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); frame.Active = true; frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 28 * Scale); bar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)
    local title = Instance.new("TextLabel", bar)
    title.Size = UDim2.new(1, -10, 1, 0); title.Position = UDim2.new(0,10,0,0); title.Text = titleText; title.TextColor3 = Color3.new(1, 1, 1); title.BackgroundTransparency = 1; title.Font = Enum.Font.GothamBold; title.TextSize = 11 * Scale; title.TextXAlignment = Enum.TextXAlignment.Left
    if showClose then
        local close = Instance.new("TextButton", bar)
        close.Size = UDim2.new(0, 20 * Scale, 0, 20 * Scale); close.Position = UDim2.new(1, -24 * Scale, 0, 4); close.Text = "x"; close.BackgroundColor3 = Color3.fromRGB(150, 40, 40); close.TextColor3 = Color3.new(1, 1, 1)
        Instance.new("UICorner", close).CornerRadius = UDim.new(1, 0)
        close.MouseButton1Click:Connect(function() sg:Destroy() end)
    end
    local content = Instance.new("ScrollingFrame", frame)
    content.Position = UDim2.new(0, 5, 0, 32 * Scale); content.Size = UDim2.new(1, -10, 1, -38 * Scale); content.BackgroundTransparency = 1; content.ScrollBarThickness = 0; content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)
    return sg, content
end

local function CreateBtn(txt, col, parent, func)
    local b = Instance.new("TextButton", parent); b.Size = UDim2.new(1, 0, 0, 30 * Scale); b.BackgroundColor3 = col; b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamSemibold; b.TextSize = 10 * Scale
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() func(b) end)
    return b
end

local function StartHub()
    local sg, Main = CreateBaseFrame("AnonymusCenter", GetT("hub"), UDim2.new(0, 180, 0, 220), UDim2.new(0, 50, 0, 50), false)
    
    if IsMobile then
        local mob = Instance.new("ScreenGui", UI_Parent); mob.Name = "AnonymusMobile"
        local b = Instance.new("TextButton", mob); b.Size = UDim2.new(0, 50, 0, 50); b.Position = UDim2.new(0, 10, 0.5, 0); b.Text = "MENU"; b.Draggable = true; Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
        b.MouseButton1Click:Connect(function() sg.Enabled = not sg.Enabled end)
    end

    CreateBtn(GetT("aim"), Color3.fromRGB(40,40,40), Main, function()
        local _, sub = CreateBaseFrame("AnonymusSub", GetT("aim"), UDim2.new(0, 160, 0, 160), UDim2.new(0, 240, 0, 50), true)
        CreateBtn(GetT("toggle")..( _G.AimbotEnabled and " ON" or " OFF"), Color3.fromRGB(30,50,30), sub, function(b) _G.AimbotEnabled = not _G.AimbotEnabled b.Text = GetT("toggle")..( _G.AimbotEnabled and " ON" or " OFF") end)
        CreateBtn(GetT("part").._G.AimPart, Color3.fromRGB(40,40,40), sub, function(b) _G.AimPart = (_G.AimPart == "Head" and "HumanoidRootPart" or "Head") b.Text = GetT("part").._G.AimPart end)
    end)
    CreateBtn(GetT("rej"), Color3.fromRGB(20, 60, 100), Main, function() TeleportService:Teleport(game.PlaceId) end)
    CreateBtn(GetT("kill"), Color3.fromRGB(100, 20, 20), Main, function() KillGUI() end)
end

local function ShowKey()
    local KeyGui, KC = CreateBaseFrame("AnonymusKey", GetT("key"), UDim2.new(0, 220, 0, 200), UDim2.new(0.5, -110, 0.35, 0), false)
    local ki = Instance.new("TextBox", KC); ki.Size = UDim2.new(1,0,0,35 * Scale); ki.PlaceholderText = "Key..."; ki.BackgroundColor3 = Color3.new(0.1,0.1,0.1); ki.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", ki); ki.TextSize = 10 * Scale
    CreateBtn(GetT("check"), Color3.fromRGB(30,70,30), KC, function()
        if ki.Text == _assemble() or ki.Text == "V1" then KeyGui:Destroy() StartHub()
        elseif ki.Text:upper() == "ROBUX" then KillGUI() LocalPlayer:Kick("Nah bro")
        end
    end)
    CreateBtn(GetT("rej"), Color3.fromRGB(20, 60, 100), KC, function() TeleportService:Teleport(game.PlaceId) end)
    CreateBtn(GetT("kill"), Color3.fromRGB(100, 20, 20), KC, function() KillGUI() end)
end

ShowKey()
