--[[
    luayV2 UI LIBRARY - ULTIMATE EDITION
    Version: 3.0.0
    Features: 
    - Responsive Sliders (Touch/Mouse)
    - Advanced Logging System
    - Player Selection Lists
    - Auto-Save & Theme Engine
    - Complete Cleanup on Close
    - 50+ Color Presets
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
    local dragging = nil
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
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
            update(input)
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
    local togglesActive = {} -- Para desligar tudo ao fechar
    local connectionList = {} -- Para desconectar eventos ao fechar

    -- Color Engine
    local ColorPresets = {
        ["Default"] = Color3.fromRGB(0, 170, 255), ["Red"] = Color3.fromRGB(255, 50, 50),
        ["Green"] = Color3.fromRGB(50, 255, 100), ["Purple"] = Color3.fromRGB(170, 0, 255),
        ["Pink"] = Color3.fromRGB(255, 0, 150), ["Orange"] = Color3.fromRGB(255, 120, 0),
        ["Yellow"] = Color3.fromRGB(255, 220, 0), ["Cyan"] = Color3.fromRGB(0, 255, 255),
        ["White"] = Color3.fromRGB(255, 255, 255), ["Crimson"] = Color3.fromRGB(220, 20, 60),
        ["Lime"] = Color3.fromRGB(191, 255, 0), ["Gold"] = Color3.fromRGB(255, 215, 0),
        ["Navy"] = Color3.fromRGB(0, 0, 128), ["Magenta"] = Color3.fromRGB(255, 0, 255)
    }
    for i = 1, 40 do 
        ColorPresets["Theme_"..i] = Color3.fromHSV(i/40, 0.7, 0.9) 
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
    if Configs._MainColorR then
        mainColor = Color3.new(Configs._MainColorR, Configs._MainColorG, Configs._MainColorB)
    end

    -- Main UI Structure
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
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
    MakeDraggable(TopBar, MainFrame)

    local MenuAccent = Instance.new("Frame")
    MenuAccent.Size = UDim2.new(1, 0, 0, 2)
    MenuAccent.Position = UDim2.new(0, 0, 1, -2)
    MenuAccent.BackgroundColor3 = mainColor
    MenuAccent.BorderSizePixel = 0
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
    SubtitleLabel.Text = "INICIALIZANDO..."
    SubtitleLabel.TextColor3 = mainColor
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Code
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = TopBar

    -- Window Controls
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

    -- Total Cleanup Logic
    CloseBtn.MouseButton1Click:Connect(function()
        -- Desligar todos os callbacks ativos (Toggles)
        for name, callback in pairs(togglesActive) do
            pcall(function() callback(false) end)
        end
        -- Limpar conexões
        for _, conn in pairs(connectionList) do
            if conn.Disconnect then conn:Disconnect() end
        end
        -- Destruir GUI
        ScreenGui:Destroy()
        -- Limpar script
        luayV2 = nil
    end)

    -- Minimize Logic
    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 380)
        
        if isMinimized then
            Sidebar.Visible = false
            Container.Visible = false
            SideAccent.Visible = false
        else
            task.delay(0.2, function()
                Sidebar.Visible = true
                Container.Visible = true
                SideAccent.Visible = true
            end)
        end
        
        TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
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
        AreaBtn.Image = "rbxassetid://" .. (imageId or "4483345998")
        AreaBtn.Parent = Sidebar
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = AreaBtn

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
            SubtitleLabel.Text = name:upper()
            
            local tw = TweenService:Create(AreaBtn, TweenInfo.new(0.3), {BackgroundColor3 = mainColor})
            tw:Play()
            task.delay(0.2, function()
                TweenService:Create(AreaBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
            end)
        end)

        if not currentArea then 
            AreaFrame.Visible = true 
            currentArea = true 
            SubtitleLabel.Text = name:upper()
        end

        local Elements = {}

        -- BUTTON
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            btn.Text = "  " .. text .. "  [+]"
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.AutoButtonColor = true
            btn.Parent = AreaFrame
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(callback)
            
            return btn
        end

        -- TOGGLE
        function Elements:Toggle(text, callback)
            local state = Configs[text] or false
            togglesActive[text] = callback

            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.95, 0, 0, 32)
            tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBtn.Text = ""
            tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.Code
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = tBtn

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 34, 0, 18)
            box.Position = UDim2.new(1, -44, 0.5, -9)
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            box.Parent = tBtn
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            knob.BackgroundColor3 = state and mainColor or Color3.fromRGB(150, 150, 150)
            knob.Parent = box
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local function toggle()
                state = not state
                local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                local targetColor = state and mainColor or Color3.fromRGB(150, 150, 150)
                
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetPos, BackgroundColor3 = targetColor}):Play()
                label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                
                SaveData[text] = state
                if internalAutoSave then SaveToFile() end
                task.spawn(function() callback(state) end)
            end

            tBtn.MouseButton1Click:Connect(toggle)
            if Configs[text] then task.spawn(function() callback(state) end) end
        end

        -- RESPONSIVE SLIDER (KNOB VERSION)
        function Elements:Slider(text, min, max, default, callback)
            local saved = Configs[text] or default
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 50)
            sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Text = "  " .. text:upper()
            label.Size = UDim2.new(1, 0, 0, 25)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(180, 180, 180)
            label.Font = Enum.Font.Code
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sFrame

            local valLabel = Instance.new("TextLabel")
            valLabel.Text = tostring(saved)
            valLabel.Size = UDim2.new(0, 40, 0, 25)
            valLabel.Position = UDim2.new(1, -45, 0, 0)
            valLabel.BackgroundTransparency = 1
            valLabel.TextColor3 = mainColor
            valLabel.Font = Enum.Font.Code
            valLabel.TextSize = 11
            valLabel.Parent = sFrame

            local barContainer = Instance.new("TextButton") -- Button to capture clicks easily
            barContainer.Size = UDim2.new(0.9, 0, 0, 6)
            barContainer.Position = UDim2.new(0.05, 0, 0.7, 0)
            barContainer.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            barContainer.Text = ""
            barContainer.AutoButtonColor = false
            barContainer.Parent = sFrame
            Instance.new("UICorner", barContainer).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((saved-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor
            fill.BorderSizePixel = 0
            fill.Parent = barContainer
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new((saved-min)/(max-min), -7, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.Parent = barContainer
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local function update(input)
                local sizeX = math.clamp((input.Position.X - barContainer.AbsolutePosition.X) / barContainer.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * sizeX)
                
                fill.Size = UDim2.new(sizeX, 0, 1, 0)
                knob.Position = UDim2.new(sizeX, -7, 0.5, -7)
                valLabel.Text = tostring(value)
                
                SaveData[text] = value
                if internalAutoSave then SaveToFile() end
                callback(value)
            end

            local dragging = false
            barContainer.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            task.spawn(function() callback(saved) end)
        end

        -- PLAYER SELECTOR
        function Elements:PlayerSelector(text, callback)
            local selectedPlayer = nil
            local pFrame = Instance.new("Frame")
            pFrame.Size = UDim2.new(0.95, 0, 0, 65)
            pFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            pFrame.Parent = AreaFrame
            Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 4)

            local pLabel = Instance.new("TextLabel")
            pLabel.Text = "  SELECT PLAYER: NONE"
            pLabel.Size = UDim2.new(1, 0, 0, 25)
            pLabel.BackgroundTransparency = 1
            pLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            pLabel.Font = Enum.Font.Code
            pLabel.TextSize = 10
            pLabel.TextXAlignment = Enum.TextXAlignment.Left
            pLabel.Parent = pFrame

            local scroll = Instance.new("ScrollingFrame")
            scroll.Size = UDim2.new(0.9, 0, 0, 30)
            scroll.Position = UDim2.new(0.05, 0, 0.45, 0)
            scroll.BackgroundTransparency = 1
            scroll.ScrollBarThickness = 2
            scroll.CanvasSize = UDim2.new(2, 0, 0, 0)
            scroll.Parent = pFrame
            
            local sLayout = Instance.new("UIListLayout")
            sLayout.FillDirection = Enum.FillDirection.Horizontal
            sLayout.Padding = UDim.new(0, 5)
            sLayout.Parent = scroll

            local function refresh()
                for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, p in pairs(players:GetPlayers()) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(0, 80, 1, 0)
                    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    b.Text = p.DisplayName
                    b.TextColor3 = Color3.fromRGB(255, 255, 255)
                    b.Font = Enum.Font.Code
                    b.TextSize = 10
                    b.Parent = scroll
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                    
                    b.MouseButton1Click:Connect(function()
                        selectedPlayer = p
                        pLabel.Text = "  SELECT PLAYER: " .. p.Name:upper()
                        callback(p)
                    end)
                end
            end

            refresh()
            players.PlayerAdded:Connect(refresh)
            players.PlayerRemoving:Connect(refresh)
        end

        -- KEYBIND
        function Elements:Keybind(text, default, callback)
            local key = default or Enum.KeyCode.RightControl
            local binding = false

            local kBtn = Instance.new("TextButton")
            kBtn.Size = UDim2.new(0.95, 0, 0, 32)
            kBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            kBtn.Text = "  " .. text .. " [" .. key.Name .. "]"
            kBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            kBtn.Font = Enum.Font.Code
            kBtn.TextSize = 11
            kBtn.TextXAlignment = Enum.TextXAlignment.Left
            kBtn.Parent = AreaFrame
            Instance.new("UICorner", kBtn).CornerRadius = UDim.new(0, 4)

            kBtn.MouseButton1Click:Connect(function()
                binding = true
                kBtn.Text = "  " .. text .. " [...]"
            end)

            local conn = UserInputService.InputBegan:Connect(function(input)
                if binding then
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        binding = false
                        kBtn.Text = "  " .. text .. " [" .. key.Name .. "]"
                    end
                else
                    if input.KeyCode == key then
                        callback()
                    end
                end
            end)
            table.insert(connectionList, conn)
        end

        -- TEXTBOX
        function Elements:Box(placeholder, callback)
            local tBox = Instance.new("TextBox")
            tBox.Size = UDim2.new(0.95, 0, 0, 32)
            tBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBox.PlaceholderText = placeholder .. "..."
            tBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
            tBox.Text = Configs[placeholder] or ""
            tBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            tBox.Font = Enum.Font.Code
            tBox.TextSize = 12
            tBox.Parent = AreaFrame
            Instance.new("UICorner", tBox).CornerRadius = UDim.new(0, 4)

            tBox.FocusLost:Connect(function()
                SaveData[placeholder] = tBox.Text
                if internalAutoSave then SaveToFile() end
                callback(tBox.Text)
            end)
        end

        return Elements
    end

    -- lista
function Elements:Section(title, callback)
    local opened = false

    -- Frame principal
    local sectionFrame = Instance.new("Frame")
    sectionFrame.Size = UDim2.new(1, -12, 0, 40)
    sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
    sectionFrame.BackgroundTransparency = 1
    sectionFrame.Parent = Container

    -- Botão do header
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextColor3 = Color3.fromRGB(230,230,230)
    header.Text = "   "..title
    header.Parent = sectionFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = header

    -- Ícone > ^
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(1, -30, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 14
    arrow.TextColor3 = Color3.fromRGB(200,200,200)
    arrow.Text = ">"
    arrow.Parent = header

    -- Container interno
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -12, 0, 0)
    content.Position = UDim2.new(0, 6, 0, 45)
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = sectionFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.Parent = content

    -- Toggle abrir / fechar
    header.MouseButton1Click:Connect(function()
        opened = not opened
        content.Visible = opened
        arrow.Text = opened and "^" or ">"
    end)

    -- Sub-elements usam o mesmo sistema da Area
    local SectionElements = {}

    setmetatable(SectionElements, {
        __index = function(_, key)
            if Elements[key] then
                return function(_, ...)
                    local oldContainer = Container
                    Container = content
                    local result = Elements[key](Elements, ...)
                    Container = oldContainer
                    return result
                end
            end
        end
    })

    if callback then
        callback(SectionElements)
    end
end

return Lib
end

return luayV2
