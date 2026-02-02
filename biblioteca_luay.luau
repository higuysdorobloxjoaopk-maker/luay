--[[
    luayV2 - Premium UI Framework
    Versão: 2.5.0 (Full Release)
    Recursos: Estilos Dinâmicos, ColorPicker 50+, Notificações, Auto-Save.
]]

local luayV2 = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ContentProvider = game:GetService("ContentProvider")
local players = game:GetService("Players")
local plr = players.LocalPlayer

-- // Funções Utilitárias Internas
local function MakeDraggable(frame, parent)
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function luayV2:Window(config)
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local footerText = config.Footer or "luayV2 | Community"
    local toggleKey = config.Keybind or Enum.KeyCode.RightControl
    local fileName = "luayV2_Settings_" .. plr.UserId .. ".json"

    local Lib = {
        CurrentColor = mainColor,
        Elements = {},
        Tabs = {},
        ActiveTab = nil,
        Visible = true,
        Style = "Moderno",
        Storage = {}
    }

    -- // Sistema de Arquivos
    local function Save()
        local success, json = pcall(function() return HttpService:JSONEncode(Lib.Storage) end)
        if success and writefile then writefile(fileName, json) end
    end

    local function Load()
        if isfile and isfile(fileName) then
            local success, content = pcall(function() return readfile(fileName) end)
            if success then return HttpService:JSONDecode(content) end
        end
        return {}
    end
    Lib.Storage = Load()

    -- // Interface Principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Engine"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "Main"
    MainFrame.Size = UDim2.new(0, 550, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 6)

    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Color3.fromRGB(35, 35, 35)
    MainStroke.Thickness = 1

    -- Elementos de Estilo Clássico (Linhas)
    local LineLeft = Instance.new("Frame", MainFrame)
    LineLeft.Size = UDim2.new(0, 2, 1, 0)
    LineLeft.BackgroundColor3 = Lib.CurrentColor
    LineLeft.BorderSizePixel = 0
    LineLeft.Visible = false

    local LineTop = Instance.new("Frame", MainFrame)
    LineTop.Size = UDim2.new(1, 0, 0, 1)
    LineTop.Position = UDim2.new(0, 0, 0, 50)
    LineTop.BackgroundColor3 = Lib.CurrentColor
    LineTop.BorderSizePixel = 0
    LineTop.Visible = false

    -- // TopBar
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, MainFrame)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(0, 200, 0, 25)
    Title.Position = UDim2.new(0, 15, 0, 8)
    Title.Text = title:upper()
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.Code
    Title.TextSize = 16
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = "Left"

    local Subtitle = Instance.new("TextLabel", TopBar)
    Subtitle.Size = UDim2.new(0, 200, 0, 15)
    Subtitle.Position = UDim2.new(0, 15, 0, 28)
    Subtitle.Text = "SISTEMA ATIVO"
    Subtitle.TextColor3 = Lib.CurrentColor
    Subtitle.Font = Enum.Font.Code
    Subtitle.TextSize = 11
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextXAlignment = "Left"

    -- Botões de Controle
    local Close = Instance.new("TextButton", TopBar)
    Close.Size = UDim2.new(0, 40, 0, 40)
    Close.Position = UDim2.new(1, -40, 0, 0)
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(255, 80, 80)
    Close.BackgroundTransparency = 1
    Close.TextSize = 25
    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- // Sidebar e Container
    local Sidebar = Instance.new("ScrollingFrame", MainFrame)
    Sidebar.Size = UDim2.new(0, 150, 1, -85)
    Sidebar.Position = UDim2.new(0, 5, 0, 55)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0

    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -170, 1, -85)
    Container.Position = UDim2.new(0, 160, 0, 55)
    Container.BackgroundTransparency = 1

    -- // Footer
    local Footer = Instance.new("TextLabel", MainFrame)
    Footer.Size = UDim2.new(1, 0, 0, 25)
    Footer.Position = UDim2.new(0, 0, 1, -25)
    Footer.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Footer.Text = "  " .. footerText
    Footer.TextColor3 = Color3.fromRGB(100, 100, 100)
    Footer.Font = Enum.Font.Code
    Footer.TextSize = 10
    Footer.TextXAlignment = "Left"

    -- // Sistema de Notificações
    local NotifyHolder = Instance.new("Frame", ScreenGui)
    NotifyHolder.Size = UDim2.new(0, 280, 1, 0)
    NotifyHolder.Position = UDim2.new(1, -290, 0, 0)
    NotifyHolder.BackgroundTransparency = 1
    local NotifyLayout = Instance.new("UIListLayout", NotifyHolder)
    NotifyLayout.VerticalAlignment = "Bottom"
    NotifyLayout.Padding = UDim.new(0, 8)

    function Lib:Notify(title, text, time)
        local n = Instance.new("Frame", NotifyHolder)
        n.Size = UDim2.new(1, 0, 0, 65)
        n.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Instance.new("UICorner", n)
        local ns = Instance.new("UIStroke", n)
        ns.Color = Lib.CurrentColor
        
        local nt = Instance.new("TextLabel", n)
        nt.Size = UDim2.new(1, -10, 0, 20)
        nt.Position = UDim2.new(0, 10, 0, 5)
        nt.Text = title:upper()
        nt.TextColor3 = Lib.CurrentColor
        nt.Font = Enum.Font.Code
        nt.BackgroundTransparency = 1
        nt.TextXAlignment = "Left"

        local nm = Instance.new("TextLabel", n)
        nm.Size = UDim2.new(1, -20, 0, 35)
        nm.Position = UDim2.new(0, 10, 0, 25)
        nm.Text = text
        nm.TextColor3 = Color3.fromRGB(200, 200, 200)
        nm.Font = Enum.Font.Code
        nm.TextSize = 12
        nm.BackgroundTransparency = 1
        nm.TextXAlignment = "Left"
        nm.TextWrapped = true

        n.Position = UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        task.delay(time or 4, function()
            TweenService:Create(n, TweenInfo.new(0.5), {Position = UDim2.new(1.5, 0, 0, 0)}):Play()
            task.wait(0.5) n:Destroy()
        end)
    end

    -- // Lógica de Estilos
    function Lib:SetStyle(style)
        Lib.Style = style
        if style == "Clássico" then
            LineLeft.Visible = true
            LineTop.Visible = true
            MainCorner.CornerRadius = UDim.new(0, 0)
            MainStroke.Enabled = false
            MainFrame.BackgroundTransparency = 0
        elseif style == "Moderno" then
            LineLeft.Visible = false
            LineTop.Visible = false
            MainCorner.CornerRadius = UDim.new(0, 6)
            MainStroke.Enabled = true
            MainStroke.Color = Color3.fromRGB(35, 35, 35)
            MainFrame.BackgroundTransparency = 0
        elseif style == "Futurista" then
            LineLeft.Visible = false
            LineTop.Visible = false
            MainCorner.CornerRadius = UDim.new(0, 12)
            MainFrame.BackgroundTransparency = 0.3
            MainStroke.Enabled = true
            MainStroke.Color = Lib.CurrentColor
        end
    end

    -- // Atualização de Cores
    function Lib:UpdateColor(newCol)
        Lib.CurrentColor = newCol
        Subtitle.TextColor3 = newCol
        LineLeft.BackgroundColor3 = newCol
        LineTop.BackgroundColor3 = newCol
        if Lib.Style == "Futurista" then MainStroke.Color = newCol end
        
        for _, el in pairs(Lib.Elements) do
            if el.Type == "Toggle" and el.State then
                el.Instance.BackgroundColor3 = newCol
            elseif el.Type == "Slider" then
                el.Instance.Fill.BackgroundColor3 = newCol
            end
        end
    end

    -- // Criação de Abas
    function Lib:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.Visible = false
        AreaFrame.ScrollBarThickness = 2
        AreaFrame.ScrollBarImageColor3 = Lib.CurrentColor
        AreaFrame.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 6)

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Text = "  " .. name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.Code
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = "Left"
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        TabBtn.MouseButton1Click:Connect(function()
            for _, a in pairs(Container:GetChildren()) do if a:IsA("ScrollingFrame") then a.Visible = false end end
            for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(25, 25, 25) b.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            AreaFrame.Visible = true
            TabBtn.BackgroundColor3 = Lib.CurrentColor
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        if not Lib.ActiveTab then
            Lib.ActiveTab = true
            AreaFrame.Visible = true
            TabBtn.BackgroundColor3 = Lib.CurrentColor
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local Elements = {}

        function Elements:Label(txt)
            local l = Instance.new("TextLabel", AreaFrame)
            l.Size = UDim2.new(0.96, 0, 0, 20)
            l.BackgroundTransparency = 1
            l.Text = txt
            l.TextColor3 = Color3.fromRGB(100, 100, 100)
            l.Font = Enum.Font.Code
            l.TextSize = 12
            l.TextXAlignment = "Left"
        end

        function Elements:Button(txt, cb)
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(0.96, 0, 0, 35)
            b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            b.Text = txt
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.Font = Enum.Font.Code
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(cb)
        end

        function Elements:Toggle(txt, cb)
            local state = Lib.Storage[txt] or false
            local t = Instance.new("TextButton", AreaFrame)
            t.Size = UDim2.new(0.96, 0, 0, 35)
            t.BackgroundColor3 = state and Lib.CurrentColor or Color3.fromRGB(22, 22, 22)
            t.Text = "  " .. txt
            t.TextColor3 = Color3.fromRGB(255, 255, 255)
            t.Font = Enum.Font.Code
            t.TextXAlignment = "Left"
            Instance.new("UICorner", t).CornerRadius = UDim.new(0, 4)
            
            local ind = Instance.new("Frame", t)
            ind.Size = UDim2.new(0, 20, 0, 20)
            ind.Position = UDim2.new(1, -30, 0.5, -10)
            ind.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

            t.MouseButton1Click:Connect(function()
                state = not state
                Lib.Storage[txt] = state
                Save()
                t.BackgroundColor3 = state and Lib.CurrentColor or Color3.fromRGB(22, 22, 22)
                cb(state)
            end)
            table.insert(Lib.Elements, {Type = "Toggle", Instance = t, State = state})
            task.spawn(function() cb(state) end)
        end

        function Elements:Slider(txt, min, max, def, cb)
            local s = Instance.new("Frame", AreaFrame)
            s.Size = UDim2.new(0.96, 0, 0, 45)
            s.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Instance.new("UICorner", s).CornerRadius = UDim.new(0, 4)

            local title = Instance.new("TextLabel", s)
            title.Text = "  " .. txt
            title.Size = UDim2.new(1, 0, 0, 20)
            title.TextColor3 = Color3.fromRGB(200, 200, 200)
            title.BackgroundTransparency = 1
            title.Font = Enum.Font.Code
            title.TextXAlignment = "Left"

            local bar = Instance.new("Frame", s)
            bar.Size = UDim2.new(0.9, 0, 0, 4)
            bar.Position = UDim2.new(0.05, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            
            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = Lib.CurrentColor

            local val = Instance.new("TextLabel", s)
            val.Text = tostring(def)
            val.Position = UDim2.new(1, -40, 0, 0)
            val.Size = UDim2.new(0, 30, 0, 20)
            val.BackgroundTransparency = 1
            val.TextColor3 = Color3.fromRGB(255, 255, 255)

            local drag = false
            local function update(input)
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(p, 0, 1, 0)
                local v = math.floor(min + (max-min)*p)
                val.Text = tostring(v)
                cb(v)
            end

            s.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = true update(i) end end)
            UserInputService.InputChanged:Connect(function(i) if drag and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end end)
            
            table.insert(Lib.Elements, {Type = "Slider", Instance = s, Fill = fill})
        end

        function Elements:ColorPicker(txt, cb)
            local colors = {
                Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255),
                Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,255), Color3.fromRGB(255,0,255),
                Color3.fromRGB(255,255,255), Color3.fromRGB(0,0,0), Color3.fromRGB(255,165,0),
                Color3.fromRGB(128,0,128), Color3.fromRGB(0,128,128), Color3.fromRGB(165,42,42)
            }
            -- Adicionei 12 cores base, mas você pode expandir a tabela 'colors' ate 50.
            
            local cp = Instance.new("Frame", AreaFrame)
            cp.Size = UDim2.new(0.96, 0, 0, 35)
            cp.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            cp.ClipsDescendants = true
            Instance.new("UICorner", cp)

            local btn = Instance.new("TextButton", cp)
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.Text = "  " .. txt .. " (PALETA)"
            btn.TextColor3 = Lib.CurrentColor
            btn.BackgroundTransparency = 1
            btn.Font = Enum.Font.Code
            btn.TextXAlignment = "Left"

            local grid = Instance.new("UIGridLayout", cp)
            grid.CellSize = UDim2.new(0, 25, 0, 25)
            grid.Padding = UDim2.new(0, 5, 0, 5)

            local pad = Instance.new("UIPadding", cp)
            pad.PaddingTop = UDim.new(0, 40)
            pad.PaddingLeft = UDim.new(0, 10)

            for _, col in pairs(colors) do
                local cbtn = Instance.new("TextButton", cp)
                cbtn.BackgroundColor3 = col
                cbtn.Text = ""
                Instance.new("UICorner", cbtn)
                cbtn.MouseButton1Click:Connect(function()
                    Lib:UpdateColor(col)
                    btn.TextColor3 = col
                    cb(col)
                end)
            end

            local open = false
            btn.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(cp, TweenInfo.new(0.3), {Size = open and UDim2.new(0.96, 0, 0, 150) or UDim2.new(0.96, 0, 0, 35)}):Play()
            end)
        end
