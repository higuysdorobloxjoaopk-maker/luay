--[[ 
    luayV2 UI LIBRARY - ULTIMATE EDITION
    Version: 3.0.0 | Lines: 800+ Target
    Developed for Mobile & PC Compatibility
]]

local luayV2 = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local plr = players.LocalPlayer
local mouse = plr:GetMouse()

-- [ UTILS ]
local function Ripple(obj)
    spawn(function()
        local mousePos = UserInputService:GetMouseLocation()
        local relPos = mousePos - obj.AbsolutePosition
        local circle = Instance.new("ImageLabel")
        circle.BackgroundTransparency = 1
        circle.Image = "rbxassetid://266543268"
        circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        circle.ImageTransparency = 0.8
        circle.Size = UDim2.new(0, 0, 0, 0)
        circle.Position = UDim2.new(0, relPos.X, 0, relPos.Y - 36)
        circle.Parent = obj
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        circle:TweenSizeAndPosition(UDim2.new(0, 200, 0, 200), UDim2.new(0, relPos.X - 100, 0, relPos.Y - 136), "Out", "Quad", 0.5, true)
        for i = 1, 10 do
            circle.ImageTransparency = 0.8 + (i * 0.02)
            task.wait(0.05)
        end
        circle:Destroy()
    end)
end

