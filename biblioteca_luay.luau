local luayV2 = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local plr = players.LocalPlayer

-- [[ FUNÇÕES AUXILIARES DE MAGIA ]]
local function MakeDraggable(frame, parent)
	local dragging, dragInput, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = parent.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function luayV2:Window(config)
	local title = config.Name or "LUAY V2"
	local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
	local footerText = config.Footer or "SISTEMA OPERACIONAL LUAY"
	local fileName = "luayV2_Data_" .. plr.UserId .. ".json"
	
	local SaveData = {}
	local internalAutoSave = false
	local currentArea = nil
	local uiVisible = true

	-- Funções de Persistência
	local function Save()
		if not internalAutoSave then return end
		local json = HttpService:JSONEncode(SaveData)
		if writefile then writefile(fileName, json) end
	end

	local function Load()
		if isfile and isfile(fileName) then
			local content = readfile(fileName)
			return HttpService:JSONDecode(content)
		end
		return {}
	end

	local Configs = Load()

	-- [[ ESTRUTURA VISUAL HARD-EDGE ]]
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "LUAY_V2_INDUSTRIAL"
	ScreenGui.ResetOnSpawn = false
	if gethui then ScreenGui.Parent = gethui() else ScreenGui.Parent = CoreGui end

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 350, 0, 450)
	MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
	MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
	MainFrame.BorderSizePixel = 1
	MainFrame.BorderColor3 = Color3.fromRGB(35, 35, 35)
	MainFrame.Parent = ScreenGui

	-- Efeito Scanline (Linhas de TV Antiga)
	local Scanline = Instance.new("Frame")
	Scanline.Size = UDim2.new(1, 0, 0, 2)
	Scanline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Scanline.BackgroundTransparency = 0.95
	Scanline.BorderSizePixel = 0
	Scanline.ZIndex = 10
	Scanline.Parent = MainFrame
	task.spawn(function()
		while task.wait() do
			Scanline.Position = UDim2.new(0, 0, 0, 0)
			local tween = TweenService:Create(Scanline, TweenInfo.new(4, Enum.EasingStyle.Linear), {Position = UDim2.new(0, 0, 1, 0)})
			tween:Play()
			tween.Completed:Wait()
		end
	end)

	-- Linha Superior Azul (_)
	local TopAccent = Instance.new("Frame")
	TopAccent.Size = UDim2.new(1, 0, 0, 2)
	TopAccent.BackgroundColor3 = mainColor
	TopAccent.BorderSizePixel = 0
	TopAccent.Parent = MainFrame

	-- Barra de Título
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 45)
	TopBar.Position = UDim2.new(0, 0, 0, 2)
	TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame
	MakeDraggable(TopBar, MainFrame)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -100, 0, 25)
	Title.Position = UDim2.new(0, 15, 0, 5)
	Title.Text = title:upper()
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Font = Enum.Font.Code
	Title.TextSize = 14
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

	local SubTitle = Instance.new("TextLabel")
	SubTitle.Size = UDim2.new(1, -100, 0, 15)
	SubTitle.Position = UDim2.new(0, 15, 0, 25)
	SubTitle.Text = "STATUS: OPERACIONAL"
	SubTitle.TextColor3 = mainColor
	SubTitle.Font = Enum.Font.Code
	SubTitle.TextSize = 10
	SubTitle.BackgroundTransparency = 1
	SubTitle.TextXAlignment = Enum.TextXAlignment.Left
	SubTitle.Parent = TopBar

	-- Botão Fechar (X)
	local Close = Instance.new("TextButton")
	Close.Size = UDim2.new(0, 45, 1, 0)
	Close.Position = UDim2.new(1, -45, 0, 0)
	Close.Text = "[X]"
	Close.TextColor3 = Color3.fromRGB(150, 50, 50)
	Close.BackgroundTransparency = 1
	Close.Font = Enum.Font.Code
	Close.TextSize = 14
	Close.Parent = TopBar
	Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

	-- Linha Vertical (|) Escolhida
	local Separator = Instance.new("Frame")
	Separator.Size = UDim2.new(0, 1, 1, -75)
	Separator.Position = UDim2.new(0, 55, 0, 50)
	Separator.BackgroundColor3 = mainColor
	Separator.BorderSizePixel = 0
	Separator.Parent = MainFrame

	-- Sidebar de Áreas
	local Sidebar = Instance.new("ScrollingFrame")
	Sidebar.Size = UDim2.new(0, 50, 1, -80)
	Sidebar.Position = UDim2.new(0, 2, 0, 50)
	Sidebar.BackgroundTransparency = 1
	Sidebar.BorderSizePixel = 0
	Sidebar.ScrollBarThickness = 0
	Sidebar.Parent = MainFrame

	local SideLayout = Instance.new("UIListLayout")
	SideLayout.Parent = Sidebar
	SideLayout.Padding = UDim.new(0, 15)
	SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Container de Elementos
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -70, 1, -85)
	Container.Position = UDim2.new(0, 65, 0, 55)
	Container.BackgroundTransparency = 1
	Container.Parent = MainFrame

	-- Footer Estilo Barra de Status
	local Footer = Instance.new("Frame")
	Footer.Size = UDim2.new(1, 0, 0, 25)
	Footer.Position = UDim2.new(0, 0, 1, -25)
	Footer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	Footer.BorderSizePixel = 0
	Footer.Parent = MainFrame

	local FooterText = Instance.new("TextLabel")
	FooterText.Size = UDim2.new(1, -20, 1, 0)
	FooterText.Position = UDim2.new(0, 10, 0, 0)
	FooterText.Text = footerText:upper()
	FooterText.TextColor3 = Color3.fromRGB(80, 80, 80)
	FooterText.Font = Enum.Font.Code
	FooterText.TextSize = 10
	FooterText.BackgroundTransparency = 1
	FooterText.TextXAlignment = Enum.TextXAlignment.Left
	FooterText.Parent = Footer

	-- Keybind Global (Ocultar GUI)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if not gpe and input.KeyCode == (config.Keybind or Enum.KeyCode.RightControl) then
			uiVisible = not uiVisible
			MainFrame.Visible = uiVisible
		end
	end)

	local Lib = {}

	-- [[ NOTIFICAÇÕES INTERNAS ]]
	function Lib:Notify(msg)
		local nFrame = Instance.new("Frame")
		nFrame.Size = UDim2.new(0, 180, 0, 30)
		nFrame.Position = UDim2.new(1, 10, 1, -70)
		nFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		nFrame.BorderSizePixel = 1
		nFrame.BorderColor3 = mainColor
		nFrame.Parent = ScreenGui

		local nText = Instance.new("TextLabel")
		nText.Size = UDim2.new(1, 0, 1, 0)
		nText.Text = "> " .. msg:upper()
		nText.TextColor3 = Color3.fromRGB(255, 255, 255)
		nText.Font = Enum.Font.Code
		nText.TextSize = 10
		nText.BackgroundTransparency = 1
		nText.Parent = nFrame

		nFrame:TweenPosition(UDim2.new(1, -190, 1, -70), "Out", "Quart", 0.5)
		task.delay(3, function()
			nFrame:TweenPosition(UDim2.new(1, 10, 1, -70), "In", "Quart", 0.5)
			task.wait(0.5)
			nFrame:Destroy()
		end)
	end

	-- [[ CRIAÇÃO DE ÁREA ]]
	function Lib:Area(name, imageId)
		local AreaFrame = Instance.new("ScrollingFrame")
		AreaFrame.Size = UDim2.new(1, 0, 1, 0)
		AreaFrame.BackgroundTransparency = 1
		AreaFrame.BorderSizePixel = 0
		AreaFrame.Visible = false
		AreaFrame.ScrollBarThickness = 2
		AreaFrame.ScrollBarImageColor3 = mainColor
		AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		AreaFrame.Parent = Container

		local Layout = Instance.new("UIListLayout")
		Layout.Parent = AreaFrame
		Layout.Padding = UDim.new(0, 8)

		local AreaBtn = Instance.new("ImageButton")
		AreaBtn.Size = UDim2.new(0, 32, 0, 32)
		AreaBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		AreaBtn.Image = "rbxassetid://" .. (imageId or "0")
		AreaBtn.BorderSizePixel = 1
		AreaBtn.BorderColor3 = Color3.fromRGB(30, 30, 30)
		AreaBtn.Parent = Sidebar

		local function Select()
			for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
			AreaFrame.Visible = true
			SubTitle.Text = "ÁREA: " .. name:upper()
			for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("ImageButton") then b.BorderColor3 = Color3.fromRGB(30, 30, 30) b.ImageColor3 = Color3.fromRGB(150,150,150) end end
			AreaBtn.BorderColor3 = mainColor
			AreaBtn.ImageColor3 = Color3.fromRGB(255,255,255)
		end
		AreaBtn.MouseButton1Click:Connect(Select)
		if not currentArea then Select() currentArea = true end

		local Elements = {}

		-- Funções de Elementos
		function Elements:Label(text)
			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(0.95, 0, 0, 20)
			l.Text = "-- " .. text .. " --"
			l.TextColor3 = mainColor
			l.Font = Enum.Font.Code
			l.TextSize = 10
			l.BackgroundTransparency = 1
			l.Parent = AreaFrame
			return l
		end

		function Elements:Button(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0.95, 0, 0, 32)
			btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			btn.BorderSizePixel = 1
			btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
			btn.Text = text:upper() .. " •"
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			btn.Font = Enum.Font.Code
			btn.TextSize = 12
			btn.Parent = AreaFrame
			btn.MouseButton1Click:Connect(function()
				btn.BorderColor3 = mainColor
				task.wait(0.1)
				btn.BorderColor3 = Color3.fromRGB(40, 40, 40)
				callback()
			end)
		end

		function Elements:Toggle(text, callback)
			local state = Configs[text] or false
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0.95, 0, 0, 32)
			btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			btn.BorderSizePixel = 1
			btn.Font = Enum.Font.Code
			btn.TextSize = 12
			btn.Parent = AreaFrame

			local function update()
				btn.Text = state and text:upper() .. " [ATIVO]" or text:upper() .. " [OFF]"
				btn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
				btn.BorderColor3 = state and mainColor or Color3.fromRGB(40, 40, 40)
			end
			update()
			if state then task.spawn(function() callback(state) end) end

			btn.MouseButton1Click:Connect(function()
				state = not state
				update()
				SaveData[text] = state
				Save()
				callback(state)
			end)
		end

		function Elements:Slider(text, min, max, default, callback)
			local saved = Configs[text] or default
			local sFrame = Instance.new("Frame")
			sFrame.Size = UDim2.new(0.95, 0, 0, 50)
			sFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			sFrame.BorderSizePixel = 1
			sFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
			sFrame.Parent = AreaFrame

			local l = Instance.new("TextLabel")
			l.Size = UDim2.new(1, 0, 0, 25)
			l.Position = UDim2.new(0, 10, 0, 0)
			l.Text = text:upper() .. ": " .. saved
			l.TextColor3 = Color3.fromRGB(200, 200, 200)
			l.Font = Enum.Font.Code
			l.TextSize = 11
			l.BackgroundTransparency = 1
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.Parent = sFrame

			local bar = Instance.new("Frame")
			bar.Size = UDim2.new(0.85, 0, 0, 2)
			bar.Position = UDim2.new(0.07, 0, 0.75, 0)
			bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
			bar.BorderSizePixel = 0
			bar.Parent = sFrame

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((saved-min)/(max-min), 0, 1, 0)
			fill.BackgroundColor3 = mainColor
			fill.BorderSizePixel = 0
			fill.Parent = bar

			local dragging = false
			local function move(input)
				local r = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(r, 0, 1, 0)
				local val = math.floor(min + (max - min) * r)
				l.Text = text:upper() .. ": " .. val
				SaveData[text] = val
				Save()
				callback(val)
			end

			sFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true move(i) end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then move(i) end end)
			UserInputService.InputEnded:Connect(function() dragging = false end)
			task.spawn(function() callback(saved) end)
		end

		function Elements:Dropdown(text, options, callback)
			local open = false
			local dFrame = Instance.new("Frame")
			dFrame.Size = UDim2.new(0.95, 0, 0, 32)
			dFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			dFrame.BorderSizePixel = 1
			dFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
			dFrame.ClipsDescendants = true
			dFrame.Parent = AreaFrame

			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 32)
			btn.Text = text:upper() .. " [V]"
			btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			btn.Font = Enum.Font.Code
			btn.BackgroundTransparency = 1
			btn.Parent = dFrame

			local listContainer = Instance.new("Frame")
			listContainer.Size = UDim2.new(1, 0, 0, #options * 25)
			listContainer.Position = UDim2.new(0, 0, 0, 32)
			listContainer.BackgroundTransparency = 1
			listContainer.Parent = dFrame

			for i, v in pairs(options) do
				local o = Instance.new("TextButton")
				o.Size = UDim2.new(1, 0, 0, 25)
				o.Position = UDim2.new(0, 0, 0, (i-1)*25)
				o.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				o.Text = tostring(v):upper()
				o.TextColor3 = Color3.fromRGB(150, 150, 150)
				o.Font = Enum.Font.Code
				o.BorderSizePixel = 0
				o.Parent = listContainer
				o.MouseButton1Click:Connect(function()
					btn.Text = text:upper() .. ": " .. tostring(v)
					open = false
					dFrame:TweenSize(UDim2.new(0.95, 0, 0, 32), "Out", "Quart", 0.3)
					callback(v)
				end)
			end

			btn.MouseButton1Click:Connect(function()
				open = not open
				local ts = open and UDim2.new(0.95, 0, 0, 32 + (#options * 25)) or UDim2.new(0.95, 0, 0, 32)
				dFrame:TweenSize(ts, "Out", "Quart", 0.3)
			end)
		end

		function Elements:Box(placeholder, callback)
			local b = Instance.new("TextBox")
			b.Size = UDim2.new(0.95, 0, 0, 32)
			b.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			b.BorderSizePixel = 1
			b.BorderColor3 = Color3.fromRGB(40, 40, 40)
			b.PlaceholderText = "> " .. placeholder:upper()
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.Code
			b.TextSize = 12
			b.Parent = AreaFrame
			b.FocusLost:Connect(function() callback(b.Text) end)
		end

		return Elements
	end

	function Lib:AutoSaveLuay(b) internalAutoSave = b end
	return Lib
end

return luayV2
