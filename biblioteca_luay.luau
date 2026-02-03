--[[
    luayV2 UI LIBRARY - ULTIMATE EDITION
    Version: 3.2.0
    
    CARACTERÍSTICAS:
    - Sistema de Arrastar Suave (Mobile & PC)
    - Sliders com Knob Responsivo
    - Dropdowns com Auto-Ajuste de Canvas
    - Logs em Tempo Real com Auto-Scroll
    - Seletor de Jogadores com Atualização Dinâmica
    - Gerenciamento de Temas (50+ Cores)
    - Auto-Save via JSON
    - Destruição Completa e Desligamento de Toggles ao Fechar
]]

local luayV2 = {}

-- Serviços do Roblox
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Utilitários Internos
local function GetGuiParent()
    local success, result = pcall(function() return gethui() end)
    if success then return result end
    return CoreGui
end

local function MakeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function luayV2:Window(config)
    local config = config or {}
    local windowTitle = config.Name or "luayV2"
    local accentColor = config.Color or Color3.fromRGB(0, 170, 255)
    local footerMsg = config.Footer or "luayV2 | Community Edition"
    local fileName = "luay_cfg_" .. LocalPlayer.UserId .. ".json"
    
    local Lib = {
        ActiveToggles = {},
        Connections = {},
        CurrentColor = accentColor,
        AutoSave = false,
        Data = {}
    }

    -- Engine de Cores (50+ Presets)
    local ColorPresets = {
        ["Sky Blue"] = Color3.fromRGB(0, 170, 255), ["Crimson"] = Color3.fromRGB(220, 20, 60),
        ["Lime"] = Color3.fromRGB(50, 255, 100), ["Electric Purple"] = Color3.fromRGB(170, 0, 255),
        ["Rose"] = Color3.fromRGB(255, 0, 150), ["Gold"] = Color3.fromRGB(255, 215, 0),
        ["Mint"] = Color3.fromRGB(0, 255, 150), ["Deep Orange"] = Color3.fromRGB(255, 80, 0)
    }
    for i = 1, 42 do ColorPresets["Theme Variation "..i] = Color3.fromHSV(i/42, 0.7, 0.9) end

    -- Sistema de Arquivos
    local function Save()
        if not Lib.AutoSave then return end
        local success, str = pcall(function() return HttpService:JSONEncode(Lib.Data) end)
        if success and writefile then writefile(fileName, str) end
    end

    local function Load()
        if isfile and isfile(fileName) then
            local success, content = pcall(function() return readfile(fileName) end)
            if success then return HttpService:JSONDecode(content) end
        end
        return {}
    end

    Lib.Data = Load()
    if Lib.Data._ThemeColorR then
        Lib.CurrentColor = Color3.new(Lib.Data._ThemeColorR, Lib.Data._ThemeColorG, Lib.Data._ThemeColorB)
    end

    -- Criação da Interface Base
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root_" .. math.random(100,999)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100
    ScreenGui.Parent = GetGuiParent()

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Barras de Acento
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    MakeDraggable(TopBar, MainFrame)

    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 3, 1, 0)
    SideAccent.BackgroundColor3 = Lib.CurrentColor
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = MainFrame

    local TopAccent = Instance.new("Frame")
    TopAccent.Size = UDim2.new(1, 0, 0, 2)
    TopAccent.Position = UDim2.new(0, 0, 1, -2)
    TopAccent.BackgroundColor3 = Lib.CurrentColor
    TopAccent.BorderSizePixel = 0
    TopAccent.Parent = TopBar

    -- Títulos
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 5)
    Title.Text = windowTitle:upper()
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -80, 0, 15)
    Subtitle.Position = UDim2.new(0, 15, 0, 25)
    Subtitle.Text = "SISTEMA PRONTO"
    Subtitle.TextColor3 = Lib.CurrentColor
    Subtitle.Font = Enum.Font.Code
    Subtitle.TextSize = 10
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TopBar

    -- Controles
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Font = Enum.Font.GothamMedium
    CloseBtn.TextSize = 25
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TopBar

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 35, 0, 35)
    MiniBtn.Position = UDim2.new(1, -70, 0, 5)
    MiniBtn.Text = "—"
    MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniBtn.Font = Enum.Font.GothamMedium
    MiniBtn.TextSize = 18
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.Parent = TopBar

    -- Containers
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 45, 1, -65)
    Sidebar.Position = UDim2.new(0, 8, 0, 55)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 10)

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -65, 1, -70)
    Container.Position = UDim2.new(0, 60, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    -- LOGICA DE FECHAMENTO TOTAL
    CloseBtn.MouseButton1Click:Connect(function()
        for name, callback in pairs(Lib.ActiveToggles) do
            pcall(function() callback(false) end)
        end
        for _, conn in pairs(Lib.Connections) do
            if conn.Disconnect then conn:Disconnect() end
        end
        ScreenGui:Destroy()
    end)

    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 380)
        Sidebar.Visible = not isMinimized
        Container.Visible = not isMinimized
        SideAccent.Visible = not isMinimized
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)

    local WindowLogic = {}
    local firstArea = true

    function WindowLogic:Area(name, imageId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.BorderSizePixel = 0
        AreaFrame.ScrollBarThickness = 2
        AreaFrame.ScrollBarImageColor3 = Lib.CurrentColor
        AreaFrame.Visible = false
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        AreaFrame.Parent = Container

        local Layout = Instance.new("UIListLayout")
        Layout.Parent = AreaFrame
        Layout.Padding = UDim.new(0, 8)
        Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local AreaBtn = Instance.new("ImageButton")
        AreaBtn.Size = UDim2.new(0, 32, 0, 32)
        AreaBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        AreaBtn.Image = "rbxassetid://" .. (imageId or "4483345998")
        AreaBtn.Parent = Sidebar
        Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
            Subtitle.Text = name:upper()
            TweenService:Create(AreaBtn, TweenInfo.new(0.2), {BackgroundColor3 = Lib.CurrentColor}):Play()
            task.delay(0.2, function() TweenService:Create(AreaBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play() end)
        end)

        if firstArea then
            AreaFrame.Visible = true
            Subtitle.Text = name:upper()
            firstArea = false
        end

        local Elements = {}

        -- BOTÃO
        function Elements:Button(text, callback)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.95, 0, 0, 32)
            b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            b.Text = "  " .. text .. "  [+]"
            b.TextColor3 = Color3.fromRGB(220, 220, 220)
            b.Font = Enum.Font.Code
            b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = AreaFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(callback)
        end

        -- TOGGLE
        function Elements:Toggle(text, callback)
            local state = Lib.Data[text] or false
            Lib.ActiveToggles[text] = callback

            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.95, 0, 0, 32)
            tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBtn.Text = ""
            tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

            local lab = Instance.new("TextLabel")
            lab.Size = UDim2.new(1, -50, 1, 0)
            lab.Position = UDim2.new(0, 10, 0, 0)
            lab.Text = text
            lab.TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,160)
            lab.Font = Enum.Font.Code
            lab.TextSize = 12
            lab.BackgroundTransparency = 1
            lab.TextXAlignment = Enum.TextXAlignment.Left
            lab.Parent = tBtn

            local sw = Instance.new("Frame")
            sw.Size = UDim2.new(0, 32, 0, 16)
            sw.Position = UDim2.new(1, -42, 0.5, -8)
            sw.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            sw.Parent = tBtn
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            knob.BackgroundColor3 = state and Lib.CurrentColor or Color3.fromRGB(120, 120, 120)
            knob.Parent = sw
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            tBtn.MouseButton1Click:Connect(function()
                state = not state
                local targetX = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = targetX, BackgroundColor3 = state and Lib.CurrentColor or Color3.fromRGB(120, 120, 120)}):Play()
                lab.TextColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,160)
                Lib.Data[text] = state
                Save()
                callback(state)
            end)
            if state then task.spawn(function() callback(true) end) end
        end

        -- SLIDER COM KNOB (Bolinha)
        function Elements:Slider(text, min, max, default, callback)
            local val = Lib.Data[text] or default
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 50)
            sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

            local lab = Instance.new("TextLabel")
            lab.Text = "  " .. text:upper()
            lab.Size = UDim2.new(1, 0, 0, 25)
            lab.TextColor3 = Color3.fromRGB(180, 180, 180)
            lab.Font = Enum.Font.Code
            lab.TextSize = 10
            lab.BackgroundTransparency = 1
            lab.TextXAlignment = Enum.TextXAlignment.Left
            lab.Parent = sFrame

            local vLab = Instance.new("TextLabel")
            vLab.Text = tostring(val)
            vLab.Size = UDim2.new(0, 40, 0, 25)
            vLab.Position = UDim2.new(1, -45, 0, 0)
            vLab.TextColor3 = Lib.CurrentColor
            vLab.Font = Enum.Font.Code
            vLab.TextSize = 10
            vLab.BackgroundTransparency = 1
            vLab.Parent = sFrame

            local bar = Instance.new("TextButton")
            bar.Size = UDim2.new(0.9, 0, 0, 4)
            bar.Position = UDim2.new(0.05, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            bar.Text = ""
            bar.Parent = sFrame
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = Lib.CurrentColor
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
                local perc = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local res = math.floor(min + (max - min) * perc)
                vLab.Text = tostring(res)
                fill.Size = UDim2.new(perc, 0, 1, 0)
                knob.Position = UDim2.new(perc, -6, 0.5, -6)
                Lib.Data[text] = res
                Save()
                callback(res)
            end

            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true update(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            task.spawn(function() callback(val) end)
        end

        -- DROPDOWN COM AUTO-CANVAS
        function Elements:Dropdown(text, list, callback)
            local open = false
            local list = list or {}
            local dFrame = Instance.new("Frame")
            dFrame.Size = UDim2.new(0.95, 0, 0, 32)
            dFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            dFrame.ClipsDescendants = true
            dFrame.Parent = AreaFrame
            Instance.new("UICorner", dFrame).CornerRadius = UDim.new(0, 4)

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundTransparency = 1
            b.Text = "  " .. text .. "  [V]"
            b.TextColor3 = Color3.fromRGB(180, 180, 180)
            b.Font = Enum.Font.Code
            b.TextSize = 12
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = dFrame

            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, #list * 28)
            container.Position = UDim2.new(0, 0, 0, 32)
            container.BackgroundTransparency = 1
            container.Parent = dFrame
            Instance.new("UIListLayout", container)

            for _, item in pairs(list) do
                local iBtn = Instance.new("TextButton")
                iBtn.Size = UDim2.new(1, 0, 0, 25)
                iBtn.BackgroundTransparency = 1
                iBtn.Text = "     " .. tostring(item)
                iBtn.TextColor3 = Color3.fromRGB(130, 130, 130)
                iBtn.Font = Enum.Font.Code
                iBtn.TextSize = 11
                iBtn.TextXAlignment = Enum.TextXAlignment.Left
                iBtn.Parent = container
                iBtn.MouseButton1Click:Connect(function()
                    open = false
                    TweenService:Create(dFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, 32)}):Play()
                    b.Text = "  " .. text .. "  [" .. tostring(item) .. "]"
                    callback(item)
                end)
            end

            b.MouseButton1Click:Connect(function()
                open = not open
                local targetH = open and (35 + (#list * 26)) or 32
                TweenService:Create(dFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, targetH)}):Play()
            end)
        end

        -- SISTEMA DE LOGS
        function Elements:Logs(h)
            local logSc = Instance.new("ScrollingFrame")
            logSc.Size = UDim2.new(0.95, 0, 0, h or 100)
            logSc.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            logSc.BorderSizePixel = 1
            logSc.BorderColor3 = Lib.CurrentColor
            logSc.ScrollBarThickness = 2
            logSc.AutomaticCanvasSize = Enum.AutomaticSize.Y
            logSc.Parent = AreaFrame
            Instance.new("UIListLayout", logSc).Padding = UDim.new(0, 2)

            local logObj = {}
            function logObj:Log(m, c)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, -10, 0, 16)
                l.BackgroundTransparency = 1
                l.Text = " [" .. os.date("%X") .. "] " .. m
                l.TextColor3 = c or Color3.fromRGB(200, 200, 200)
                l.Font = Enum.Font.Code
                l.TextSize = 10
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.Parent = logSc
                logSc.CanvasPosition = Vector2.new(0, 9999)
            end
            function logObj:Clear() for _, v in pairs(logSc:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end end
            return logObj
        end

        -- SELETOR DE PLAYER
        function Elements:PlayerSelector(callback)
            local pFrame = Instance.new("Frame")
            pFrame.Size = UDim2.new(0.95, 0, 0, 60)
            pFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            pFrame.Parent = AreaFrame
            Instance.new("UICorner", pFrame).CornerRadius = UDim.new(0, 4)

            local lab = Instance.new("TextLabel")
            lab.Text = "  JOGADOR: NENHUM"
            lab.Size = UDim2.new(1, 0, 0, 20)
            lab.TextColor3 = Lib.CurrentColor
            lab.Font = Enum.Font.Code
            lab.TextSize = 10
            lab.BackgroundTransparency = 1
            lab.TextXAlignment = Enum.TextXAlignment.Left
            lab.Parent = pFrame

            local sc = Instance.new("ScrollingFrame")
            sc.Size = UDim2.new(0.95, 0, 0, 30)
            sc.Position = UDim2.new(0.025, 0, 0.4, 0)
            sc.BackgroundTransparency = 1
            sc.ScrollBarThickness = 2
            sc.CanvasSize = UDim2.new(2, 0, 0, 0)
            sc.Parent = pFrame
            Instance.new("UIListLayout", sc).FillDirection = Enum.FillDirection.Horizontal

            local function Update()
                for _, v in pairs(sc:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, p in pairs(Players:GetPlayers()) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(0, 80, 1, 0)
                    b.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                    b.Text = p.DisplayName
                    b.TextColor3 = Color3.fromRGB(255, 255, 255)
                    b.Font = Enum.Font.Code
                    b.TextSize = 9
                    b.Parent = sc
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
                    b.MouseButton1Click:Connect(function()
                        lab.Text = "  JOGADOR: " .. p.Name:upper()
                        callback(p)
                    end)
                end
            end
            Update()
            Players.PlayerAdded:Connect(Update)
            Players.PlayerRemoving:Connect(Update)
        end

        -- BOX DE TEXTO
        function Elements:Box(place, callback)
            local b = Instance.new("TextBox")
            b.Size = UDim2.new(0.95, 0, 0, 32)
            b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            b.PlaceholderText = place
            b.Text = Lib.Data[place] or ""
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.Code
            b.TextSize = 12
            b.Parent = AreaFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.FocusLost:Connect(function()
                Lib.Data[place] = b.Text
                Save()
                callback(b.Text)
            end)
        end

        -- KEYBIND
        function Elements:Keybind(text, def, callback)
            local key = def or Enum.KeyCode.F
            local binding = false
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0.95, 0, 0, 32)
            b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            b.Text = "  " .. text .. "  [" .. key.Name .. "]"
            b.TextColor3 = Color3.fromRGB(200, 200, 200)
            b.Font = Enum.Font.Code
            b.TextSize = 11
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.Parent = AreaFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

            b.MouseButton1Click:Connect(function() binding = true b.Text = "  " .. text .. "  [...]" end)
            local c = UserInputService.InputBegan:Connect(function(i)
                if binding and i.UserInputType == Enum.UserInputType.Keyboard then
                    key = i.KeyCode
                    binding = false
                    b.Text = "  " .. text .. "  [" .. key.Name .. "]"
                elseif i.KeyCode == key then
                    callback()
                end
            end)
            table.insert(Lib.Connections, c)
        end

        return Elements
    end

    function WindowLogic:SetColor(c)
        Lib.CurrentColor = c
        SideAccent.BackgroundColor3 = c
        TopAccent.BackgroundColor3 = c
        Subtitle.TextColor3 = c
        Lib.Data._ThemeColorR, Lib.Data._ThemeColorG, Lib.Data._ThemeColorB = c.r, c.g, c.b
        Save()
    end
    function WindowLogic:AutoSaveLuay(v) Lib.AutoSave = v end
    function WindowLogic:GetThemes() 
        local n = {} for k,_ in pairs(ColorPresets) do table.insert(n, k) end
        return n, ColorPresets
    end

    return WindowLogic
end

return luayV2
-- criado por joao (essa Blibioteca pode ser livremente alterada ela não está ofuscada ou outros ela é algo plubico modifique se quiser)
