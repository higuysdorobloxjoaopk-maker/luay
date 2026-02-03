-- [[ luayV2 - THE LEVIATHAN CORE ]] --
local luayV2 = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

local ICON_MAP = {
    ["house"] = "rbxassetid://7072706663",
    ["settings"] = "rbxassetid://7072721682",
    ["user"] = "rbxassetid://7072724418",
    ["combat"] = "rbxassetid://7072882435",
    ["folder"] = "rbxassetid://7072706503",
    ["eye"] = "rbxassetid://7072706395",
    ["shield"] = "rbxassetid://7072720072"
}

local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame", obj)
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.6
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        ripple:TweenSizeAndPosition(UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200), "Out", "Quad", 0.5)
        TweenService:Create(ripple, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        Debris:AddItem(ripple, 0.5)
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

function luayV2:Window(config)
    local Window = {
        MainColor = config.Color or Color3.fromRGB(0, 170, 255),
        Size = config.Size or UDim2.new(0, 450, 0, 500),
        Running = true,
        Data = {},
        AutoSave = false
    }

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Leviathan_" .. HttpService:GenerateGUID(false)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = Window.Size
    Main.Position = UDim2.new(0.5, -Main.Size.X.Offset/2, 0.5, -Main.Size.Y.Offset/2)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0

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
    Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 55, 1, -55); Sidebar.Position = UDim2.new(0, 8, 0, 55); Sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 10)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -80, 1, -70); Container.Position = UDim2.new(0, 75, 0, 60); Container.BackgroundTransparency = 1; Container.ClipsDescendants = true

    -- [[ FUNÇÃO RESIZE ADICIONADA ]] --
    function Window:Resize(newX, newY)
        Window.Size = UDim2.new(0, newX, 0, newY)
        local info = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(Main, info, {Size = Window.Size}):Play()
    end

    function Window:SetTheme(color)
        Window.MainColor = color
        AccentV.BackgroundColor3 = color; AccentH.BackgroundColor3 = color; Subtitle.TextColor3 = color
    end

    function Window:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.BorderSizePixel = 0; AreaFrame.ScrollBarThickness = 2; AreaFrame.ScrollBarImageColor3 = Window.MainColor; AreaFrame.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 8)

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 38, 0, 38); TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBtn.BorderSizePixel = 0; TabBtn.Image = ICON_MAP[icon] or icon; TabBtn.ImageColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("ImageButton") then v.ImageColor3 = Color3.fromRGB(150, 150, 150) end end
            AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor; Subtitle.Text = "  " .. name:upper()
        end)

        if #Sidebar:GetChildren() == 2 then AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor; Subtitle.Text = "  " .. name:upper() end

        local Elements = {}

        function Elements:Button(txt, cb)
            local b = Instance.new("TextButton", AreaFrame); b.Size = UDim2.new(0.97, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(18, 18, 18); b.BorderSizePixel = 0; b.Text = "  " .. txt:upper(); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 13; b.TextXAlignment = "Left"
            Ripple(b); b.MouseButton1Click:Connect(cb)
        end

        function Elements:Toggle(txt, def, cb)
            local s = def or false
            local t = Instance.new("TextButton", AreaFrame); t.Size = UDim2.new(0.97, 0, 0, 35); t.BackgroundColor3 = Color3.fromRGB(18, 18, 18); t.BorderSizePixel = 0; t.Text = "  " .. txt; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(150,150,150); t.Font = "Code"; t.TextSize = 13; t.TextXAlignment = "Left"
            local ind = Instance.new("Frame", t); ind.Size = UDim2.new(0, 16, 0, 16); ind.Position = UDim2.new(1, -24, 0.5, -8); ind.BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40); ind.BorderSizePixel = 0
            t.MouseButton1Click:Connect(function()
                s = not s; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(150,150,150)
                TweenService:Create(ind, TweenInfo.new(0.2), {BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40)}):Play()
                cb(s)
            end)
        end

        function Elements:Slider(txt, min, max, def, cb)
            local sF = Instance.new("Frame", AreaFrame); sF.Size = UDim2.new(0.97, 0, 0, 50); sF.BackgroundColor3 = Color3.fromRGB(18,18,18); sF.BorderSizePixel = 0
            local lab = Instance.new("TextLabel", sF); lab.Text = "  " .. txt .. ": " .. def; lab.Size = UDim2.new(1, 0, 0, 25); lab.TextColor3 = Color3.new(1,1,1); lab.Font = "Code"; lab.TextSize = 12; lab.BackgroundTransparency = 1; lab.TextXAlignment = "Left"
            local track = Instance.new("Frame", sF); track.Size = UDim2.new(0.85, 0, 0, 4); track.Position = UDim2.new(0.07, 0, 0.7, 0); track.BackgroundColor3 = Color3.fromRGB(45,45,45); track.BorderSizePixel = 0
            local fill = Instance.new("Frame", track); fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Window.MainColor; fill.BorderSizePixel = 0
            local ball = Instance.new("TextButton", fill); ball.AnchorPoint = Vector2.new(0.5, 0.5); ball.Size = UDim2.new(0, 14, 0, 14); ball.Position = UDim2.new(1, 0, 0.5, 0); ball.BackgroundColor3 = Window.MainColor; ball.BorderSizePixel = 0; ball.Text = ""
            local drag = false
            local function up()
                local p = math.clamp((mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local v = math.floor(min + (max-min)*p)
                fill.Size = UDim2.new(p, 0, 1, 0); lab.Text = "  " .. txt .. ": " .. v; cb(v)
            end
            ball.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then up() end end)
            track.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then up() end end)
        end

        function Elements:Logs(h)
            local s = Instance.new("ScrollingFrame", AreaFrame); s.Size = UDim2.new(0.97, 0, 0, h or 150); s.BackgroundColor3 = Color3.new(0,0,0); s.BorderSizePixel = 0; s.ScrollBarThickness = 2; s.AutomaticCanvasSize = "Y"
            local l = Instance.new("UIListLayout", s)
            return {
                Log = function(_, m, c)
                    local t = Instance.new("TextLabel", s); t.Size = UDim2.new(1, -10, 0, 18); t.BackgroundTransparency = 1; t.Text = " > " .. m; t.TextColor3 = c or Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 11; t.TextXAlignment = "Left"; s.CanvasPosition = Vector2.new(0, 9999)
                end,
                Clear = function() for _, v in pairs(s:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end end
            }
        end

        return Elements
    end
    return Window
end

return luayV2
