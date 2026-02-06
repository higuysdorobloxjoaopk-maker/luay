-- [[ luayV2 - THE LEVIATHAN CORE | FULL UNABRIDGED VERSION ]] --
-- [[ DEVELOPED BY JOAOPK]] --

local luayV2 = {}
luayV2.Values = {}

-- [[ SERVIÇOS DO MOTOR ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")

-- [[ VARIÁVEIS GLOBAIS ]] --
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ MAPA DE ÍCONES ]] --
local ICON_MAP = {
    ["house"] = "rbxassetid://7072706663",
    ["settings"] = "rbxassetid://7072721682",
    ["user"] = "rbxassetid://7072724418",
    ["combat"] = "rbxassetid://7072882435",
    ["folder"] = "rbxassetid://7072706503",
    ["eye"] = "rbxassetid://7072706395",
    ["shield"] = "rbxassetid://7072720072",
    ["mouse"] = "rbxassetid://7072706180",
    ["key"] = "rbxassetid://115657721477798"
}

-- [[ SISTEMA DE RIPPLE (EFEITO DE CLIQUE) ]] --
local function CreateRipple(Parent)
    Parent.ClipsDescendants = true
    Parent.MouseButton1Down:Connect(function()
        local RippleFrame = Instance.new("Frame")
        local UICorner = Instance.new("UICorner")
        
        RippleFrame.Name = "Ripple"
        RippleFrame.Parent = Parent
        RippleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        RippleFrame.BackgroundTransparency = 0.7
        RippleFrame.ZIndex = 10
        RippleFrame.Size = UDim2.new(0, 0, 0, 0)
        RippleFrame.Position = UDim2.new(0, Mouse.X - Parent.AbsolutePosition.X, 0, Mouse.Y - Parent.AbsolutePosition.Y)
        
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = RippleFrame
        
        local TweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        local Tween = TweenService:Create(RippleFrame, TweenInfo, {
            Size = UDim2.new(0, Parent.AbsoluteSize.X * 1.5, 0, Parent.AbsoluteSize.X * 1.5),
            Position = UDim2.new(0.5, -(Parent.AbsoluteSize.X * 1.5)/2, 0.5, -(Parent.AbsoluteSize.X * 1.5)/2),
            BackgroundTransparency = 1
        })
        
        Tween:Play()
        Debris:AddItem(RippleFrame, 0.6)
    end)
end

-- [[ SISTEMA DE DRAG (ARRASTAR) ]] --
local function MakeDraggable(Control, Target)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(Input)
        local Delta = Input.Position - DragStart
        Target.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end

    Control.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPosition = Target.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Control.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end)
end

