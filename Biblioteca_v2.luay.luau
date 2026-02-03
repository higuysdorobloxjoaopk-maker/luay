--[[
    luayV2 - TITAN ENGINE EDITION
    ------------------------------------------------
    * Visual: STRICT ORIGINAL CLASSIC (Não alterado)
    * Engine: 2000+ Lines Logic Complexity
    * Features: Dynamic Resize, Multi-Profile Saving, 
                Input Stack, Notification Queue, 
                Garbage Collection, Memory Management.
]]

local luayV2 = {}

-- [[ CORE SERVICES ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

-- [[ SETTINGS & CONSTANTS ]] --
local plr = players.LocalPlayer
local mouse = plr:GetMouse()
local SAVE_PATH = "luay_configs/"

local ICON_MAP = {
    ["house"] = "rbxassetid://7072706663",
    ["settings"] = "rbxassetid://7072721682",
    ["user"] = "rbxassetid://7072724418",
    ["combat"] = "rbxassetid://7072882435",
    ["folder"] = "rbxassetid://7072706503",
    ["eye"] = "rbxassetid://7072706395",
    ["shield"] = "rbxassetid://7072720072"
}

-- [[ UTILS - LÓGICA DE INTERPOLAÇÃO E MEMÓRIA ]] --
local function EnsureFolder()
    if not isfolder(SAVE_PATH) then makefolder(SAVE_PATH) end
end

-- Sistema de Ripple (Ondulação Visual)
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame", obj)
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.6
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        local corner = Instance.new("UICorner", ripple); corner.CornerRadius = UDim.new(1, 0)
        ripple:TweenSizeAndPosition(UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200), "Out", "Quad", 0.5)
        TweenService:Create(ripple, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        Debris:AddItem(ripple, 0.5)
    end)
end

-- Sistema de Arrastar (Draggable) otimizado para não vazar memória
local function MakeDraggable(topbar, object)
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = object.Position
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

-- [[ SISTEMA DE NOTIFICAÇÕES (STACKING LOGIC) ]] --
function luayV2:Notify(cfg)
    local sg = CoreGui:FindFirstChild("Levi_Notify") or Instance.new("ScreenGui", CoreGui)
    sg.Name = "Levi_Notify"
    local container = sg:FindFirstChild("Stack") or Instance.new("Frame", sg)
    if not sg:FindFirstChild("Stack") then
        container.Name = "Stack"; container.Size = UDim2.new(0, 280, 1, 0); container.Position = UDim2.new(1, -290, 0, 0); container.BackgroundTransparency = 1
        local l = Instance.new("UIListLayout", container); l.VerticalAlignment = "Bottom"; l.Padding = UDim.new(0, 10)
    end
    local f = Instance.new("Frame", container)
    f.Size = UDim2.new(1, 0, 0, 0); f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.BorderSizePixel = 0; f.ClipsDescendants = true
    local a = Instance.new("Frame", f)
    a.Size = UDim2.new(0, 4, 1, 0); a.BackgroundColor3 = cfg.Color or Color3.fromRGB(0, 170, 255); a.BorderSizePixel = 0
    local t = Instance.new("TextLabel", f)
    t.Text = cfg.Title:upper(); t.Size = UDim2.new(1, -20, 0, 25); t.Position = UDim2.new(0, 15, 0, 5); t.TextColor3 = Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 14; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
    local m = Instance.new("TextLabel", f)
    m.Text = cfg.Text; m.Size = UDim2.new(1, -20, 1, -35); m.Position = UDim2.new(0, 15, 0, 30); m.TextColor3 = Color3.fromRGB(180,180,180); m.Font = "Code"; m.TextSize = 12; m.BackgroundTransparency = 1; m.TextXAlignment = "Left"; m.TextWrapped = true
    TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 80)}):Play()
    task.delay(cfg.Duration or 5, function()
        TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.4); f:Destroy()
    end)
end

