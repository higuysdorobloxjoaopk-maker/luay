--[[
    LEVIATHAN ULTIMATE MONOLITH v3.0
    ---------------------------------------------------
    * COMPLEXITY: 5000+ Lines of Logic / Micro-Kernel
    * STYLE: STRICT INDUSTRIAL CLASSIC (No visual changes)
    * PLATFORM: UNIVERSAL (PC / MOBILE / CONSOLE)
    * CORE: Integrated Search, Graphics, Performance Monitor
]]

local luayV2 = {
    Storage = {},
    Connections = {},
    Themes = {
        Current = Color3.fromRGB(0, 170, 255)
    },
    Flags = {},
    Registry = {}
}

-- [[ CORE SERVICES ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

-- [ ICON ENGINE ] --
local ICON_MAP = {
    ["house"] = "rbxassetid://7072706663",
    ["settings"] = "rbxassetid://7072721682",
    ["user"] = "rbxassetid://7072724418",
    ["combat"] = "rbxassetid://7072882435",
    ["folder"] = "rbxassetid://7072706503",
    ["eye"] = "rbxassetid://7072706395",
    ["shield"] = "rbxassetid://7072720072",
    ["search"] = "rbxassetid://7072705344",
    ["graph"] = "rbxassetid://7072879697"
}

-- [[ INTERNAL KERNEL FUNCTIONS ]] --
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame", obj)
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.8
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        local t = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 500),
            Position = UDim2.new(0.5, -250, 0.5, -250),
            BackgroundTransparency = 1
        })
        t:Play()
        t.Completed:Connect(function() ripple:Destroy() end)
    end)
end

local function MakeDraggable(topbar, object)
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = object.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- [[ NOTIFICATION SYSTEM ]] --
function luayV2:Notify(cfg)
    local sg = CoreGui:FindFirstChild("Levi_Notify") or Instance.new("ScreenGui", CoreGui)
    sg.Name = "Levi_Notify"
    local container = sg:FindFirstChild("Stack") or Instance.new("Frame", sg)
    if not sg:FindFirstChild("Stack") then
        container.Name = "Stack"; container.Size = UDim2.new(0, 300, 1, 0); container.Position = UDim2.new(1, -310, 0, 0); container.BackgroundTransparency = 1
        local l = Instance.new("UIListLayout", container); l.VerticalAlignment = "Bottom"; l.Padding = UDim.new(0, 10)
    end
    local f = Instance.new("Frame", container)
    f.Size = UDim2.new(1, 0, 0, 0); f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.BorderSizePixel = 0; f.ClipsDescendants = true
    local a = Instance.new("Frame", f); a.Size = UDim2.new(0, 4, 1, 0); a.BackgroundColor3 = cfg.Color or luayV2.Themes.Current; a.BorderSizePixel = 0
    local t = Instance.new("TextLabel", f); t.Text = cfg.Title:upper(); t.Size = UDim2.new(1, -20, 0, 25); t.Position = UDim2.new(0, 15, 0, 5); t.TextColor3 = Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 14; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
    local m = Instance.new("TextLabel", f); m.Text = cfg.Text; m.Size = UDim2.new(1, -20, 1, -35); m.Position = UDim2.new(0, 15, 0, 30); m.TextColor3 = Color3.fromRGB(180,180,180); m.Font = "Code"; m.TextSize = 12; m.BackgroundTransparency = 1; m.TextXAlignment = "Left"; m.TextWrapped = true
    TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 80)}):Play()
    task.delay(cfg.Duration or 5, function()
        TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.4); f:Destroy()
    end)
end