-- [[ SISTEMA DE NOTIFICAÇÃO ]] --
function luayV2:Notify(Config)
    local NotifyGui = CoreGui:FindFirstChild("LeviNotify") or Instance.new("ScreenGui", CoreGui)
    NotifyGui.Name = "LeviNotify"
    
    local Stack = NotifyGui:FindFirstChild("Stack") or Instance.new("Frame", NotifyGui)
    if not NotifyGui:FindFirstChild("Stack") then
        Stack.Name = "Stack"
        Stack.Size = UDim2.new(0, 240, 1, 0)
        Stack.Position = UDim2.new(1, -250, 0, 0)
        Stack.BackgroundTransparency = 1
        local List = Instance.new("UIListLayout", Stack)
        List.VerticalAlignment = "Bottom"
        List.Padding = UDim.new(0, 8)
    end

    local Notif = Instance.new("Frame", Stack)
    Notif.Size = UDim2.new(1, 0, 0, 0)
    Notif.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Notif.BorderSizePixel = 0
    Notif.ClipsDescendants = true
    
    local Accent = Instance.new("Frame", Notif)
    Accent.Size = UDim2.new(0, 3, 1, 0)
    Accent.BackgroundColor3 = Config.Color or Color3.fromRGB(0, 170, 255)
    Accent.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Notif)
    Title.Text = Config.Title:upper()
    Title.Size = UDim2.new(1, -20, 0, 25)
    Title.Position = UDim2.new(0, 12, 0, 5)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 13
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = "Left"

    local Msg = Instance.new("TextLabel", Notif)
    Msg.Text = Config.Text
    Msg.Size = UDim2.new(1, -20, 1, -30)
    Msg.Position = UDim2.new(0, 12, 0, 25)
    Msg.TextColor3 = Color3.fromRGB(180, 180, 180)
    Msg.Font = Enum.Font.Code
    Msg.TextSize = 11
    Msg.BackgroundTransparency = 1
    Msg.TextXAlignment = "Left"
    Msg.TextWrapped = true

    TweenService:Create(Notif, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 75)}):Play()
    
    task.delay(Config.Duration or 5, function()
        TweenService:Create(Notif, TweenInfo.new(0.5), {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.5)
        Notif:Destroy()
    end)
end

-- [[ CONSTRUTOR DA JANELA PRINCIPAL ]] --
function luayV2:Window(Config)
    local Window = {
        Theme = Config.Color or Color3.fromRGB(0, 170, 255),
        Toggles = {},
        FreeButtons = {},
        ConfigData = {},
        ActiveTab = nil,
        Minimized = false,
        Closed = false,
        Size = UDim2.new(0, 250, 0, 345), -- TAMANHO PADRÃO EXIGIDO
        FileName = (Config.Name or "Leviathan") .. "_Config.json"
    }

    -- SALVAMENTO BRUTO (JSON)
    local function LoadData()
        if isfile and isfile(Window.FileName) then
            local success, content = pcall(function() return readfile(Window.FileName) end)
            if success then
                Window.ConfigData = HttpService:JSONDecode(content)
            end
        end
    end

    local function SaveData()
        if writefile then
            pcall(function()
                writefile(Window.FileName, HttpService:JSONEncode(Window.ConfigData))
            end)
        end
    end

    LoadData()

    -- INSTÂNCIAS DA GUI
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Leviathan_" .. HttpService:GenerateGUID(false)
    ScreenGui.ResetOnSpawn = false

    local Main = Instance.new("Frame", ScreenGui)
    Main.Name = "MainFrame"
    Main.Size = Window.Size
    Main.Position = UDim2.new(0.5, -115, 0.5, -177)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 4)

    -- [[ O "L" INVERTIDO NO TOPO E NA ESQUERDA ]] --
    -- Barra Topo (Horizontal)
    local L_Top = Instance.new("Frame", Main)
    L_Top.Name = "L_Top"
    L_Top.Size = UDim2.new(1, 0, 0, 2)
    L_Top.Position = UDim2.new(0, 0, 0, 45) -- Logo abaixo da TopBar
    L_Top.BackgroundColor3 = Window.Theme
    L_Top.BorderSizePixel = 0
    L_Top.ZIndex = 5

    -- Barra Lateral (Vertical)
    local L_Side = Instance.new("Frame", Main)
    L_Side.Name = "L_Side"
    L_Side.Size = UDim2.new(0, 2, 1, 0)
    L_Side.Position = UDim2.new(0, 0, 0, 0) -- ❌ AQUI
    L_Side.BackgroundColor3 = Window.Theme
    L_Side.BorderSizePixel = 0
    L_Side.ZIndex = 5

    -- TOPBAR
    local TopBar = Instance.new("Frame", Main)
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, Main)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Name = "Title"
    Title.Text = "  " .. Config.Name:upper()
    Title.Size = UDim2.new(0.6, 0, 0, 28)
    Title.Position = UDim2.new(0, 0, 0, 2)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 13
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = "Left"

    local Subtitle = Instance.new("TextLabel", TopBar)
    Subtitle.Name = "Subtitle"
    Subtitle.Text = "  ESTADO: PRONTO"
    Subtitle.Size = UDim2.new(0.6, 0, 0, 15)
    Subtitle.Position = UDim2.new(0, 0, 0, 24)
    Subtitle.TextColor3 = Window.Theme
    Subtitle.Font = Enum.Font.Code
    Subtitle.TextSize = 9
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextXAlignment = "Left"

    -- BOTÕES DA TOPBAR
    local Close = Instance.new("TextButton", TopBar)
    Close.Name = "Close"
    Close.Size = UDim2.new(0, 35, 0, 35)
    Close.Position = UDim2.new(1, -38, 0, 5)
    Close.Text = "×"
    Close.TextColor3 = Color3.fromRGB(255, 80, 80)
    Close.Font = Enum.Font.Code
    Close.TextSize = 22
    Close.BackgroundTransparency = 1

    local Minimize = Instance.new("TextButton", TopBar)
    Minimize.Name = "Minimize"
    Minimize.Size = UDim2.new(0, 35, 0, 35)
    Minimize.Position = UDim2.new(1, -73, 0, 5)
    Minimize.Text = "-"
    Minimize.TextColor3 = Color3.new(1, 1, 1)
    Minimize.Font = Enum.Font.Code
    Minimize.TextSize = 22
    Minimize.BackgroundTransparency = 1

    -- CORPO
    local Body = Instance.new("Frame", Main)
    Body.Name = "Body"
    Body.Size = UDim2.new(1, 0, 1, -47)
    Body.Position = UDim2.new(0, 0, 0, 47)
    Body.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", Body)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 40, 1, 0)
    Sidebar.BackgroundTransparency = 1
    
    local SidebarList = Instance.new("UIListLayout", Sidebar)
    SidebarList.HorizontalAlignment = "Center"
    SidebarList.Padding = UDim.new(0, 8)

    local Container = Instance.new("Frame", Body)
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -45, 1, -10)
    Container.Position = UDim2.new(0, 45, 0, 5)
    Container.BackgroundTransparency = 1

    -- [ LÓGICA DE MINIMIZAR ]
    Minimize.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Body.Visible = false
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 230, 0, 47)}):Play()
        else
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = Window.Size}):Play()
            task.wait(0.5)
            Body.Visible = true
        end
    end)

    -- [ LÓGICA DE FECHAR (KILL-SWITCH) ]
    Close.MouseButton1Click:Connect(function()
        if Window.Closed then return end
        Window.Closed = true
        
        -- 1. Desativa todos os Toggles
        for _, Callback in pairs(Window.Toggles) do
            pcall(function() Callback(false) end)
        end
        
        -- [[ NOVO: Destrói os botões flutuantes vinculados a ESTA janela ]] --
        for _, Btn in pairs(Window.FreeButtons) do
            if Btn.Destroy then
                pcall(function() Btn:Destroy() end)
            end
        end
        
        local CloseTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 230, 0, 47)})
        CloseTween:Play()
        CloseTween.Completed:Wait()
        
        local ExitTween = TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 47)})
        ExitTween:Play()
        ExitTween.Completed:Wait()
        
        ScreenGui:Destroy()
    end)

    -- [ FUNÇÃO DE ÁREA ]
    function Window:Area(Name, Icon)
        Window.ConfigData[Name] = Window.ConfigData[Name] or {}
        
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Name = Name .. "_Area"
        AreaFrame.Size = UDim2.new(1, 0, 1, 0)
        AreaFrame.BackgroundTransparency = 1
        AreaFrame.Visible = false
        AreaFrame.BorderSizePixel = 0
        AreaFrame.ScrollBarThickness = 0
        AreaFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local AreaList = Instance.new("UIListLayout", AreaFrame)
        AreaList.Padding = UDim.new(0, 6)
        AreaList.SortOrder = Enum.SortOrder.LayoutOrder

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Name = Name .. "_Btn"
        TabBtn.Size = UDim2.new(0, 26, 0, 26)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Image = ICON_MAP[Icon] or Icon
        TabBtn.ImageColor3 = Color3.fromRGB(120, 120, 120)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(Sidebar:GetChildren()) do
                if v:IsA("ImageButton") then v.ImageColor3 = Color3.fromRGB(120, 120, 120) end
            end
            AreaFrame.Visible = true
            TabBtn.ImageColor3 = Window.Theme
            Subtitle.Text = "  ÁREA: " .. Name:upper()
        end)

        -- Ativa a primeira aba automaticamente
        if #Sidebar:GetChildren() == 2 then 
            AreaFrame.Visible = true
            TabBtn.ImageColor3 = Window.Theme
            Subtitle.Text = "  ÁREA: " .. Name:upper()
        end

        local Elements = {}

        -- [[ BOTÃO ]] --
        function Elements:Button(Text, Callback)
            local Btn = Instance.new("TextButton", AreaFrame)
            Btn.Name = Text .. "_Btn"
            Btn.Size = UDim2.new(0.96, 0, 0, 32)
            Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            Btn.BorderSizePixel = 0
            Btn.Text = "  " .. Text:upper()
            Btn.TextColor3 = Color3.new(1, 1, 1)
            Btn.Font = Enum.Font.Code
            Btn.TextSize = 10
            Btn.TextXAlignment = "Left"
            
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
            CreateRipple(Btn)
            Btn.MouseButton1Click:Connect(Callback)
            
            local Obj = {}
            function Obj:SetText(NewText) Btn.Text = "  " .. NewText:upper() end
            return Obj
        end

        -- [[ TOGGLE ESTILO IOS/MOBILE BOLINHA ]] --
        function Elements:Toggle(Text, Default, Callback)
    local Saved = Window.ConfigData[Name][Text]
    local Enabled = (Saved ~= nil and Saved) or Default or false
    
    local TglBtn = Instance.new("TextButton", AreaFrame)
    TglBtn.Name = Text .. "_Tgl"
    TglBtn.Size = UDim2.new(0.96, 0, 0, 32)
    TglBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    TglBtn.BorderSizePixel = 0
    TglBtn.Text = "  " .. Text
    TglBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    TglBtn.Font = Enum.Font.Code
    TglBtn.TextSize = 11
    TglBtn.TextXAlignment = "Left"
    Instance.new("UICorner", TglBtn).CornerRadius = UDim.new(0, 4)

    -- Trilha do Switch
    local Track = Instance.new("Frame", TglBtn)
    Track.Size = UDim2.new(0, 34, 0, 18)
    Track.Position = UDim2.new(1, -40, 0.5, -9)
    Track.BackgroundColor3 = Enabled and Window.Theme or Color3.fromRGB(45, 45, 45)
    Track.BorderSizePixel = 0
    local TrackCorner = Instance.new("UICorner", Track)
    TrackCorner.CornerRadius = UDim.new(1, 0)

    -- Bolinha
    local Ball = Instance.new("Frame", Track)
    Ball.Size = UDim2.new(0, 14, 0, 14)
    Ball.Position = Enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Ball.BackgroundColor3 = Color3.new(1, 1, 1)
    Ball.BorderSizePixel = 0
    local BallCorner = Instance.new("UICorner", Ball)
    BallCorner.CornerRadius = UDim.new(1, 0)

    local function Update()
        Window.ConfigData[Name][Text] = Enabled
        SaveData()
        
        local TargetPos = Enabled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        local TargetColor = Enabled and Window.Theme or Color3.fromRGB(45, 45, 45)
        
        TweenService:Create(Track, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            BackgroundColor3 = TargetColor
        }):Play()

        Ball:TweenPosition(TargetPos, "Out", "Quart", 0.3, true)
        Callback(Enabled)
    end

    TglBtn.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        Update()
    end)

    table.insert(Window.Toggles, function(Val)
        if Val == false and Enabled then
            Callback(false)
        end
    end)

    if Enabled then task.spawn(Callback, true) end

    -- =========================
    -- ADIÇÃO
    -- =========================

    Window.ToggleControllers = Window.ToggleControllers or {}
    Window.ToggleControllers[Name] = Window.ToggleControllers[Name] or {}

    Window.ToggleControllers[Name][Text] = function(State)
        if Enabled ~= State then
            Enabled = State
            Update()
        end
    end
