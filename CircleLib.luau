--[[
    circle.et.library
    Design: Radial Menu V5
]]

local circle = { et = {} }
circle.et.library = {}
circle.et.library.__index = circle.et.library

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

function circle.et.library.new(data)
    local self = setmetatable({}, circle.et.library)
    
    self.Title = data.name or "Minha Janela"
    self.Areas = {}
    self.Toggles = {}
    self.CurrentPageIndex = 1
    self.IsOpen = false
    self.RotationValue = 0
    
    self.Config = {
        Radius = 134,
        InnerRadius = 55,
        Colors = {
            Background = Color3.fromRGB(18,18,18),
            Separator = Color3.fromRGB(255,255,255),
            Active = Color3.fromRGB(0,140,255),
            Error = Color3.fromRGB(255,50,50)
        }
    }
    
    self:Init()
    return self
end

function circle.et.library:Init()
    self.Gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    self.Gui.Name = "CircleEtLib_" .. math.random(100,999)
    self.Gui.IgnoreGuiInset = true

    -- Botão Toggle Principal
    self.OpenBtn = Instance.new("TextButton", self.Gui)
    self.OpenBtn.Size = UDim2.fromOffset(45,45)
    self.OpenBtn.Position = UDim2.new(0, 25, 0.5, -22)
    self.OpenBtn.BackgroundColor3 = Color3.new(0,0,0)
    self.OpenBtn.BackgroundTransparency = 0.2
    self.OpenBtn.Text = "☺"
    self.OpenBtn.TextColor3 = Color3.new(1,1,1)
    self.OpenBtn.TextSize = 25
    Instance.new("UICorner", self.OpenBtn).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", self.OpenBtn).Color = Color3.new(1,1,1)

    -- Container do Menu
    self.Main = Instance.new("Frame", self.Gui)
    self.Main.Visible = false
    self.Main.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Main.Position = UDim2.fromScale(0.5, 0.5)
    self.Main.Size = UDim2.fromOffset(0, 0)
    self.Main.BackgroundTransparency = 1

    self.Canvas = Instance.new("CanvasGroup", self.Main)
    self.Canvas.Size = UDim2.fromScale(1, 1)
    self.Canvas.BackgroundTransparency = 1
    self.Canvas.GroupTransparency = 1

    local bg = Instance.new("Frame", self.Canvas)
    bg.Size = UDim2.fromScale(1,1)
    bg.BackgroundColor3 = self.Config.Colors.Background
    bg.BackgroundTransparency = 0.12
    Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)
    
    self.Stroke = Instance.new("UIStroke", bg)
    self.Stroke.Color = self.Config.Colors.Separator
    self.Stroke.Transparency = 0.6

    self.Rotator = Instance.new("Frame", self.Canvas)
    self.Rotator.Size = UDim2.fromScale(1,1)
    self.Rotator.BackgroundTransparency = 1

    -- Centro
    self.Center = Instance.new("TextButton", self.Canvas)
    self.Center.Size = UDim2.fromOffset(self.Config.InnerRadius*2, self.Config.InnerRadius*2)
    self.Center.Position = UDim2.fromScale(0.5,0.5)
    self.Center.AnchorPoint = Vector2.new(0.5,0.5)
    self.Center.BackgroundColor3 = self.Config.Colors.Background
    self.Center.Text = ""
    self.Center.ZIndex = 10
    Instance.new("UICorner", self.Center).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", self.Center).Color = self.Config.Colors.Separator

    self.CenterText = Instance.new("TextLabel", self.Center)
    self.CenterText.Size = UDim2.fromScale(0.8,0.8)
    self.CenterText.Position = UDim2.fromScale(0.5,0.5)
    self.CenterText.AnchorPoint = Vector2.new(0.5,0.5)
    self.CenterText.BackgroundTransparency = 1
    self.CenterText.TextColor3 = self.Config.Colors.Separator
    self.CenterText.Font = Enum.Font.GothamMedium
    self.CenterText.TextSize = 11
    self.CenterText.Text = self.Title

    -- Lógica de Abrir/Fechar
    self.OpenBtn.MouseButton1Click:Connect(function()
        self.IsOpen = not self.IsOpen
        if self.IsOpen then
            self:Render()
            self.Main.Visible = true
            TweenService:Create(self.Main, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.fromOffset(self.Config.Radius*2, self.Config.Radius*2)}):Play()
            TweenService:Create(self.Canvas, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
        else
            local tw = TweenService:Create(self.Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.fromOffset(0,0)})
            TweenService:Create(self.Canvas, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
            tw:Play()
        end
    end)

    -- Navegação
    self.Center.MouseButton1Click:Connect(function()
        local mouse = player:GetMouse()
        local centerPos = self.Center.AbsolutePosition + (self.Center.AbsoluteSize/2)
        local dir = (mouse.X < centerPos.X) and -1 or 1
        
        local nextP = self.CurrentPageIndex + dir
        if nextP < 1 or nextP > #self.Areas then
            TweenService:Create(self.Stroke, TweenInfo.new(0.15), {Color = self.Config.Colors.Error}):Play()
            task.delay(0.3, function() TweenService:Create(self.Stroke, TweenInfo.new(0.3), {Color = self.Config.Colors.Separator}):Play() end)
            return
        end
        
        self.CurrentPageIndex = nextP
        self.RotationValue += 360 * dir
        TweenService:Create(self.Rotator, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Rotation = self.RotationValue}):Play()
        task.wait(0.2)
        self:Render()
    end)