function luayV2:Window(config)
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local fileName = "luayV2_Data_" .. plr.UserId .. ".json"
    
    local SaveData = {}
    local internalAutoSave = false
    local currentArea = nil

    -- [ THEME GENERATOR ]
    local ColorPresets = {}
    for i = 0, 50 do
        ColorPresets["Theme_"..i] = Color3.fromHSV(i/50, 0.7, 1)
    end

    local function SaveToFile()
        if not internalAutoSave then return end
        local success, json = pcall(function() return HttpService:JSONEncode(SaveData) end)
        if success and writefile then writefile(fileName, json) end
    end

    local function LoadFromFile()
        if isfile and isfile(fileName) then
            local success, content = pcall(function() return readfile(fileName) end)
            if success then return HttpService:JSONDecode(content) end
        end
        return {}
    end

    local Configs = LoadFromFile()
    if Configs._GlobalColorR then
        mainColor = Color3.new(Configs._GlobalColorR, Configs._GlobalColorG, Configs._GlobalColorB)
    end

    -- [ GUI ROOT ]
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Premium"
    ScreenGui.ResetOnSpawn = false
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    -- [ DECORATION ]
    local LeftBorder = Instance.new("Frame")
    LeftBorder.Size = UDim2.new(0, 4, 1, 0)
    LeftBorder.BackgroundColor3 = mainColor
    LeftBorder.BorderSizePixel = 0
    LeftBorder.Parent = MainFrame
    Instance.new("UICorner", LeftBorder).CornerRadius = UDim.new(0, 10)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local BottomAccent = Instance.new("Frame")
    BottomAccent.Size = UDim2.new(1, 0, 0, 2)
    BottomAccent.Position = UDim2.new(0, 0, 1, -2)
    BottomAccent.BackgroundColor3 = mainColor
    BottomAccent.BorderSizePixel = 0
    BottomAccent.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 0, 30)
    Title.Position = UDim2.new(0, 20, 0, 5)
    Title.Text = title:upper()
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1
    Title.Parent = TopBar

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -100, 0, 20)
    Status.Position = UDim2.new(0, 20, 0, 25)
    Status.Text = "SISTEMA ATIVO"
    Status.TextColor3 = mainColor
    Status.Font = Enum.Font.Code
    Status.TextSize = 10
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.BackgroundTransparency = 1
    Status.Parent = TopBar

    -- [ BUTTONS ]
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -45, 0, 5)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.TextSize = 30
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TopBar
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- [ CONTENT HOLDERS ]
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 50, 1, -70)
    Sidebar.Position = UDim2.new(0, 10, 0, 60)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -80, 1, -70)
    Container.Position = UDim2.new(0, 70, 0, 60)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = Sidebar
    SideLayout.Padding = UDim.new(0, 10)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Lib = {}

    function Lib:Area(name, iconId)
        local AreaPage = Instance.new("ScrollingFrame")
        AreaPage.Size = UDim2.new(1, 0, 1, 0)
        AreaPage.BackgroundTransparency = 1
        AreaPage.Visible = false
        AreaPage.ScrollBarThickness = 2
        AreaPage.ScrollBarImageColor3 = mainColor
        AreaPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        AreaPage.Parent = Container

        local Layout = Instance.new("UIListLayout")
        Layout.Parent = AreaPage
        Layout.Padding = UDim.new(0, 8)

        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 38, 0, 38)
        TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        TabBtn.Image = "rbxassetid://" .. (iconId or "4483345998")
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaPage.Visible = true
            Status.Text = name:upper()
            Ripple(TabBtn)
        end)

        if not currentArea then AreaPage.Visible = true currentArea = true Status.Text = name:upper() end

        local Elements = {}

        -- [ ELEMENTO: BOTÃO ]
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.98, 0, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.Parent = AreaPage
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseButton1Click:Connect(function()
                Ripple(btn)
                callback()
            end)
        end

        -- [ ELEMENTO: TOGGLE ]
        function Elements:Toggle(text, callback)
            local state = Configs[text] or false
            local tMain = Instance.new("TextButton")
            tMain.Size = UDim2.new(0.98, 0, 0, 35)
            tMain.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            tMain.Text = ""
            tMain.Parent = AreaPage
            Instance.new("UICorner", tMain).CornerRadius = UDim.new(0, 6)

            local tText = Instance.new("TextLabel")
            tText.Size = UDim2.new(1, -50, 1, 0)
            tText.Position = UDim2.new(0, 12, 0, 0)
            tText.Text = text
            tText.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            tText.Font = Enum.Font.Code
            tText.TextSize = 12
            tText.TextXAlignment = Enum.TextXAlignment.Left
            tText.BackgroundTransparency = 1
            tText.Parent = tMain

            local switch = Instance.new("Frame")
            switch.Size = UDim2.new(0, 30, 0, 16)
            switch.Position = UDim2.new(1, -40, 0.5, -8)
            switch.BackgroundColor3 = state and mainColor or Color3.fromRGB(40, 40, 40)
            switch.Parent = tMain
            Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Parent = switch
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            tMain.MouseButton1Click:Connect(function()
                state = not state
                tText.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
                TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and mainColor or Color3.fromRGB(40, 40, 40)}):Play()
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
                SaveData[text] = state
                SaveToFile()
                callback(state)
            end)
            if state then task.spawn(function() callback(state) end) end
        end

        -- [ ELEMENTO: SLIDER (FIXED MOBILE/PC) ]
        function Elements:Slider(text, min, max, default, callback)
            local val = Configs[text] or default
            local sMain = Instance.new("Frame")
            sMain.Size = UDim2.new(0.98, 0, 0, 50)
            sMain.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            sMain.Parent = AreaPage
            Instance.new("UICorner", sMain).CornerRadius = UDim.new(0, 6)

            local sText = Instance.new("TextLabel")
            sText.Size = UDim2.new(1, 0, 0, 25)
            sText.Position = UDim2.new(0, 12, 0, 0)
            sText.Text = text:upper() .. ": " .. val
            sText.TextColor3 = Color3.fromRGB(200, 200, 200)
            sText.Font = Enum.Font.Code
            sText.TextSize = 10
            sText.TextXAlignment = Enum.TextXAlignment.Left
            sText.BackgroundTransparency = 1
            sText.Parent = sMain

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0.85, 0, 0, 4)
            bar.Position = UDim2.new(0.07, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            bar.Parent = sMain
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor
            fill.Parent = bar
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = UDim2.new((val-min)/(max-min), -6, 0.5, -6)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Parent = bar
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function update(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * pos)
                sText.Text = text:upper() .. ": " .. val
                fill.Size = UDim2.new(pos, 0, 1, 0)
                knob.Position = UDim2.new(pos, -6, 0.5, -6)
                SaveData[text] = val
                SaveToFile()
                callback(val)
            end

            bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            task.spawn(function() callback(val) end)
        end

        -- [ NOVO ELEMENTO: LOGS ]
        function Elements:LogSection(height)
            local logFrame = Instance.new("ScrollingFrame")
            logFrame.Size = UDim2.new(0.98, 0, 0, height or 100)
            logFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            logFrame.BorderSizePixel = 1
            logFrame.BorderColor3 = mainColor
            logFrame.ScrollBarThickness = 2
            logFrame.Parent = AreaPage
            
            local logLayout = Instance.new("UIListLayout")
            logLayout.Parent = logFrame
            logLayout.Padding = UDim.new(0, 2)

            local logFuncs = {}
            function logFuncs:Add(msg, color)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, -5, 0, 18)
                l.BackgroundTransparency = 1
                l.Text = " > " .. msg
                l.TextColor3 = color or Color3.fromRGB(200, 200, 200)
                l.Font = Enum.Font.Code
                l.TextSize = 10
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.Parent = logFrame
                logFrame.CanvasPosition = Vector2.new(0, logFrame.AbsoluteCanvasSize.Y)
            end
            return logFuncs
        end

        -- [ NOVO ELEMENTO: PLAYER SELECTOR ]
        function Elements:PlayerDropdown(callback)
            local d = "Selecionar Player"
            local playersList = {}
            for _, p in pairs(players:GetPlayers()) do table.insert(playersList, p.Name) end
            
            self:Dropdown("Player", playersList, function(sel)
                callback(players:FindFirstChild(sel))
            end)
        end

        -- [ ELEMENTO: DROPDOWN ]
        function Elements:Dropdown(text, list, callback)
            local dropped = false
            local dMain = Instance.new("Frame")
            dMain.Size = UDim2.new(0.98, 0, 0, 35)
            dMain.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            dMain.ClipsDescendants = true
            dMain.Parent = AreaPage
            Instance.new("UICorner", dMain).CornerRadius = UDim.new(0, 6)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundTransparency = 1
            btn.Text = text .. "  ▼"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.Parent = dMain

            local itemHolder = Instance.new("Frame")
            itemHolder.Size = UDim2.new(1, 0, 0, #list * 30)
            itemHolder.Position = UDim2.new(0, 0, 0, 35)
            itemHolder.BackgroundTransparency = 1
            itemHolder.Parent = dMain

            local iLayout = Instance.new("UIListLayout")
            iLayout.Parent = itemHolder

            for _, val in pairs(list) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 30)
                item.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
                item.BorderSizePixel = 0
                item.Text = tostring(val)
                item.TextColor3 = Color3.fromRGB(150, 150, 150)
                item.Font = Enum.Font.Code
                item.TextSize = 11
                item.Parent = itemHolder
                item.MouseButton1Click:Connect(function()
                    dropped = false
                    dMain:TweenSize(UDim2.new(0.98, 0, 0, 35), "Out", "Quad", 0.3, true)
                    btn.Text = text .. " [" .. tostring(val) .. "]"
                    callback(val)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                dropped = not dropped
                local target = dropped and UDim2.new(0.98, 0, 0, 35 + (#list * 30)) or UDim2.new(0.98, 0, 0, 35)
                dMain:TweenSize(target, "Out", "Quad", 0.3, true)
            end)
        end

        return Elements
    end

    function Lib:SetColor(newColor)
        mainColor = newColor
        LeftBorder.BackgroundColor3 = newColor
        BottomAccent.BackgroundColor3 = newColor
        Status.TextColor3 = newColor
        SaveData._GlobalColorR = newColor.r
        SaveData._GlobalColorG = newColor.g
        SaveData._GlobalColorB = newColor.b
        SaveToFile()
    end

    function Lib:AutoSaveLuay(b) internalAutoSave = b end
    function Lib:GetThemes() return ColorPresets end

    return Lib
end

return luayV2
