--[[
    luayV2 UI LIBRARY
    Version: 2.1.0
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
    local activeElements = {}

    -- Tabela de Cores (50 Cores para o Dropdown de Temas)
    local ColorPresets = {
        ["Default"] = Color3.fromRGB(0, 170, 255), ["Red"] = Color3.fromRGB(255, 50, 50),
        ["Green"] = Color3.fromRGB(50, 255, 100), ["Purple"] = Color3.fromRGB(170, 0, 255),
        ["Pink"] = Color3.fromRGB(255, 0, 150), ["Orange"] = Color3.fromRGB(255, 120, 0),
        ["Yellow"] = Color3.fromRGB(255, 220, 0), ["Cyan"] = Color3.fromRGB(0, 255, 255),
        ["White"] = Color3.fromRGB(255, 255, 255), ["Silver"] = Color3.fromRGB(180, 180, 180),
        ["DarkGray"] = Color3.fromRGB(40, 40, 40), ["Crimson"] = Color3.fromRGB(220, 20, 60),
        ["Lime"] = Color3.fromRGB(191, 255, 0), ["Gold"] = Color3.fromRGB(255, 215, 0),
        ["SkyBlue"] = Color3.fromRGB(135, 206, 235), ["Violet"] = Color3.fromRGB(238, 130, 238),
        ["Brown"] = Color3.fromRGB(165, 42, 42), ["Tan"] = Color3.fromRGB(210, 180, 140),
        -- Adicionando variações automáticas para chegar próximo a 50
    }
    for i = 1, 32 do ColorPresets["Variation_"..i] = Color3.fromHSV(i/32, 0.8, 1) end

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

    -- UI Principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_UI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    -- Cantos Arredondados
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    -- Accent Bars (Solicitadas)
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
    SubtitleLabel.Text = "PRINCIPAL"
    SubtitleLabel.TextColor3 = mainColor
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Code
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = TopBar

    -- Buttons Control
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

    -- Container e Sidebar
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

    -- Minimize Logic (Corrigida para esconder elementos)
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
        
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = targetSize}):Play()
    end)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

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
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = AreaBtn

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
            SubtitleLabel.Text = name:upper()
            TweenService:Create(AreaBtn, TweenInfo.new(0.2), {BackgroundColor3 = mainColor}):Play()
            task.wait(0.1)
            TweenService:Create(AreaBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
        end)

        if not currentArea then 
            AreaFrame.Visible = true 
            currentArea = true 
            SubtitleLabel.Text = name:upper()
        end

        local Elements = {}

        -- BOTÃO
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            btn.Text = "  " .. text .. "  [+]"
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = AreaFrame
            
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(callback)
        end

        -- TOGGLE
        function Elements:Toggle(text, callback)
            local state = Configs[text] or false
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
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.Code
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = tBtn

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 18, 0, 18)
            box.Position = UDim2.new(1, -28, 0.5, -9)
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            box.Parent = tBtn
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 10, 0, 10)
            check.Position = UDim2.new(0.5, -5, 0.5, -5)
            check.BackgroundColor3 = mainColor
            check.BackgroundTransparency = state and 0 or 1
            check.Parent = box
            Instance.new("UICorner", check).CornerRadius = UDim.new(0, 2)

            local function toggle()
                state = not state
                check.BackgroundTransparency = state and 0 or 1
                label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)
                SaveData[text] = state
                if internalAutoSave then SaveToFile() end
                callback(state)
            end

            tBtn.MouseButton1Click:Connect(toggle)
            if Configs[text] then task.spawn(function() callback(state) end) end
        end

        -- SLIDER
        function Elements:Slider(text, min, max, default, callback)
            local saved = Configs[text] or default
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
            valLabel.Text = tostring(saved)
            valLabel.Size = UDim2.new(0, 40, 0, 25)
            valLabel.Position = UDim2.new(1, -45, 0, 0)
            valLabel.BackgroundTransparency = 1
            valLabel.TextColor3 = mainColor
            valLabel.Font = Enum.Font.Code
            valLabel.TextSize = 10
            valLabel.Parent = sFrame

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0.9, 0, 0, 4)
            bar.Position = UDim2.new(0.05, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            bar.Parent = sFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((saved-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor
            fill.BorderSizePixel = 0
            fill.Parent = bar

            local dragging = false
            local function move(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                valLabel.Text = tostring(val)
                SaveData[text] = val
                if internalAutoSave then SaveToFile() end
                callback(val)
            end

            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true move(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then move(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            task.spawn(function() callback(saved) end)
        end

        -- DROPDOWN (LISTA)
        function Elements:Dropdown(text, list, callback)
            local open = false
            local dFrame = Instance.new("Frame")
            dFrame.Size = UDim2.new(0.95, 0, 0, 32)
            dFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            dFrame.ClipsDescendants = true
            dFrame.Parent = AreaFrame
            Instance.new("UICorner", dFrame).CornerRadius = UDim.new(0, 4)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundTransparency = 1
            btn.Text = "  " .. text .. "  [v]"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = dFrame

            local itemContainer = Instance.new("Frame")
            itemContainer.Size = UDim2.new(1, 0, 0, #list * 25)
            itemContainer.Position = UDim2.new(0, 0, 0, 32)
            itemContainer.BackgroundTransparency = 1
            itemContainer.Parent = dFrame

            local iLayout = Instance.new("UIListLayout")
            iLayout.Parent = itemContainer

            for _, name in pairs(list) do
                local iBtn = Instance.new("TextButton")
                iBtn.Size = UDim2.new(1, 0, 0, 25)
                iBtn.BackgroundTransparency = 1
                iBtn.Text = "     " .. tostring(name)
                iBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
                iBtn.Font = Enum.Font.Code
                iBtn.TextSize = 11
                iBtn.TextXAlignment = Enum.TextXAlignment.Left
                iBtn.Parent = itemContainer

                iBtn.MouseButton1Click:Connect(function()
                    open = false
                    dFrame.Size = UDim2.new(0.95, 0, 0, 32)
                    btn.Text = "  " .. text .. "  [" .. tostring(name) .. "]"
                    callback(name)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(dFrame, TweenInfo.new(0.3), {Size = open and UDim2.new(0.95, 0, 0, 35 + (#list * 25)) or UDim2.new(0.95, 0, 0, 32)}):Play()
            end)
        end

        -- CAIXA DE TEXTO (TEXTBOX)
        function Elements:Box(placeholder, callback)
            local tBox = Instance.new("TextBox")
            tBox.Size = UDim2.new(0.95, 0, 0, 32)
            tBox.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBox.PlaceholderText = placeholder .. "..."
            tBox.Text = Configs[placeholder] or ""
            tBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            tBox.Font = Enum.Font.Code
            tBox.TextSize = 12
            tBox.Parent = AreaFrame
            Instance.new("UICorner", tBox).CornerRadius = UDim.new(0, 4)

            tBox.FocusLost:Connect(function(enter)
                SaveData[placeholder] = tBox.Text
                if internalAutoSave then SaveToFile() end
                callback(tBox.Text)
            end)
        end

        return Elements
    end

    -- Funções Globais da Janela
    function Lib:SetColor(newColor)
        mainColor = newColor
        SideAccent.BackgroundColor3 = newColor
        MenuAccent.BackgroundColor3 = newColor
        SubtitleLabel.TextColor3 = newColor
        SaveData._MainColorR = newColor.r
        SaveData._MainColorG = newColor.g
        SaveData._MainColorB = newColor.b
        if internalAutoSave then SaveToFile() end
    end

    function Lib:AutoSaveLuay(v) internalAutoSave = v end
    function Lib:Save() SaveToFile() end
    function Lib:GetThemes() 
        local names = {}
        for n, _ in pairs(ColorPresets) do table.insert(names, n) end
        return names, ColorPresets
    end

    return Lib
end

return luayV2