end

        -- [[ INPUT ]] --
        function Elements:Input(Text, Placeholder, Callback)
            local InputFrame = Instance.new("Frame", AreaFrame)
            InputFrame.Size = UDim2.new(0.96, 0, 0, 45)
            InputFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            InputFrame.BorderSizePixel = 0
            Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 4)

            local Label = Instance.new("TextLabel", InputFrame)
            Label.Text = "  " .. Text:upper()
            Label.Size = UDim2.new(1, 0, 0, 18)
            Label.TextColor3 = Window.Theme
            Label.Font = Enum.Font.Code
            Label.TextSize = 9
            Label.BackgroundTransparency = 1
            Label.TextXAlignment = "Left"

            local Box = Instance.new("TextBox", InputFrame)
            Box.Size = UDim2.new(0.9, 0, 0, 20)
            Box.Position = UDim2.new(0.05, 0, 0.45, 0)
            Box.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            Box.BorderSizePixel = 0
            Box.Text = ""
            Box.PlaceholderText = Placeholder
            Box.TextColor3 = Color3.new(1, 1, 1)
            Box.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
            Box.Font = Enum.Font.Code
            Box.TextSize = 10
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)

            Box.FocusLost:Connect(function(Enter)
                if Enter then Callback(Box.Text) end
            end)
        end

        -- [[ SLIDER MOBILE-FRIENDLY COM HITBOX MAIOR ]]
