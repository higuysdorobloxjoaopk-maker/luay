-- [[ luayV2 - THE LEVIATHAN CORE (ULTIMATE EDITION) ]] --
local luayV2 = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Debris = game:GetService("Debris")

local plr = players.LocalPlayer
local mouse = plr:GetMouse()

local ICON_MAP = {
    ["house"] = "rbxassetid://7072706663",
    ["settings"] = "rbxassetid://7072721682",
    ["user"] = "rbxassetid://7072724418",
    ["combat"] = "rbxassetid://7072882435",
    ["folder"] = "rbxassetid://7072706503",
    ["eye"] = "rbxassetid://7072706395",
    ["shield"] = "rbxassetid://7072720072"
}

-- [[ FUNÇÕES AUXILIARES ]] --
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Down:Connect(function()
        local ripple = Instance.new("Frame", obj)
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.6
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0, mouse.X - obj.AbsolutePosition.X, 0, mouse.Y - obj.AbsolutePosition.Y)
        Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
        ripple:TweenSizeAndPosition(UDim2.new(0, 400, 0, 400), UDim2.new(0.5, -200, 0.5, -200), "Out", "Quad", 0.5)
        TweenService:Create(ripple, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        Debris:AddItem(ripple, 0.5)
    end)
end

local function MakeDraggable(topbar, object)
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = object.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function luayV2:Window(config)
    local Window = {
        MainColor = config.Color or Color3.fromRGB(0, 170, 255),
        Size = UDim2.new(0, 230, 0, 450),
        Closed = false,
        AutoSave = false,
        ConfigData = {},
        Toggles = {}, -- Para desligamento automático
        FileName = (config.Name or "Config") .. "_Levi.json"
    }

    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "Leviathan_" .. HttpService:GenerateGUID(false)

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = Window.Size
    Main.Position = UDim2.new(0.5, -115, 0.5, -225)
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Main.BorderSizePixel = 0; Main.ClipsDescendants = true

    local TopBar = Instance.new("Frame", Main)
    TopBar.Size = UDim2.new(1, 0, 0, 40); TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18); TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, Main)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Text = "  " .. config.Name:upper(); Title.Size = UDim2.new(0.6, 0, 1, 0); Title.TextColor3 = Color3.new(1,1,1); Title.Font = "Code"; Title.TextSize = 13; Title.BackgroundTransparency = 1; Title.TextXAlignment = "Left"

    -- [[ BOTÕES DE CONTROLE ]] --
    local BtnContainer = Instance.new("Frame", TopBar)
    BtnContainer.Size = UDim2.new(0, 80, 1, 0); BtnContainer.Position = UDim2.new(1, -85, 0, 0); BtnContainer.BackgroundTransparency = 1
    
    local Close = Instance.new("TextButton", BtnContainer)
    Close.Size = UDim2.new(0.5, 0, 1, 0); Close.Position = UDim2.new(0.5, 0, 0, 0); Close.Text = "×"; Close.TextColor3 = Color3.fromRGB(255, 80, 80); Close.Font = "Code"; Close.TextSize = 20; Close.BackgroundTransparency = 1

    local Minimize = Instance.new("TextButton", BtnContainer)
    Minimize.Size = UDim2.new(0.5, 0, 1, 0); Minimize.Text = "-"; Minimize.TextColor3 = Color3.new(0.7,0.7,0.7); Minimize.Font = "Code"; Minimize.TextSize = 20; Minimize.BackgroundTransparency = 1

    -- [[ LÓGICA DE PERSISTÊNCIA ]] --
    function Window:Save()
        if writefile then pcall(function() writefile(Window.FileName, HttpService:JSONEncode(Window.ConfigData)) end) end
    end

    function Window:Load()
        if isfile and isfile(Window.FileName) then
            local success, content = pcall(function() return readfile(Window.FileName) end)
            if success then Window.ConfigData = HttpService:JSONDecode(content) end
        end
    end

    -- [[ FECHAMENTO ANIMADO & CLEANUP ]] --
    Close.MouseButton1Click:Connect(function()
        if Window.Closed then return end
        Window.Closed = true
        
        -- 1. Desliga tudo
        for _, toggle in pairs(Window.Toggles) do toggle(false) end
        
        -- 2. Animação Sequencial
        local info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        TweenService:Create(Main, info, {Size = UDim2.new(0, 230, 0, 40)}):Play()
        task.wait(0.4)
        TweenService:Create(Main, info, {Size = UDim2.new(0, 0, 0, 40)}):Play()
        task.wait(0.4)
        ScreenGui:Destroy()
    end)

    -- [[ MINIMIZAÇÃO ]] --
    local isMin = false
    Minimize.MouseButton1Click:Connect(function()
        isMin = not isMin
        local targetSize = isMin and UDim2.new(0, 230, 0, 40) or Window.Size
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
    end)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 40, 1, -50); Sidebar.Position = UDim2.new(0, 5, 0, 45); Sidebar.BackgroundTransparency = 1
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

    local Container = Instance.new("Frame", Main)
    Container.Size = UDim2.new(1, -55, 1, -50); Container.Position = UDim2.new(0, 50, 0, 45); Container.BackgroundTransparency = 1

    function Window:Area(name, icon)
        Window.ConfigData[name] = Window.ConfigData[name] or {}
        
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, 0, 1, 0); AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.BorderSizePixel = 0; AreaFrame.ScrollBarThickness = 0; AreaFrame.AutomaticCanvasSize = "Y"
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 30, 0, 30); TabBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); TabBtn.BorderSizePixel = 0; TabBtn.Image = ICON_MAP[icon] or icon; TabBtn.ImageColor3 = Color3.fromRGB(120, 120, 120)
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("ImageButton") then v.ImageColor3 = Color3.fromRGB(120, 120, 120) end end
            AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor
        end)

        if #Sidebar:GetChildren() == 2 then AreaFrame.Visible = true; TabBtn.ImageColor3 = Window.MainColor end

        local Elements = {}

        -- Botão Dinâmico
        function Elements:Button(txt, cb)
            local b = Instance.new("TextButton", AreaFrame); b.Size = UDim2.new(0.95, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(18, 18, 18); b.BorderSizePixel = 0; b.Text = " " .. txt:upper(); b.TextColor3 = Color3.new(1,1,1); b.Font = "Code"; b.TextSize = 11; b.TextXAlignment = "Left"
            Ripple(b); b.MouseButton1Click:Connect(cb)
            return {
                SetText = function(_, nt) b.Text = " " .. nt:upper() end
            }
        end

        -- Toggle com Salvamento e Cleanup
        function Elements:Toggle(txt, def, cb)
            local saved = Window.ConfigData[name][txt]
            local s = (saved ~= nil and saved) or def or false
            
            local t = Instance.new("TextButton", AreaFrame); t.Size = UDim2.new(0.95, 0, 0, 30); t.BackgroundColor3 = Color3.fromRGB(18, 18, 18); t.BorderSizePixel = 0; t.Text = " " .. txt; t.TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(120,120,120); t.Font = "Code"; t.TextSize = 11; t.TextXAlignment = "Left"
            local ind = Instance.new("Frame", t); ind.Size = UDim2.new(0, 2, 1, 0); ind.Position = UDim2.new(1, -2, 0, 0); ind.BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40); ind.BorderSizePixel = 0
            
            local function update(val)
                s = val
                Window.ConfigData[name][txt] = s
                TweenService:Create(t, TweenInfo.new(0.2), {TextColor3 = s and Color3.new(1,1,1) or Color3.fromRGB(120,120,120)}):Play()
                TweenService:Create(ind, TweenInfo.new(0.2), {BackgroundColor3 = s and Window.MainColor or Color3.fromRGB(40,40,40)}):Play()
                cb(s)
                if Window.AutoSave then Window:Save() end
            end

            t.MouseButton1Click:Connect(function() update(not s) end)
            table.insert(Window.Toggles, function(force) if force == false and s then cb(false) end end)
            
            if saved ~= nil then task.spawn(cb, s) end
        end

        -- Caixa de Entrada de Texto
        function Elements:Input(txt, placeholder, cb)
            local f = Instance.new("Frame", AreaFrame); f.Size = UDim2.new(0.95, 0, 0, 45); f.BackgroundColor3 = Color3.fromRGB(15,15,15); f.BorderSizePixel = 0
            local l = Instance.new("TextLabel", f); l.Text = " " .. txt:upper(); l.Size = UDim2.new(1, 0, 0, 18); l.TextColor3 = Window.MainColor; l.Font = "Code"; l.TextSize = 9; l.BackgroundTransparency = 1; l.TextXAlignment = "Left"
            local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.9, 0, 0, 20); i.Position = UDim2.new(0.05, 0, 0.5, 0); i.BackgroundColor3 = Color3.fromRGB(10,10,10); i.BorderSizePixel = 0; i.Text = ""; i.PlaceholderText = placeholder; i.TextColor3 = Color3.new(1,1,1); i.Font = "Code"; i.TextSize = 11
            i.FocusLost:Connect(function(e) if e then cb(i.Text) end end)
        end

        -- Label Atualizável
        function Elements:Label(txt)
            local l = Instance.new("TextLabel", AreaFrame); l.Size = UDim2.new(0.95, 0, 0, 20); l.BackgroundTransparency = 1; l.Text = "> " .. txt; l.TextColor3 = Color3.fromRGB(180,180,180); l.Font = "Code"; l.TextSize = 10; l.TextXAlignment = "Left"
            return {
                Update = function(_, nt) l.Text = "> " .. nt end,
                Color = function(_, c) l.TextColor3 = c end
            }
        end

        -- Controles de Sistema
        function Elements:SystemConfig()
            self:Toggle("Auto-Salvamento", Window.AutoSave, function(v) Window.AutoSave = v end)
            self:Button("Salvar Agora", function() Window:Save() end)
        end

        return Elements
    end

    Window:Load()
    return Window
end

return luayV2
