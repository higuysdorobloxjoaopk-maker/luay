-- [[ luayV2 - THE LEVIATHAN CORE (PREMIUM MAXIMALIST) ]] --
local luayV2 = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local plr = game:GetService("Players").LocalPlayer
local mouse = plr:GetMouse()

local ICON_MAP = {
    ["house"] = "rbxassetid://7072706663", ["settings"] = "rbxassetid://7072721682",
    ["user"] = "rbxassetid://7072724418", ["combat"] = "rbxassetid://7072882435",
    ["folder"] = "rbxassetid://7072706503", ["eye"] = "rbxassetid://7072706395",
    ["shield"] = "rbxassetid://7072720072"
}

-- [ SUPORTE ]
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame", obj)
        ripple.BackgroundColor3 = Color3.new(1, 1, 1); ripple.BackgroundTransparency = 0.6; ripple.Size = UDim2.new(0, 0, 0, 0)
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
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- [ NOTIFICAÇÕES ]
function luayV2:Notify(cfg)
    local sg = CoreGui:FindFirstChild("Levi_Notify") or Instance.new("ScreenGui", CoreGui)
    sg.Name = "Levi_Notify"
    local container = sg:FindFirstChild("Stack") or Instance.new("Frame", sg)
    if not sg:FindFirstChild("Stack") then
        container.Name = "Stack"; container.Size = UDim2.new(0, 220, 1, 0); container.Position = UDim2.new(1, -230, 0, 0); container.BackgroundTransparency = 1
        Instance.new("UIListLayout", container).VerticalAlignment = "Bottom"
    end
    local f = Instance.new("Frame", container)
    f.Size = UDim2.new(1, 0, 0, 0); f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.BorderSizePixel = 0; f.ClipsDescendants = true
    local accent = Instance.new("Frame", f); accent.Size = UDim2.new(0, 3, 1, 0); accent.BackgroundColor3 = cfg.Color or Color3.fromRGB(0, 170, 255); accent.BorderSizePixel = 0
    local t = Instance.new("TextLabel", f); t.Text = cfg.Title:upper(); t.Size = UDim2.new(1, -20, 0, 25); t.Position = UDim2.new(0, 10, 0, 5); t.TextColor3 = Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 13; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
    local m = Instance.new("TextLabel", f); m.Text = cfg.Text; m.Size = UDim2.new(1, -20, 1, -30); m.Position = UDim2.new(0, 10, 0, 25); m.TextColor3 = Color3.fromRGB(180,180,180); m.Font = "Code"; m.TextSize = 11; m.BackgroundTransparency = 1; m.TextXAlignment = "Left"; m.TextWrapped = true
    TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 70)}):Play()
    task.delay(cfg.Duration or 5, function()
        TweenService:Create(f, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.4); f:Destroy()
    end)
end