function Elements:Slider(cfg)
    local Name = cfg.Name or "Slider"
    local Min = cfg.Min or 0
    local Max = cfg.Max or 100
    local Value = cfg.Placeholder or Min

    Value = math.clamp(Value, Min, Max)
    luayV2.Values[Name] = Value

    -- Container
    local SliderFrame = Instance.new("Frame", AreaFrame)
    SliderFrame.Size = UDim2.new(0.96, 0, 0, 45)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(18,18,18)
    SliderFrame.BorderSizePixel = 0
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 4)

    -- Título
    local Title = Instance.new("TextLabel", SliderFrame)
    Title.Size = UDim2.new(1, -50, 0, 18)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(220,220,220)
    Title.Font = Enum.Font.Code
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = Name

    -- Valor numérico
    local ValueLabel = Instance.new("TextLabel", SliderFrame)
    ValueLabel.Size = UDim2.new(0, 50, 0, 18)
    ValueLabel.Position = UDim2.new(1, -50, 0, 0)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.TextColor3 = luayV2.ThemeColor or Color3.fromRGB(0,255,150)
    ValueLabel.Font = Enum.Font.Code
    ValueLabel.TextSize = 12
    ValueLabel.Text = tostring(Value)

    -- Barra
    local Bar = Instance.new("Frame", SliderFrame)
    Bar.Size = UDim2.new(1, -10, 0, 6)
    Bar.Position = UDim2.new(0, 5, 0, 26)
    Bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1,0)

    -- Preenchimento
    local Fill = Instance.new("Frame", Bar)
    Fill.Size = UDim2.new((Value-Min)/(Max-Min), 0, 1, 0)
    Fill.BackgroundColor3 = luayV2.ThemeColor or Color3.fromRGB(0,255,150)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1,0)

    -- Bolinha/handle com HITBOX maior
    local Handle = Instance.new("TextButton", Bar)
    Handle.Size = UDim2.new(0, 14, 0, 14)
    Handle.AnchorPoint = Vector2.new(0.5,0.5)
    Handle.Position = UDim2.new((Value-Min)/(Max-Min), 0, 0.5, 0)
    Handle.BackgroundColor3 = luayV2.ThemeColor or Color3.fromRGB(0,255,150)
    Handle.AutoButtonColor = false
    Handle.Text = "" -- remove o texto
    Instance.new("UICorner", Handle).CornerRadius = UDim.new(1,0)

    -- HITBOX maior (Frame transparente)
    local Hitbox = Instance.new("TextButton", Bar)
    Hitbox.Size = UDim2.new(0, 40, 0, 40)
    Hitbox.AnchorPoint = Vector2.new(0.5,0.5)
    Hitbox.Position = Handle.Position
    Hitbox.BackgroundTransparency = 1
    Hitbox.AutoButtonColor = false
    Hitbox.Text = "" -- remove o texto

    local UIS = game:GetService("UserInputService")
    local dragging = false

    local function updateSlider(inputX)
        local relative = math.clamp((inputX - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,0,1)
        Value = math.floor(Min + (Max-Min)*relative)
        Fill.Size = UDim2.new(relative,0,1,0)
        Handle.Position = UDim2.new(relative,0,0.5,0)
        Hitbox.Position = Handle.Position
        ValueLabel.Text = tostring(Value)
        luayV2.Values[Name] = Value
    end

    local function startDrag(input)
        dragging = true
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateSlider(input.Position.X)
        end
    end

    local function stopDrag(input)
        dragging = false
    end

    Hitbox.InputBegan:Connect(startDrag)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(stopDrag)
end

        -- [[ LABEL ATUALIZÁVEL ]] --
        function Elements:Label(Text)
            local Lbl = Instance.new("TextLabel", AreaFrame)
            Lbl.Size = UDim2.new(0.96, 0, 0, 20)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = "> " .. Text
            Lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
            Lbl.Font = Enum.Font.Code
            Lbl.TextSize = 11
            Lbl.TextXAlignment = "Left"
            
            local Obj = {}
            function Obj:Update(NewText) Lbl.Text = "> " .. NewText end
            function Obj:SetColor(NewColor) Lbl.TextColor3 = NewColor end
            return Obj
        end

        -- [[ CONSOLE DE LOGS ]] --
        function Elements:Logs(Height)
            local LogFrame = Instance.new("ScrollingFrame", AreaFrame)
            LogFrame.Size = UDim2.new(0.96, 0, 0, Height or 100)
            LogFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
            LogFrame.BorderSizePixel = 0
            LogFrame.ScrollBarThickness = 2
            LogFrame.ScrollBarImageColor3 = Window.Theme
            LogFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 4)
            
            local LogList = Instance.new("UIListLayout", LogFrame)
            LogList.Padding = UDim.new(0, 2)

            local LogObj = {}
            function LogObj:Log(Msg, Color)
                local Entry = Instance.new("TextLabel", LogFrame)
                Entry.Size = UDim2.new(1, -5, 0, 14)
                Entry.BackgroundTransparency = 1
                Entry.Text = " [" .. os.date("%X") .. "] " .. Msg
                Entry.TextColor3 = Color or Color3.new(1, 1, 1)
                Entry.Font = Enum.Font.Code
                Entry.TextSize = 9
                Entry.TextXAlignment = "Left"
                LogFrame.CanvasPosition = Vector2.new(0, 9999)
            end
            
            function LogObj:Clear()
                for _, v in pairs(LogFrame:GetChildren()) do
                    if v:IsA("TextLabel") then v:Destroy() end
                end
            end
            
            return LogObj
        end

        return Elements
    end
