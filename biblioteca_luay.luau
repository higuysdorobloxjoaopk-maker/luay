--[[
    luayV2 UI LIBRARY - Version 2.1.0 (REVERTED SIZE & STYLE)
    Features: Auto-Save, Themes (50+ Colors), Anti-Glitch Minimize, Sidebar & Top Accents.
]]

local luayV2 = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local plr = players.LocalPlayer

function luayV2:Window(config)
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local footerText = config.Footer or "luayV2 | Community"
    local fileName = "luayV2_Config_" .. plr.UserId .. ".json"
    
    local SaveData = {}
    local internalAutoSave = false
    local currentArea = nil
    local connections = {} 
    local activeToggles = {}

    local ColorPresets = {
        ["Default"] = Color3.fromRGB(0, 170, 255), ["Red"] = Color3.fromRGB(255, 50, 50),
        ["Green"] = Color3.fromRGB(50, 255, 100), ["Purple"] = Color3.fromRGB(170, 0, 255),
        ["Pink"] = Color3.fromRGB(255, 0, 150), ["Orange"] = Color3.fromRGB(255, 120, 0),
        ["Yellow"] = Color3.fromRGB(255, 220, 0), ["Cyan"] = Color3.fromRGB(0, 255, 255),
        ["White"] = Color3.fromRGB(255, 255, 255)
    }
    for i = 1, 41 do ColorPresets["Var_"..i] = Color3.fromHSV(i/41, 0.8, 1) end

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

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_UI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 380) -- TAMANHO ORIGINAL VOLTOU
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 3, 1, 0)
    SideAccent.BackgroundColor3 = mainColor
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local MenuAccent = Instance.new("Frame")
    MenuAccent.Size = UDim2.new(1, 0, 0, 2)
    MenuAccent.Position = UDim2.new(0, 0, 1, -2)
    MenuAccent.BackgroundColor3 = mainColor
    MenuAccent.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 0, 25)
    TitleLabel.Position = UDim2.new(0, 15, 0, 5)
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 15
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(1, -80, 0, 15)
    SubtitleLabel.Position = UDim2.new(0, 15, 0, 25)
    SubtitleLabel.Text = "PRINCIPAL"
    SubtitleLabel.TextColor3 = mainColor
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Code
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.GothamMedium
    CloseBtn.TextSize = 25
    CloseBtn.Parent = TopBar

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 35, 0, 35)
    MiniBtn.Position = UDim2.new(1, -70, 0, 5)
    MiniBtn.Text = "—"
    MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.Font = Enum.Font.GothamMedium
    MiniBtn.TextSize = 18
    MiniBtn.Parent = TopBar

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 45, 1, -70)
    Sidebar.Position = UDim2.new(0, 8, 0, 55)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -65, 1, -70)
    Container.Position = UDim2.new(0, 60, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = Sidebar
    SideLayout.Padding = UDim.new(0, 10)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Logic: Close and Cleanup
    CloseBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(activeToggles) do if t.State then pcall(function() t.Callback(false) end) end end
        for _, c in pairs(connections) do c:Disconnect() end
        ScreenGui:Destroy()
    end)

    -- Minimize Logic
    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 380)
        if isMinimized then
            Sidebar.Visible = false; Container.Visible = false; SideAccent.Visible = false
        else
            task.delay(0.2, function() Sidebar.Visible = true; Container.Visible = true; SideAccent.Visible = true end)
        end
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = targetSize}):Play()
    end)

    local Lib = {}

    function Lib:Area(name, imageId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.BorderSizePixel = 0
        AreaFrame.ScrollBarThickness = 2
        AreaFrame.ScrollBarImageColor3 = mainColor
        AreaFrame.Visible = false
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        AreaFrame.Parent = Container

        local Layout = Instance.new("UIListLayout")
        Layout.Parent = AreaFrame
        Layout.Padding = UDim.new(0, 8)
        
        local AreaBtn = Instance.new("ImageButton")
        AreaBtn.Size = UDim2.new(0, 32, 0, 32)
        AreaBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        AreaBtn.Image = "rbxassetid://" .. (imageId or "0")
        AreaBtn.Parent = Sidebar
        Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
            SubtitleLabel.Text = name:upper()
        end)

        if not currentArea then AreaFrame.Visible = true; currentArea = true; SubtitleLabel.Text = name:upper() end

        local Elements = {}

        -- SLIDER CORRIGIDO (COM THUMB E MOBILE)
        function Elements:Slider(text, min, max, default, callback)
            local val = Configs[text] or default
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 48)
            sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Text = "  " .. text:upper()
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(150, 150, 150)
            label.Font = Enum.Font.Code
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sFrame

            local valLabel = Instance.new("TextLabel")
            valLabel.Text = tostring(val)
            valLabel.Size = UDim2.new(0, 40, 0, 25)
            valLabel.Position = UDim2.new(1, -45, 0, 0)
            valLabel.BackgroundTransparency = 1
            valLabel.TextColor3 = mainColor
            valLabel.Font = Enum.Font.Code
            valLabel.TextSize = 10
            valLabel.Parent = sFrame

            local bar = Instance.new("TextButton")
            bar.Size = UDim2.new(0.9, 0, 0, 4)
            bar.Position = UDim2.new(0.05, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            bar.Text = ""
            bar.AutoButtonColor = false
            bar.Parent = sFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor
            fill.BorderSizePixel = 0
            fill.Parent = bar

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 10, 0, 10)
            thumb.Position = UDim2.new((val-min)/(max-min), -5, 0.5, -5)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            thumb.Parent = bar
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function move(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local n = math.floor(min + (max - min) * pos)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                thumb.Position = UDim2.new(pos, -5, 0.5, -5)
                valLabel.Text = tostring(n)
                SaveData[text] = n
                if internalAutoSave then SaveToFile() end
                callback(n)
            end

            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true move(i) end end)
            table.insert(connections, UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then move(i) end end))
            table.insert(connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
            task.spawn(function() callback(val) end)
        end

        -- PLAYER LIST (ESTILO ORIGINAL)
        function Elements:PlayerList(text, callback)
            local pFrame = Instance.new("Frame")
            pFrame.Size = UDim2.new(0.95, 0, 0, 100)
            pFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            pFrame.Parent = AreaFrame
            Instance.new("UICorner", pFrame)

            local pScroll = Instance.new("ScrollingFrame")
            pScroll.Size = UDim2.new(1, -10, 0.7, 0)
            pScroll.Position = UDim2.new(0, 5, 0, 5)
            pScroll.BackgroundTransparency = 1
            pScroll.ScrollBarThickness = 2
            pScroll.Parent = pFrame
            Instance.new("UIListLayout", pScroll).Padding = UDim.new(0, 2)

            local sel = nil
            local function up()
                for _, v in pairs(pScroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, p in pairs(players:GetPlayers()) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1, 0, 0, 18)
                    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    b.Text = " " .. p.Name
                    b.TextColor3 = Color3.fromRGB(200, 200, 200)
                    b.Font = Enum.Font.Code
                    b.TextSize = 10
                    b.TextXAlignment = Enum.TextXAlignment.Left
                    b.Parent = pScroll
                    b.MouseButton1Click:Connect(function() sel = p; callback(p) end)
                end
            end
            up()
            table.insert(connections, players.PlayerAdded:Connect(up))
            table.insert(connections, players.PlayerRemoving:Connect(up))
        end

        -- RESTO DOS ELEMENTOS (BUTTON, TOGGLE, BOX, DROPDOWN)
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            btn.Text = "  " .. text .. "  [+]"
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code; btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = AreaFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(callback)
        end

        function Elements:Toggle(text, callback)
            local state = Configs[text] or false
            activeToggles[text] = {State = state, Callback = callback}
            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.95, 0, 0, 32)
            tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBtn.Text = ""; tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 1, 0); label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1; label.Text = text
            label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.Code; label.TextSize = 12; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = tBtn

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 18, 0, 18); box.Position = UDim2.new(1, -28, 0.5, -9)
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 40); box.Parent = tBtn
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 10, 0, 10); check.Position = UDim2.new(0.5, -5, 0.5, -5)
            check.BackgroundColor3 = mainColor; check.BackgroundTransparency = state and 0 or 1; check.Parent = box
            Instance.new("UICorner", check).CornerRadius = UDim.new(0, 2)

            tBtn.MouseButton1Click:Connect(function()
                state = not state
                activeToggles[text].State = state
                check.BackgroundTransparency = state and 0 or 1
                label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                SaveData[text] = state
                if internalAutoSave then SaveToFile() end
                callback(state)
            end)
            if state then task.spawn(function() callback(true) end) end
        end

        function Elements:Logs()
            local lFrame = Instance.new("ScrollingFrame")
            lFrame.Size = UDim2.new(0.95, 0, 0, 80)
            lFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            lFrame.Parent = AreaFrame
            Instance.new("UIListLayout", lFrame)
            local Log = {}
            function Log:Add(t, c)
                local txt = Instance.new("TextLabel")
                txt.Size = UDim2.new(1, 0, 0, 15); txt.BackgroundTransparency = 1
                txt.Text = " > " .. t; txt.TextColor3 = c or Color3.fromRGB(255, 255, 255)
                txt.Font = Enum.Font.Code; txt.TextSize = 10; txt.TextXAlignment = Enum.TextXAlignment.Left; txt.Parent = lFrame
            end
            return Log
        end

        return Elements
    end

    function Lib:SetColor(c) mainColor = c; SideAccent.BackgroundColor3 = c; MenuAccent.BackgroundColor3 = c; SubtitleLabel.TextColor3 = c end
    function Lib:AutoSaveLuay(v) internalAutoSave = v end
    function Lib:GetThemes() 
        local n = {}
        for k, _ in pairs(ColorPresets) do table.insert(n, k) end
        return n, ColorPresets
    end

    return Lib
end

return luayV2
