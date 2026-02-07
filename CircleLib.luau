local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Turn = {}
Turn.__toggles = {}

function Turn.Toggle(name, state)
    local t = Turn.__toggles[name]
    if t then
        t:Set(state)
        return true
    end
    return false
end

function Turn.GetToggle(name)
    return Turn.__toggles[name]
end

local Circle = {}

local CONFIG = {
    Radius = 140,
    InnerRadius = 55,
    Colors = {
        Background = Color3.fromRGB(18,18,18),
        Stroke = Color3.fromRGB(255,255,255),
        Active = Color3.fromRGB(0,140,255),
        Text = Color3.fromRGB(255,255,255),
        Error = Color3.fromRGB(255,60,60)
    }
}

function Circle:Window(title)
    local gui = Instance.new("ScreenGui")
    gui.Name = "CircleLib"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local openButton = Instance.new("TextButton", gui)
    openButton.Size = UDim2.fromOffset(44,44)
    openButton.Position = UDim2.new(0,25,0.5,-22)
    openButton.Text = "☺"
    openButton.TextSize = 24
    openButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
    openButton.BackgroundTransparency = 0.2
    openButton.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", openButton).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", openButton).Color = Color3.new(1,1,1)

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.fromOffset(CONFIG.Radius*2, CONFIG.Radius*2)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundTransparency = 1
    main.Visible = false

    local group = Instance.new("CanvasGroup", main)
    group.Size = UDim2.fromScale(1,1)
    group.GroupTransparency = 1

    local outer = Instance.new("Frame", group)
    outer.Size = UDim2.fromScale(1,1)
    outer.BackgroundColor3 = CONFIG.Colors.Background
    outer.BackgroundTransparency = 0.12
    Instance.new("UICorner", outer).CornerRadius = UDim.new(1,0)

    local outerStroke = Instance.new("UIStroke", outer)
    outerStroke.Color = CONFIG.Colors.Stroke
    outerStroke.Transparency = 0.6

    local rotationWrapper = Instance.new("Frame", group)
    rotationWrapper.Size = UDim2.fromScale(1,1)
    rotationWrapper.BackgroundTransparency = 1

    local center = Instance.new("TextButton", group)
    center.Size = UDim2.fromOffset(CONFIG.InnerRadius*2, CONFIG.InnerRadius*2)
    center.Position = UDim2.fromScale(0.5,0.5)
    center.AnchorPoint = Vector2.new(0.5,0.5)
    center.BackgroundColor3 = CONFIG.Colors.Background
    center.BackgroundTransparency = 0.05
    center.Text = ""
    center.ZIndex = 10
    Instance.new("UICorner", center).CornerRadius = UDim.new(1,0)

    local centerStroke = Instance.new("UIStroke", center)
    centerStroke.Color = CONFIG.Colors.Stroke
    centerStroke.Transparency = 0.6

    local centerText = Instance.new("TextLabel", center)
    centerText.Size = UDim2.fromScale(0.8,0.8)
    centerText.Position = UDim2.fromScale(0.5,0.5)
    centerText.AnchorPoint = Vector2.new(0.5,0.5)
    centerText.BackgroundTransparency = 1
    centerText.Text = title or "MENU"
    centerText.TextColor3 = CONFIG.Colors.Text
    centerText.Font = Enum.Font.GothamMedium
    centerText.TextScaled = true
    centerText.ZIndex = 11

    local areas = {}
    local currentArea = 1
    local currentPage = 1
    local currentRotation = 0

    local numberLabels = {}
    local slotButtons = {}

    for i=1,8 do
        local angle = (360/8)*(i-1)

        local pivot = Instance.new("Frame", rotationWrapper)
        pivot.Size = UDim2.fromScale(0,0)
        pivot.Position = UDim2.fromScale(0.5,0.5)
        pivot.Rotation = angle + (360/16)
        pivot.BackgroundTransparency = 1

        local line = Instance.new("Frame", pivot)
        line.BackgroundColor3 = CONFIG.Colors.Stroke
        line.BorderSizePixel = 0
        line.Size = UDim2.new(0,1,0,(CONFIG.Radius-CONFIG.InnerRadius)*0.6)
        line.Position = UDim2.new(0.5,0,0,-CONFIG.InnerRadius-6)
        line.AnchorPoint = Vector2.new(0.5,1)

        local rad = math.rad(angle-90)

        local txt = Instance.new("TextLabel", rotationWrapper)
        txt.Size = UDim2.fromOffset(15,15)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = CONFIG.Colors.Text
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 13
        txt.AnchorPoint = Vector2.new(0.5,0.5)
        txt.Position = UDim2.new(0.5, math.cos(rad)*(CONFIG.InnerRadius+12), 0.5, math.sin(rad)*(CONFIG.InnerRadius+12))
        numberLabels[i] = txt

        local slot = Instance.new("ImageButton", rotationWrapper)
        slot.Size = UDim2.fromOffset(36,36)
        slot.AnchorPoint = Vector2.new(0.5,0.5)
        slot.Position = UDim2.new(0.5, math.cos(rad)*(CONFIG.InnerRadius+40), 0.5, math.sin(rad)*(CONFIG.InnerRadius+40))
        slot.BackgroundTransparency = 1
        slot.Image = "rbxassetid://3926305904"
        slot.ImageRectOffset = Vector2.new(964,324)
        slot.ImageRectSize = Vector2.new(36,36)
        slotButtons[i] = slot
    end

    local function refreshNumbers()
        for i=1,8 do
            local id = (currentPage-1)*8+i
            numberLabels[i].Text = tostring(id)
            numberLabels[i].Rotation = -currentRotation
        end
    end

    local function updateToggleVisual(btn, state)
        TweenService:Create(btn,TweenInfo.new(0.15),{
            ImageColor3 = state and CONFIG.Colors.Active or Color3.new(1,1,1)
        }):Play()
    end

    local function draw()
        refreshNumbers()
    end

    local function navigate(dir)
        local area = areas[currentArea]
        if not area then return end
        local maxPages = math.max(1, math.ceil(#area.Items / 8))
        local n = currentPage + dir
        if n < 1 or n > maxPages then
            TweenService:Create(outerStroke,TweenInfo.new(0.15),{Color=CONFIG.Colors.Error}):Play()
            task.delay(0.4,function()
                TweenService:Create(outerStroke,TweenInfo.new(0.3),{Color=CONFIG.Colors.Stroke}):Play()
            end)
            return
        end
        currentPage = n
        currentRotation += 360 * dir
        TweenService:Create(rotationWrapper,TweenInfo.new(0.6,Enum.EasingStyle.Quart),{Rotation=currentRotation}):Play()
        draw()
    end

    center.MouseButton1Click:Connect(function()
        local mouse = Player:GetMouse()
        local pos = center.AbsolutePosition + center.AbsoluteSize/2
        if mouse.X < pos.X then navigate(-1) else navigate(1) end
    end)

    local isOpen = false
    openButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            main.Visible = true
            main.Size = UDim2.fromOffset(0,0)
            group.GroupTransparency = 1
            TweenService:Create(main,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(CONFIG.Radius*2,CONFIG.Radius*2)}):Play()
            TweenService:Create(group,TweenInfo.new(0.3),{GroupTransparency=0}):Play()
        else
            TweenService:Create(main,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.fromOffset(0,0)}):Play()
            TweenService:Create(group,TweenInfo.new(0.2),{GroupTransparency=1}):Play()
            task.delay(0.25,function()
                if not isOpen then main.Visible=false end
            end)
        end
    end)

    local window = {}

    function window:Area(name)
        local area = {Name=name, Items={}}
        table.insert(areas, area)

        function area:Button(cfg)
            table.insert(self.Items,{
                Type="Button",
                Name=cfg.name,
                Callback=cfg.callback
            })
        end

        function area:Toggle(cfg)
            local state = false
            local obj = {}

            function obj:Set(v)
                state = v
                if cfg.callback then
                    task.spawn(cfg.callback, v)
                end
            end

            Turn.__toggles[cfg.name] = obj

            table.insert(self.Items,{
                Type="Toggle",
                Name=cfg.name,
                Obj=obj
            })
        end

        draw()
        return area
    end

    return window
end

return {
    Circle = Circle,
    Turn = Turn
}