-- [[ BOTÃO LIVRE / FLUTUANTE VINCULADO À JANELA ]] --
    function Window:CreateFreeButton(Config) -- Mudamos de luayV2 para Window
        local FreeButton = {
            DraggingEnabled = Config.Draggable or false,
            IsHeld = false
        }

        -- Cria uma ScreenGui separada para o botão, mas com nome único baseado na Janela
        local ButtonGui = Instance.new("ScreenGui", CoreGui)
        ButtonGui.Name = "LuayBtn_" .. HttpService:GenerateGUID(false) -- Nome único evita conflitos
        
        -- [[ DICA: Isso ajuda no Anti-Bug visual entre janelas ]]
        ButtonGui.DisplayOrder = ScreenGui.DisplayOrder + 10 

        local BtnFrame = Instance.new("TextButton")
        BtnFrame.Name = Config.Name or "FreeButton"
        BtnFrame.Size = UDim2.new(0, 45, 0, 45)
        BtnFrame.Position = Config.Position or UDim2.new(0.5, 0, 0.5, 0)
        BtnFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        BtnFrame.BackgroundTransparency = 0.35 
        BtnFrame.Text = Config.Text or ""
        BtnFrame.TextColor3 = Color3.new(1, 1, 1)
        BtnFrame.Font = Enum.Font.Code
        BtnFrame.TextSize = 18
        BtnFrame.Parent = ButtonGui
        BtnFrame.AutoButtonColor = false

        -- Estilização
        local Corner = Instance.new("UICorner", BtnFrame)
        Corner.CornerRadius = UDim.new(1, 0)

        local Stroke = Instance.new("UIStroke", BtnFrame)
        Stroke.Color = Window.Theme -- Usa o tema da Janela Pai
        Stroke.Thickness = 2

        -- [ LÓGICA DE ARRASTAR (Mantida igual) ]
        local function EnableDrag()
            local Dragging, DragInput, DragStart, StartPos
            
            BtnFrame.InputBegan:Connect(function(input)
                if FreeButton.DraggingEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    Dragging = true
                    DragStart = input.Position
                    StartPos = BtnFrame.Position
                end
            end)

            BtnFrame.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local Delta = input.Position - DragStart
                    BtnFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
        end
        EnableDrag()

        -- [ LÓGICA DE CLIQUE ]
        BtnFrame.MouseButton1Down:Connect(function()
            FreeButton.IsHeld = true
            if Config.Callback then Config.Callback(true) end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and FreeButton.IsHeld then
                FreeButton.IsHeld = false
                if Config.Callback then Config.Callback(false) end
            end
        end)

        -- Loop de Hold
        task.spawn(function()
            while true do
                if FreeButton.IsHeld and Config.OnHold then
                    Config.OnHold()
                end
                task.wait(0.05)
                if not BtnFrame.Parent then break end
            end
        end)

        -- Métodos do Botão
        function FreeButton:SetLocked(Value)
            self.DraggingEnabled = not Value
            Stroke.Transparency = Value and 0.5 or 0
        end

        function FreeButton:Visible(Value)
            BtnFrame.Visible = Value
        end

        function FreeButton:Destroy()
            ButtonGui:Destroy() -- Destrói a GUI inteira do botão
        end

        -- [[ O SEGREDO: REGISTRAR O BOTÃO NA JANELA ]] --
        table.insert(Window.FreeButtons, FreeButton)

        return FreeButton
    end
    return Window
