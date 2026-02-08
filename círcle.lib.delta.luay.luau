-- up ↑
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local Library = {}

local CONFIG = {
    Radius = 134,
    InnerRadius = 55,
    FontSize = 13,
    Font = Enum.Font.GothamBold,
    Colors = {
        Background = Color3.fromRGB(18,18,18),
        Separator = Color3.fromRGB(255,255,255),
        Text = Color3.fromRGB(255,255,255),
        Error = Color3.fromRGB(255,50,50),
        Active = Color3.fromRGB(0,140,255)
    },
    Alpha = {
        Background = 0.12,
        SeparatorLine = 0.5,
        Border = 0.6
    }
}

CONFIG.Radius2 = CONFIG.Radius * 2
CONFIG.InnerRadius2 = CONFIG.InnerRadius * 2

local function chunk(tbl, size)
    local pages = {}
    for i = 1, #tbl, size do
        local page = {}
        for j = i, math.min(i+size-1, #tbl) do
            table.insert(page, tbl[j])
        end
        table.insert(pages, page)
    end
    return pages
end

function Library:Window(name)
    local self = {}

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CircleLib_"..name
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false -- GUI NÃO SOME AO MORRER
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local openButton = Instance.new("TextButton")
    openButton.Size = UDim2.fromOffset(45,45)
    openButton.Position = UDim2.new(0,25,0.5,-22)
    openButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
    openButton.BackgroundTransparency = 0.2
    openButton.Text = "☺"
    openButton.TextColor3 = Color3.new(1,1,1)
    openButton.TextSize = 25
    openButton.Parent = screenGui
    Instance.new("UICorner",openButton).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke",openButton).Color = Color3.new(1,1,1)

    local mainFrame = Instance.new("Frame")
    mainFrame.Visible = false
    mainFrame.Size = UDim2.fromOffset(CONFIG.Radius2,CONFIG.Radius2)
    mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    mainFrame.Position = UDim2.fromScale(0.5,0.5)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = screenGui

    local group = Instance.new("CanvasGroup")
    group.Size = UDim2.fromScale(1,1)
    group.BackgroundTransparency = 1
    group.GroupTransparency = 1
    group.Parent = mainFrame

    local outerBg = Instance.new("Frame")
    outerBg.Size = UDim2.fromScale(1,1)
    outerBg.BackgroundColor3 = CONFIG.Colors.Background
    outerBg.BackgroundTransparency = CONFIG.Alpha.Background
    outerBg.Parent = group
    Instance.new("UICorner",outerBg).CornerRadius = UDim.new(1,0)

    local outerStroke = Instance.new("UIStroke",outerBg)
    outerStroke.Color = CONFIG.Colors.Separator
    outerStroke.Transparency = CONFIG.Alpha.Border

    local rotationWrapper = Instance.new("Frame")
    rotationWrapper.Size = UDim2.fromScale(1,1)
    rotationWrapper.BackgroundTransparency = 1
    rotationWrapper.Parent = group

    --- ==========================================
    --- CONCERTO DAS DIVISÓRIAS (PONTA AFIADA)
    --- ==========================================
    for i=1, 8 do
        local angle = (360/8) * (i - 0.5)
        local rad = math.rad(angle - 90)
        
        -- Container invisível para rotacionar a partir do centro exato
        local linePivot = Instance.new("Frame")
        linePivot.Size = UDim2.fromOffset(2, CONFIG.Radius - CONFIG.InnerRadius - 5)
        linePivot.AnchorPoint = Vector2.new(0.5, 0)
        -- Posiciona na borda do círculo interno
        linePivot.Position = UDim2.new(
            0.5, math.cos(rad) * (CONFIG.InnerRadius), 
            0.5, math.sin(rad) * (CONFIG.InnerRadius)
        )
        linePivot.Rotation = angle
        linePivot.BackgroundTransparency = 1
        linePivot.Parent = rotationWrapper

        -- A linha real que afina
        local sharpLine = Instance.new("Frame")
        sharpLine.Size = UDim2.new(1, 0, 1, 0)
        sharpLine.BackgroundColor3 = CONFIG.Colors.Separator
        sharpLine.BackgroundTransparency = 0.4
        sharpLine.BorderSizePixel = 0
        sharpLine.Parent = linePivot
        
        -- O segredo da ponta afiada: UICorner total em uma frame muito fina
        local uiCorner = Instance.new("UICorner", sharpLine)
        uiCorner.CornerRadius = UDim.new(1, 0) 
        
        -- Gradiente para reforçar o visual de "desaparecer" na ponta (opcional, mas fica foda)
        local gradient = Instance.new("UIGradient", sharpLine)
        gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),    -- Começa visível na base
            NumberSequenceKeypoint.new(1, 1)     -- Fica invisível na ponta fina
        })
        gradient.Rotation = 90
    end
    --- ==========================================

    local slots = {}

    for i=1,8 do
        local angle = (360/8)*(i-1)
        local rad = math.rad(angle-90)

        local slot = Instance.new("ImageButton")
        slot.Size = UDim2.fromOffset(36,36)
        slot.AnchorPoint = Vector2.new(0.5,0.5)
        slot.Position = UDim2.new(0.5, math.cos(rad)*(CONFIG.InnerRadius+40), 0.5, math.sin(rad)*(CONFIG.InnerRadius+40))
        slot.BackgroundTransparency = 1
        slot.Image = "rbxassetid://3926305904"
        slot.ImageRectOffset = Vector2.new(964,324)
        slot.ImageRectSize = Vector2.new(36,36)
        slot.ImageColor3 = Color3.new(1,1,1)
        slot.ZIndex = 12
        slot.Parent = rotationWrapper

        slots[i] = slot
    end

    local centerCircle = Instance.new("TextButton")
    centerCircle.Size = UDim2.fromOffset(CONFIG.InnerRadius2,CONFIG.InnerRadius2)
    centerCircle.Position = UDim2.fromScale(0.5,0.5)
    centerCircle.AnchorPoint = Vector2.new(0.5,0.5)
    centerCircle.BackgroundColor3 = CONFIG.Colors.Background
    centerCircle.BackgroundTransparency = 0.05
    centerCircle.Text = ""
    centerCircle.ZIndex = 10
    centerCircle.Parent = group
    Instance.new("UICorner",centerCircle).CornerRadius = UDim.new(1,0)
    
    -- BORDA NO CÍRCULO CENTRAL
    local centerStroke = Instance.new("UIStroke", centerCircle)
    centerStroke.Color = CONFIG.Colors.Separator
    centerStroke.Thickness = 2
    centerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local centerText = Instance.new("TextLabel")
    centerText.Size = UDim2.fromScale(0.8,0.8)
    centerText.Position = UDim2.fromScale(0.5,0.5)
    centerText.AnchorPoint = Vector2.new(0.5,0.5)
    centerText.BackgroundTransparency = 1
    centerText.TextColor3 = CONFIG.Colors.Text
    centerText.Font = Enum.Font.GothamMedium
    centerText.TextSize = 12
    centerText.ZIndex = 11
    centerText.Parent = centerCircle

    local Areas = {}
    local areaIndex = 1
    local pageIndex = 1

    local function render()
        local area = Areas[areaIndex]
        if not area then return end

        centerText.Text = area.Title
        local pages = chunk(area.Items,8)
        local page = pages[pageIndex] or {}

        for i=1,8 do
            local btn = slots[i]
            local item = page[i]

            if item then
                btn.Visible = true
                btn.ImageColor3 = Color3.new(1,1,1)
                
                -- Clique rápido (0.1s)
                btn.MouseButton1Click:Connect(function()
                    local t = TweenService:Create(btn, TweenInfo.new(0.1), {ImageColor3 = CONFIG.Colors.Active})
                    t:Play()
                    t.Completed:Connect(function()
                        TweenService:Create(btn, TweenInfo.new(0.1), {ImageColor3 = Color3.new(1,1,1)}):Play()
                    end)
                    item.Callback()
                end)
            else
                btn.Visible = false
            end
        end
    end

    local function navigate(dir)
        local area = Areas[areaIndex]
        local pages = chunk(area.Items,8)
        pageIndex += dir

        if pageIndex > #pages then
            areaIndex = math.min(areaIndex + 1, #Areas)
            pageIndex = 1
        elseif pageIndex < 1 then
            areaIndex = math.max(areaIndex - 1, 1)
            local prev = Areas[areaIndex]
            pageIndex = #chunk(prev.Items,8)
        end
        render()
    end

    centerCircle.MouseButton1Click:Connect(function()
        local mouse = player:GetMouse()
        local centerPos = centerCircle.AbsolutePosition + (centerCircle.AbsoluteSize/2)
        if mouse.X < centerPos.X then navigate(-1) else navigate(1) end
    end)

    openButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
        group.GroupTransparency = mainFrame.Visible and 0 or 1
    end)

    function self:Area(title)
        local area = {Title=title,Items={}}
        table.insert(Areas,area)

        function area:Button(cfg)
            table.insert(area.Items,{
                Type="button",
                Name=cfg.name,
                Callback=cfg.callback or function() end
            })
            render()
        end
        return area
    end

    render()
    return self
end

return Library
