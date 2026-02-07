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

local Areas = {}
local Toggles = {}
local CurrentWindow

function Library:Window(name)
local self = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CircleLib_"..name
screenGui.IgnoreGuiInset = true
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

local numberLabels = {}
local slotButtons = {}

for i=1,8 do
local angle = (360/8)*(i-1)

local pivot = Instance.new("Frame")
pivot.Size = UDim2.fromScale(0,0)
pivot.Position = UDim2.fromScale(0.5,0.5)
pivot.Rotation = angle + (360/16)
pivot.BackgroundTransparency = 1
pivot.Parent = rotationWrapper

local line = Instance.new("Frame")
line.BackgroundColor3 = CONFIG.Colors.Separator
line.BorderSizePixel = 0
line.Size = UDim2.new(0,1,0,(CONFIG.Radius-CONFIG.InnerRadius)*0.6)
line.Position = UDim2.new(0.5,0,0,-CONFIG.InnerRadius-5)
line.AnchorPoint = Vector2.new(0.5,1)
line.Parent = pivot

local grad = Instance.new("UIGradient",line)
grad.Rotation = -90
grad.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0,0.2),
NumberSequenceKeypoint.new(1,1)
})

local rad = math.rad(angle-90)

local txt = Instance.new("TextLabel")
txt.Size = UDim2.fromOffset(15,15)
txt.BackgroundTransparency = 1
txt.TextColor3 = CONFIG.Colors.Text
txt.Font = CONFIG.Font
txt.TextSize = CONFIG.FontSize
txt.AnchorPoint = Vector2.new(0.5,0.5)
txt.Position = UDim2.new(0.5, math.cos(rad)*(CONFIG.InnerRadius+12), 0.5, math.sin(rad)*(CONFIG.InnerRadius+12))
txt.Parent = rotationWrapper
numberLabels[i] = txt

local slot = Instance.new("ImageButton")
slot.Size = UDim2.fromOffset(36,36)
slot.AnchorPoint = Vector2.new(0.5,0.5)
slot.Position = UDim2.new(0.5, math.cos(rad)*(CONFIG.InnerRadius+40), 0.5, math.sin(rad)*(CONFIG.InnerRadius+40))
slot.BackgroundTransparency = 1
slot.Image = "rbxassetid://3926305904"
slot.ImageRectOffset = Vector2.new(964,324)
slot.ImageRectSize = Vector2.new(36,36)
slot.ImageColor3 = Color3.new(1,1,1)
slot.Parent = rotationWrapper

slotButtons[i] = slot
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

local innerStroke = Instance.new("UIStroke",centerCircle)
innerStroke.Color = CONFIG.Colors.Separator
innerStroke.Transparency = CONFIG.Alpha.Border

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

local currentPage = 1
local currentRotation = 0
local isOpen = false

local function refreshNumbers()
for i=1,8 do
local id = (currentPage-1)*8+i
numberLabels[i].Text = tostring(id)
numberLabels[i].Rotation = -currentRotation
end
end

local function updateSlot(id)
local localId = ((id-1)%8)+1
local btn = slotButtons[localId]
if Toggles[id] then
TweenService:Create(btn,TweenInfo.new(0.15),{ImageColor3 = CONFIG.Colors.Active}):Play()
else
TweenService:Create(btn,TweenInfo.new(0.15),{ImageColor3 = Color3.new(1,1,1)}):Play()
end
end

local function flash(btn)
TweenService:Create(btn,TweenInfo.new(0.1),{ImageColor3 = CONFIG.Colors.Active}):Play()
local grow = TweenService:Create(btn,TweenInfo.new(0.1),{Size = UDim2.fromOffset(40,40)})
local shrink = TweenService:Create(btn,TweenInfo.new(0.1),{Size = UDim2.fromOffset(36,36)})
grow:Play()
grow.Completed:Wait()
shrink:Play()
task.delay(0.7,function()
TweenService:Create(btn,TweenInfo.new(0.15),{ImageColor3 = Color3.new(1,1,1)}):Play()
end)
end

for i=1,8 do
slotButtons[i].MouseButton1Click:Connect(function()
local id = (currentPage-1)*8+i
local data = Areas[id]
if not data then return end
if data.Type == "toggle" then
Toggles[id] = not Toggles[id]
updateSlot(id)
data.Callback(Toggles[id])
else
flash(slotButtons[i])
data.Callback()
end
end)
end

local function navigate(dir)
local maxPages = math.max(1, math.ceil(#Areas/8))
local n = currentPage + dir
if n<1 or n>maxPages then
TweenService:Create(outerStroke,TweenInfo.new(0.15),{Color=CONFIG.Colors.Error}):Play()
task.delay(0.4,function()
TweenService:Create(outerStroke,TweenInfo.new(0.3),{Color=CONFIG.Colors.Separator}):Play()
end)
return
end
currentPage = n
currentRotation += 360*dir
TweenService:Create(rotationWrapper,TweenInfo.new(0.6,Enum.EasingStyle.Quart),{Rotation=currentRotation}):Play()
task.wait(0.3)
centerText.Text = Areas[((currentPage-1)*8)+1].Area
refreshNumbers()
end

centerCircle.MouseButton1Click:Connect(function()
local mouse = player:GetMouse()
local centerPos = centerCircle.AbsolutePosition + (centerCircle.AbsoluteSize/2)
if mouse.X < centerPos.X then navigate(-1) else navigate(1) end
end)

openButton.MouseButton1Click:Connect(function()
isOpen = not isOpen
if isOpen then
mainFrame.Visible = true
mainFrame.Size = UDim2.fromOffset(0,0)
group.GroupTransparency = 1
TweenService:Create(mainFrame,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Size=UDim2.fromOffset(CONFIG.Radius2,CONFIG.Radius2)}):Play()
TweenService:Create(group,TweenInfo.new(0.3),{GroupTransparency=0}):Play()
else
local tw = TweenService:Create(mainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.fromOffset(0,0)})
TweenService:Create(group,TweenInfo.new(0.2),{GroupTransparency=1}):Play()
tw:Play()
tw.Completed:Wait()
mainFrame.Visible=false
end
end)

function self:Area(title)
local area = {}
area.Title = title
function area:Button(cfg)
table.insert(Areas,{
Name = cfg.name,
Image = cfg.image,
Callback = cfg.callback or function() end,
Type = "button",
Area = title
})
centerText.Text = Areas[1].Area
refreshNumbers()
end

function area:Toggle(cfg)
table.insert(Areas,{
Name = cfg.name,
Image = cfg.image,
Callback = cfg.callback or function() end,
Type = "toggle",
Area = title
})
centerText.Text = Areas[1].Area
refreshNumbers()
end
return area
end

CurrentWindow = self
return self
end

function Library.Toggle(name,state)
for id,data in pairs(Areas) do
if data.Name == name and data.Type == "toggle" then
Toggles[id] = state
updateSlot(id)
end
end
end

return Library