end

function circle.et.library:Area(title)
    local newArea = {Title = title, Items = {}}
    table.insert(self.Areas, newArea)
    return newArea
end

function circle.et.library:Button(area, data)
    table.insert(area.Items, {
        Type = "Button",
        Name = data.name,
        Image = data.image,
        Callback = data.callback or function() end
    })
    
    -- Se passar de 8 itens, cria uma sub-área automaticamente
    if #area.Items > 8 then
        local baseName = area.Title:gsub(" %d+$", "")
        local newPage = self:Area(baseName .. " " .. (#self.Areas + 1))
        local lastItem = table.remove(area.Items)
        table.insert(newPage.Items, lastItem)
    end
end

function circle.et.library:Toggle(area, data)
    local item = {
        Type = "Toggle",
        Name = data.name,
        Image = data.image,
        State = false,
        Callback = data.callback or function() end
    }
    table.insert(area.Items, item)
    self.Toggles[data.name] = item

    if #area.Items > 8 then
        local baseName = area.Title:gsub(" %d+$", "")
        local newPage = self:Area(baseName .. " " .. (#self.Areas + 1))
        local lastItem = table.remove(area.Items)
        table.insert(newPage.Items, lastItem)
    end
end

function circle.et.library:SetToggle(name, mode)
    local item = self.Toggles[name]
    if item then
        item.State = (mode == "on")
        self:Render()
    end
end

function circle.et.library:Render()
    self.Rotator:ClearAllChildren()
    local area = self.Areas[self.CurrentPageIndex]
    if not area then return end
    
    self.CenterText.Text = area.Title
    
    for i, item in ipairs(area.Items) do
        local angle = (360/8) * (i-1)
        local rad = math.rad(angle - 90)
        
        local btn = Instance.new("ImageButton", self.Rotator)
        btn.Size = UDim2.fromOffset(36,36)
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        btn.Position = UDim2.new(0.5, math.cos(rad)*(self.Config.InnerRadius+40), 0.5, math.sin(rad)*(self.Config.InnerRadius+40))
        btn.BackgroundTransparency = 1
        btn.Image = "rbxassetid://" .. tostring(item.Image)
        btn.Rotation = -self.RotationValue
        
        if item.Type == "Toggle" and item.State then
            btn.ImageColor3 = self.Config.Colors.Active
        else
            btn.ImageColor3 = Color3.new(1,1,1)
        end
        
        btn.MouseButton1Click:Connect(function()
            if item.Type == "Toggle" then
                item.State = not item.State
                btn.ImageColor3 = item.State and self.Config.Colors.Active or Color3.new(1,1,1)
                item.Callback(item.State)
            else
                -- Efeito Flash para botão normal
                TweenService:Create(btn, TweenInfo.new(0.1), {ImageColor3 = self.Config.Colors.Active}):Play()
                task.delay(0.2, function() btn.ImageColor3 = Color3.new(1,1,1) end)
                item.Callback()
            end
        end)
    end
end

return circle.et.library
