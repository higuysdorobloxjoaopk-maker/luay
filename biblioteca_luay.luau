--[[
    luayV2 UI LIBRARY - ULTIMATE EDITION (600+ Lines)
    Desenvolvido por JoãoPK & Gemini
    Foco: Performance, Mobile Friendly e Estética Premium.
]]

local luayV2 = {}

-- [[ SERVIÇOS ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

-- [[ CONFIGURAÇÕES GERAIS ]] --
local UI_TAG = "luay_v2_core"
local SAVE_PATH = "luay_configs/"

if not isfolder(SAVE_PATH) and makefolder then
    makefolder(SAVE_PATH)
end

-- [[ FUNÇÕES UTILITÁRIAS ]] --
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Click:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Parent = obj
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.6
        ripple.ZIndex = 10
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        
        local corner = Instance.new("UICorner", ripple)
        corner.CornerRadius = UDim.new(1, 0)
        
        ripple:TweenSizeAndPosition(UDim2.new(0, 300, 0, 300), UDim2.new(0.5, -150, 0.5, -150), "Out", "Quad", 0.5)
        TweenService:Create(ripple, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        ripple:Destroy()
    end)
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
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

-- [[ NOTIFICAÇÕES ]] --
function luayV2:Notify(config)
    local title = config.Title or "Notificação"
    local text = config.Text or "Mensagem"
    local duration = config.Duration or 5
    
    local notifyGui = CoreGui:FindFirstChild("luay_Notify") or Instance.new("ScreenGui", CoreGui)
    notifyGui.Name = "luay_Notify"
    
    local container = notifyGui:FindFirstChild("Container") or Instance.new("Frame", notifyGui)
    if not notifyGui:FindFirstChild("Container") then
        container.Name = "Container"
        container.Size = UDim2.new(0, 250, 1, 0)
        container.Position = UDim2.new(1, -260, 0, 0)
        container.BackgroundTransparency = 1
        local layout = Instance.new("UIListLayout", container)
        layout.VerticalAlignment = "Bottom"
        layout.Padding = UDim.new(0, 10)
    end
    
    local nFrame = Instance.new("Frame", container)
    nFrame.Size = UDim2.new(1, 0, 0, 0) -- Começa com 0 para animar
    nFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    nFrame.BorderSizePixel = 0
    Instance.new("UICorner", nFrame)
    
    local line = Instance.new("Frame", nFrame)
    line.Size = UDim2.new(0, 3, 1, 0)
    line.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    line.BorderSizePixel = 0
    
    local tLabel = Instance.new("TextLabel", nFrame)
    tLabel.Text = title:upper()
    tLabel.Size = UDim2.new(1, -10, 0, 20)
    tLabel.Position = UDim2.new(0, 10, 0, 5)
    tLabel.TextColor3 = Color3.new(1, 1, 1)
    tLabel.Font = "Code"; tLabel.TextSize = 14; tLabel.TextXAlignment = "Left"; tLabel.BackgroundTransparency = 1
    
    local mLabel = Instance.new("TextLabel", nFrame)
    mLabel.Text = text
    mLabel.Size = UDim2.new(1, -10, 1, -25)
    mLabel.Position = UDim2.new(0, 10, 0, 25)
    mLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    mLabel.Font = "Code"; mLabel.TextSize = 12; mLabel.TextXAlignment = "Left"; mLabel.TextYAlignment = "Top"; mLabel.BackgroundTransparency = 1; mLabel.TextWrapped = true
    
    TweenService:Create(nFrame, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 70)}):Play()
    
    task.delay(duration, function()
        TweenService:Create(nFrame, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}):Play()
        task.wait(0.5)
        nFrame:Destroy()
    end)
end

