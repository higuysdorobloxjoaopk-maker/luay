--[[
    luayV2 UI LIBRARY - PRO EDITION
    Version: 2.5.0
    
    Changelog:
    - Fixed Slider (Mobile/PC Friendly with Thumb)
    - Added Player Selection List with Action Buttons
    - Added Rich Console Logs (Auto-scrolling)
    - Added Keybind System
    - Added Section Labels & Dividers
    - Full Cleanup on Close (Anti-Lag)
]]

local luayV2 = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
    local connections = {} -- Para limpeza total
    local togglesAtivos = {} -- Para desligar funções ao fechar

    -- Tabela de Cores (50+ Cores)
    local ColorPresets = {
        ["Default"] = Color3.fromRGB(0, 170, 255), ["Red"] = Color3.fromRGB(255, 50, 50),
        ["Green"] = Color3.fromRGB(50, 255, 100), ["Purple"] = Color3.fromRGB(170, 0, 255),
        ["Pink"] = Color3.fromRGB(255, 0, 150), ["Orange"] = Color3.fromRGB(255, 120, 0),
        ["Yellow"] = Color3.fromRGB(255, 220, 0), ["Cyan"] = Color3.fromRGB(0, 255, 255),
        ["White"] = Color3.fromRGB(255, 255, 255), ["Midnight"] = Color3.fromRGB(15, 15, 40)
    }
    for i = 1, 40 do ColorPresets["Hue_Shift_"..i] = Color3.fromHSV(i/40, 0.7, 1) end

    -- Sistema de Arquivos
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

    -- GUI Principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Elite"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 320)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 6)
    MainCorner.Parent = MainFrame

    -- Design: Accents
    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 2, 1, 0)
    SideAccent.BackgroundColor3 = mainColor
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Container de Conteúdo
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 130, 1, -45)
    Sidebar.Position = UDim2.new(0, 5, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = Sidebar
    SideLayout.Padding = UDim.new(0, 4)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -145, 1, -50)
    Container.Position = UDim2.new(0, 140, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    -- Buttons Control
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextSize = 24
    CloseBtn.Parent = TopBar

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 40, 0, 40)
    MiniBtn.Position = UDim2.new(1, -80, 0, 0)
    MiniBtn.Text = "-"
    MiniBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.TextSize = 24
    MiniBtn.Parent = TopBar

    -- Minimize Logic
    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 450, 0, 40) or UDim2.new(0, 450, 0, 320)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.QuartOut), {Size = targetSize}):Play()
        Sidebar.Visible = not isMinimized
        Container.Visible = not isMinimized
    end)

    -- FECHAR TUDO (REQUISITO 3)
    CloseBtn.MouseButton1Click:Connect(function()
        -- Desligar todos os callbacks ativos (Toggles)
        for name, data in pairs(togglesAtivos) do
            if data.State == true then
                pcall(function() data.Callback(false) end)
            end
        end
        -- Limpar conexões de eventos
        for _, conn in pairs(connections) do conn:Disconnect() end
        -- Destruir GUI
        ScreenGui:Destroy()
    end)

    local Lib = {}

    function Lib:Area(name, icon)
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
        Layout.Padding = UDim.new(0, 6)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local AreaBtn = Instance.new("TextButton")
        AreaBtn.Size = UDim2.new(1, -10, 0, 30)
        AreaBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        AreaBtn.Text = "  " .. name
        AreaBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
        AreaBtn.Font = Enum.Font.Code
        AreaBtn.TextSize = 12
        AreaBtn.TextXAlignment = Enum.TextXAlignment.Left
        AreaBtn.Parent = Sidebar
        
        Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 4)

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do 
                if v:IsA("TextButton") then 
                    TweenService:Create(v, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 20), TextColor3 = Color3.fromRGB(180, 180, 180)}):Play() 
                end 
            end
            AreaFrame.Visible = true
            TweenService:Create(AreaBtn, TweenInfo.new(0.2), {BackgroundColor3 = mainColor, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        end)

        if not currentArea then 
            AreaFrame.Visible = true 
            currentArea = true 
            AreaBtn.BackgroundColor3 = mainColor
            AreaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local Elements = {}

        -- SEÇÃO / LABEL
        function Elements:Label(text)
            local lab = Instance.new("TextLabel")
            lab.Size = UDim2.new(0.95, 0, 0, 20)
            lab.BackgroundTransparency = 1
            lab.Text = "— " .. text:upper() .. " —"
            lab.TextColor3 = mainColor
            lab.Font = Enum.Font.Code
            lab.TextSize = 10
            lab.Parent = AreaFrame
        end

        -- BOTÃO SIMPLES
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.Parent = AreaFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            
            btn.MouseButton1Click:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = mainColor}):Play()
                task.wait(0.1)
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
                callback()
            end)
        end

        -- TOGGLE COM MEMÓRIA
        function Elements:Toggle(text, callback)
            local state = Configs[text] or false
            togglesAtivos[text] = {State = state, Callback = callback}

            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.95, 0, 0, 30)
            tBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            tBtn.Text = ""
            tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            label.Font = Enum.Font.Code
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = tBtn

            local switch = Instance.new("Frame")
            switch.Size = UDim2.new(0, 30, 0, 16)
            switch.Position = UDim2.new(1, -40, 0.5, -8)
            switch.BackgroundColor3 = state and mainColor or Color3.fromRGB(50, 50, 50)
            switch.Parent = tBtn
            Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)

            local circle = Instance.new("Frame")
            circle.Size = UDim2.new(0, 12, 0, 12)
            circle.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.Parent = switch
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

            tBtn.MouseButton1Click:Connect(function()
                state = not state
                togglesAtivos[text].State = state
                local targetPos = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
                TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = state and mainColor or Color3.fromRGB(50, 50, 50)}):Play()
                label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
                
                SaveData[text] = state
                if internalAutoSave then SaveToFile() end
                callback(state)
            end)
            
            if state then task.spawn(function() callback(true) end) end
        end

        -- SLIDER CORRIGIDO (REQUISITO 1)
        function Elements:Slider(text, min, max, default, callback)
            local val = Configs[text] or default
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 45)
            sFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Text = "  " .. text
            label.Size = UDim2.new(1, 0, 0, 20)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.Font = Enum.Font.Code
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = sFrame

            local valLabel = Instance.new("TextLabel")
            valLabel.Text = tostring(val)
            valLabel.Size = UDim2.new(0, 40, 0, 20)
            valLabel.Position = UDim2.new(1, -45, 0, 0)
            valLabel.BackgroundTransparency = 1
            valLabel.TextColor3 = mainColor
            valLabel.TextSize = 11
            valLabel.Parent = sFrame

            local container = Instance.new("TextButton")
            container.Size = UDim2.new(0.9, 0, 0, 4)
            container.Position = UDim2.new(0.05, 0, 0.75, 0)
            container.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            container.Text = ""
            container.AutoButtonColor = false
            container.Parent = sFrame
            Instance.new("UICorner", container)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor
            fill.BorderSizePixel = 0
            fill.Parent = container
            Instance.new("UICorner", fill)

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 12, 0, 12)
            thumb.Position = UDim2.new((val - min) / (max - min), -6, 0.5, -6)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            thumb.Parent = container
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function update(input)
                local x = math.clamp((input.Position.X - container.AbsolutePosition.X) / container.AbsoluteSize.X, 0, 1)
                local n = math.floor(min + (max - min) * x)
                valLabel.Text = tostring(n)
                fill.Size = UDim2.new(x, 0, 1, 0)
                thumb.Position = UDim2.new(x, -6, 0.5, -6)
                val = n
                SaveData[text] = n
                if internalAutoSave then SaveToFile() end
                callback(n)
            end

            container.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(i)
                end
            end)
            
            table.insert(connections, UserInputService.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    update(i)
                end
            end))

            table.insert(connections, UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end))
            
            task.spawn(function() callback(val) end)
        end

        -- PLAYER LIST COM AÇÃO (REQUISITO 2)
        function Elements:PlayerList(text, callback)
            local pFrame = Instance.new("Frame")
            pFrame.Size = UDim2.new(0.95, 0, 0, 120)
            pFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            pFrame.Parent = AreaFrame
            Instance.new("UICorner", pFrame)

            local pList = Instance.new("ScrollingFrame")
            pList.Size = UDim2.new(1, -10, 0.7, 0)
            pList.Position = UDim2.new(0, 5, 0, 5)
            pList.BackgroundTransparency = 1
            pList.ScrollBarThickness = 2
            pList.Parent = pFrame
            
            local pLayout = Instance.new("UIListLayout")
            pLayout.Parent = pList
            pLayout.Padding = UDim.new(0, 2)

            local selectedPlayer = nil

            local function refresh()
                for _, v in pairs(pList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, p in pairs(players:GetPlayers()) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1, 0, 0, 20)
                    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    b.Text = " " .. p.Name
                    b.TextColor3 = Color3.fromRGB(200, 200, 200)
                    b.Font = Enum.Font.Code
                    b.TextSize = 10
                    b.TextXAlignment = Enum.TextXAlignment.Left
                    b.Parent = pList
                    
                    b.MouseButton1Click:Connect(function()
                        selectedPlayer = p
                        for _, v in pairs(pList:GetChildren()) do if v:IsA("TextButton") then v.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end end
                        b.BackgroundColor3 = mainColor
                    end)
                end
            end

            local actBtn = Instance.new("TextButton")
            actBtn.Size = UDim2.new(1, -10, 0, 25)
            actBtn.Position = UDim2.new(0, 5, 0.75, 0)
            actBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            actBtn.Text = text
            actBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            actBtn.Font = Enum.Font.Code
            actBtn.Parent = pFrame

            actBtn.MouseButton1Click:Connect(function()
                if selectedPlayer then callback(selectedPlayer) end
            end)

            refresh()
            table.insert(connections, players.PlayerAdded:Connect(refresh))
            table.insert(connections, players.PlayerRemoving:Connect(refresh))
        end

        -- LOGS CONSOLE (REQUISITO 2)
        function Elements:Logs()
            local logFrame = Instance.new("ScrollingFrame")
            logFrame.Size = UDim2.new(0.95, 0, 0, 100)
            logFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            logFrame.BorderSizePixel = 1
            logFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
            logFrame.ScrollBarThickness = 2
            logFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            logFrame.Parent = AreaFrame

            Instance.new("UIListLayout", logFrame).Padding = UDim.new(0, 2)

            local LogObj = {}
            function LogObj:Add(msg, color)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, 0, 0, 18)
                l.BackgroundTransparency = 1
                l.Text = " [" .. os.date("%X") .. "] " .. msg
                l.TextColor3 = color or Color3.fromRGB(200, 200, 200)
                l.Font = Enum.Font.Code
                l.TextSize = 10
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.Parent = logFrame
                logFrame.CanvasPosition = Vector2.new(0, 9999)
            end
            return LogObj
        end

        -- KEYBIND
        function Elements:Keybind(text, default, callback)
            local key = default
            local kBtn = Instance.new("TextButton")
            kBtn.Size = UDim2.new(0.95, 0, 0, 30)
            kBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            kBtn.Text = "  " .. text .. ": " .. key.Name
            kBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            kBtn.Font = Enum.Font.Code
            kBtn.TextSize = 12
            kBtn.TextXAlignment = Enum.TextXAlignment.Left
            kBtn.Parent = AreaFrame
            Instance.new("UICorner", kBtn)

            kBtn.MouseButton1Click:Connect(function()
                kBtn.Text = "  " .. text .. " [PRESS ANY KEY]"
                local conn; conn = UserInputService.InputBegan:Connect(function(io)
                    if io.UserInputType == Enum.UserInputType.Keyboard then
                        key = io.KeyCode
                        kBtn.Text = "  " .. text .. ": " .. key.Name
                        conn:Disconnect()
                    end
                end)
            end)

            table.insert(connections, UserInputService.InputBegan:Connect(function(io, gpe)
                if not gpe and io.KeyCode == key then callback() end
            end))
        end

        return Elements
    end

    -- Funções Utilitárias da Janela
    function Lib:SetColor(newColor)
        mainColor = newColor
        SideAccent.BackgroundColor3 = newColor
        for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.ScrollBarImageColor3 = newColor end end
        SaveData._MainColorR = newColor.r
        SaveData._MainColorG = newColor.g
        SaveData._MainColorB = newColor.b
        if internalAutoSave then SaveToFile() end
    end

    function Lib:AutoSaveLuay(v) internalAutoSave = v end

    return Lib
end

return luayV2