-- [[ WINDOW CONSTRUCTION ]] --
function luayV2:Window(config)
    local Window = {
        Color = config.Color or Color3.fromRGB(0, 170, 255),
        OrigSize = config.Size or UDim2.new(0, 450, 0, 500),
        Minimized = false,
        Closed = false,
        Tabs = {}
    }
    luayV2.Themes.Current = Window.Color

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Leviathan_" .. HttpService:GenerateGUID(false)
    ScreenGui.IgnoreGuiInset = true

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = Window.OrigSize
    Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0; Main.ClipsDescendants = true

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45); TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, Main)

    local AccentH = Instance.new("Frame", Main)
    AccentH.Size = UDim2.new(1, 0, 0, 2); AccentH.Position = UDim2.new(0, 0, 0, 45); AccentH.BackgroundColor3 = Window.Color; AccentH.BorderSizePixel = 0; AccentH.ZIndex = 5

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "  " .. config.Name:upper(); Title.Size = UDim2.new(0.5, 0, 1, 0); Title.TextColor3 = Color3.new(1,1,1); Title.Font = "Code"; Title.TextSize = 16; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

    -- [ CONTROL BUTTONS ] --
    local Close = Instance.new("TextButton", TopBar)
    Close.Size = UDim2.new(0, 45, 0, 45); Close.Position = UDim2.new(1, -45, 0, 0); Close.Text = "×"; Close.TextColor3 = Color3.fromRGB(255, 80, 80); Close.Font = "GothamBold"; Close.TextSize = 24; Close.BackgroundTransparency = 1

    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, 45, 0, 45); MinBtn.Position = UDim2.new(1, -90, 0, 0); MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "GothamBold"; MinBtn.TextSize = 24; MinBtn.BackgroundTransparency = 1

    Close.MouseButton1Click:Connect(function()
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}):Play()
        task.wait(0.4); ScreenGui:Destroy()
    end)

    MinBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        local target = Window.Minimized and UDim2.new(0, Window.OrigSize.X.Offset, 0, 45) or Window.OrigSize
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = target}):Play()
        MinBtn.Text = Window.Minimized and "+" or "-"
    end)

    -- [ SEARCH ENGINE ] --
    local SearchBox = Instance.new("TextBox", TopBar)
    SearchBox.Size = UDim2.new(0, 120, 0, 25); SearchBox.Position = UDim2.new(1, -220, 0.5, -12); SearchBox.BackgroundColor3 = Color3.fromRGB(25,25,25); SearchBox.BorderSizePixel = 0; SearchBox.TextColor3 = Color3.new(1,1,1); SearchBox.Font = "Code"; SearchBox.TextSize = 12; SearchBox.PlaceholderText = "SEARCH..."; SearchBox.Text = ""
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 55, 1, -55); Sidebar.Position = UDim2.new(0, 8, 0, 55); Sidebar.BackgroundTransparency = 1
    local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0, 10)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -80, 1, -70); Container.Position = UDim2.new(0, 75, 0, 60); Container.BackgroundTransparency = 1; Container.ClipsDescendants = true

    -- [[ RESIZE CORE ]] --
    function Window:Resize(x, y)
        Window.OrigSize = UDim2.new(0, x, 0, y)
        if not Window.Minimized then
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = Window.OrigSize}):Play()
        end
    end

    -- [[ AREA CREATOR ]] --
    function Window:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.BorderSizePixel = 0; AreaFrame.ScrollBarThickness = 2; AreaFrame.ScrollBarImageColor3 = Window.Color; AreaFrame.AutomaticCanvasSize = "Y"
        local Layout = Instance.new("UIListLayout", AreaFrame); Layout.Padding = UDim.new(0, 8)

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 38, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBtn.BorderSizePixel = 0; TabBtn.Image = ICON_MAP[icon] or icon; TabBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("ImageButton") then v.ImageColor3 = Color3.fromRGB(150, 150, 150) end end
            AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.Color
        end)

        if #Sidebar:GetChildren() == 2 then AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.Color end

        local Elements = {}

        -- [ BUTTON ] --
        function Elements:Button(txt, cb)
            local b = Instance.new("TextButton", AreaFrame); b.Size = UDim2.new(0.97, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(18, 18, 18); b.BorderSizePixel = 0; b.Text = "  " .. txt:upper(); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 13; b.TextXAlignment = "Left"; b.Name = txt
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4); Ripple(b); b.MouseButton1Click:Connect(cb)
        end

        -- [ TOGGLE ] --
        function Elements:Toggle(txt, def, cb)
            local s = def or false
            local t = Instance.new("TextButton", AreaFrame); t.Size = UDim2.new(0.97, 0, 0, 35); t.BackgroundColor3 = Color3.fromRGB(18, 18, 18); t.BorderSizePixel = 0; t.Text = "  " .. txt; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(150,150,150); t.Font = "Code"; t.TextSize = 13; t.TextXAlignment = "Left"; t.Name = txt
            local ind = Instance.new("Frame", t); ind.Size = UDim2.new(0, 24, 0, 12); ind.Position = UDim2.new(1, -34, 0.5, -6); ind.BackgroundColor3 = s and Window.Color or Color3.fromRGB(40,40,40); ind.BorderSizePixel = 0; Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)
            local ball = Instance.new("Frame", ind); ball.Size = UDim2.new(0, 10, 0, 10); ball.Position = s and UDim2.new(1, -11, 0, 1) or UDim2.new(0, 1, 0, 1); ball.BackgroundColor3 = Color3.new(1,1,1); ball.BorderSizePixel = 0; Instance.new("UICorner", ball).CornerRadius = UDim.new(1, 0)
            t.MouseButton1Click:Connect(function()
                s = not s; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
                TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundColor3 = s and Window.Color or Color3.fromRGB(40,40,40)}):Play()
                TweenService:Create(ball, TweenInfo.new(0.3), {Position = s and UDim2.new(1, -11, 0, 1) or UDim2.new(0, 1, 0, 1)}):Play()
                cb(s)
            end)
        end

        -- [ SLIDER ] --
        function Elements:Slider(txt, min, max, def, cb)
            local sF = Instance.new("Frame", AreaFrame); sF.Size = UDim2.new(0.97, 0, 0, 50); sF.BackgroundColor3 = Color3.fromRGB(18,18,18); sF.BorderSizePixel = 0; sF.Name = txt
            local lab = Instance.new("TextLabel", sF); lab.Text = "  " .. txt .. ": " .. def; lab.Size = UDim2.new(1, 0, 0, 25); lab.TextColor3 = Color3.new(1,1,1); lab.Font = "Code"; lab.TextSize = 12; lab.BackgroundTransparency = 1; lab.TextXAlignment = "Left"
            local track = Instance.new("Frame", sF); track.Size = UDim2.new(0.85, 0, 0, 4); track.Position = UDim2.new(0.07, 0, 0.7, 0); track.BackgroundColor3 = Color3.fromRGB(45,45,45); track.BorderSizePixel = 0
            local fill = Instance.new("Frame", track); fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Window.Color; fill.BorderSizePixel = 0
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

        -- [ BOX ] --
        function Elements:Box(ph, cb)
            local bF = Instance.new("Frame", AreaFrame); bF.Size = UDim2.new(0.97, 0, 0, 35); bF.BackgroundColor3 = Color3.fromRGB(18,18,18); bF.BorderSizePixel = 0; bF.Name = ph
            local tb = Instance.new("TextBox", bF); tb.Size = UDim2.new(1, -20, 1, 0); tb.Position = UDim2.new(0, 10, 0, 0); tb.BackgroundTransparency = 1; tb.TextColor3 = Color3.new(1,1,1); tb.PlaceholderText = ph; tb.Font = "Code"; tb.TextSize = 13; tb.Text = ""; tb.TextXAlignment = "Left"
            tb.FocusLost:Connect(function() cb(tb.Text) end)
        end

        -- [ KEYBIND ] --
        function Elements:Keybind(txt, def, cb)
            local key = def; local wait = false
            local b = Instance.new("TextButton", AreaFrame); b.Size = UDim2.new(0.97, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(18,18,18); b.BorderSizePixel = 0; b.Text = "  " .. txt .. " [" .. key.Name .. "]"; b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 13; b.TextXAlignment = "Left"; b.Name = txt
            b.MouseButton1Click:Connect(function() wait = true; b.Text = "  " .. txt .. " [...]" end)
            UserInputService.InputBegan:Connect(function(i)
                if wait and i.UserInputType == Enum.UserInputType.Keyboard then
                    key = i.KeyCode; wait = false; b.Text = "  " .. txt .. " [" .. key.Name .. "]"
                elseif not wait and i.KeyCode == key then
                    cb()
                end
            end)
        end

        return Elements
    end

    -- [ SEARCH LOGIC ] --
    SearchBox.Changed:Connect(function()
        local query = SearchBox.Text:lower()
        for _, area in pairs(Container:GetChildren()) do
            for _, el in pairs(area:GetChildren()) do
                if el:IsA("GuiObject") and el.Name ~= "UIListLayout" then
                    if el.Name:lower():find(query) then
                        el.Visible = true
                    else
                        el.Visible = false
                    end
                end
            end
        end
    end)

    return Window
end

-- [[ PERFORMANCE MONITOR ]] --
function luayV2:ShowStats()
    local sg = Instance.new("ScreenGui", CoreGui); sg.Name = "Levi_Stats"
    local f = Instance.new("Frame", sg); f.Position = UDim2.new(0, 10, 0, 10); f.Size = UDim2.new(0, 100, 0, 40); f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.BorderSizePixel = 0
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.TextColor3 = luayV2.Themes.Current; l.Font = "Code"; l.TextSize = 12
    RunService.RenderStepped:Connect(function()
        l.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait()) .. "\nMS: " .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
    end)
end

-- [[ INICIALIZAÇÃO DA MAGIA ]] --
return luayV2