-- [[ SISTEMA DE JANELA ]] --
function luayV2:Window(config)
    local Window = {
        MainColor = config.Color or Color3.fromRGB(0, 170, 255),
        Title = config.Name or "LUAY V2",
        AutoSave = false,
        CurrentTab = nil,
        Tabs = {},
        Elements = {}
    }

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "luay_v2_" .. HttpService:GenerateGUID(false)
    
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 350, 0, 420)
    Main.Position = UDim2.new(0.5, -175, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    
    -- Barra Superior
    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TopBar.BorderSizePixel = 0
    local TopCorner = Instance.new("UICorner", TopBar)
    
    local TopLine = Instance.new("Frame", TopBar)
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 1, -2)
    TopLine.BackgroundColor3 = Window.MainColor
    TopLine.BorderSizePixel = 0
    
    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = Window.Title:upper()
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = "Code"; Title.TextSize = 16; Title.TextXAlignment = "Left"; Title.BackgroundTransparency = 1
    
    -- Botões de Controle (Discord Style)
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0, 5)
    CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.Font = "GothamBold"; CloseBtn.TextSize = 25; CloseBtn.BackgroundTransparency = 1
    
    local MiniBtn = Instance.new("TextButton", TopBar)
    MiniBtn.Size = UDim2.new(0, 35, 0, 35)
    MiniBtn.Position = UDim2.new(1, -75, 0, 5)
    MiniBtn.Text = "—"; MiniBtn.TextColor3 = Color3.new(1, 1, 1); MiniBtn.Font = "GothamBold"; MiniBtn.TextSize = 18; MiniBtn.BackgroundTransparency = 1
    
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    local minimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        local targetSize = minimized and UDim2.new(0, 350, 0, 45) or UDim2.new(0, 350, 0, 420)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)
    
    MakeDraggable(TopBar, Main)
    
    -- Sidebar (Abas)
    local Sidebar = Instance.new("ScrollingFrame", Main)
    Sidebar.Size = UDim2.new(0, 60, 1, -60)
    Sidebar.Position = UDim2.new(0, 5, 0, 55)
    Sidebar.BackgroundTransparency = 1; Sidebar.ScrollBarThickness = 0
    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 10); SideLayout.HorizontalAlignment = "Center"
    
    -- Container Principal
    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -85, 1, -70)
    Container.Position = UDim2.new(0, 75, 0, 60)
    Container.BackgroundTransparency = 1
    
    -- [[ MÉTODOS DE WINDOW ]] --
    function Window:AutoSaveLuay(state) Window.AutoSave = state end
    
    function Window:SetColor(newCol)
        Window.MainColor = newCol
        TopLine.BackgroundColor3 = newCol
        -- Atualizar elementos ativos
    end
    
    function Window:GetThemes()
        local tNames = {"Padrão", "Crimson", "Ocean", "Emerald", "Gold", "Vaporwave"}
        local tColors = {
            ["Padrão"] = Color3.fromRGB(0, 170, 255),
            ["Crimson"] = Color3.fromRGB(220, 20, 60),
            ["Ocean"] = Color3.fromRGB(0, 105, 148),
            ["Emerald"] = Color3.fromRGB(80, 220, 100),
            ["Gold"] = Color3.fromRGB(255, 215, 0),
            ["Vaporwave"] = Color3.fromRGB(255, 0, 255)
        }
        return tNames, tColors
    end

    -- [[ CRIAÇÃO DE ABAS ]] --
    function Window:Area(name, iconId)
        local Area = { Name = name, Elements = {} }
        
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.ScrollBarThickness = 3
        AreaFrame.ScrollBarImageColor3 = Window.MainColor; AreaFrame.AutomaticCanvasSize = "Y"
        local AreaLayout = Instance.new("UIListLayout", AreaFrame)
        AreaLayout.Padding = UDim.new(0, 8); AreaLayout.SortOrder = "LayoutOrder"
        
        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 42, 0, 42)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Image = "rbxassetid://" .. (iconId or "4483345998")
        TabBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
        Instance.new("UICorner", TabBtn)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("ImageButton") then TweenService:Create(v, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25, 25, 25), ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play() end end
            
            AreaFrame.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Window.MainColor, ImageColor3 = Color3.new(1, 1, 1)}):Play()
        end)
        
        if not Window.CurrentTab then
            Window.CurrentTab = AreaFrame
            AreaFrame.Visible = true
            TabBtn.BackgroundColor3 = Window.MainColor
            TabBtn.ImageColor3 = Color3.new(1, 1, 1)
        end

        -- [[ ELEMENTOS DA ABA ]] --
        local Elements = {}

        -- BOTÃO
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton", AreaFrame)
            btn.Size = UDim2.new(0.96, 0, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.Text = "  " .. text:upper()
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = "Code"; btn.TextSize = 13; btn.TextXAlignment = "Left"
            Instance.new("UICorner", btn)
            Ripple(btn)
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        -- TOGGLE (DISCORD / SWITCH STYLE)
        function Elements:Toggle(text, callback)
            local state = false
            local tBtn = Instance.new("TextButton", AreaFrame)
            tBtn.Size = UDim2.new(0.96, 0, 0, 38)
            tBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            tBtn.Text = "  " .. text
            tBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            tBtn.Font = "Code"; tBtn.TextSize = 13; tBtn.TextXAlignment = "Left"
            Instance.new("UICorner", tBtn)
            
            local switch = Instance.new("Frame", tBtn)
            switch.Size = UDim2.new(0, 40, 0, 22)
            switch.Position = UDim2.new(1, -50, 0.5, -11)
            switch.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
            
            local knob = Instance.new("Frame", switch)
            knob.Size = UDim2.new(0, 16, 0, 16)
            knob.Position = UDim2.new(0, 3, 0.5, -8)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            
            tBtn.MouseButton1Click:Connect(function()
                state = not state
                local targetPos = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                local targetColor = state and Window.MainColor or Color3.fromRGB(50, 50, 50)
                
                TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Position = targetPos}):Play()
                TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
                tBtn.TextColor3 = state and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
                
                callback(state)
            end)
        end

        -- SLIDER (ARRASTÁVEL & MOBILE)
        function Elements:Slider(text, min, max, default, callback)
            local sFrame = Instance.new("Frame", AreaFrame)
            sFrame.Size = UDim2.new(0.96, 0, 0, 50)
            sFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", sFrame)
            
            local label = Instance.new("TextLabel", sFrame)
            label.Text = "  " .. text .. ": " .. default
            label.Size = UDim2.new(1, 0, 0, 25); label.BackgroundTransparency = 1; label.TextColor3 = Color3.new(1,1,1)
            label.Font = "Code"; label.TextSize = 12; label.TextXAlignment = "Left"
            
            local bar = Instance.new("Frame", sFrame)
            bar.Size = UDim2.new(0.9, 0, 0, 6)
            bar.Position = UDim2.new(0.05, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Instance.new("UICorner", bar)
            
            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = Window.MainColor
            Instance.new("UICorner", fill)
            
            local knob = Instance.new("Frame", bar)
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new((default-min)/(max-min), -7, 0.5, -7)
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", knob)
            
            local dragging = false
            local function update(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                knob.Position = UDim2.new(pos, -7, 0.5, -7)
                label.Text = "  " .. text .. ": " .. val
                callback(val)
            end
            
            sFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true update(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        end

        -- TEXTBOX
        function Elements:Box(placeholder, callback)
            local boxFrame = Instance.new("Frame", AreaFrame)
            boxFrame.Size = UDim2.new(0.96, 0, 0, 35)
            boxFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Instance.new("UICorner", boxFrame)
            
            local tb = Instance.new("TextBox", boxFrame)
            tb.Size = UDim2.new(1, -20, 1, 0)
            tb.Position = UDim2.new(0, 10, 0, 0)
            tb.BackgroundTransparency = 1; tb.TextColor3 = Color3.new(1, 1, 1); tb.PlaceholderText = placeholder
            tb.Font = "Code"; tb.TextSize = 13; tb.Text = ""; tb.TextXAlignment = "Left"
            
            tb.FocusLost:Connect(function() callback(tb.Text) end)
        end

        -- DROPDOWN
        function Elements:Dropdown(text, list, callback)
            local open = false
            local dropFrame = Instance.new("Frame", AreaFrame)
            dropFrame.Size = UDim2.new(0.96, 0, 0, 35)
            dropFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            dropFrame.ClipsDescendants = true
            Instance.new("UICorner", dropFrame)
            
            local btn = Instance.new("TextButton", dropFrame)
            btn.Size = UDim2.new(1, 0, 0, 35)
            btn.BackgroundTransparency = 1; btn.Text = "  " .. text .. " [V]"; btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = "Code"; btn.TextSize = 13; btn.TextXAlignment = "Left"
            
            local container = Instance.new("Frame", dropFrame)
            container.Size = UDim2.new(1, 0, 0, #list * 30)
            container.Position = UDim2.new(0, 0, 0, 35); container.BackgroundTransparency = 1
            Instance.new("UIListLayout", container)
            
            for _, v in pairs(list) do
                local item = Instance.new("TextButton", container)
                item.Size = UDim2.new(1, 0, 0, 30); item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                item.Text = v; item.TextColor3 = Color3.fromRGB(200, 200, 200); item.Font = "Code"; item.TextSize = 12
                item.BorderSizePixel = 0
                item.MouseButton1Click:Connect(function()
                    btn.Text = "  " .. text .. " [" .. v .. "]"
                    open = false
                    TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.96, 0, 0, 35)}):Play()
                    callback(v)
                end)
            end
            
            btn.MouseButton1Click:Connect(function()
                open = not open
                local targetH = open and (35 + (#list * 30)) or 35
                TweenService:Create(dropFrame, TweenInfo.new(0.3), {Size = UDim2.new(0.96, 0, 0, targetH)}):Play()
            end)
        end

        -- PLAYER SELECTOR
        function Elements:PlayerSelector(text, callback)
            local function getPlrs()
                local tbl = {}
                for _, p in pairs(players:GetPlayers()) do table.insert(tbl, p.Name) end
                return tbl
            end
            self:Dropdown(text, getPlrs(), function(selected)
                callback(players:FindFirstChild(selected))
            end)
        end

        -- KEYBIND
        function Elements:Keybind(text, default, callback)
            local key = default
            local waiting = false
            local kBtn = self:Button(text .. " [" .. key.Name .. "]", function() end)
            
            kBtn.MouseButton1Click:Connect(function()
                waiting = true
                kBtn.Text = "  " .. text .. " [...]"
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                    key = input.KeyCode
                    waiting = false
                    kBtn.Text = "  " .. text .. " [" .. key.Name .. "]"
                elseif not waiting and input.KeyCode == key then
                    callback()
                end
            end)
        end

        -- CONSOLE DE LOGS
        function Elements:Logs(h)
            local logScroll = Instance.new("ScrollingFrame", AreaFrame)
            logScroll.Size = UDim2.new(0.96, 0, 0, h or 150)
            logScroll.BackgroundColor3 = Color3.new(0, 0, 0)
            logScroll.ScrollBarThickness = 2; logScroll.AutomaticCanvasSize = "Y"
            Instance.new("UICorner", logScroll)
            local logLayout = Instance.new("UIListLayout", logScroll)
            
            local logObj = {}
            function logObj:Log(msg, color)
                local l = Instance.new("TextLabel", logScroll)
                l.Size = UDim2.new(1, -10, 0, 20); l.BackgroundTransparency = 1
                l.Text = " > " .. msg; l.TextColor3 = color or Color3.new(1, 1, 1)
                l.Font = "Code"; l.TextSize = 11; l.TextXAlignment = "Left"
            end
            function logObj:Clear()
                for _, v in pairs(logScroll:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end
            end
            return logObj
        end

        return Elements
    end

    return Window
end

return luayV2
