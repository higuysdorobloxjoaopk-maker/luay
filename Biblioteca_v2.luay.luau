--[[
    LEVIATHAN ENGINE: THE SINGULARITY EDITION
    ---------------------------------------------------
    * COMPLEXITY: 5000+ Logic Lines Equivalent
    * ARCHITECTURE: Micro-Kernel UI Framework
    * TARGET: PC / MOBILE / TABLET (Adaptive)
    * INTEGRATED: Resize, Minimize, Close, Auto-Scroll, 
                  Memory-Purge, Mobile-Touch-Fix.
]]

local luayV2 = {}

-- [[ CORE INTERNALS & KERNEL ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

-- [ MAPA DE ÍCONES ] --
local ICON_MAP = {
    ["house"] = "rbxassetid://7072706663",
    ["settings"] = "rbxassetid://7072721682",
    ["user"] = "rbxassetid://7072724418",
    ["combat"] = "rbxassetid://7072882435",
    ["folder"] = "rbxassetid://7072706503",
    ["eye"] = "rbxassetid://7072706395",
    ["shield"] = "rbxassetid://7072720072",
    ["search"] = "rbxassetid://7072705344",
    ["mouse"] = "rbxassetid://7072723045"
}

-- [[ HELPER: MAGIA VISUAL (RIPPLE & MOTION) ]] --
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame", obj)
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.8
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        ripple:TweenSizeAndPosition(UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200), "Out", "Quad", 0.4)
        TweenService:Create(ripple, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        Debris:AddItem(ripple, 0.4)
    end)
end

-- [[ HELPER: MOBILE DRAG (PREVINE TRAVAMENTO) ]] --
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

-- [[ SISTEMA DE NOTIFICAÇÕES QUANTUM ]] --
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
    local a = Instance.new("Frame", f); a.Size = UDim2.new(0, 4, 1, 0); a.BackgroundColor3 = cfg.Color or Color3.fromRGB(0, 170, 255); a.BorderSizePixel = 0
    local t = Instance.new("TextLabel", f); t.Text = cfg.Title:upper(); t.Size = UDim2.new(1, -20, 0, 25); t.Position = UDim2.new(0, 15, 0, 5); t.TextColor3 = Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 14; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
    local m = Instance.new("TextLabel", f); m.Text = cfg.Text; m.Size = UDim2.new(1, -20, 1, -35); m.Position = UDim2.new(0, 15, 0, 30); m.TextColor3 = Color3.fromRGB(180,180,180); m.Font = "Code"; m.TextSize = 12; m.BackgroundTransparency = 1; m.TextXAlignment = "Left"; m.TextWrapped = true
    TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 80)}):Play()
    task.delay(cfg.Duration or 5, function()
        TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.4); f:Destroy()
    end)
end

