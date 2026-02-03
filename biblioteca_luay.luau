local luayV2 = {}

-- [[ SERVICES ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local plr = players.LocalPlayer

-- [[ UTILS ]] --
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

-- [[ MAIN WINDOW ]] --
function luayV2:Window(config)
    local Lib = {}
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local currentArea = nil
    local internalAutoSave = false
    
    -- Root GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = (gethui and gethui()) or CoreGui or plr:WaitForChild("PlayerGui")

    -- Notificações Premium
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "NotifHolder"
    NotifHolder.Size = UDim2.new(0, 250, 1, -20)
    NotifHolder.Position = UDim2.new(1, -260, 0, 10)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui
    local NotifLayout = Instance.new("UIListLayout", NotifHolder)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 8)

    function Lib:Notify(txt, duration)
        local n = Instance.new("Frame")
        n.Size = UDim2.new(1, 0, 0, 45)
        n.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        n.BorderSizePixel = 0
        n.Parent = NotifHolder
        Instance.new("UICorner", n).CornerRadius = UDim.new(0, 6)
        
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 3, 1, 0)
        accent.BackgroundColor3 = mainColor
        accent.Parent = n
        Instance.new("UICorner", accent)

        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -15, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.Text = txt
        l.TextColor3 = Color3.new(1,1,1)
        l.Font = Enum.Font.Code
        l.TextSize = 13
        l.BackgroundTransparency = 1
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = n

        task.delay(duration or 4, function()
            TweenService:Create(n, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            TweenService:Create(l, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            task.wait(0.5)
            n:Destroy()
        end)
    end

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 330, 0, 430)
    MainFrame.Position = UDim2.new(0.5, -165, 0.5, -215)
    MainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 13)
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar)
    MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = mainColor
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TopBar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -70, 1, -60)
    Container.Position = UDim2.new(0, 65, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 50, 1, -60)
    Sidebar.Position = UDim2.new(0, 8, 0, 55)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 10)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- [[ AREA FUNCTION ]] --
    function Lib:Area(name, iconId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.Visible = false
        AreaFrame.ScrollBarThickness = 2
        AreaFrame.ScrollBarImageColor3 = mainColor
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        AreaFrame.Parent = Container
        local AreaLayout = Instance.new("UIListLayout", AreaFrame)
        AreaLayout.Padding = UDim.new(0, 6)
        AreaLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 38, 0, 38)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Image = "rbxassetid://" .. (iconId or "4483345998")
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = mainColor}):Play()
            task.wait(0.1)
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(25,25,25)}):Play()
        end)

        if not currentArea then AreaFrame.Visible = true; currentArea = true end

        local Elements = {}

        -- BUTTON
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.96, 0, 0, 35)
            btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            btn.Text = "  " .. text
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.Code
            btn.TextSize = 13
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.Parent = AreaFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            
            btn.MouseButton1Click:Connect(function()
                pcall(callback)
                local circle = Instance.new("Frame")
                circle.Size = UDim2.new(0,0,0,0); circle.BackgroundColor3 = Color3.new(1,1,1); circle.BackgroundTransparency = 0.8; circle.Parent = btn
                Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)
                circle.Position = UDim2.new(0, mouse.X - btn.AbsolutePosition.X, 0, mouse.Y - btn.AbsolutePosition.Y)
                TweenService:Create(circle, TweenInfo.new(0.4), {Size = UDim2.new(0,200,0,200), Position = circle.Position - UDim2.new(0,100,0,100), BackgroundTransparency = 1}):Play()
            end)
            return btn
        end

        -- TOGGLE
        function Elements:Toggle(text, callback)
            local active = false
            local tBtn = Instance.new("TextButton")
            tBtn.Size = UDim2.new(0.96, 0, 0, 35)
            tBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            tBtn.Text = "  " .. text
            tBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            tBtn.Font = Enum.Font.Code
            tBtn.TextXAlignment = Enum.TextXAlignment.Left
            tBtn.Parent = AreaFrame
            Instance.new("UICorner", tBtn)

            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 35, 0, 18)
            box.Position = UDim2.new(1, -45, 0.5, -9)
            box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            box.Parent = tBtn
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new(0, 2, 0.5, -7)
            knob.BackgroundColor3 = Color3.new(0.6, 0.6, 0.6)
            knob.Parent = box
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            tBtn.MouseButton1Click:Connect(function()
                active = not active
                local targetX = active and 19 or 2
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, targetX, 0.5, -7), BackgroundColor3 = active and mainColor or Color3.new(0.6,0.6,0.6)}):Play()
                tBtn.TextColor3 = active and Color3.new(1,1,1) or Color3.fromRGB(200,200,200)
                callback(active)
            end)
        end

        -- SLIDER
        function Elements:Slider(text, min, max, default, callback)
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.96, 0, 0, 50)
            sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame)

            local lab = Instance.new("TextLabel")
            lab.Size = UDim2.new(1, 0, 0, 25); lab.Text = "  " .. text:upper() .. " [" .. default .. "]"; lab.TextColor3 = Color3.new(0.8,0.8,0.8); lab.Font = Enum.Font.Code; lab.BackgroundTransparency = 1; lab.TextXAlignment = Enum.TextXAlignment.Left; lab.Parent = sFrame

            local bar = Instance.new("TextButton")
            bar.Size = UDim2.new(0.9, 0, 0, 5); bar.Position = UDim2.new(0.05, 0, 0.7, 0); bar.BackgroundColor3 = Color3.fromRGB(45,45,45); bar.Text = ""; bar.Parent = sFrame
            Instance.new("UICorner", bar)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = mainColor; fill.Parent = bar
            Instance.new("UICorner", fill)

            local function update(input)
                local p = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * p)
                fill.Size = UDim2.new(p, 0, 1, 0)
                lab.Text = "  " .. text:upper() .. " [" .. val .. "]"
                callback(val)
            end

            local dragging = false
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
        end

        -- SECTION (O QUE VOCÊ PEDIU)
        function Elements:Section(title)
            local opened = false
            local secFrame = Instance.new("Frame")
            secFrame.Size = UDim2.new(0.96, 0, 0, 35)
            secFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            secFrame.ClipsDescendants = true
            secFrame.Parent = AreaFrame
            Instance.new("UICorner", secFrame)

            local head = Instance.new("TextButton")
            head.Size = UDim2.new(1, 0, 0, 35)
            head.BackgroundTransparency = 1
            head.Text = "  " .. title:upper()
            head.TextColor3 = mainColor
            head.Font = Enum.Font.Code
            head.TextXAlignment = Enum.TextXAlignment.Left
            head.Parent = secFrame

            local arrow = Instance.new("TextLabel")
            arrow.Size = UDim2.new(0, 35, 1, 0); arrow.Position = UDim2.new(1, -35, 0, 0); arrow.Text = ">"; arrow.TextColor3 = Color3.new(1,1,1); arrow.BackgroundTransparency = 1; arrow.Parent = head

            local content = Instance.new("Frame")
            content.Size = UDim2.new(1, 0, 0, 0); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.Parent = secFrame
            local lay = Instance.new("UIListLayout", content); lay.Padding = UDim.new(0, 5); lay.HorizontalAlignment = Enum.HorizontalAlignment.Center

            head.MouseButton1Click:Connect(function()
                opened = not opened
                arrow.Text = opened and "^" or ">"
                local targetY = opened and lay.AbsoluteContentSize.Y + 45 or 35
                TweenService:Create(secFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0.96, 0, 0, targetY)}):Play()
            end)

            -- Retorna as funções para poder usar dentro da seção
            local SecElements = {}
            function SecElements:Button(t, c) return Elements:Button(t, c) end
            SecElements.Parent = content -- Hack para colocar o elemento no lugar certo
            
            -- Aqui, você pode repetir os Elements para a Section, mas redirecionando o Parent:
            local function Redirect(funcName)
                return function(self, ...)
                    local oldParent = AreaFrame
                    AreaFrame = content
                    local result = Elements[funcName](Elements, ...)
                    AreaFrame = oldParent
                    return result
                end
            end

            return {
                Button = Redirect("Button"),
                Toggle = Redirect("Toggle"),
                Slider = Redirect("Slider"),
                Box = Redirect("Box")
            }
        end

        -- PLAYER SELECTOR
        function Elements:PlayerSelector(text, callback)
            local pBtn = Elements:Button(text .. " [SELECIONAR]", function()
                local p = players:GetPlayers()
                callback(p[math.random(1, #p)])
            end)
        end

        -- BOX (TEXTBOX)
        function Elements:Box(placeholder, callback)
            local b = Instance.new("TextBox")
            b.Size = UDim2.new(0.96, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(22,22,22); b.PlaceholderText = placeholder; b.Text = ""; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.Parent = AreaFrame
            Instance.new("UICorner", b); b.FocusLost:Connect(function() callback(b.Text) end)
        end

        -- LOGS
        function Elements:Logs(height)
            local logFrame = Instance.new("ScrollingFrame")
            logFrame.Size = UDim2.new(0.96, 0, 0, height or 100); logFrame.BackgroundColor3 = Color3.new(0,0,0); logFrame.BorderSizePixel = 0; logFrame.Parent = AreaFrame
            Instance.new("UIListLayout", logFrame)
            return {
                Log = function(_, txt, color)
                    local l = Instance.new("TextLabel")
                    l.Size = UDim2.new(1, 0, 0, 20); l.Text = " > " .. txt; l.TextColor3 = color or Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = logFrame
                end,
                Clear = function() logFrame:ClearAllChildren(); Instance.new("UIListLayout", logFrame) end
            }
        end

        -- KEYBIND
        function Elements:Keybind(text, default, callback)
            local key = default
            local b = Elements:Button(text .. " [" .. key.Name .. "]", function() end)
            UserInputService.InputBegan:Connect(function(i) if i.KeyCode == key then callback() end end)
        end

        return Elements
    end

    function Lib:SetColor(c) mainColor = c; TitleLabel.TextColor3 = c end
    function Lib:GetThemes() return {"Neon", "Red", "Green"}, {Neon = Color3.fromRGB(0,170,255), Red = Color3.fromRGB(255,0,0), Green = Color3.fromRGB(0,255,0)} end
    function Lib:AutoSaveLuay(v) internalAutoSave = v end

    return Lib
end

return luayV2
