--[[
    luayV2 UI LIBRARY - PROFESSIONAL EDITION
    Version: 2.1.5
    Maintaining Original Dimensions: 280x380
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
    local fileName = "luayV2_Config_" .. plr.UserId .. ".json"
    
    local SaveData = {}
    local internalAutoSave = false
    local currentArea = nil
    local connections = {} 
    local activeToggles = {}
    local taskThreads = {}

    -- 50+ Cores para o sistema de temas
    local ColorPresets = {
        ["Default"] = Color3.fromRGB(0, 170, 255), ["Crimson"] = Color3.fromRGB(220, 20, 60),
        ["Lime"] = Color3.fromRGB(50, 255, 50), ["Gold"] = Color3.fromRGB(255, 215, 0),
        ["DeepSea"] = Color3.fromRGB(0, 50, 150), ["Blood"] = Color3.fromRGB(150, 0, 0),
        ["Forest"] = Color3.fromRGB(34, 139, 34), ["Cyber"] = Color3.fromRGB(255, 0, 255)
    }
    for i = 1, 42 do ColorPresets["Gradient_"..i] = Color3.fromHSV(i/42, 0.7, 0.9) end

    -- Sistema Interno de Configuração
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

    -- Renderização da MainFrame (DIMENSÕES ORIGINAIS PRESERVADAS)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_UI"
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 280, 0, 380) -- DIMENSÃO EXATA SOLICITADA
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    -- Decoração (Original)
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
    TitleLabel.Font = Enum.Font.Code; TitleLabel.TextSize = 15; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.Parent = TopBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(1, -80, 0, 15)
    SubtitleLabel.Position = UDim2.new(0, 15, 0, 25)
    SubtitleLabel.Text = "PRINCIPAL"
    SubtitleLabel.TextColor3 = mainColor
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Code; SubtitleLabel.TextSize = 11; SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left; SubtitleLabel.Parent = TopBar

    -- Controle de Janela
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextSize = 25; CloseBtn.Parent = TopBar

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 35, 0, 35); MiniBtn.Position = UDim2.new(1, -70, 0, 5)
    MiniBtn.Text = "—"; MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255); MiniBtn.BackgroundTransparency = 1
    MiniBtn.TextSize = 18; MiniBtn.Parent = TopBar

    -- Sidebar e Container
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 45, 1, -70); Sidebar.Position = UDim2.new(0, 8, 0, 55)
    Sidebar.BackgroundTransparency = 1; Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 0; Sidebar.Parent = MainFrame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -65, 1, -70); Container.Position = UDim2.new(0, 60, 0, 55)
    Container.BackgroundTransparency = 1; Container.Parent = MainFrame

    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 10)

    -- FECHAMENTO E LIMPEZA TOTAL (REQUISITO)
    CloseBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(activeToggles) do if t.State then pcall(function() t.Callback(false) end) end end
        for _, c in pairs(connections) do c:Disconnect() end
        for _, thr in pairs(taskThreads) do pcall(function() task.cancel(thr) end) end
        ScreenGui:Destroy()
    end)

    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 380)
        if isMinimized then Sidebar.Visible = false; Container.Visible = false; SideAccent.Visible = false
        else task.delay(0.2, function() Sidebar.Visible = true; Container.Visible = true; SideAccent.Visible = true end) end
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.QuartOut), {Size = targetSize}):Play()
    end)

    local Lib = {}

    function Lib:Area(name, imageId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.BorderSizePixel = 0
        AreaFrame.ScrollBarThickness = 2; AreaFrame.ScrollBarImageColor3 = mainColor; AreaFrame.Visible = false
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; AreaFrame.Parent = Container
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 8)
        
        local AreaBtn = Instance.new("ImageButton")
        AreaBtn.Size = UDim2.new(0, 32, 0, 32); AreaBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        AreaBtn.Image = "rbxassetid://" .. (imageId or "0"); AreaBtn.Parent = Sidebar
        Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true; SubtitleLabel.Text = name:upper()
        end)

        if not currentArea then AreaFrame.Visible = true; currentArea = true; SubtitleLabel.Text = name:upper() end

        local Elements = {}

        -- ELEMENTO: LABEL / SEÇÃO
        function Elements:Label(text)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(0.95, 0, 0, 20); l.BackgroundTransparency = 1; l.Text = text:upper()
            l.TextColor3 = mainColor; l.Font = Enum.Font.Code; l.TextSize = 10; l.Parent = AreaFrame
        end

        -- ELEMENTO: BOTÃO
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            btn.Text = "  " .. text .. "  [+]"; btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = AreaFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.MouseButton1Click:Connect(callback)
        end

        -- ELEMENTO: TOGGLE
        function Elements:Toggle(text, callback)
            local state = Configs[text] or false
            activeToggles[text] = {State = state, Callback = callback}
            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.95, 0, 0, 32); tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBtn.Text = ""; tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -40, 1, 0); label.Position = UDim2.new(0, 10, 0, 0); label.BackgroundTransparency = 1
            label.Text = text; label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
            label.Font = Enum.Font.Code; label.TextSize = 11; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = tBtn

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 18, 0, 18); box.Position = UDim2.new(1, -28, 0.5, -9); box.BackgroundColor3 = Color3.fromRGB(40, 40, 40); box.Parent = tBtn
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

            local check = Instance.new("Frame")
            check.Size = UDim2.new(0, 10, 0, 10); check.Position = UDim2.new(0.5, -5, 0.5, -5); check.BackgroundColor3 = mainColor
            check.BackgroundTransparency = state and 0 or 1; check.Parent = box; Instance.new("UICorner", check).CornerRadius = UDim.new(0, 2)

            tBtn.MouseButton1Click:Connect(function()
                state = not state; activeToggles[text].State = state
                check.BackgroundTransparency = state and 0 or 1
                label.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
                SaveData[text] = state; SaveToFile(); callback(state)
            end)
            if state then task.spawn(function() callback(true) end) end
        end

        -- ELEMENTO: SLIDER (MOBILE & THUMB)
        function Elements:Slider(text, min, max, default, callback)
            local val = Configs[text] or default
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 48); sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22); sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

            local label = Instance.new("TextLabel")
            label.Text = "  " .. text:upper(); label.Size = UDim2.new(1, 0, 0, 25); label.BackgroundTransparency = 1
            label.TextColor3 = Color3.fromRGB(150, 150, 150); label.Font = Enum.Font.Code; label.TextSize = 10; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = sFrame

            local bar = Instance.new("TextButton")
            bar.Size = UDim2.new(0.9, 0, 0, 4); bar.Position = UDim2.new(0.05, 0, 0.7, 0); bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45); bar.Text = ""; bar.AutoButtonColor = false; bar.Parent = sFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = mainColor; fill.BorderSizePixel = 0; fill.Parent = bar

            local thumb = Instance.new("Frame")
            thumb.Size = UDim2.new(0, 10, 0, 10); thumb.Position = UDim2.new((val-min)/(max-min), -5, 0.5, -5); thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255); thumb.Parent = bar
            Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            local function move(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local n = math.floor(min + (max - min) * pos)
                fill.Size = UDim2.new(pos, 0, 1, 0); thumb.Position = UDim2.new(pos, -5, 0.5, -5)
                SaveData[text] = n; SaveToFile(); callback(n)
            end

            local dragging = false
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true move(i) end end)
            table.insert(connections, UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then move(i) end end))
            table.insert(connections, UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end))
            task.spawn(function() callback(val) end)
        end

        -- ELEMENTO: DROPDOWN
        function Elements:Dropdown(text, list, callback)
            local open = false
            local dFrame = Instance.new("Frame")
            dFrame.Size = UDim2.new(0.95, 0, 0, 32); dFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22); dFrame.ClipsDescendants = true; dFrame.Parent = AreaFrame
            Instance.new("UICorner", dFrame).CornerRadius = UDim.new(0, 4)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32); btn.BackgroundTransparency = 1; btn.Text = "  " .. text .. "  [v]"; btn.TextColor3 = Color3.fromRGB(200, 200, 200); btn.Font = Enum.Font.Code; btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.Parent = dFrame

            local cont = Instance.new("Frame")
            cont.Size = UDim2.new(1, 0, 0, #list * 25); cont.Position = UDim2.new(0, 0, 0, 32); cont.BackgroundTransparency = 1; cont.Parent = dFrame
            Instance.new("UIListLayout", cont)

            for _, v in pairs(list) do
                local i = Instance.new("TextButton")
                i.Size = UDim2.new(1, 0, 0, 25); i.BackgroundTransparency = 1; i.Text = "     " .. tostring(v); i.TextColor3 = Color3.fromRGB(150, 150, 150); i.Font = Enum.Font.Code; i.TextSize = 10; i.TextXAlignment = Enum.TextXAlignment.Left; i.Parent = cont
                i.MouseButton1Click:Connect(function() open = false; dFrame.Size = UDim2.new(0.95, 0, 0, 32); btn.Text = "  "..text.." ["..tostring(v).."]"; callback(v) end)
            end

            btn.MouseButton1Click:Connect(function() open = not open; TweenService:Create(dFrame, TweenInfo.new(0.3), {Size = open and UDim2.new(0.95, 0, 0, 35 + (#list * 25)) or UDim2.new(0.95, 0, 0, 32)}):Play() end)
        end

        -- ELEMENTO: TEXT BOX
        function Elements:Box(text, callback)
            local b = Instance.new("TextBox")
            b.Size = UDim2.new(0.95, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.PlaceholderText = text.."..."; b.Text = Configs[text] or ""
            b.TextColor3 = Color3.fromRGB(255, 255, 255); b.Font = Enum.Font.Code; b.TextSize = 11; b.Parent = AreaFrame
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.FocusLost:Connect(function() SaveData[text] = b.Text; SaveToFile(); callback(b.Text) end)
        end

        -- ELEMENTO: PLAYER LIST (DYNAMIC)
        function Elements:PlayerList(text, callback)
            local pf = Instance.new("Frame")
            pf.Size = UDim2.new(0.95, 0, 0, 120); pf.BackgroundColor3 = Color3.fromRGB(18, 18, 18); pf.Parent = AreaFrame
            Instance.new("UICorner", pf)
            
            local sc = Instance.new("ScrollingFrame")
            sc.Size = UDim2.new(1, -10, 0, 80); sc.Position = UDim2.new(0, 5, 0, 5); sc.BackgroundTransparency = 1; sc.ScrollBarThickness = 2; sc.Parent = pf
            Instance.new("UIListLayout", sc).Padding = UDim.new(0, 2)

            local selected = nil
            local function refresh()
                for _, v in pairs(sc:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, p in pairs(players:GetPlayers()) do
                    local b = Instance.new("TextButton")
                    b.Size = UDim2.new(1, 0, 0, 20); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = " "..p.Name; b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.Code; b.TextSize = 10; b.TextXAlignment = Enum.TextXAlignment.Left; b.Parent = sc
                    b.MouseButton1Click:Connect(function() selected = p; for _, x in pairs(sc:GetChildren()) do if x:IsA("TextButton") then x.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end end; b.BackgroundColor3 = mainColor end)
                end
            end
            refresh(); table.insert(connections, players.PlayerAdded:Connect(refresh)); table.insert(connections, players.PlayerRemoving:Connect(refresh))

            local act = Instance.new("TextButton")
            act.Size = UDim2.new(1, -10, 0, 25); act.Position = UDim2.new(0, 5, 0, 90); act.BackgroundColor3 = Color3.fromRGB(40, 40, 40); act.Text = text; act.TextColor3 = Color3.fromRGB(255, 255, 255); act.Font = Enum.Font.Code; act.Parent = pf
            act.MouseButton1Click:Connect(function() if selected then callback(selected) end end)
        end

        -- ELEMENTO: KEYBIND
        function Elements:Keybind(text, def, callback)
            local key = def
            local kBtn = Instance.new("TextButton")
            kBtn.Size = UDim2.new(0.95, 0, 0, 32); kBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); kBtn.Text = "  "..text..": "..key.Name; kBtn.TextColor3 = Color3.fromRGB(200, 200, 200); kBtn.Font = Enum.Font.Code; kBtn.TextXAlignment = Enum.TextXAlignment.Left; kBtn.Parent = AreaFrame
            Instance.new("UICorner", kBtn)
            kBtn.MouseButton1Click:Connect(function()
                kBtn.Text = "  ...PRESS ANY KEY..."; local c; c = UserInputService.InputBegan:Connect(function(io)
                    if io.UserInputType == Enum.UserInputType.Keyboard then key = io.KeyCode; kBtn.Text = "  "..text..": "..key.Name; c:Disconnect() end
                end)
            end)
            table.insert(connections, UserInputService.InputBegan:Connect(function(io, g) if not g and io.KeyCode == key then callback() end end))
        end

        -- ELEMENTO: LOGS
        function Elements:Logs()
            local sf = Instance.new("ScrollingFrame")
            sf.Size = UDim2.new(0.95, 0, 0, 100); sf.BackgroundColor3 = Color3.fromRGB(10, 10, 10); sf.ScrollBarThickness = 2; sf.AutomaticCanvasSize = Enum.AutomaticSize.Y; sf.Parent = AreaFrame
            Instance.new("UIListLayout", sf)
            local LogObj = {}
            function LogObj:Add(msg, col)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, 0, 0, 16); l.BackgroundTransparency = 1; l.Text = " > "..msg; l.TextColor3 = col or Color3.fromRGB(200, 200, 200); l.Font = Enum.Font.Code; l.TextSize = 9; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = sf
                sf.CanvasPosition = Vector2.new(0, 9999)
            end
            return LogObj
        end

        return Elements
    end

    function Lib:SetColor(c) mainColor = c; SideAccent.BackgroundColor3 = c; MenuAccent.BackgroundColor3 = c; SubtitleLabel.TextColor3 = c end
    function Lib:AutoSaveLuay(v) internalAutoSave = v end
    function Lib:GetThemes() local n = {}; for k, _ in pairs(ColorPresets) do table.insert(n, k) end return n, ColorPresets end

    return Lib
end

return luayV2
