local luayV2 = {}

function luayV2:Window(config)
    local title = config.Name or "luayV2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local footerText = config.Footer or "luayV2 | Community"
    
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_UI"
    if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

    -- Estrutura Principal (Altura Limitada)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 260, 0, 350) -- Altura Fixa Máxima
    MainFrame.Position = UDim2.new(0.5, -130, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local NeonLine = Instance.new("Frame")
    NeonLine.Size = UDim2.new(1, 0, 0, 2)
    NeonLine.Position = UDim2.new(0, 0, 1, -2)
    NeonLine.BackgroundColor3 = mainColor
    NeonLine.BorderSizePixel = 0
    NeonLine.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -80, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.Text = title:upper()
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 13
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    -- Botões de Controle
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 1, 0)
    CloseBtn.Position = UDim2.new(1, -30, 0, 0)
    CloseBtn.Text = "x"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Font = Enum.Font.Gotham
    CloseBtn.TextSize = 18
    CloseBtn.Parent = TopBar
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 30, 1, 0)
    MiniBtn.Position = UDim2.new(1, -60, 0, 0)
    MiniBtn.Text = "_"
    MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.Font = Enum.Font.Gotham
    MiniBtn.TextSize = 18
    MiniBtn.Parent = TopBar

    -- Container de Itens com Scroll Automático
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, 0, 1, -55)
    Content.Position = UDim2.new(0, 0, 0, 35)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = mainColor
    Content.CanvasSize = UDim2.new(0, 0, 0, 0) -- Ajustado pelo UIListLayout
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.Parent = MainFrame
    
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = Content
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Padding = UDim.new(0, 6)

    local Padding = Instance.new("UIPadding")
    Padding.Parent = Content
    Padding.PaddingTop = UDim.new(0, 10)
    Padding.PaddingLeft = UDim.new(0, 8)

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, 0, 0, 20)
    Footer.Position = UDim2.new(0, 0, 1, -20)
    Footer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Footer.Text = footerText
    Footer.TextColor3 = Color3.fromRGB(120, 120, 120)
    Footer.Font = Enum.Font.Code
    Footer.TextSize = 10
    Footer.BorderSizePixel = 0
    Footer.Parent = MainFrame

    -- Lógica de Minimizar
    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        Content.Visible = not isMinimized
        Footer.Visible = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 350)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)

    local Lib = {}

    function Lib:Button(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.94, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.Text = string.format("[ %s • ]", text)
        btn.TextColor3 = Color3.fromRGB(230, 230, 230)
        btn.Font = Enum.Font.Code
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = Content
        btn.MouseButton1Click:Connect(callback)
    end

    function Lib:Toggle(text, callback)
        local state = false
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.94, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        btn.Text = string.format("[ %s [ ] ]", text)
        btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        btn.Font = Enum.Font.Code
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = Content

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = state and string.format("[ %s [✓] ]", text) or string.format("[ %s [ ] ]", text)
            btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
            callback(state)
        end)
    end

    function Lib:Box(placeholder, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.94, 0, 0, 32)
        box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        box.Text = ""
        box.PlaceholderText = "[ > " .. placeholder .. "... ]"
        box.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
        box.TextColor3 = Color3.fromRGB(255, 255, 255)
        box.Font = Enum.Font.Code
        box.TextSize = 12
        box.BorderSizePixel = 0
        box.Parent = Content
        box.FocusLost:Connect(function() callback(box.Text) end)
    end

    function Lib:Slider(text, min, max, default, callback)
        local sliderFrame = Instance.new("Frame")
        sliderFrame.Size = UDim2.new(0.94, 0, 0, 45)
        sliderFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        sliderFrame.BorderSizePixel = 0
        sliderFrame.Parent = Content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 5, 0, 2)
        label.Text = string.format("[ %s ]", text:upper())
        label.TextColor3 = Color3.fromRGB(180, 180, 180)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderFrame

        local barObj = Instance.new("Frame")
        barObj.Size = UDim2.new(0.65, 0, 0, 4)
        barObj.Position = UDim2.new(0.05, 0, 0.7, 0)
        barObj.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        barObj.BorderSizePixel = 0
        barObj.Parent = sliderFrame

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
        fill.BackgroundColor3 = mainColor
        fill.BorderSizePixel = 0
        fill.Parent = barObj

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = UDim2.new(1, -5, 0.5, -5)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = fill
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local percentLabel = Instance.new("TextLabel")
        percentLabel.Size = UDim2.new(0.25, 0, 0, 20)
        percentLabel.Position = UDim2.new(0.72, 0, 0.55, 0)
        percentLabel.BackgroundTransparency = 1
        percentLabel.TextColor3 = mainColor
        percentLabel.Font = Enum.Font.Code
        percentLabel.TextSize = 11
        percentLabel.Text = string.format("[%d%%]", ((default - min)/(max-min))*100)
        percentLabel.Parent = sliderFrame

        local function update(input)
            local inputPos = input.Position.X
            local barPos = barObj.AbsolutePosition.X
            local barSize = barObj.AbsoluteSize.X
            local ratio = math.clamp((inputPos - barPos) / barSize, 0, 1)
            
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            percentLabel.Text = string.format("[%d%%]", ratio * 100)
            local value = math.floor(min + (max - min) * ratio)
            callback(value)
        end

        local isDragging = false
        -- Ativação para PC e Mobile
        sliderFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = true
                update(input)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDragging = false
            end
        end)
    end

    function Lib:Dropdown(text, list, callback)
        local open = false
        local dropFrame = Instance.new("Frame")
        dropFrame.Size = UDim2.new(0.94, 0, 0, 32)
        dropFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        dropFrame.ClipsDescendants = true
        dropFrame.BorderSizePixel = 0
        dropFrame.Parent = Content

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundTransparency = 1
        btn.Text = string.format("  [ %s > ]", text)
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.Font = Enum.Font.Code
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = dropFrame

        local itemContainer = Instance.new("Frame")
        itemContainer.Size = UDim2.new(1, 0, 0, #list * 30)
        itemContainer.Position = UDim2.new(0, 0, 0, 32)
        itemContainer.BackgroundTransparency = 1
        itemContainer.Parent = dropFrame

        for i, item in pairs(list) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.Position = UDim2.new(0, 0, 0, (i-1)*30)
            itemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            itemBtn.Text = "    - " .. tostring(item)
            itemBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            itemBtn.Font = Enum.Font.Code
            itemBtn.TextSize = 11
            itemBtn.BorderSizePixel = 0
            itemBtn.Parent = itemContainer
            itemBtn.MouseButton1Click:Connect(function()
                btn.Text = string.format("  [ %s: %s > ]", text, item)
                callback(item)
                open = false
                dropFrame:TweenSize(UDim2.new(0.94, 0, 0, 32), "Out", "Quart", 0.3, true)
            end)
        end

        btn.MouseButton1Click:Connect(function()
            open = not open
            btn.Text = open and string.format("  [ %s ^ ]", text) or string.format("  [ %s > ]", text)
            dropFrame:TweenSize(open and UDim2.new(0.94, 0, 0, 32 + (#list * 30)) or UDim2.new(0.94, 0, 0, 32), "Out", "Quart", 0.3, true)
        end)
    end

    return Lib
end

return luayV2