-- [ JANELA ]
function luayV2:Window(config)
    local Window = {
        MainColor = config.Color or Color3.fromRGB(0, 170, 255),
        Size = UDim2.new(0, 230, 0, 355),
        Toggles = {}, ConfigData = {}, Closed = false, Minimized = false,
        FileName = (config.Name or "Levi") .. "_Data.json"
    }

    if isfile and isfile(Window.FileName) then
        pcall(function() Window.ConfigData = HttpService:JSONDecode(readfile(Window.FileName)) end)
    end
    local function Save() if writefile then writefile(Window.FileName, HttpService:JSONEncode(Window.ConfigData)) end end

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Leviathan_" .. HttpService:GenerateGUID(false)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = Window.Size; Main.Position = UDim2.new(0.5, -115, 0.5, -177)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0; Main.ClipsDescendants = true

    -- L INVERTIDO COLORIDO
    local L_Vert = Instance.new("Frame", Main); L_Vert.Size = UDim2.new(0, 2, 1, 0); L_Vert.Position = UDim2.new(1, -2, 0, 0); L_Vert.BackgroundColor3 = Window.MainColor; L_Vert.BorderSizePixel = 0
    local L_Horz = Instance.new("Frame", Main); L_Horz.Size = UDim2.new(1, 0, 0, 2); L_Horz.Position = UDim2.new(0, 0, 1, -2); L_Horz.BackgroundColor3 = Window.MainColor; L_Horz.BorderSizePixel = 0

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 45); TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, Main)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "  " .. config.Name:upper(); Title.Size = UDim2.new(0.6, 0, 0, 25); Title.TextColor3 = Color3.new(1,1,1); Title.Font = "Code"; Title.TextSize = 13; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

    local SubTitle = Instance.new("TextLabel", TopBar)
    SubTitle.Text = "  SELECIONE UMA ÁREA"; SubTitle.Size = UDim2.new(0.6, 0, 0, 20); SubTitle.Position = UDim2.new(0, 0, 0, 22); SubTitle.TextColor3 = Window.MainColor; SubTitle.Font = "Code"; SubTitle.TextSize = 10; SubTitle.BackgroundTransparency = 1; SubTitle.TextXAlignment = "Left"

    local Close = Instance.new("TextButton", TopBar)
    Close.Size = UDim2.new(0, 35, 0, 35); Close.Position = UDim2.new(1, -35, 0, 5); Close.Text = "×"; Close.TextColor3 = Color3.fromRGB(255, 80, 80); Close.Font = "Code"; Close.TextSize = 22; Close.BackgroundTransparency = 1

    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, 35, 0, 35); MinBtn.Position = UDim2.new(1, -70, 0, 5); MinBtn.Text = "-"; MinBtn.TextColor3 = Color3.new(1,1,1); MinBtn.Font = "Code"; MinBtn.TextSize = 22; MinBtn.BackgroundTransparency = 1

    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1, 0, 1, -45); Body.Position = UDim2.new(0, 0, 0, 45); Body.BackgroundTransparency = 1

    MinBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Body.Visible = false
            TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 230, 0, 45)}):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = Window.Size}):Play()
            task.wait(0.4); Body.Visible = true
        end
    end)

    Close.MouseButton1Click:Connect(function()
        if Window.Closed then return end
        Window.Closed = true
        for _, cb in pairs(Window.Toggles) do pcall(function() cb(false) end) end
        local info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        TweenService:Create(Main, info, {Size = UDim2.new(0, 230, 0, 45)}):Play()
        task.wait(0.4); TweenService:Create(Main, info, {Size = UDim2.new(0, 0, 0, 45)}):Play()
        task.wait(0.4); ScreenGui:Destroy()
    end)

    local Sidebar = Instance.new("Frame", Body)
    Sidebar.Size = UDim2.new(0, 35, 1, -10); Sidebar.Position = UDim2.new(0, 5, 0, 5); Sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", Body)
    Container.Size = UDim2.new(1, -50, 1, -10); Container.Position = UDim2.new(0, 45, 0, 5); Container.BackgroundTransparency = 1

    function Window:Area(name, icon)
        Window.ConfigData[name] = Window.ConfigData[name] or {}
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.BorderSizePixel = 0; AreaFrame.ScrollBarThickness = 0; AreaFrame.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 28, 0, 28); TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBtn.BorderSizePixel = 0; TabBtn.Image = ICON_MAP[icon] or icon; TabBtn.ImageColor3 = Color3.fromRGB(100, 100, 100)
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("ImageButton") then v.ImageColor3 = Color3.fromRGB(100, 100, 100) end end
            AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor
            SubTitle.Text = "  " .. name:upper()
        end)

        if #Sidebar:GetChildren() == 2 then AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor; SubTitle.Text = "  " .. name:upper() end

        local Elements = {}

        function Elements:Button(txt, cb)
            local b = Instance.new("TextButton", AreaFrame); b.Size = UDim2.new(0.95, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.BorderSizePixel = 0; b.Text = " " .. txt:upper(); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 10; b.TextXAlignment = "Left"
            Ripple(b); b.MouseButton1Click:Connect(cb)
            return { SetText = function(_, nt) b.Text = " " .. nt:upper() end }
        end

        function Elements:Toggle(txt, def, cb)
            local s = Window.ConfigData[name][txt] or def or false
            local t = Instance.new("TextButton", AreaFrame); t.Size = UDim2.new(0.95, 0, 0, 30); t.BackgroundColor3 = Color3.fromRGB(22, 22, 22); t.BorderSizePixel = 0; t.Text = " " .. txt; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(120,120,120); t.Font = "Code"; t.TextSize = 10; t.TextXAlignment = "Left"
            local ind = Instance.new("Frame", t); ind.Size = UDim2.new(0, 3, 1, 0); ind.Position = UDim2.new(1, -3, 0, 0); ind.BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40); ind.BorderSizePixel = 0
            local function toggle(v)
                s = v; Window.ConfigData[name][txt] = s; Save()
                TweenService:Create(t, TweenInfo.new(0.2), {TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(120,120,120)}):Play()
                TweenService:Create(ind, TweenInfo.new(0.2), {BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40)}):Play()
                cb(s)
            end
            t.MouseButton1Click:Connect(function() toggle(not s) end)
            table.insert(Window.Toggles, function(v) if not v and s then cb(false) end end)
            if s then task.spawn(cb, s) end
        end

        function Elements:Input(txt, placeholder, cb)
            local f = Instance.new("Frame", AreaFrame); f.Size = UDim2.new(0.95, 0, 0, 42); f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.BorderSizePixel = 0
            local l = Instance.new("TextLabel", f); l.Text = " " .. txt:upper(); l.Size = UDim2.new(1, 0, 0, 16); l.TextColor3 = Window.MainColor; l.Font = "Code"; l.TextSize = 9; l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
            local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.9, 0, 0, 18); i.Position = UDim2.new(0.05, 0, 0.5, 0); i.BackgroundColor3 = Color3.fromRGB(10,10,10); i.BorderSizePixel = 0; i.Text = ""; i.PlaceholderText = placeholder; i.TextColor3 = Color3.new(1,1,1); i.Font = "Code"; i.TextSize = 10
            i.FocusLost:Connect(function(e) if e then cb(i.Text) end end)
        end

        function Elements:Label(txt)
            local l = Instance.new("TextLabel", AreaFrame); l.Size = UDim2.new(0.95, 0, 0, 18); l.BackgroundTransparency = 1; l.Text = "> " .. txt; l.TextColor3 = Color3.fromRGB(180,180,180); l.Font = "Code"; l.TextSize = 10; l.TextXAlignment = "Left"
            return { Update = function(_, nt) l.Text = "> " .. nt end, SetColor = function(_, c) l.TextColor3 = c end }
        end

        function Elements:Logs(h)
            local s = Instance.new("ScrollingFrame", AreaFrame); s.Size = UDim2.new(0.95, 0, 0, h or 100); s.BackgroundColor3 = Color3.new(0,0,0); s.BorderSizePixel = 0; s.ScrollBarThickness = 0; s.AutomaticCanvasSize = "Y"
            Instance.new("UIListLayout", s)
            return {
                Log = function(_, m, c)
                    local t = Instance.new("TextLabel", s); t.Size = UDim2.new(1, 0, 0, 14); t.BackgroundTransparency = 1; t.Text = " [" .. os.date("%X") .. "] " .. m; t.TextColor3 = c or Color3.new(1,1,1); t.Font = "Code"; t.TextSize = 9; t.TextXAlignment = "Left"
                    s.CanvasPosition = Vector2.new(0, 9999)
                end,
                Clear = function() for _, v in pairs(s:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end end
            }
        end
        return Elements
    end
    return Window
end

return luayV2
