local luayV2 = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local plr = players.LocalPlayer

-- Função de Arrastar (Draggable) aprimorada
local function MakeDraggable(frame, parent)
	local dragging = false
	local dragInput, dragStart, startPos

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = parent.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function luayV2:Window(config)
	local title = config.Name or "luayV2"
	local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
	local footerText = config.Footer or "luayV2 | Community"
	local toggleKey = config.Keybind or Enum.KeyCode.RightControl
	local fileName = "luayV2_Config_" .. plr.UserId .. ".json"
	
	local SaveData = {}
	local internalAutoSave = false
	local currentArea = nil
	local uiVisible = true

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

	-- GUI PRINCIPAL
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "luayV2_Engine"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = game:GetService("CoreGui") end

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Size = UDim2.new(0, 300, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
	MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 6)
	MainCorner.Parent = MainFrame

	local Stroke = Instance.new("UIStroke")
	Stroke.Thickness = 1
	Stroke.Color = Color3.fromRGB(35, 35, 35)
	Stroke.Parent = MainFrame

	-- BARRA SUPERIOR
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame
	MakeDraggable(TopBar, MainFrame)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -100, 0, 28)
	TitleLabel.Position = UDim2.new(0, 15, 0, 4)
	TitleLabel.Text = title:upper()
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.Code
	TitleLabel.TextSize = 15
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TopBar

	local SubtitleLabel = Instance.new("TextLabel")
	SubtitleLabel.Size = UDim2.new(1, -100, 0, 15)
	SubtitleLabel.Position = UDim2.new(0, 15, 0, 26)
	SubtitleLabel.Text = "CARREGANDO..."
	SubtitleLabel.TextColor3 = mainColor
	SubtitleLabel.BackgroundTransparency = 1
	SubtitleLabel.Font = Enum.Font.Code
	SubtitleLabel.TextSize = 11
	SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubtitleLabel.Parent = TopBar

	-- CONTROLES (X e _)
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -40, 0, 0)
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Font = Enum.Font.Code
	CloseBtn.TextSize = 24
	CloseBtn.Parent = TopBar
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

	local MiniBtn = Instance.new("TextButton")
	MiniBtn.Size = UDim2.new(0, 40, 0, 40)
	MiniBtn.Position = UDim2.new(1, -80, 0, 0)
	MiniBtn.Text = "—"
	MiniBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
	MiniBtn.BackgroundTransparency = 1
	MiniBtn.Font = Enum.Font.Code
	MiniBtn.TextSize = 18
	MiniBtn.Parent = TopBar

	local isMinimized = false
	MiniBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		local targetSize = isMinimized and UDim2.new(0, 300, 0, 50) or UDim2.new(0, 300, 0, 400)
		TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
	end)

	-- SIDEBAR
	local Sidebar = Instance.new("ScrollingFrame")
	Sidebar.Size = UDim2.new(0, 50, 1, -80)
	Sidebar.Position = UDim2.new(0, 5, 0, 55)
	Sidebar.BackgroundTransparency = 1
	Sidebar.BorderSizePixel = 0
	Sidebar.ScrollBarThickness = 0
	Sidebar.Parent = MainFrame

	local SideLayout = Instance.new("UIListLayout")
	SideLayout.Parent = Sidebar
	SideLayout.Padding = UDim.new(0, 10)
	SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- CONTAINER
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -65, 1, -80)
	Container.Position = UDim2.new(0, 60, 0, 55)
	Container.BackgroundTransparency = 1
	Container.Parent = MainFrame

	-- FOOTER
	local Footer = Instance.new("TextLabel")
	Footer.Size = UDim2.new(1, 0, 0, 25)
	Footer.Position = UDim2.new(0, 0, 1, -25)
	Footer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	Footer.BorderSizePixel = 0
	Footer.Text = footerText
	Footer.TextColor3 = Color3.fromRGB(80, 80, 80)
	Footer.Font = Enum.Font.Code
	Footer.TextSize = 10
	Footer.Parent = MainFrame

	-- Toggle Keybind Global
	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == toggleKey then
			uiVisible = not uiVisible
			MainFrame.Visible = uiVisible
		end
	end)

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
		Layout.Padding = UDim.new(0, 8)
		
		local AreaBtn = Instance.new("ImageButton")
		AreaBtn.Size = UDim2.new(0, 34, 0, 34)
		AreaBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		AreaBtn.Image = "rbxassetid://" .. (imageId or "0")
		AreaBtn.Parent = Sidebar
		
		local AreaCorner = Instance.new("UICorner")
		AreaCorner.CornerRadius = UDim.new(0, 8)
		AreaCorner.Parent = AreaBtn

		local function Select()
			for _, v in pairs(Container:GetChildren()) do 
				if v:IsA("ScrollingFrame") then v.Visible = false end
			end
			AreaFrame.Visible = true
			SubtitleLabel.Text = name:upper()
			-- Efeito de cor no botão selecionado
			for _, b in pairs(Sidebar:GetChildren()) do
				if b:IsA("ImageButton") then b.ImageColor3 = Color3.fromRGB(150, 150, 150) end
			end
			AreaBtn.ImageColor3 = mainColor
		end

		AreaBtn.MouseButton1Click:Connect(Select)
		if not currentArea then Select() currentArea = true end

		local Elements = {}

		function Elements:Label(text)
			local lab = Instance.new("TextLabel")
			lab.Size = UDim2.new(0.96, 0, 0, 20)
			lab.BackgroundTransparency = 1
			lab.Text = text
			lab.TextColor3 = Color3.fromRGB(150, 150, 150)
			lab.Font = Enum.Font.Code
			lab.TextSize = 11
			lab.TextXAlignment = Enum.TextXAlignment.Left
			lab.Parent = AreaFrame
		end

		function Elements:Button(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0.96, 0, 0, 34)
			btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			btn.Text = text .. " •"
			btn.TextColor3 = Color3.fromRGB(230, 230, 230)
			btn.Font = Enum.Font.Code
			btn.TextSize = 12
			btn.Parent = AreaFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
			
			btn.MouseButton1Click:Connect(function()
				local t = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = mainColor})
				t:Play() t.Completed:Connect(function() 
					TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
				end)
				callback()
			end)
		end

		function Elements:Toggle(text, callback)
			local state = Configs[text] or false
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0.96, 0, 0, 34)
			btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			btn.Font = Enum.Font.Code
			btn.TextSize = 12
			btn.Parent = AreaFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

			local function update()
				btn.Text = state and text .. " ✓" or text .. " ○"
				btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
				btn.BackgroundColor3 = state and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(22, 22, 22)
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
		end

		function Elements:Slider(text, min, max, default, callback)
			local saved = Configs[text] or default
			local sFrame = Instance.new("Frame")
			sFrame.Size = UDim2.new(0.96, 0, 0, 48)
			sFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			sFrame.Parent = AreaFrame
			Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)

			local lab = Instance.new("TextLabel")
			lab.Size = UDim2.new(1, 0, 0, 22)
			lab.Position = UDim2.new(0, 10, 0, 2)
			lab.Text = text:upper()
			lab.TextColor3 = Color3.fromRGB(180, 180, 180)
			lab.BackgroundTransparency = 1
			lab.Font = Enum.Font.Code
			lab.TextSize = 10
			lab.TextXAlignment = Enum.TextXAlignment.Left
			lab.Parent = sFrame

			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(0.75, 0, 0, 5)
			bar.Position = UDim2.new(0.05, 0, 0.75, -5)
			bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			bar.Parent = sFrame
			Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((saved-min)/(max-min), 0, 1, 0)
			fill.BackgroundColor3 = mainColor
			fill.Parent = bar
			Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

			local valLabel = Instance.new("TextLabel")
			valLabel.Size = UDim2.new(0, 40, 0, 20)
			valLabel.Position = UDim2.new(0.82, 0, 0.6, -10)
			valLabel.Text = tostring(saved)
			valLabel.TextColor3 = mainColor
			valLabel.BackgroundTransparency = 1
			valLabel.Font = Enum.Font.Code
			valLabel.Parent = sFrame

			local dragging = false
			local function move(input)
				local r = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(r, 0, 1, 0)
				local val = math.floor(min + (max - min) * r)
				valLabel.Text = tostring(val)
				SaveData[text] = val
				if internalAutoSave then SaveToFile() end
				callback(val)
			end

			sFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true move(i) end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then move(i) end end)
			UserInputService.InputEnded:Connect(function() dragging = false end)
			task.spawn(function() callback(saved) end)
		end

		function Elements:Dropdown(text, list, callback)
			local open = false
			local dropFrame = Instance.new("Frame")
			dropFrame.Size = UDim2.new(0.96, 0, 0, 34)
			dropFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			dropFrame.ClipsDescendants = true
			dropFrame.Parent = AreaFrame
			Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 4)

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 34)
			btn.BackgroundTransparency = 1
			btn.Text = text .. " >"
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			btn.Font = Enum.Font.Code
			btn.TextSize = 12
			btn.Parent = dropFrame

			local container = Instance.new("Frame")
			container.Size = UDim2.new(1, 0, 0, #list * 30)
			container.Position = UDim2.new(0, 0, 0, 34)
			container.BackgroundTransparency = 1
			container.Parent = dropFrame

			for i, v in pairs(list) do
				local item = Instance.new("TextButton")
				item.Size = UDim2.new(1, 0, 0, 30)
				item.Position = UDim2.new(0, 0, 0, (i-1)*30)
				item.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
				item.BorderSizePixel = 0
				item.Text = tostring(v)
				item.TextColor3 = Color3.fromRGB(150, 150, 150)
				item.Font = Enum.Font.Code
				item.TextSize = 11
				item.Parent = container
				item.MouseButton1Click:Connect(function()
					btn.Text = text .. ": " .. tostring(v)
					open = false
					dropFrame:TweenSize(UDim2.new(0.96, 0, 0, 34), "Out", "Quart", 0.3, true)
					callback(v)
				end)
			end

			btn.MouseButton1Click:Connect(function()
				open = not open
				local target = open and UDim2.new(0.96, 0, 0, 34 + (#list * 30)) or UDim2.new(0.96, 0, 0, 34)
				dropFrame:TweenSize(target, "Out", "Quart", 0.3, true)
			end)
		end

		function Elements:Box(placeholder, callback)
			local saved = Configs[placeholder] or ""
			local box = Instance.new("TextBox")
			box.Size = UDim2.new(0.96, 0, 0, 34)
			box.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			box.Text = saved
			box.PlaceholderText = "> " .. placeholder .. "..."
			box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
			box.TextColor3 = Color3.fromRGB(255, 255, 255)
			box.Font = Enum.Font.Code
			box.TextSize = 12
			box.Parent = AreaFrame
			Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
			
			box.FocusLost:Connect(function(enter)
				SaveData[placeholder] = box.Text
				if internalAutoSave then SaveToFile() end
				callback(box.Text)
			end)
		end

		return Elements
	end

	function Lib:AutoSaveLuay(b) internalAutoSave = b end
	function Lib:Save() internalAutoSave = true SaveToFile() end

	return Lib
end

return luayV2