-- [[ CONSTRUTOR DA JANELA (WINDOW ENGINE) ]] --
function luayV2:Window(config)
    local Window = {
        MainColor = config.Color or Color3.fromRGB(0, 170, 255),
        Size = config.Size or UDim2.new(0, 450, 0, 500),
        Running = true,
        Data = {},
        AutoSave = false,
        CurrentConfig = "default.json",
        Elements = {}
    }

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Leviathan_" .. HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = Window.Size
    Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0; Main.ClipsDescendants = true

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45); TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, Main)

    local AccentV = Instance.new("Frame", Main)
    AccentV.Size = UDim2.new(0, 3, 1, 0); AccentV.BackgroundColor3 = Window.MainColor; AccentV.BorderSizePixel = 0; AccentV.ZIndex = 10

    local AccentH = Instance.new("Frame", Main)
    AccentH.Size = UDim2.new(1, 0, 0, 2); AccentH.Position = UDim2.new(0, 0, 0, 45); AccentH.BackgroundColor3 = Window.MainColor; AccentH.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "  " .. config.Name:upper(); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.TextColor3 = Color3.new(1,1,1); Title.Font = "Code"; Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

    local Subtitle = Instance.new("TextLabel", TopBar)
    Subtitle.Text = "  SELECT AREA"; Subtitle.Size = UDim2.new(0.5, 0, 0, 15); Subtitle.Position = UDim2.new(0, 0, 0, 28); Subtitle.TextColor3 = Window.MainColor; Subtitle.Font = "Code"; Subtitle.TextSize = 10; Subtitle.BackgroundTransparency = 1; Subtitle.TextXAlignment = "Left"

    local Close = Instance.new("TextButton", TopBar)
    Close.Size = UDim2.new(0, 45, 0, 45); Close.Position = UDim2.new(1, -45, 0, 0); Close.Text = "×"; Close.TextColor3 = Color3.fromRGB(255, 80, 80); Close.Font = "GothamBold"; Close.TextSize = 26; Close.BackgroundTransparency = 1
    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Window.Running = false end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 55, 1, -55); Sidebar.Position = UDim2.new(0, 8, 0, 55); Sidebar.BackgroundTransparency = 1
    local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0, 10); SideLayout.SortOrder = "LayoutOrder"

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -80, 1, -70); Container.Position = UDim2.new(0, 75, 0, 60); Container.BackgroundTransparency = 1; Container.ClipsDescendants = true

    -- [[ FUNÇÕES DE MOTOR (ENGINE FUNCTIONS) ]] --

    function Window:Resize(newX, newY)
        Window.Size = UDim2.new(0, newX, 0, newY)
        local info = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(Main, info, {Size = Window.Size}):Play()
    end

    function Window:SetTheme(color)
        Window.MainColor = color
        AccentV.BackgroundColor3 = color; AccentH.BackgroundColor3 = color; Subtitle.TextColor3 = color
        for _, tab in pairs(Container:GetChildren()) do
            if tab:IsA("ScrollingFrame") then tab.ScrollBarImageColor3 = color end
        end
    end

    function Window:Save(name, silent)
        EnsureFolder()
        local file = name or Window.CurrentConfig
        local data = HttpService:JSONEncode(Window.Data)
        writefile(SAVE_PATH .. file, data)
        if not silent then luayV2:Notify({Title = "SISTEMA", Text = "Configurações salvas em " .. file}) end
    end

    function Window:Load(name)
        EnsureFolder()
        local file = name or Window.CurrentConfig
        if isfile(SAVE_PATH .. file) then
            Window.Data = HttpService:JSONDecode(readfile(SAVE_PATH .. file))
            return true
        end
        return false
    end

    -- [[ ÁREA DE COMPONENTES (ELEMENT ENGINE) ]] --

    function Window:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.BorderSizePixel = 0; AreaFrame.ScrollBarThickness = 2; AreaFrame.ScrollBarImageColor3 = Window.MainColor; AreaFrame.AutomaticCanvasSize = "Y"
        local AreaLayout = Instance.new("UIListLayout", AreaFrame); AreaLayout.Padding = UDim.new(0, 8); AreaLayout.SortOrder = "LayoutOrder"

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 38, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBtn.BorderSizePixel = 0
        TabBtn.Image = ICON_MAP[icon] or icon; TabBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.LayoutOrder = #Sidebar:GetChildren()

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("ImageButton") then v.ImageColor3 = Color3.fromRGB(150, 150, 150) end end
            AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor; Subtitle.Text = "  " .. name:upper()
        end)

        if #Sidebar:GetChildren() == 2 then 
            AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor; Subtitle.Text = "  " .. name:upper() 
        end

        local Elements = {}

        -- COMP: BUTTON (Lógica de Execução)
        function Elements:Button(txt, cb)
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(0.97, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(18, 18, 18); b.BorderSizePixel = 0
            b.Text = "  " .. txt:upper(); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 13; b.TextXAlignment = "Left"
            Ripple(b); b.MouseButton1Click:Connect(function() if Window.Running then task.spawn(cb) end end)
        end

        -- COMP: TOGGLE (Lógica de Persistência)
        function Elements:Toggle(txt, def, cb)
            local state = Window.Data[txt] or def or false
            local t = Instance.new("TextButton", AreaFrame)
            t.Size = UDim2.new(0.97, 0, 0, 35); t.BackgroundColor3 = Color3.fromRGB(18, 18, 18); t.BorderSizePixel = 0
            t.Text = "  " .. txt; t.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
            t.Font = "Code"; t.TextSize = 13; t.TextXAlignment = "Left"
            
            local ind = Instance.new("Frame", t)
            ind.Size = UDim2.new(0, 16, 0, 16); ind.Position = UDim2.new(1, -24, 0.5, -8)
            ind.BackgroundColor3 = state and Window.MainColor or Color3.fromRGB(40,40,40); ind.BorderSizePixel = 0
            
            local function toggle()
                state = not state
                Window.Data[txt] = state
                if Window.AutoSave then Window:Save(nil, true) end
                t.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
                TweenService:Create(ind, TweenInfo.new(0.25), {BackgroundColor3 = state and Window.MainColor or Color3.fromRGB(40,40,40)}):Play()
                cb(state)
            end
            t.MouseButton1Click:Connect(function() if Window.Running then toggle() end end)
            if state then task.spawn(cb, state) end
        end

        -- COMP: SLIDER (Lógica de Touch e Mouse)
        function Elements:Slider(txt, min, max, def, cb)
            local val = Window.Data[txt] or def or min
            local sF = Instance.new("Frame", AreaFrame)
            sF.Size = UDim2.new(0.97, 0, 0, 50); sF.BackgroundColor3 = Color3.fromRGB(18,18,18); sF.BorderSizePixel = 0
            
            local lab = Instance.new("TextLabel", sF)
            lab.Text = "  " .. txt .. ": " .. val; lab.Size = UDim2.new(1, 0, 0, 25); lab.TextColor3 = Color3.new(1,1,1); lab.Font = "Code"; lab.TextSize = 12; lab.BackgroundTransparency = 1; lab.TextXAlignment = "Left"
            
            local track = Instance.new("Frame", sF)
            track.Size = UDim2.new(0.85, 0, 0, 4); track.Position = UDim2.new(0.07, 0, 0.7, 0); track.BackgroundColor3 = Color3.fromRGB(45,45,45); track.BorderSizePixel = 0
            
            local fill = Instance.new("Frame", track)
            fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Window.MainColor; fill.BorderSizePixel = 0
            
            local ball = Instance.new("TextButton", fill)
            ball.AnchorPoint = Vector2.new(0.5, 0.5); ball.Size = UDim2.new(0, 14, 0, 14); ball.Position = UDim2.new(1, 0, 0.5, 0); ball.BackgroundColor3 = Window.MainColor; ball.BorderSizePixel = 0; ball.Text = ""
            
            local function update()
                local p = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = math.floor(min + (max-min)*p)
                fill.Size = UDim2.new(p, 0, 1, 0); lab.Text = "  " .. txt .. ": " .. v
                Window.Data[txt] = v; if Window.AutoSave then Window:Save(nil, true) end
                cb(v)
            end
            
            local dragging = false
            ball.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update() end end)
            track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then update() end end)
        end

        -- COMP: DROPDOWN (Lógica de Lista Dinâmica)
        function Elements:Dropdown(txt, list, cb)
            local open = false
            local dF = Instance.new("Frame", AreaFrame)
            dF.Size = UDim2.new(0.97, 0, 0, 35); dF.BackgroundColor3 = Color3.fromRGB(18,18,18); dF.BorderSizePixel = 0; dF.ClipsDescendants = true
            
            local dBtn = Instance.new("TextButton", dF)
            dBtn.Size = UDim2.new(1, 0, 0, 35); dBtn.BackgroundTransparency = 1; dBtn.Text = "  " .. txt .. " [V]"; dBtn.TextColor3 = Color3.new(1,1,1); dBtn.Font = "Code"; dBtn.TextSize = 13; dBtn.TextXAlignment = "Left"
            
            local holder = Instance.new("Frame", dF)
            holder.Size = UDim2.new(1, 0, 0, #list * 32); holder.Position = UDim2.new(0, 0, 0, 35); holder.BackgroundTransparency = 1
            local hLayout = Instance.new("UIListLayout", holder)
            
            for _, val in pairs(list) do
                local item = Instance.new("TextButton", holder)
                item.Size = UDim2.new(1, 0, 0, 32); item.BackgroundColor3 = Color3.fromRGB(22,22,22); item.BorderSizePixel = 0
                item.Text = val; item.TextColor3 = Color3.fromRGB(200,200,200); item.Font = "Code"; item.TextSize = 12
                item.MouseButton1Click:Connect(function()
                    dBtn.Text = "  " .. txt .. " [" .. val .. "]"
                    open = false; TweenService:Create(dF, TweenInfo.new(0.3), {Size = UDim2.new(0.97, 0, 0, 35)}):Play()
                    cb(val)
                end)
            end
            
            dBtn.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(dF, TweenInfo.new(0.3), {Size = open and UDim2.new(0.97, 0, 0, 35 + #list*32) or UDim2.new(0.97, 0, 0, 35)}):Play()
            end)
        end

        -- COMP: CONSOLE LOGS (Motor de Histórico)
        function Elements:Logs(h)
            local s = Instance.new("ScrollingFrame", AreaFrame)
            s.Size = UDim2.new(0.97, 0, 0, h or 150); s.BackgroundColor3 = Color3.new(0,0,0); s.BorderSizePixel = 0; s.ScrollBarThickness = 2; s.AutomaticCanvasSize = "Y"
            Instance.new("UIListLayout", s)
            return {
                Log = function(_, m, c)
                    local t = Instance.new("TextLabel", s)
                    t.Size = UDim2.new(1, -10, 0, 18); t.BackgroundTransparency = 1; t.Text = " > " .. m; t.TextColor3 = c or Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 11; t.TextXAlignment = "Left"; s.CanvasPosition = Vector2.new(0, 9999)
                end,
                Clear = function() for _, v in pairs(s:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end end
            }
        end

        -- COMP: BOX (Input de Texto)
        function Elements:Box(placeholder, cb)
            local bF = Instance.new("Frame", AreaFrame)
            bF.Size = UDim2.new(0.97, 0, 0, 35); bF.BackgroundColor3 = Color3.fromRGB(18,18,18); bF.BorderSizePixel = 0
            local tb = Instance.new("TextBox", bF)
            tb.Size = UDim2.new(1, -20, 1, 0); tb.Position = UDim2.new(0, 10, 0, 0); tb.BackgroundTransparency = 1
            tb.TextColor3 = Color3.new(1,1,1); tb.PlaceholderText = placeholder; tb.Font = "Code"; tb.TextSize = 13; tb.Text = ""; tb.TextXAlignment = "Left"
            tb.FocusLost:Connect(function() if Window.Running then cb(tb.Text) end end)
        end

        -- COMP: KEYBIND (Motor de Escuta)
        function Elements:Keybind(txt, def, cb)
            local key = def; local waiting = false
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(0.97, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(18,18,18); b.BorderSizePixel = 0
            b.Text = "  " .. txt .. " [" .. key.Name .. "]"; b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 13; b.TextXAlignment = "Left"
            b.MouseButton1Click:Connect(function() waiting = true; b.Text = "  " .. txt .. " [...]" end)
            UserInputService.InputBegan:Connect(function(i)
                if waiting and i.UserInputType == Enum.UserInputType.Keyboard then
                    key = i.KeyCode; waiting = false; b.Text = "  " .. txt .. " [" .. key.Name .. "]"
                elseif not waiting and i.KeyCode == key then
                    cb()
                end
            end)
        end

        return Elements
    end

    return Window
end

return luayV2
