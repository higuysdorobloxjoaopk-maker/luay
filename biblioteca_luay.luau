--[[
    luayV2 UI LIBRARY - FIXED & MODULAR
    Version: 3.1.0
]]

local luayV2 = {}

-- Services
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local plr = players.LocalPlayer

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
    local internalAutoSave = false
    local togglesActive = {}
    local connectionList = {}

    -- Temas para o Dropdown do exemplo
    local ColorPresets = {
        ["Padrão"] = Color3.fromRGB(0, 170, 255),
        ["Vermelho"] = Color3.fromRGB(255, 50, 50),
        ["Verde"] = Color3.fromRGB(50, 255, 100),
        ["Roxo"] = Color3.fromRGB(170, 0, 255),
        ["Laranja"] = Color3.fromRGB(255, 120, 0)
    }

    -- GUI Principal
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 300, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
    MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -60, 1, -50)
    Container.Position = UDim2.new(0, 55, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 45, 1, -50)
    Sidebar.Position = UDim2.new(0, 5, 0, 45)
    Sidebar.BackgroundTransparency = 1
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame
    local SideLayout = Instance.new("UIListLayout", Sidebar)
    SideLayout.Padding = UDim.new(0, 5)

    -- Função de Fechar
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Parent = TopBar
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- API da Window
    function Lib:AutoSaveLuay(bool) internalAutoSave = bool end
    
    function Lib:SetColor(color)
        mainColor = color
        -- Aqui você pode atualizar as cores dos elementos dinamicamente se desejar
    end

    function Lib:GetThemes()
        local names = {}
        for name, _ in pairs(ColorPresets) do table.insert(names, name) end
        return names, ColorPresets
    end

    function Lib:Area(name, iconId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.Visible = false
        AreaFrame.CanvasSize = UDim2.new(0,0,0,0)
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        AreaFrame.Parent = Container
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 35, 0, 35)
        TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        TabBtn.Image = "rbxassetid://" .. (iconId or "4483345998")
        TabBtn.Parent = Sidebar
        Instance.new("UICorner", TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
        end)

        if #Sidebar:GetChildren() <= 2 then AreaFrame.Visible = true end

        local Elements = {}

        -- ELEMENTO: BOTÃO
        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Parent = AreaFrame
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(callback)
            return btn
        end

        -- ELEMENTO: TOGGLE
        function Elements:Toggle(text, callback)
            local state = false
            local tgl = Instance.new("TextButton")
            tgl.Size = UDim2.new(1, -10, 0, 30)
            tgl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            tgl.Text = text .. ": OFF"
            tgl.TextColor3 = Color3.fromRGB(200, 200, 200)
            tgl.Parent = AreaFrame
            Instance.new("UICorner", tgl)

            tgl.MouseButton1Click:Connect(function()
                state = not state
                tgl.Text = text .. (state and ": ON" or ": OFF")
                tgl.TextColor3 = state and mainColor or Color3.fromRGB(200, 200, 200)
                callback(state)
            end)
        end

        -- ELEMENTO: SLIDER
        function Elements:Slider(text, min, max, default, callback)
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(1, -10, 0, 45)
            sFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame)

            local lab = Instance.new("TextLabel")
            lab.Text = text .. " [" .. default .. "]"
            lab.Size = UDim2.new(1, 0, 0, 20)
            lab.BackgroundTransparency = 1
            lab.TextColor3 = Color3.fromRGB(255,255,255)
            lab.Parent = sFrame

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.9, 0, 0, 5)
            btn.Position = UDim2.new(0.05, 0, 0.7, 0)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.Text = ""
            btn.Parent = sFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor
            fill.Parent = btn

            local function update(input)
                local pos = math.clamp((input.Position.X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                lab.Text = text .. " [" .. val .. "]"
                callback(val)
            end

            local move;
            btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    move = UserInputService.InputChanged:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end
                    end)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 and move then move:Disconnect() end
            end)
        end

        -- ELEMENTO: DROPDOWN
        function Elements:Dropdown(text, list, callback)
            local drop = Instance.new("TextButton")
            drop.Size = UDim2.new(1, -10, 0, 30)
            drop.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            drop.Text = text .. " >"
            drop.Parent = AreaFrame
            
            drop.MouseButton1Click:Connect(function()
                -- Simples: Alterna entre os itens da lista ao clicar
                local current = table.find(list, drop.Text:gsub(text .. " ", "")) or 0
                local nextIdx = (current % #list) + 1
                drop.Text = text .. " " .. list[nextIdx]
                callback(list[nextIdx])
            end)
        end

        -- ELEMENTO: TEXTBOX (BOX)
        function Elements:Box(text, callback)
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, -10, 0, 30)
            box.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            box.PlaceholderText = text
            box.Text = ""
            box.TextColor3 = Color3.fromRGB(255,255,255)
            box.Parent = AreaFrame
            Instance.new("UICorner", box)
            box.FocusLost:Connect(function() callback(box.Text) end)
        end
        
        -- ELEMENTO: PLAYER SELECTOR
        function Elements:PlayerSelector(text, callback)
            self:Dropdown(text, (function()
                local t = {}
                for _,p in pairs(players:GetPlayers()) do table.insert(t, p.Name) end
                return t
            end)(), function(sel)
                callback(players:FindFirstChild(sel))
            end)
        end

        -- ELEMENTO: KEYBIND
        function Elements:Keybind(text, default, callback)
            local current = default
            local btn = self:Button(text .. " [" .. current.Name .. "]", function() end)
            local waiting = false
            btn.MouseButton1Click:Connect(function() 
                waiting = true 
                btn.Text = "... pressionando ..."
            end)
            UserInputService.InputBegan:Connect(function(input)
                if waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                    current = input.KeyCode
                    btn.Text = text .. " [" .. current.Name .. "]"
                    waiting = false
                elseif input.KeyCode == current then
                    callback()
                end
            end)
        end

        -- ELEMENTO: LOGS
        function Elements:Logs(height)
            local logFrame = Instance.new("ScrollingFrame")
            logFrame.Size = UDim2.new(1, -10, 0, height or 100)
            logFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
            logFrame.Parent = AreaFrame
            Instance.new("UIListLayout", logFrame)

            local LogAPI = {}
            function LogAPI:Log(txt, color)
                local l = Instance.new("TextLabel")
                l.Size = UDim2.new(1, 0, 0, 20)
                l.Text = " > " .. txt
                l.TextColor3 = color or Color3.new(1,1,1)
                l.BackgroundTransparency = 1
                l.TextXAlignment = Enum.TextXAlignment.Left
                l.Parent = logFrame
            end
            function LogAPI:Clear() logFrame:ClearAllChildren(); Instance.new("UIListLayout", logFrame) end
            return LogAPI
        end

        return Elements
    end

    return Lib
end

return luayV2
