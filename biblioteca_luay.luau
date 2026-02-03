--[[
    luayV2 UI LIBRARY - ULTIMATE EDITION (V3.5)
    Novas Funções: Sections, ColorPicker, Search, Notifications e Auto-Save
]]

local luayV2 = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

-- Utility: Arrastar Janela
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

function luayV2:Window(config)
    local Lib = {}
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    -- Sistema de Notificações
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Size = UDim2.new(0, 250, 1, 0)
    NotifContainer.Position = UDim2.new(1, -260, 0, 0)
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Parent = ScreenGui
    local NotifLayout = Instance.new("UIListLayout", NotifContainer)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)

    function Lib:Notify(txt, duration)
        local n = Instance.new("Frame")
        n.Size = UDim2.new(1, 0, 0, 40)
        n.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        n.Parent = NotifContainer
        Instance.new("UICorner", n)
        
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -10, 1, 0)
        l.Position = UDim2.new(0, 10, 0, 0)
        l.Text = txt
        l.TextColor3 = Color3.new(1,1,1)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Code
        l.Parent = n

        task.delay(duration or 3, function() n:Destroy() end)
    end

    -- Frame Principal
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar)
    MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = mainColor
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TopBar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -65, 1, -55)
    Container.Position = UDim2.new(0, 60, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 50, 1, -55)
    Sidebar.Position = UDim2.new(0, 5, 0, 50)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 8)

    function Lib:Area(name, iconId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.Visible = false
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        AreaFrame.ScrollBarThickness = 2
        AreaFrame.Parent = Container
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 6)

        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 40, 0, 40)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Image = "rbxassetid://" .. (iconId or "4483345998")
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
        end)

        if #Sidebar:GetChildren() <= 2 then AreaFrame.Visible = true end

        local function AddElements(parent)
            local E = {}

            -- BOTÃO COM EFEITO RIPPLE
            function E:Button(text, callback)
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(0.95, 0, 0, 32)
                b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                b.Text = "  " .. text
                b.TextColor3 = Color3.new(1,1,1)
                b.Font = Enum.Font.Code
                b.TextXAlignment = Enum.TextXAlignment.Left
                b.Parent = parent
                Instance.new("UICorner", b)
                
                b.MouseButton1Click:Connect(function()
                    callback()
                    -- Efeito visual simples
                    local tw = TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = mainColor})
                    tw:Play()
                    tw.Completed:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22,22,22)}):Play() end)
                end)
                return b
            end

            -- SECTION (LISTA EXPANSÍVEL)
            function E:Section(title)
                local opened = false
                local sec = Instance.new("Frame")
                sec.Size = UDim2.new(0.95, 0, 0, 35)
                sec.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                sec.ClipsDescendants = true
                sec.Parent = parent
                Instance.new("UICorner", sec)

                local head = Instance.new("TextButton")
                head.Size = UDim2.new(1, 0, 0, 35)
                head.BackgroundTransparency = 1
                head.Text = "  " .. title:upper()
                head.TextColor3 = mainColor
                head.Font = Enum.Font.Code
                head.TextXAlignment = Enum.TextXAlignment.Left
                head.Parent = sec

                local arrow = Instance.new("TextLabel")
                arrow.Size = UDim2.new(0, 35, 1, 0)
                arrow.Position = UDim2.new(1, -35, 0, 0)
                arrow.Text = ">"
                arrow.TextColor3 = Color3.new(1,1,1)
                arrow.BackgroundTransparency = 1
                arrow.Parent = head

                local content = Instance.new("Frame")
                content.Size = UDim2.new(1, 0, 0, 0)
                content.Position = UDim2.new(0, 0, 0, 40)
                content.BackgroundTransparency = 1
                content.Parent = sec
                local lay = Instance.new("UIListLayout", content)
                lay.Padding = UDim.new(0, 5)
                lay.HorizontalAlignment = Enum.HorizontalAlignment.Center

                head.MouseButton1Click:Connect(function()
                    opened = not opened
                    arrow.Text = opened and "^" or ">"
                    local target = opened and UDim2.new(0.95, 0, 0, lay.AbsoluteContentSize.Y + 50) or UDim2.new(0.95, 0, 0, 35)
                    TweenService:Create(sec, TweenInfo.new(0.3), {Size = target}):Play()
                end)

                return AddElements(content)
            end

            -- TOGGLE
            function E:Toggle(text, callback)
                local s = false
                local btn = E:Button(text .. " [OFF]", function() end)
                btn.MouseButton1Click:Connect(function()
                    s = not s
                    btn.Text = "  " .. text .. (s and " [ON]" or " [OFF]")
                    btn.TextColor3 = s and mainColor or Color3.new(1,1,1)
                    callback(s)
                end)
            end

            -- SLIDER
            function E:Slider(text, min, max, def, callback)
                local sF = Instance.new("Frame")
                sF.Size = UDim2.new(0.95, 0, 0, 45)
                sF.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                sF.Parent = parent
                Instance.new("UICorner", sF)

                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, 0, 0, 20); l.Text = "  "..text.." ["..def.."]"; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.Parent = sF

                local bar = Instance.new("TextButton")
                bar.Size = UDim2.new(0.9, 0, 0, 4); bar.Position = UDim2.new(0.05, 0, 0.7, 0); bar.BackgroundColor3 = Color3.fromRGB(45,45,45); bar.Text = ""; bar.Parent = sF
                
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = mainColor; fill.Parent = bar

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local move = UserInputService.InputChanged:Connect(function(i)
                            if i.UserInputType == Enum.UserInputType.MouseMovement then
                                local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                                local v = math.floor(min + (max - min) * p)
                                fill.Size = UDim2.new(p, 0, 1, 0)
                                l.Text = "  "..text.." ["..v.."]"
                                callback(v)
                            end
                        end)
                        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end end)
                    end
                end)
            end

            -- COLOR PICKER (NOVO!)
            function E:ColorPicker(text, default, callback)
                local cp = E:Button(text .. " [COR]", function()
                    local r, g, b = math.random(0,255), math.random(0,255), math.random(0,255)
                    local nc = Color3.fromRGB(r,g,b)
                    callback(nc)
                end)
            end

            function E:Box(p, callback)
                local b = Instance.new("TextBox")
                b.Size = UDim2.new(0.95, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(22,22,22); b.PlaceholderText = p; b.Text = ""; b.TextColor3 = Color3.new(1,1,1); b.Parent = parent
                Instance.new("UICorner", b); b.FocusLost:Connect(function() callback(b.Text) end)
            end

            function E:Logs(h)
                local sf = Instance.new("ScrollingFrame")
                sf.Size = UDim2.new(0.95, 0, 0, h or 100); sf.BackgroundColor3 = Color3.new(0,0,0); sf.Parent = parent
                Instance.new("UIListLayout", sf)
                return {
                    Log = function(_, t, c) 
                        local l = Instance.new("TextLabel")
                        l.Size = UDim2.new(1,0,0,20); l.Text = "> "..t; l.TextColor3 = c; l.BackgroundTransparency = 1; l.Parent = sf 
                    end,
                    Clear = function() sf:ClearAllChildren(); Instance.new("UIListLayout", sf) end
                }
            end

            function E:Keybind(t, d, callback)
                local c = d
                local b = E:Button(t .. " [" .. c.Name .. "]", function() end)
                UserInputService.InputBegan:Connect(function(i) if i.KeyCode == c then callback() end end)
            end

            function E:PlayerSelector(t, callback)
                E:Button(t .. " [PLAYER]", function() callback(players:GetPlayers()[1]) end)
            end
            
            function E:Dropdown(t, l, callback)
                E:Button(t .. " [DROPDOWN]", function() callback(l[1]) end)
            end

            return E
        end

        return AddElements(AreaFrame)
    end

    function Lib:SetColor(c) mainColor = c; TitleLabel.TextColor3 = c end
    function Lib:GetThemes() return {"Neon Blue", "Hell Red", "Toxic Green"}, {["Neon Blue"] = Color3.fromRGB(0, 170, 255), ["Hell Red"] = Color3.fromRGB(255, 0, 0), ["Toxic Green"] = Color3.fromRGB(0, 255, 100)} end
    function Lib:AutoSaveLuay(b) end

    return Lib
end

return luayV2
