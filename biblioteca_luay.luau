--[[
    luayV2 UI LIBRARY - ULTIMATE EDITION v3.5
    Desenvolvida para ser completa, pesada e funcional.
    Suporte Total: Mobile (Touch) & PC (Mouse)
]]

local luayV2 = {}

-- [[ SERVIÇOS DO SISTEMA ]] --
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ UTILITÁRIOS INTERNOS ]] --
local function MakeDraggable(topbarobject, object)
    local dragging, dragInput, dragStart, startPos
    topbarobject.InputBegan:Connect(function(input)
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

-- [[ ENGINE DA JANELA PRINCIPAL ]] --
function luayV2:Window(config)
    local WindowLib = {
        Color = config.Color or Color3.fromRGB(0, 170, 255),
        Title = config.Name or "luayV2",
        CurrentArea = nil,
        Closed = false
    }

    -- Root GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root_" .. math.random(100, 999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    -- Main Frame (O design que você mandou)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner", MainFrame)
    MainCorner.CornerRadius = UDim.new(0, 8)

    local SideAccent = Instance.new("Frame", MainFrame)
    SideAccent.Size = UDim2.new(0, 3, 1, 0)
    SideAccent.BackgroundColor3 = WindowLib.Color
    SideAccent.BorderSizePixel = 0

    -- TopBar & Controls
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.Size = UDim2.new(1, -90, 0, 30); TitleLabel.Position = UDim2.new(0, 15, 0, 5)
    TitleLabel.Text = WindowLib.Title:upper(); TitleLabel.TextColor3 = Color3.new(1,1,1)
    TitleLabel.Font = Enum.Font.Code; TitleLabel.TextSize = 16; TitleLabel.TextXAlignment = 0; TitleLabel.BackgroundTransparency = 1

    local Subtitle = Instance.new("TextLabel", TopBar)
    Subtitle.Size = UDim2.new(1, -90, 0, 15); Subtitle.Position = UDim2.new(0, 15, 0, 28)
    Subtitle.Text = "STABLE EDITION"; Subtitle.TextColor3 = WindowLib.Color
    Subtitle.Font = Enum.Font.Code; Subtitle.TextSize = 10; Subtitle.TextXAlignment = 0; Subtitle.BackgroundTransparency = 1

    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 35, 0, 35); CloseBtn.Position = UDim2.new(1, -40, 0, 7)
    CloseBtn.Text = "×"; CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80); CloseBtn.BackgroundTransparency = 1; CloseBtn.TextSize = 25
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Sidebar
    local Sidebar = Instance.new("ScrollingFrame", MainFrame)
    Sidebar.Size = UDim2.new(0, 50, 1, -90); Sidebar.Position = UDim2.new(0, 8, 0, 60)
    Sidebar.BackgroundTransparency = 1; Sidebar.BorderSizePixel = 0; Sidebar.ScrollBarThickness = 0
    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 10); SideLayout.HorizontalAlignment = 1

    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -75, 1, -95); Container.Position = UDim2.new(0, 65, 0, 60)
    Container.BackgroundTransparency = 1

    -- [[ NOTIFICATION SYSTEM ]] --
    local NotifContainer = Instance.new("Frame", ScreenGui)
    NotifContainer.Size = UDim2.new(0, 250, 1, 0); NotifContainer.Position = UDim2.new(1, -260, 0, 0); NotifContainer.BackgroundTransparency = 1
    Instance.new("UIListLayout", NotifContainer).VerticalAlignment = 2

    function WindowLib:Notify(txt, dur)
        local n = Instance.new("Frame", NotifContainer)
        n.Size = UDim2.new(1, 0, 0, 0); n.BackgroundColor3 = Color3.fromRGB(18, 18, 18); n.BorderSizePixel = 0; n.ClipsDescendants = true
        Instance.new("UICorner", n)
        local l = Instance.new("TextLabel", n)
        l.Size = UDim2.new(1, -20, 1, 0); l.Position = UDim2.new(0, 10, 0, 0); l.Text = txt; l.TextColor3 = Color3.new(1,1,1)
        l.Font = Enum.Font.Code; l.TextSize = 12; l.BackgroundTransparency = 1; l.TextWrapped = true
        
        TweenService:Create(n, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 50)}):Play()
        task.delay(dur or 4, function()
            TweenService:Create(n, TweenInfo.new(0.4), {Size = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.4); n:Destroy()
        end)
    end

    -- [[ ÁREAS E ELEMENTOS ]] --
    function WindowLib:Area(name, iconId)
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.BorderSizePixel = 0
        AreaFrame.Visible = false; AreaFrame.ScrollBarThickness = 2; AreaFrame.AutomaticCanvasSize = 2
        local AreaLayout = Instance.new("UIListLayout", AreaFrame); AreaLayout.Padding = UDim.new(0, 8)

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 35, 0, 35); TabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); TabBtn.Image = "rbxassetid://"..(iconId or "4483345998")
        Instance.new("UICorner", TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaFrame.Visible = true
            Subtitle.Text = name:upper()
        end)

        if not WindowLib.CurrentArea then AreaFrame.Visible = true; WindowLib.CurrentArea = true; Subtitle.Text = name:upper() end

        local Elements = {}

        -- SECTION (Com Bug fix de tamanho)
        function Elements:Section(title)
            local sec = Instance.new("Frame", AreaFrame)
            sec.Size = UDim2.new(0.95, 0, 0, 35); sec.BackgroundColor3 = Color3.fromRGB(20, 20, 20); sec.ClipsDescendants = true
            Instance.new("UICorner", sec)
            
            local h = Instance.new("TextButton", sec)
            h.Size = UDim2.new(1, 0, 0, 35); h.BackgroundTransparency = 1; h.Text = "  " .. title:upper() .. "  >"; h.TextColor3 = WindowLib.Color; h.Font = Enum.Font.Code; h.TextXAlignment = 0

            local cF = Instance.new("Frame", sec)
            cF.Size = UDim2.new(1, 0, 0, 0); cF.Position = UDim2.new(0, 0, 0, 35); cF.BackgroundTransparency = 1
            local lay = Instance.new("UIListLayout", cF); lay.Padding = UDim.new(0, 5)

            h.MouseButton1Click:Connect(function()
                local open = sec.Size.Y.Offset < 40
                local targetH = open and (lay.AbsoluteContentSize.Y + 45) or 35
                TweenService:Create(sec, TweenInfo.new(0.3), {Size = UDim2.new(0.95, 0, 0, targetH)}):Play()
                h.Text = "  " .. title:upper() .. (open and "  ^" or "  >")
            end)

            local sub = {}
            function sub:Button(t, c)
                local b = Instance.new("TextButton", cF)
                b.Size = UDim2.new(1, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(30, 30, 30); b.Text = "  " .. t; b.TextColor3 = Color3.new(1,1,1); b.Font = 3; b.TextXAlignment = 0
                Instance.new("UICorner", b)
                b.MouseButton1Click:Connect(c)
            end
            return sub
        end

        -- TOGGLE
        function Elements:Toggle(text, callback)
            local state = false
            local tBtn = Instance.new("TextButton", AreaFrame)
            tBtn.Size = UDim2.new(0.95, 0, 0, 35); tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); tBtn.Text = ""
            Instance.new("UICorner", tBtn)

            local label = Instance.new("TextLabel", tBtn)
            label.Size = UDim2.new(1, -50, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.Text = text; label.TextColor3 = Color3.new(0.8,0.8,0.8); label.Font = 3; label.TextXAlignment = 0; label.BackgroundTransparency = 1

            local box = Instance.new("Frame", tBtn)
            box.Size = UDim2.new(0, 35, 0, 18); box.Position = UDim2.new(1, -45, 0.5, -9); box.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", box)
            knob.Size = UDim2.new(0, 14, 0, 14); knob.Position = UDim2.new(0, 2, 0.5, -7); knob.BackgroundColor3 = Color3.new(0.6,0.6,0.6)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            tBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = state and WindowLib.Color or Color3.new(0.6,0.6,0.6)}):Play()
                callback(state)
            end)
        end

        -- RESPONSIVE SLIDER
        function Elements:Slider(text, min, max, def, callback)
            local sFrame = Instance.new("Frame", AreaFrame)
            sFrame.Size = UDim2.new(0.95, 0, 0, 50); sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Instance.new("UICorner", sFrame)

            local label = Instance.new("TextLabel", sFrame)
            label.Size = UDim2.new(1, 0, 0, 25); label.Text = "  "..text:upper(); label.TextColor3 = Color3.new(0.7,0.7,0.7); label.Font = 3; label.TextXAlignment = 0; label.BackgroundTransparency = 1

            local valLabel = Instance.new("TextLabel", sFrame)
            valLabel.Size = UDim2.new(0, 40, 0, 25); valLabel.Position = UDim2.new(1, -45, 0, 0); valLabel.Text = tostring(def); valLabel.TextColor3 = WindowLib.Color; valLabel.Font = 3; valLabel.BackgroundTransparency = 1

            local bar = Instance.new("TextButton", sFrame)
            bar.Size = UDim2.new(0.9, 0, 0, 6); bar.Position = UDim2.new(0.05, 0, 0.7, 0); bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45); bar.Text = ""
            Instance.new("UICorner", bar)

            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = WindowLib.Color; fill.BorderSizePixel = 0
            Instance.new("UICorner", fill)

            local function update(input)
                local sizeX = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * sizeX)
                fill.Size = UDim2.new(sizeX, 0, 1, 0)
                valLabel.Text = tostring(value)
                callback(value)
            end

            local dragging = false
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true; update(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        -- LOG SYSTEM
        function Elements:Logs(h)
            local lF = Instance.new("ScrollingFrame", AreaFrame)
            lF.Size = UDim2.new(0.95, 0, 0, h or 100); lF.BackgroundColor3 = Color3.new(0.05, 0.05, 0.05); lF.BorderSizePixel = 0
            lF.ScrollBarThickness = 2; lF.AutomaticCanvasSize = 2
            Instance.new("UIListLayout", lF)
            return {
                Log = function(_, txt, col)
                    local l = Instance.new("TextLabel", lF)
                    l.Size = UDim2.new(1, 0, 0, 20); l.Text = " > "..txt; l.TextColor3 = col or Color3.new(1,1,1)
                    l.Font = 3; l.TextSize = 11; l.TextXAlignment = 0; l.BackgroundTransparency = 1
                end,
                Clear = function() for _,v in pairs(lF:GetChildren()) do if v:IsA("TextLabel") then v:Destroy() end end end
            }
        end

        -- PLAYER SELECTOR
        function Elements:PlayerSelector(txt, callback)
            local sel = nil
            local btn = Elements:Button(txt .. ": NONE", function()
                sel = Players:GetPlayers()[math.random(1, #Players:GetPlayers())]
                callback(sel)
            end)
        end

        function Elements:Button(text, callback)
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(0.95, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(22, 22, 22); b.Text = "  "..text; b.TextColor3 = Color3.new(1,1,1)
            b.Font = 3; b.TextSize = 12; b.TextXAlignment = 0; Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(callback)
            return b
        end

        return Elements
    end

    return WindowLib
end

return luayV2
