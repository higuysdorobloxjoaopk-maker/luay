local luayV2 = {}

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local plr = players.LocalPlayer

local function MakeDraggable(topbarobject, object)
    local dragging, dragInput, dragStart, startPos
    topbarobject.InputBegan:Connect(function(input)
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

function luayV2:Window(config)
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local Lib = {MainColor = mainColor, Closed = false}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Premium"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 320, 0, 380)
    Main.Position = UDim2.new(0.5, -160, 0.5, -190)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

    -- Barra Superior
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.Parent = Main
    local tc = Instance.new("UICorner", TopBar)
    
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 2)
    Line.Position = UDim2.new(0, 0, 1, 0)
    Line.BackgroundColor3 = mainColor
    Line.BorderSizePixel = 0
    Line.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Text = config.Name or "LUAY V2"
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = "Left"
    Title.Font = "Code"
    Title.Parent = TopBar

    -- Botões de Controle
    local Close = Instance.new("TextButton")
    Close.Size = UDim2.new(0, 30, 0, 30)
    Close.Position = UDim2.new(1, -35, 0, 5)
    Close.Text = "×"; Close.TextColor3 = Color3.new(1,0,0); Close.BackgroundTransparency = 1; Close.TextSize = 25; Close.Parent = TopBar
    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Mini = Instance.new("TextButton")
    Mini.Size = UDim2.new(0, 30, 0, 30)
    Mini.Position = UDim2.new(1, -65, 0, 5)
    Mini.Text = "—"; Mini.TextColor3 = Color3.new(1,1,1); Mini.BackgroundTransparency = 1; Mini.TextSize = 20; Mini.Parent = TopBar

    MakeDraggable(TopBar, Main)

    -- Sidebar e Container
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 50, 1, -55)
    Sidebar.Position = UDim2.new(0, 5, 0, 50)
    Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 0; Sidebar.Parent = Main
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 8)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -70, 1, -55)
    Container.Position = UDim2.new(0, 65, 0, 50)
    Container.BackgroundTransparency = 1; Container.Parent = Main

    function Lib:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.AutomaticCanvasSize = "Y"; AreaFrame.ScrollBarThickness = 2
        AreaFrame.Parent = Container
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 8)

        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 38, 0, 38)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Image = "rbxassetid://" .. (icon or "4483345998")
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaFrame.Visible = true
        end)

        if not Lib.FirstArea then AreaFrame.Visible = true; Lib.FirstArea = true end

        local Elements = {}

        -- TOGGLE DISCORD STYLE
        function Elements:Toggle(text, callback)
            local state = false
            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.95, 0, 0, 35)
            tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBtn.Text = "  " .. text; tBtn.TextColor3 = Color3.new(0.8,0.8,0.8); tBtn.TextXAlignment = "Left"; tBtn.Font = "Code"; tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn)

            local switch = Instance.new("Frame")
            switch.Size = UDim2.new(0, 36, 0, 20)
            switch.Position = UDim2.new(1, -45, 0.5, -10)
            switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            switch.Parent = tBtn
            Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 16, 0, 16)
            circle.Position = UDim2.new(0, 2, 0.5, -8)
            circle.BackgroundColor3 = Color3.new(1,1,1)
            circle.Parent = switch
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            tBtn.MouseButton1Click:Connect(function()
                state = not state
                local p = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local c = state and Lib.MainColor or Color3.fromRGB(50, 50, 50)
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = p}):Play()
                TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = c}):Play()
                callback(state)
            end)
        end

        -- SLIDER MOBILE FRIENDLY
        function Elements:Slider(text, min, max, def, callback)
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 45)
            sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22); sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame)

            local lab = Instance.new("TextLabel")
            lab.Text = "  " .. text .. ": " .. def; lab.Size = UDim2.new(1, 0, 0, 20); lab.BackgroundTransparency = 1; lab.TextColor3 = Color3.new(1,1,1); lab.Font = "Code"; lab.TextXAlignment = "Left"; lab.Parent = sFrame

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0.85, 0, 0, 4)
            bar.Position = UDim2.new(0.07, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(45,45,45); bar.Parent = sFrame
            Instance.new("UICorner", bar)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Lib.MainColor; fill.Parent = bar
            Instance.new("UICorner", fill)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12); knob.Position = UDim2.new((def-min)/(max-min), -6, 0.5, -6)
            knob.BackgroundColor3 = Color3.new(1,1,1); knob.Parent = bar
            Instance.new("UICorner", knob)

            local function update(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                knob.Position = UDim2.new(pos, -6, 0.5, -6)
                lab.Text = "  " .. text .. ": " .. val
                callback(val)
            end

            local dragging = false
            sFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true update(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        end

        function Elements:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.95, 0, 0, 32)
            b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.Text = "  " .. text; b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextXAlignment = "Left"; b.Parent = AreaFrame
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(callback)
        end

        return Elements
    end

    function Lib:SetColor(c) Lib.MainColor = c; Line.BackgroundColor3 = c end
    function Lib:AutoSaveLuay(s) end
    function Lib:GetThemes() return {"Azul", "Roxo", "Verde"}, {Azul=Color3.new(0,0.6,1), Roxo=Color3.new(0.5,0,1), Verde=Color3.new(0,1,0.5)} end

    return Lib
end

return luayV2
