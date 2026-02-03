--[[
luayV2 UI LIBRARY - ULTIMATE EDITION (FIXED & EXPANDED)
]]

local luayV2 = {}

-- Services
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

-- Utility Functions
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
    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function luayV2:Window(config)
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local footerText = config.Footer or "luayV2 | Premium"
    local fileName = "luayV2_Config_" .. plr.UserId .. ".json"

    local SaveData = {}  
    local internalAutoSave = false  
    local currentArea = nil  
    local togglesActive = {} 
    local connectionList = {} 

    -- Color Engine & Themes
    local ColorPresets = {  
        ["Padrão"] = Color3.fromRGB(0, 170, 255), ["Vermelho"] = Color3.fromRGB(255, 50, 50),  
        ["Verde"] = Color3.fromRGB(50, 255, 100), ["Roxo"] = Color3.fromRGB(170, 0, 255),  
        ["Rosa"] = Color3.fromRGB(255, 0, 150), ["Laranja"] = Color3.fromRGB(255, 120, 0),  
        ["Amarelo"] = Color3.fromRGB(255, 220, 0), ["Ciano"] = Color3.fromRGB(0, 255, 255)
    }

    -- Main UI Structure
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root"
    ScreenGui.ResetOnSpawn = false
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 3, 1, 0)
    SideAccent.BackgroundColor3 = mainColor
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.Parent = MainFrame
    MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 0, 25)
    TitleLabel.Position = UDim2.new(0, 15, 0, 5)
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = "Left"
    TitleLabel.Parent = TopBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(1, -80, 0, 15)
    SubtitleLabel.Position = UDim2.new(0, 15, 0, 25)
    SubtitleLabel.Text = "PRONTO"
    SubtitleLabel.TextColor3 = mainColor
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Code
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = "Left"
    SubtitleLabel.Parent = TopBar

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 45, 1, -70)
    Sidebar.Position = UDim2.new(0, 8, 0, 55)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 10)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -65, 1, -70)
    Container.Position = UDim2.new(0, 60, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    -- WINDOW METHODS
    local Window = {}

    function Window:AutoSaveLuay(state)
        internalAutoSave = state
    end

    function Window:GetThemes()
        local keys = {}
        for k, _ in pairs(ColorPresets) do table.insert(keys, k) end
        return keys, ColorPresets
    end

    function Window:SetColor(newColor)
        mainColor = newColor
        SideAccent.BackgroundColor3 = newColor
        SubtitleLabel.TextColor3 = newColor
    end

    function Window:Area(name, imageId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.ScrollBarThickness = 2
        AreaFrame.Visible = false
        AreaFrame.AutomaticCanvasSize = "Y"
        AreaFrame.Parent = Container
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 8)

        local AreaBtn = Instance.new("ImageButton")
        AreaBtn.Size = UDim2.new(0, 32, 0, 32)
        AreaBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        AreaBtn.Image = "rbxassetid://" .. (imageId or "4483345998")
        AreaBtn.Parent = Sidebar
        Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaFrame.Visible = true
            SubtitleLabel.Text = name:upper()
        end)

        if not currentArea then
            AreaFrame.Visible = true
            currentArea = AreaFrame
            SubtitleLabel.Text = name:upper()
        end

        local Elements = {}

        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            btn.Text = "  " .. text
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = "Code"
            btn.TextSize = 12
            btn.TextXAlignment = "Left"
            btn.Parent = AreaFrame
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        function Elements:Toggle(text, callback)
            local state = false
            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.95, 0, 0, 32)
            tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBtn.Text = "  " .. text
            tBtn.TextColor3 = Color3.new(0.8, 0.8, 0.8)
            tBtn.Font = "Code"
            tBtn.TextSize = 12
            tBtn.TextXAlignment = "Left"
            tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn)

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 34, 0, 18)
            box.Position = UDim2.new(1, -44, 0.5, -9)
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            box.Parent = tBtn
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new(0, 2, 0.5, -7)
            knob.BackgroundColor3 = Color3.new(0.6,0.6,0.6)
            knob.Parent = box
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            tBtn.MouseButton1Click:Connect(function()
                state = not state
                local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = state and mainColor or Color3.new(0.6,0.6,0.6)}):Play()
                callback(state)
            end)
        end

        function Elements:Slider(text, min, max, default, callback)
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 50)
            sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame)

            local label = Instance.new("TextLabel")
            label.Text = "  " .. text:upper()
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(0.7,0.7,0.7)
            label.Font = "Code"; label.TextSize = 11; label.TextXAlignment = "Left"; label.Parent = sFrame

            local bar = Instance.new("TextButton")
            bar.Size = UDim2.new(0.9, 0, 0, 6)
            bar.Position = UDim2.new(0.05, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
            bar.Text = ""; bar.Parent = sFrame
            Instance.new("UICorner", bar)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor; fill.Parent = bar
            Instance.new("UICorner", fill)

            local dragging = false
            local function update(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + (max - min) * pos)
                callback(val)
            end

            bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(input) end end)
            UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end end)
            UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
        end

        function Elements:Box(placeholder, callback)
            local tBox = Instance.new("TextBox")
            tBox.Size = UDim2.new(0.95, 0, 0, 32)
            tBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBox.PlaceholderText = placeholder
            tBox.TextColor3 = Color3.new(1,1,1)
            tBox.Font = "Code"; tBox.TextSize = 12; tBox.Parent = AreaFrame
            Instance.new("UICorner", tBox)
            tBox.FocusLost:Connect(function() callback(tBox.Text) end)
        end

        function Elements:Dropdown(text, list, callback)
            local drop = Instance.new("TextButton")
            drop.Size = UDim2.new(0.95, 0, 0, 32)
            drop.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            drop.Text = "  " .. text .. " [SELECIONE]"
            drop.TextColor3 = Color3.new(0.8,0.8,0.8)
            drop.TextXAlignment = "Left"; drop.Font = "Code"; drop.Parent = AreaFrame
            Instance.new("UICorner", drop)

            drop.MouseButton1Click:Connect(function()
                -- Lógica simplificada: Alterna entre os itens da lista a cada clique
                local current = table.find(list, drop.Text:split("]")[1]:split("[")[2]) or 0
                local nextIdx = (current % #list) + 1
                drop.Text = "  " .. text .. " [" .. list[nextIdx] .. "]"
                callback(list[nextIdx])
            end)
        end

        function Elements:PlayerSelector(text, callback)
            self:Dropdown(text, (function() 
                local t = {} for _, p in pairs(players:GetPlayers()) do table.insert(t, p.Name) end return t 
            end)(), function(val) callback(players:FindFirstChild(val)) end)
        end

        function Elements:Keybind(text, default, callback)
            local key = default
            local btn = self:Button(text .. " [" .. key.Name .. "]", function() end)
            local waiting = false
            btn.MouseButton1Click:Connect(function() btn.Text = "..."; waiting = true end)
            UserInputService.InputBegan:Connect(function(input)
                if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode; waiting = false
                    btn.Text = "  " .. text .. " [" .. key.Name .. "]"
                elseif not waiting and input.KeyCode == key then
                    callback()
                end
            end)
        end

        function Elements:Logs(h)
            local logFrame = Instance.new("ScrollingFrame")
            logFrame.Size = UDim2.new(0.95, 0, 0, h or 100)
            logFrame.BackgroundColor3 = Color3.new(0,0,0)
            logFrame.Parent = AreaFrame
            Instance.new("UIListLayout", logFrame)
            
            local logObj = {}
            function logObj:Log(msg, color)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1,0,0,18); l.Text = " > " .. msg
                l.TextColor3 = color or Color3.new(1,1,1)
                l.BackgroundTransparency = 1; l.Font = "Code"; l.TextSize = 10
                l.TextXAlignment = "Left"; l.Parent = logFrame
            end
            function logObj:Clear() for _, v in pairs(logFrame:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end end
            return logObj
        end

        return Elements
    end

    return Window
end

return luayV2
