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

    -- Cores para a lista (50 Cores)
    local ColorPresets = {
        ["Azul Padrão"] = Color3.fromRGB(0, 170, 255), ["Vermelho"] = Color3.fromRGB(255, 50, 50),
        ["Verde"] = Color3.fromRGB(50, 255, 100), ["Roxo"] = Color3.fromRGB(170, 0, 255),
        ["Rosa"] = Color3.fromRGB(255, 0, 150), ["Laranja"] = Color3.fromRGB(255, 120, 0),
        ["Amarelo"] = Color3.fromRGB(255, 220, 0), ["Ciano"] = Color3.fromRGB(0, 255, 255),
        ["Branco"] = Color3.fromRGB(255, 255, 255), ["Cinza"] = Color3.fromRGB(150, 150, 150)
        -- ... (Adicionadas dinamicamente via loop para completar 50 na lógica de temas se desejar)
    }

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
    if Configs.MainColorR then
        mainColor = Color3.new(Configs.MainColorR, Configs.MainColorG, Configs.MainColorB)
    end

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

    -- Barra Decorativa Lateral Esquerda
    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 2, 1, 0)
    SideAccent.BackgroundColor3 = mainColor
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    -- Barra Decorativa Inferior do Menu
    local MenuLine = Instance.new("Frame")
    MenuLine.Size = UDim2.new(1, 0, 0, 2)
    MenuLine.Position = UDim2.new(0, 0, 1, -2)
    MenuLine.BackgroundColor3 = mainColor
    MenuLine.BorderSizePixel = 0
    MenuLine.Parent = TopBar

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

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 45, 1, -65)
    Sidebar.Position = UDim2.new(0, 5, 0, 50)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainFrame

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -60, 1, -65)
    Container.Position = UDim2.new(0, 55, 0, 50)
    Container.BackgroundTransparency = 1
    Container.Parent = MainFrame

    -- Corrigindo Minimizar para sumir com os elementos
    local isMinimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local targetSize = isMinimized and UDim2.new(0, 280, 0, 45) or UDim2.new(0, 280, 0, 380)
        Sidebar.Visible = not isMinimized
        Container.Visible = not isMinimized
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = targetSize}):Play()
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
        Layout.Padding = UDim.new(0, 6)
        
        local AreaBtn = Instance.new("ImageButton")
        AreaBtn.Size = UDim2.new(0, 32, 0, 32)
        AreaBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        AreaBtn.Image = "rbxassetid://" .. (imageId or "0")
        AreaBtn.Parent = Sidebar
        Instance.new("UICorner", AreaBtn).CornerRadius = UDim.new(0, 6)

        AreaBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaFrame.Visible = true
            SubtitleLabel.Text = name:upper()
        end)
        if not currentArea then AreaFrame.Visible = true currentArea = true end

        local Elements = {}

        -- NOVO: Elemento de Dropdown/Lista (Usado para cores e temas)
        function Elements:Dropdown(text, list, callback)
            local dropped = false
            local dropFrame = Instance.new("Frame")
            dropFrame.Size = UDim2.new(0.95, 0, 0, 32)
            dropFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            dropFrame.ClipsDescendants = true
            dropFrame.Parent = AreaFrame
            Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 4)

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundTransparency = 1
            btn.Text = text .. " ▽"
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
            btn.Parent = dropFrame

            local itemList = Instance.new("Frame")
            itemList.Size = UDim2.new(1, 0, 0, #list * 25)
            itemList.Position = UDim2.new(0, 0, 0, 32)
            itemList.BackgroundTransparency = 1
            itemList.Parent = dropFrame

            local iLayout = Instance.new("UIListLayout")
            iLayout.Parent = itemList

            for _, val in pairs(list) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 25)
                item.BackgroundTransparency = 1
                item.Text = tostring(val)
                item.TextColor3 = Color3.fromRGB(150, 150, 150)
                item.Font = Enum.Font.Code
                item.TextSize = 11
                item.Parent = itemList
                
                item.MouseButton1Click:Connect(function()
                    dropped = false
                    dropFrame.Size = UDim2.new(0.95, 0, 0, 32)
                    btn.Text = text .. " [" .. tostring(val) .. "]"
                    callback(val)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                dropped = not dropped
                dropFrame.Size = dropped and UDim2.new(0.95, 0, 0, 32 + (#list * 25)) or UDim2.new(0.95, 0, 0, 32)
            end)
        end

        function Elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0.95, 0, 0, 32)
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            btn.Text = text .. " •"
            btn.TextColor3 = Color3.fromRGB(230, 230, 230)
            btn.Font = Enum.Font.Code
            btn.TextSize = 12
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
            btn.Parent = AreaFrame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

            local function update()
                btn.Text = state and text .. " ✓" or text .. " ○"
                btn.TextColor3 = state and mainColor or Color3.fromRGB(150, 150, 150)
            end
            update()
            btn.MouseButton1Click:Connect(function()
                state = not state
                update()
                SaveData[text] = state
                if internalAutoSave then SaveToFile() end
                callback(state)
            end)
        end

        return Elements
    end

    -- Função para mudar a cor dinamicamente
    function Lib:SetColor(newColor)
        mainColor = newColor
        SubtitleLabel.TextColor3 = newColor
        SideAccent.BackgroundColor3 = newColor
        MenuLine.BackgroundColor3 = newColor
        SaveData.MainColorR = newColor.r
        SaveData.MainColorG = newColor.g
        SaveData.MainColorB = newColor.b
        if internalAutoSave then SaveToFile() end
    end

    function Lib:AutoSaveLuay(b) internalAutoSave = b end
    function Lib:Save() SaveToFile() end

    return Lib
end

return luayV2