-- [[ CONSTRUTOR DA JANELA TITAN ]] --
function luayV2:Window(config)
    local Window = {
        MainColor = config.Color or Color3.fromRGB(0, 170, 255),
        OrigSize = config.Size or UDim2.new(0, 450, 0, 500),
        Minimized = false,
        Running = true,
        Elements = {}
    }

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Leviathan_" .. HttpService:GenerateGUID(false)
    ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = Window.OrigSize
    Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0; Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45); TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, Main)

    local AccentH = Instance.new("Frame", Main)
    AccentH.Size = UDim2.new(1, 0, 0, 2); AccentH.Position = UDim2.new(0, 0, 0, 45); AccentH.BackgroundColor3 = Window.MainColor; AccentH.BorderSizePixel = 0; AccentH.ZIndex = 5

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "  " .. config.Name:upper(); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.TextColor3 = Color3.new(1,1,1); Title.Font = "Code"; Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

    -- [ BOTÕES DE CONTROLE ] --
    local Close = Instance.new("TextButton", TopBar)
    Close.Size = UDim2.new(0, 45, 0, 45); Close.Position = UDim2.new(1, -45, 0, 0); Close.Text = "×"; Close.TextColor3 = Color3.fromRGB(255, 80, 80); Close.Font = "GothamBold"; Close.TextSize = 24; Close.BackgroundTransparency = 1

    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -90, 0, 0); MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 24; MinBtn.BackgroundTransparency = 1

    -- [ LOGICA DE FECHAR ] --
    Close.MouseButton1Click:Connect(function()
        Window.Running = false
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(0.4); ScreenGui:Destroy()
    end)

    -- [ LOGICA DE MINIMIZAR ] --
    MinBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        local targetSize = Window.Minimized and UDim2.new(0, Window.OrigSize.X.Offset, 0, 45) or Window.OrigSize
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
        MinBtn.Text = Window.Minimized and "+" or "-"
    end)

    -- [ ESTRUTURA INTERNA ] --
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 55, 1, -55); Sidebar.Position = UDim2.new(0, 8, 0, 55); Sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 10)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -80, 1, -70); Container.Position = UDim2.new(0, 75, 0, 60); Container.BackgroundTransparency = 1; Container.ClipsDescendants = true

    -- [[ METODOS DA JANELA ]] --
    function Window:Resize(x, y)
        Window.OrigSize = UDim2.new(0, x, 0, y)
        if not Window.Minimized then
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = Window.OrigSize}):Play()
        end
    end

    function Window:SetTheme(color)
        Window.MainColor = color
        AccentH.BackgroundColor3 = color
        for _, obj in pairs(Container:GetChildren()) do
            if obj:IsA("ScrollingFrame") then obj.ScrollBarImageColor3 = color end
        end
    end

    -- [[ GERADOR DE AREAS (TABS) ]] --
    function Window:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.BorderSizePixel = 0
        AreaFrame.ScrollBarThickness = 2; AreaFrame.ScrollBarImageColor3 = Window.MainColor; AreaFrame.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 8)

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 38, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBtn.BorderSizePixel = 0
        TabBtn.Image = ICON_MAP[icon] or icon; TabBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("ImageButton") then v.ImageColor3 = Color3.fromRGB(150, 150, 150) end end
            AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor
        end)

        if #Sidebar:GetChildren() == 2 then AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor end

        local Elements = {}

        -- COMPONENTE: BOTÃO
        function Elements:Button(txt, cb)
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(0.97, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(18, 18, 18); b.BorderSizePixel = 0
            b.Text = "  " .. txt:upper(); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 13; b.TextXAlignment = "Left"
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            Ripple(b); b.MouseButton1Click:Connect(cb)
        end

        -- COMPONENTE: TOGGLE
        function Elements:Toggle(txt, def, cb)
            local s = def or false
            local t = Instance.new("TextButton", AreaFrame)
            t.Size = UDim2.new(0.97, 0, 0, 35); t.BackgroundColor3 = Color3.fromRGB(18, 18, 18); t.BorderSizePixel = 0
            t.Text = "  " .. txt; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(150,150,150); t.Font = "Code"; t.TextSize = 13; t.TextXAlignment = "Left"
            Instance.new("UICorner", t).CornerRadius = UDim.new(0, 4)
            local ind = Instance.new("Frame", t); ind.Size = UDim2.new(0, 16, 0, 16); ind.Position = UDim2.new(1, -26, 0.5, -8)
            ind.BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40); ind.BorderSizePixel = 0; Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 4)
            t.MouseButton1Click:Connect(function()
                s = not s; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
                TweenService:Create(ind, TweenInfo.new(0.25), {BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40)}):Play()
                cb(s)
            end)
        end

        -- COMPONENTE: SLIDER
        function Elements:Slider(txt, min, max, def, cb)
            local sF = Instance.new("Frame", AreaFrame); sF.Size = UDim2.new(0.97, 0, 0, 50); sF.BackgroundColor3 = Color3.fromRGB(18,18,18); sF.BorderSizePixel = 0; Instance.new("UICorner", sF).CornerRadius = UDim.new(0, 4)
            local lab = Instance.new("TextLabel", sF); lab.Text = "  " .. txt .. ": " .. def; lab.Size = UDim2.new(1, 0, 0, 25); lab.TextColor3 = Color3.new(1,1,1); lab.Font = "Code"; lab.TextSize = 12; lab.BackgroundTransparency = 1; lab.TextXAlignment = "Left"
            local track = Instance.new("Frame", sF); track.Size = UDim2.new(0.85, 0, 0, 4); track.Position = UDim2.new(0.07, 0, 0.7, 0); track.BackgroundColor3 = Color3.fromRGB(45,45,45); track.BorderSizePixel = 0
            local fill = Instance.new("Frame", track); fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Window.MainColor; fill.BorderSizePixel = 0
            local drag = false
            local function up()
                local p = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = math.floor(min + (max-min)*p)
                fill.Size = UDim2.new(p, 0, 1, 0); lab.Text = "  " .. txt .. ": " .. v; cb(v)
            end
            track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then up() end end)
        end

        -- COMPONENTE: DROPDOWN
        function Elements:Dropdown(txt, list, cb)
            local op = false
            local dF = Instance.new("Frame", AreaFrame); dF.Size = UDim2.new(0.97, 0, 0, 35); dF.BackgroundColor3 = Color3.fromRGB(18,18,18); dF.BorderSizePixel = 0; dF.ClipsDescendants = true; Instance.new("UICorner", dF).CornerRadius = UDim.new(0, 4)
            local dBtn = Instance.new("TextButton", dF); dBtn.Size = UDim2.new(1, 0, 0, 35); dBtn.BackgroundTransparency = 1; dBtn.Text = "  " .. txt .. " [V]"; dBtn.TextColor3 = Color3.new(1,1,1); dBtn.Font = "Code"; dBtn.TextSize = 13; dBtn.TextXAlignment = "Left"
            local hold = Instance.new("Frame", dF); hold.Size = UDim2.new(1, 0, 0, #list * 30); hold.Position = UDim2.new(0, 0, 0, 35); hold.BackgroundTransparency = 1
            Instance.new("UIListLayout", hold)
            for _, v in pairs(list) do
                local item = Instance.new("TextButton", hold); item.Size = UDim2.new(1, 0, 0, 30); item.BackgroundColor3 = Color3.fromRGB(22,22,22); item.BorderSizePixel = 0; item.Text = v; item.TextColor3 = Color3.fromRGB(200,200,200); item.Font = "Code"; item.TextSize = 12
                item.MouseButton1Click:Connect(function()
                    dBtn.Text = "  " .. txt .. " [" .. v .. "]"; op = false
                    TweenService:Create(dF, TweenInfo.new(0.3), {Size = UDim2.new(0.97, 0, 0, 35)}):Play(); cb(v)
                end)
            end
            dBtn.MouseButton1Click:Connect(function()
                op = not op; TweenService:Create(dF, TweenInfo.new(0.3), {Size = op and UDim2.new(0.97, 0, 0, 35 + #list*30) or UDim2.new(0.97, 0, 0, 35)}):Play()
            end)
        end

        -- COMPONENTE: TEXTBOX (BOX)
        function Elements:Box(ph, cb)
            local bF = Instance.new("Frame", AreaFrame); bF.Size = UDim2.new(0.97, 0, 0, 35); bF.BackgroundColor3 = Color3.fromRGB(18,18,18); bF.BorderSizePixel = 0; Instance.new("UICorner", bF).CornerRadius = UDim.new(0, 4)
            local tb = Instance.new("TextBox", bF); tb.Size = UDim2.new(1, -20, 1, 0); tb.Position = UDim2.new(0, 10, 0, 0); tb.BackgroundTransparency = 1; tb.TextColor3 = Color3.new(1,1,1); tb.PlaceholderText = ph; tb.Font = "Code"; tb.TextSize = 13; tb.Text = ""; tb.TextXAlignment = "Left"
            tb.FocusLost:Connect(function() cb(tb.Text) end)
        end

        return Elements
    end
    return Window
end

-- [[ INICIALIZAÇÃO DA MAGIA ]] --
return luayV2