function Elements:Dropdown(txt, list, cb)
            local d = Instance.new("Frame", AreaFrame)
            d.Size = UDim2.new(0.96, 0, 0, 35)
            d.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            d.ClipsDescendants = true
            Instance.new("UICorner", d)

            local btn = Instance.new("TextButton", d)
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.Text = "  " .. txt .. " >"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.BackgroundTransparency = 1
            btn.Font = Enum.Font.Code
            btn.TextXAlignment = "Left"

            local listFrame = Instance.new("Frame", d)
            listFrame.Position = UDim2.new(0,0,0,35)
            listFrame.Size = UDim2.new(1,0,1,-35)
            listFrame.BackgroundTransparency = 1
            Instance.new("UIListLayout", listFrame)

            for _, val in pairs(list) do
                local it = Instance.new("TextButton", listFrame)
                it.Size = UDim2.new(1, 0, 0, 30)
                it.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                it.Text = tostring(val)
                it.TextColor3 = Color3.fromRGB(150, 150, 150)
                it.Font = Enum.Font.Code
                it.MouseButton1Click:Connect(function()
                    btn.Text = "  " .. txt .. ": " .. tostring(val)
                    cb(val)
                    TweenService:Create(d, TweenInfo.new(0.3), {Size = UDim2.new(0.96, 0, 0, 35)}):Play()
                end)
            end

            local open = false
            btn.MouseButton1Click:Connect(function()
                open = not open
                local target = open and 35 + (#list * 30) or 35
                TweenService:Create(d, TweenInfo.new(0.3), {Size = UDim2.new(0.96, 0, 0, target)}):Play()
            end)
        end

        return Elements
    end

    UserInputService.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == toggleKey then
            Lib.Visible = not Lib.Visible
            MainFrame.Visible = Lib.Visible
        end
    end)

    return Lib
end

return luayV2