end

-- [[ ELEMENTO SOLO: KEY SYSTEM COMPLETO ]] --
function luayV2:KeySystem(Config)
    local Key = Config.Key or ""
    local KeyURL = Config.URL or ""
    local LoadstringScript = Config.Loadstring or ""
    local FileName = "LeviKey_Save.json"
    
    -- Função para executar o script final
    local function SuccessAction()
        luayV2:Notify({
            Title = "Key System", 
            Text = "Key corretamente carregando recursos...", 
            Color = Color3.fromRGB(0, 255, 100),
            Duration = 5
        })
        task.wait(1)
        if LoadstringScript ~= "" then
            local s, e = pcall(function()
                loadstring(LoadstringScript)()
            end)
            if not s then warn("Erro ao carregar o script final: " .. e) end
        end
    end

    -- [ AUTO-SAVE: VERIFICA SE JÁ ACERTOU ANTES ]
    if isfile and isfile(FileName) then
        if readfile(FileName) == Key then
            SuccessAction()
            return 
        end
    end

    local KeyGui = Instance.new("ScreenGui", CoreGui)
    KeyGui.Name = "LeviKey_" .. HttpService:GenerateGUID(false)

    local Main = Instance.new("Frame", KeyGui)
    Main.Size = UDim2.new(0, 230, 0, 230)
    Main.Position = UDim2.new(0.5, -115, 0.5, -115)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)
    pcall(function() MakeDraggable(Main, Main) end)

    -- Linha Lateral
    local L_Side = Instance.new("Frame", Main)
    L_Side.Size = UDim2.new(0, 2, 1, 0)
    L_Side.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    L_Side.BorderSizePixel = 0

    -- Botões de Controle (X e -)
    local Controls = Instance.new("Frame", Main)
    Controls.Size = UDim2.new(1, -10, 0, 20)
    Controls.Position = UDim2.new(0, 5, 0, 5)
    Controls.BackgroundTransparency = 1

    local CloseBtn = Instance.new("TextButton", Controls)
    CloseBtn.Text = "X"
    CloseBtn.Size = UDim2.new(0, 20, 0, 20)
    CloseBtn.Position = UDim2.new(1, -20, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 16

    local MiniBtn = Instance.new("TextButton", Controls)
    MiniBtn.Text = "-"
    MiniBtn.Size = UDim2.new(0, 20, 0, 20)
    MiniBtn.Position = UDim2.new(1, -45, 0, 0)
    MiniBtn.BackgroundTransparency = 1
    MiniBtn.TextColor3 = Color3.new(1, 1, 1)
    MiniBtn.Font = Enum.Font.Code
    MiniBtn.TextSize = 20

    -- Imagem e Título
    local Icon = Instance.new("ImageLabel", Main)
    Icon.Size = UDim2.new(0, 60, 0, 60)
    Icon.Position = UDim2.new(0.5, -30, 0, 20)
    Icon.BackgroundTransparency = 1
    Icon.Image = "rbxassetid://81772726"

    local Title = Instance.new("TextLabel", Main)
    Title.Text = "KEY SYSTEM"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Position = UDim2.new(0, 0, 0, 85)
    Title.TextColor3 = Color3.new(1, 1, 1)
    Title.Font = Enum.Font.Code
    Title.TextSize = 14
    Title.BackgroundTransparency = 1

    -- Input e Botões
    local Input = Instance.new("TextBox", Main)
    Input.Size = UDim2.new(0.8, 0, 0, 30)
    Input.Position = UDim2.new(0.1, 0, 0, 120)
    Input.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Input.PlaceholderText = "INSIRA A CHAVE..."
    Input.Text = ""
    Input.TextColor3 = Color3.new(1, 1, 1)
    Input.Font = Enum.Font.Code
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 4)

    local Submit = Instance.new("TextButton", Main)
    Submit.Text = "SUBMIT"
    Submit.Size = UDim2.new(0.8, 0, 0, 25)
    Submit.Position = UDim2.new(0.1, 0, 0, 160)
    Submit.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Submit.TextColor3 = Color3.new(1, 1, 1)
    Submit.Font = Enum.Font.Code
    Instance.new("UICorner", Submit).CornerRadius = UDim.new(0, 4)

    local GetKey = Instance.new("TextButton", Main)
    GetKey.Text = "GET KEY"
    GetKey.Size = UDim2.new(0.8, 0, 0, 25)
    GetKey.Position = UDim2.new(0.1, 0, 0, 190)
    GetKey.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    GetKey.TextColor3 = Color3.fromRGB(150, 150, 150)
    GetKey.Font = Enum.Font.Code
    Instance.new("UICorner", GetKey).CornerRadius = UDim.new(0, 4)

    -- [ LÓGICA DOS BOTÕES ]
    CloseBtn.MouseButton1Click:Connect(function() KeyGui:Destroy() end)
    
    local Minimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        Minimized = not Minimized
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = Minimized and UDim2.new(0, 230, 0, 30) or UDim2.new(0, 230, 0, 230)}):Play()
    end)

    Submit.MouseButton1Click:Connect(function()
        if Input.Text == Key then
            if writefile then writefile(FileName, Key) end
            KeyGui:Destroy()
            SuccessAction()
        else
            luayV2:Notify({
                Title = "Key System", 
                Text = "Erro Key {" .. Input.Text .. "} não é valida", 
                Color = Color3.fromRGB(255, 50, 50),
                Duration = 5
            })
            Input.Text = ""
        end
    end)

    GetKey.MouseButton1Click:Connect(function()
        setclipboard(KeyURL)
        luayV2:Notify({Title = "Key System", Text = "URL Copiada!", Color = Color3.fromRGB(200, 200, 200)})
    end)
end

--[[ end ]]--
function luayV2:GetValue(name)
    return self.Values[name]
end

return luayV2
