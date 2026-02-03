--[[
    luayV2 UI LIBRARY - CLASSIC & COMPACT EDITION
    - Bordas Quadradas (Estilo Clássico)
    - Barra Lateral Colorida Fixa |—
    - Mobile Friendly (Touch/Drag)
    - Sistema de Notificação e Logs Integrado
]]

local luayV2 = {}

-- Serviços
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

-- Função de Arrastar (Mobile e PC)
local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Notificações Clássicas
function luayV2:Notify(config)
    local title = config.Title or "SISTEMA"
    local text = config.Text or "Mensagem"
    local duration = config.Duration or 5
    
    local notifyGui = CoreGui:FindFirstChild("luay_Notify") or Instance.new("ScreenGui", CoreGui)
    notifyGui.Name = "luay_Notify"
    
    local container = notifyGui:FindFirstChild("Container") or Instance.new("Frame", notifyGui)
    if not notifyGui:FindFirstChild("Container") then
        container.Name = "Container"
        container.Size = UDim2.new(0, 220, 1, 0)
        container.Position = UDim2.new(1, -230, 0, 0)
        container.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout", container)
        layout.VerticalAlignment = "Bottom"; layout.Padding = UDim.new(0, 5)
    end
    
    local nFrame = Instance.new("Frame", container)
    nFrame.Size = UDim2.new(1, 0, 0, 60)
    nFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    nFrame.BorderSizePixel = 1
    nFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    
    local line = Instance.new("Frame", nFrame)
    line.Size = UDim2.new(0, 2, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    line.BorderSizePixel = 0
    
    local tLabel = Instance.new("TextLabel", nFrame)
    tLabel.Text = title:upper()
    tLabel.Size = UDim2.new(1, -10, 0, 20); tLabel.Position = UDim2.new(0, 10, 0, 5)
    tLabel.TextColor3 = Color3.new(1, 1, 1); tLabel.Font = "Code"; tLabel.TextSize = 13; tLabel.TextXAlignment = "Left"; tLabel.BackgroundTransparency = 1
    
    local mLabel = Instance.new("TextLabel", nFrame)
    mLabel.Text = text
    mLabel.Size = UDim2.new(1, -10, 1, -25); mLabel.Position = UDim2.new(0, 10, 0, 25)
    mLabel.TextColor3 = Color3.fromRGB(180, 180, 180); mLabel.Font = "Code"; mLabel.TextSize = 11; mLabel.TextXAlignment = "Left"; mLabel.TextYAlignment = "Top"; mLabel.BackgroundTransparency = 1; mLabel.TextWrapped = true
    
    task.delay(duration, function()
        nFrame:Destroy()
    end)
end

function luayV2:Window(config)
    local Lib = {
        MainColor = config.Color or Color3.fromRGB(0, 170, 255),
        Minimized = false
    }

    local ScreenGui = Instance.new("ScreenGui", (gethui and gethui()) or CoreGui)
    ScreenGui.Name = "luay_Classic_Hub"

    -- Frame Principal Compacto
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 280, 0, 320)
    Main.Position = UDim2.new(0.5, -140, 0.5, -160)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 1
    Main.BorderColor3 = Color3.fromRGB(30, 30, 30)

    -- Barra Lateral Colorida Clássica |—
    local AccentBar = Instance.new("Frame", Main)
    AccentBar.Size = UDim2.new(0, 2, 1, 0)
    AccentBar.BackgroundColor3 = Lib.MainColor
    AccentBar.BorderSizePixel = 0

    -- TopBar
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 30)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, Main)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = (config.Name or "LUAY V2"):upper()
    Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1); Title.Font = "Code"; Title.TextSize = 14; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1

    -- Botões Minimizar e Fechar
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50); CloseBtn.BackgroundTransparency = 1; CloseBtn.Font = "Code"; CloseBtn.TextSize = 16

    local MiniBtn = Instance.new("TextButton", TopBar)
    MiniBtn.Size = UDim2.new(0, 30, 0, 30); MiniBtn.Position = UDim2.new(1, -60, 0, 0)
    MiniBtn.Text = "-"; MiniBtn.TextColor3 = Color3.new(1, 1, 1); MiniBtn.BackgroundTransparency = 1; MiniBtn.Font = "Code"; MiniBtn.TextSize = 18

    local ContentFrame = Instance.new("Frame", Main)
    ContentFrame.Size = UDim2.new(1, -45, 1, -30); ContentFrame.Position = UDim2.new(0, 42, 0, 30); ContentFrame.BackgroundTransparency = 1

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    MiniBtn.MouseButton1Click:Connect(function()
        Lib.Minimized = not Lib.Minimized
        ContentFrame.Visible = not Lib.Minimized
        Main:TweenSize(Lib.Minimized and UDim2.new(0, 280, 0, 30) or UDim2.new(0, 280, 0, 320), "Out", "Quad", 0.2, true)
    end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 35, 1, -35); Sidebar.Position = UDim2.new(0, 5, 0, 35); Sidebar.BackgroundTransparency = 1
    local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0, 5); SideLayout.HorizontalAlignment = "Center"

    function Lib:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame", ContentFrame)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.ScrollBarThickness = 2; AreaFrame.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 6)

        local TBtn = Instance.new("ImageButton", Sidebar)
        TBtn.Size = UDim2.new(0, 28, 0, 28); TBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TBtn.BorderSizePixel = 1; TBtn.BorderColor3 = Color3.fromRGB(40,40,40)
        TBtn.Image = "rbxassetid://" .. (icon or "4483345998")
        
        TBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentFrame:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
        end)

        if not Lib.FirstArea then AreaFrame.Visible = true; Lib.FirstArea = true end

        local Elements = {}

        function Elements:Button(text, callback)
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(1, -5, 0, 28); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.BorderSizePixel = 1; b.BorderColor3 = Color3.fromRGB(40,40,40)
            b.Text = " " .. text:upper(); b.TextColor3 = Color3.new(1, 1, 1); b.Font = "Code"; b.TextSize = 12; b.TextXAlignment = "Left"
            b.MouseButton1Click:Connect(callback)
        end

        function Elements:Toggle(text, callback)
            local state = false
            local t = Instance.new("TextButton", AreaFrame)
            t.Size = UDim2.new(1, -5, 0, 28); t.BackgroundColor3 = Color3.fromRGB(25, 25, 25); t.BorderSizePixel = 1; t.BorderColor3 = Color3.fromRGB(40,40,40)
            t.Text = " [OFF] " .. text; t.TextColor3 = Color3.fromRGB(150, 150, 150); t.Font = "Code"; t.TextSize = 12; t.TextXAlignment = "Left"
            
            t.MouseButton1Click:Connect(function()
                state = not state
                t.Text = state and " [ON] " .. text or " [OFF] " .. text
                t.TextColor3 = state and Lib.MainColor or Color3.fromRGB(150, 150, 150)
                callback(state)
            end)
        end

        function Elements:Slider(text, min, max, def, callback)
            local s = Instance.new("Frame", AreaFrame)
            s.Size = UDim2.new(1, -5, 0, 40); s.BackgroundColor3 = Color3.fromRGB(25, 25, 25); s.BorderSizePixel = 1; s.BorderColor3 = Color3.fromRGB(40,40,40)
            
            local l = Instance.new("TextLabel", s)
            l.Text = " " .. text .. ": " .. def; l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1; l.TextColor3 = Color3.new(1,1,1); l.Font = "Code"; l.TextSize = 11; l.TextXAlignment = "Left"
            
            local b = Instance.new("Frame", s)
            b.Size = UDim2.new(0.9, 0, 0, 2); b.Position = UDim2.new(0.05, 0, 0.75, 0); b.BackgroundColor3 = Color3.fromRGB(60,60,60); b.BorderSizePixel = 0
            
            local f = Instance.new("Frame", b)
            f.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); f.BackgroundColor3 = Lib.MainColor; f.BorderSizePixel = 0
            
            local knob = Instance.new("Frame", b)
            knob.Size = UDim2.new(0, 8, 0, 8); knob.Position = UDim2.new((def-min)/(max-min), -4, 0.5, -4); knob.BackgroundColor3 = Color3.new(1,1,1); knob.BorderSizePixel = 0

            local drag = false
            local function update(input)
                local p = math.clamp((input.Position.X - b.AbsolutePosition.X) / b.AbsoluteSize.X, 0, 1)
                local v = math.floor(min + (max-min)*p)
                f.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, -4, 0.5, -4)
                l.Text = " " .. text .. ": " .. v
                callback(v)
            end
            s.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true update(i) end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
        end

        function Elements:Box(placeholder, callback)
            local box = Instance.new("TextBox", AreaFrame)
            box.Size = UDim2.new(1, -5, 0, 28); box.BackgroundColor3 = Color3.fromRGB(20, 20, 20); box.BorderSizePixel = 1; box.BorderColor3 = Color3.fromRGB(45, 45, 45)
            box.PlaceholderText = placeholder; box.Text = ""; box.TextColor3 = Color3.new(1,1,1); box.Font = "Code"; box.TextSize = 12
            box.FocusLost:Connect(function() callback(box.Text) end)
        end

        function Elements:Dropdown(text, list, callback)
            local d = Instance.new("TextButton", AreaFrame)
            d.Size = UDim2.new(1, -5, 0, 28); d.BackgroundColor3 = Color3.fromRGB(25, 25, 25); d.BorderSizePixel = 1; d.BorderColor3 = Color3.fromRGB(40,40,40)
            d.Text = " " .. text .. " >"; d.TextColor3 = Color3.new(1,1,1); d.Font = "Code"; d.TextSize = 12; d.TextXAlignment = "Left"
            local cur = 0
            d.MouseButton1Click:Connect(function()
                cur = (cur % #list) + 1
                d.Text = " " .. text .. " [" .. list[cur] .. "]"
                callback(list[cur])
            end)
        end
        
        function Elements:PlayerSelector(t, c) self:Dropdown(t, (function() local p={} for _,v in pairs(players:GetPlayers()) do table.insert(p, v.Name) end return p end)(), function(v) c(players:FindFirstChild(v)) end) end

        function Elements:Logs(h)
            local sc = Instance.new("ScrollingFrame", AreaFrame)
            sc.Size = UDim2.new(1, -5, 0, h or 100); sc.BackgroundColor3 = Color3.new(0,0,0); sc.BorderSizePixel = 1; sc.BorderColor3 = Color3.fromRGB(40,40,40); sc.AutomaticCanvasSize = "Y"
            Instance.new("UIListLayout", sc)
            local log = {}
            function log:Log(m, col)
                local l = Instance.new("TextLabel", sc)
                l.Size = UDim2.new(1,0,0,15); l.Text = " > "..m; l.TextColor3 = col or Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Font = "Code"; l.TextSize = 10; l.TextXAlignment = "Left"
            end
            function log:Clear() for _, v in pairs(sc:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end end
            return log
        end

        return Elements
    end

    function Lib:SetColor(c) Lib.MainColor = c; AccentBar.BackgroundColor3 = c end
    function Lib:GetThemes() return {"Crimson", "Classic", "Emerald"}, {Crimson=Color3.fromRGB(220, 20, 60), Classic=Color3.fromRGB(0, 170, 255), Emerald=Color3.fromRGB(0, 200, 100)} end
    function Lib:AutoSaveLuay() end

    return Lib
end

return luayV2
