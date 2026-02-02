local luayV2 = {}
local HttpService = game:GetService("HttpService")
local players = game:GetService("Players")
local plr = players.LocalPlayer

function luayV2:Window(config)
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local footerText = config.Footer or "luayV2 | Community"
    local fileName = "luayV2_Config_" .. plr.UserId .. ".json"
    
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local SaveData = {}
    local internalAutoSave = false
    local currentArea = nil

    local function SaveToFile()
        if not internalAutoSave then return end
        local success, json = pcall(function() return HttpService:JSONEncode(SaveData) end)
        if success and writefile then writefile(fileName, json) end
    end

    local function LoadFromFile()
        if isfile and isfile(fileName) then
            local success, content = pcall(function() return readfile(fileName) end)
            if success then return HttpService:JSONDecode(content) end
        end
        return {}
    end

    local Configs = LoadFromFile()

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_UI"
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 280, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 0, 25)
    TitleLabel.Position = UDim2.new(0, 12, 0, 2)
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(1, -80, 0, 15)
    SubtitleLabel.Position = UDim2.new(0, 12, 0, 22)
    SubtitleLabel.Text = "PRINCIPAL"
    SubtitleLabel.TextColor3 = mainColor
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Code
    SubtitleLabel.TextSize = 11
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = TopBar

    -- Botões de Controle
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.TextSize = 22
    CloseBtn.Parent = TopBar
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 35, 0, 35)
    MiniBtn.Position = UDim2.new(1, -70, 0, 0)
    MiniBtn.Text = "_"
    MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.Font = Enum.Font.Gotham
    MiniBtn.TextSize = 20
    MiniBtn.Parent = TopBar

    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 380)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 45, 1, -65)
    Sidebar.Position = UDim2.new(0, 5, 0, 50)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Parent = Sidebar
    SideLayout.Padding = UDim.new(0, 8)
    SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -60, 1, -65)
    Container.Position = UDim2.new(0, 55, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    local Lib = {}

    function Lib:Area(name, imageId)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.BorderSizePixel = 0
        AreaFrame.ScrollBarThickness = 2
        AreaFrame.ScrollBarImageColor3 = mainColor
        AreaFrame.Visible = false
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        AreaFrame.Parent = Container

        local Layout = Instance.new("UIListLayout")
        Layout.Parent = AreaFrame
        Layout.Padding = UDim.new(0, 6)
        
        local AreaBtn = Instance.new("ImageButton")
        AreaBtn.Size = UDim2.new(0, 32, 0, 32)
        AreaBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        AreaBtn.Image = "rbxassetid://" .. (imageId or "0")
        AreaBtn.Parent = Sidebar
        Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

        local function Select()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaFrame.Visible = true
            SubtitleLabel.Text = name:upper()
        end

        AreaBtn.MouseButton1Click:Connect(Select)
        if not currentArea then Select() currentArea = true end

        local Elements = {}

        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.Text = text .. " •"
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            btn.Parent = AreaFrame
            btn.MouseButton1Click:Connect(callback)
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        end

        function Elements:Toggle(text, callback)
            local state = Configs[text] or false
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.BorderSizePixel = 0
            btn.Parent = AreaFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            local function update()
                btn.Text = state and text .. " ✓" or text .. " ○"
                btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            end
            update()
            if state then task.spawn(function() callback(state) end) end

            btn.MouseButton1Click:Connect(function()
                state = not state
                update()
                SaveData[text] = state
                if internalAutoSave then SaveToFile() end
                callback(state)
            end)
            SaveData[text] = state
        end

        function Elements:Slider(text, min, max, default, callback)
            local saved = Configs[text] or default
            local sFrame = Instance.new("Frame")
            sFrame.Size = UDim2.new(0.95, 0, 0, 45)
            sFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            sFrame.Parent = AreaFrame
            Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

            local lab = Instance.new("TextLabel")
            lab.Size = UDim2.new(1, 0, 0, 20)
            lab.Position = UDim2.new(0, 8, 0, 2)
            lab.Text = text:upper()
            lab.TextColor3 = Color3.fromRGB(180, 180, 180)
            lab.BackgroundTransparency = 1
            lab.Font = Enum.Font.Code
            lab.TextSize = 10
            lab.TextXAlignment = Enum.TextXAlignment.Left
            lab.Parent = sFrame

            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0.7, 0, 0, 4)
            bar.Position = UDim2.new(0.08, 0, 0.7, 0)
            bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            bar.Parent = sFrame

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((saved-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = mainColor
            fill.BorderSizePixel = 0
            fill.Parent = bar

            local per = Instance.new("TextLabel")
            per.Size = UDim2.new(0, 40, 0, 20)
            per.Position = UDim2.new(0.8, 0, 0.55, 0)
            per.Text = math.floor(((saved-min)/(max-min))*100) .. "%"
            per.TextColor3 = mainColor
            per.BackgroundTransparency = 1
            per.Font = Enum.Font.Code
            per.Parent = sFrame

            local drag = false
            local function up(input)
                local r = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(r, 0, 1, 0)
                local val = math.floor(min + (max - min) * r)
                per.Text = math.floor(r*100) .. "%"
                SaveData[text] = val
                if internalAutoSave then SaveToFile() end
                callback(val)
            end

            sFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true up(i) end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then up(i) end end)
            UserInputService.InputEnded:Connect(function(i) drag = false end)
            task.spawn(function() callback(saved) end)
        end

        function Elements:Box(placeholder, callback)
            local saved = Configs[placeholder] or ""
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0.95, 0, 0, 32)
            box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            box.Text = saved
            box.PlaceholderText = "> " .. placeholder .. "..."
            box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            box.Font = Enum.Font.Code
            box.TextSize = 12
            box.BorderSizePixel = 0
            box.Parent = AreaFrame
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
            if saved ~= "" then task.spawn(function() callback(saved) end) end
            box.FocusLost:Connect(function() 
                SaveData[placeholder] = box.Text
                if internalAutoSave then SaveToFile() end
                callback(box.Text) 
            end)
        end

        return Elements
    end

    function Lib:AutoSaveLuay(b) internalAutoSave = b end
    function Lib:Save() SaveToFile() end

    return Lib
end

return luayV2
