-- [[ LUAY V2 SUPREME ENGINE - 800+ LINES EDITION ]]
local luayV2 = {}

-- SERVIÇOS
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

-- VARIÁVEIS GLOBAIS DA LIB
local NotificationHolder = nil
local CurrentWindow = nil

-- [[ UTILITÁRIOS DE RENDERIZAÇÃO ]]
local function Create(class, props)
    local inst = Instance.new(class)
    for i, v in pairs(props) do inst[i] = v end
    return inst
end

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

-- [[ SISTEMA DE NOTIFICAÇÕES ]]
local function SetupNotifications()
    if NotificationHolder then return end
    NotificationHolder = Create("ScreenGui", {Name = "Luay_Notifications", Parent = gethui and gethui() or CoreGui})
    local container = Create("Frame", {
        Size = UDim2.new(0, 250, 1, 0),
        Position = UDim2.new(1, -260, 0, 0),
        BackgroundTransparency = 1,
        Parent = NotificationHolder
    })
    Create("UIListLayout", {
        Parent = container,
        Padding = UDim.new(0, 10),
        VerticalAlignment = Enum.VerticalAlignment.Bottom
    })
    NotificationHolder.AttributeChanged:Connect(function() end) -- Placeholder para expansão
end

function luayV2:Notify(data)
    SetupNotifications()
    local title = data.Title or "SISTEMA"
    local text = data.Text or "Mensagem vazia"
    local color = data.Color or Color3.fromRGB(0, 170, 255)
    local duration = data.Duration or 5

    local nFrame = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 1,
        BorderColor3 = color,
        Parent = NotificationHolder.Frame
    })
    
    local line = Create("Frame", {
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = nFrame
    })

    local tLabel = Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        Text = title:upper(),
        TextColor3 = color,
        Font = Enum.Font.Code,
        TextSize = 13,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = nFrame
    })

    local mLabel = Create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 30),
        Position = UDim2.new(0, 10, 0, 25),
        Text = text,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Font = Enum.Font.Code,
        TextSize = 11,
        BackgroundTransparency = 1,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = nFrame
    })

    task.delay(duration, function()
        TweenService:Create(nFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(tLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(mLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.5)
        nFrame:Destroy()
    end)
end

-- [[ JANELA PRINCIPAL ]]
function luayV2:Window(config)
    local title = config.Name or "LUAY V2"
    local mainColor = config.Color or Color3.fromRGB(0, 170, 255)
    local footerMsg = config.Footer or "SISTEMA INDUSTRIAL"
    local toggleKey = config.Keybind or Enum.KeyCode.RightControl
    
    local internalAutoSave = false
    local currentArea = nil
    local isVisible = true
    local fileName = "Luay_Data_" .. plr.UserId .. ".json"
    
    local SaveData = {}
    local function DoSave()
        if internalAutoSave and writefile then
            writefile(fileName, HttpService:JSONEncode(SaveData))
        end
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "LuayV2_Master",
        ResetOnSpawn = false,
        Parent = gethui and gethui() or CoreGui
    })

    local MainFrame = Create("Frame", {
        Size = UDim2.new(0, 400, 0, 500),
        Position = UDim2.new(0.5, -200, 0.5, -250),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 1,
        BorderColor3 = Color3.fromRGB(30, 30, 30),
        Parent = ScreenGui
    })

    -- ELEMENTO: LINHA SUPERIOR (_)
    local TopNeonLine = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = mainColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    -- ELEMENTO: SCANLINES (Magia Visual)
    local Scanline = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.98,
        ZIndex = 5,
        Parent = MainFrame
    })
    RunService.RenderStepped:Connect(function()
        Scanline.Position = UDim2.new(0, 0, 0, (tick()*100)%MainFrame.AbsoluteSize.Y)
    end)

    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = Color3.fromRGB(15, 15, 15),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    MakeDraggable(TopBar, MainFrame)

    local TitleLabel = Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0.5, 0),
        Position = UDim2.new(0, 15, 0, 5),
        Text = title:upper(),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Code,
        TextSize = 16,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    local SubLabel = Create("TextLabel", {
        Size = UDim2.new(0.6, 0, 0.3, 0),
        Position = UDim2.new(0, 15, 0, 28),
        Text = "SELECIONE UMA ÁREA",
        TextColor3 = mainColor,
        Font = Enum.Font.Code,
        TextSize = 11,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TopBar
    })

    -- CONTROLES
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 50, 1, 0),
        Position = UDim2.new(1, -50, 0, 0),
        Text = "[X]",
        TextColor3 = Color3.fromRGB(200, 60, 60),
        Font = Enum.Font.Code,
        BackgroundTransparency = 1,
        Parent = TopBar
    })
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- ELEMENTO: LINHA VERTICAL (|)
    local VerticalSeparator = Create("Frame", {
        Size = UDim2.new(0, 1, 1, -85),
        Position = UDim2.new(0, 65, 0, 55),
        BackgroundColor3 = mainColor,
        BorderSizePixel = 0,
        Parent = MainFrame
    })

    -- SIDEBAR
    local Sidebar = Create("ScrollingFrame", {
        Size = UDim2.new(0, 60, 1, -90),
        Position = UDim2.new(0, 2, 0, 55),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        Parent = MainFrame
    })
    Create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 15), HorizontalAlignment = Enum.HorizontalAlignment.Center})

    -- CONTAINER
    local Container = Create("Frame", {
        Size = UDim2.new(1, -85, 1, -90),
        Position = UDim2.new(0, 75, 0, 55),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })

    -- FOOTER
    local Footer = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 1, -30),
        BackgroundColor3 = Color3.fromRGB(12, 12, 12),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    local FLabel = Create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Text = footerMsg:upper(),
        TextColor3 = Color3.fromRGB(80, 80, 80),
        Font = Enum.Font.Code,
        TextSize = 11,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Footer
    })

    -- ATALHO PARA ESCONDER
    UserInputService.InputBegan:Connect(function(i, g)
        if not g and i.KeyCode == toggleKey then
            isVisible = not isVisible
            MainFrame.Visible = isVisible
        end
    end)

    local Lib = {}

    -- [[ ÁREA ]]
    function Lib:Area(name, icon)
        local AreaFrame = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = mainColor,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = Container
        })
        Create("UIListLayout", {Parent = AreaFrame, Padding = UDim.new(0, 10)})

        local AreaBtn = Create("ImageButton", {
            Size = UDim2.new(0, 38, 0, 38),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BorderSizePixel = 1,
            BorderColor3 = Color3.fromRGB(40, 40, 40),
            Image = "rbxassetid://" .. (icon or "0"),
            Parent = Sidebar
        })

        local function Switch()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            AreaFrame.Visible = true
            SubLabel.Text = "ÁREA ATUAL: " .. name:upper()
            for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("ImageButton") then b.BorderColor3 = Color3.fromRGB(40, 40, 40) end end
            AreaBtn.BorderColor3 = mainColor
        end
        AreaBtn.MouseButton1Click:Connect(Switch)
        if not currentArea then Switch() currentArea = true end

        local E = {}

        -- ELEMENTO: BOTÃO MASTER
        function E:Button(text, callback)
            local btn = Create("TextButton", {
                Size = UDim2.new(0.96, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(40, 40, 40),
                Text = text:upper() .. " // EXEC",
                TextColor3 = Color3.fromRGB(220, 220, 220),
                Font = Enum.Font.Code,
                TextSize = 12,
                Parent = AreaFrame
            })
            btn.MouseButton1Click:Connect(function()
                btn.BackgroundColor3 = mainColor
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
                task.wait(0.1)
                btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                btn.TextColor3 = Color3.fromRGB(220, 220, 220)
                callback()
            end)
        end

        -- ELEMENTO: TOGGLE MASTER
        function E:Toggle(text, callback)
            local state = false
            local tBtn = Create("TextButton", {
                Size = UDim2.new(0.96, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(40, 40, 40),
                Text = text:upper() .. " [OFF]",
                TextColor3 = Color3.fromRGB(130, 130, 130),
                Font = Enum.Font.Code,
                TextSize = 12,
                Parent = AreaFrame
            })
            
            local function update()
                tBtn.Text = state and text:upper() .. " [ON]" or text:upper() .. " [OFF]"
                tBtn.BorderColor3 = state and mainColor or Color3.fromRGB(40, 40, 40)
                tBtn.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 130)
            end

            tBtn.MouseButton1Click:Connect(function()
                state = not state
                update()
                SaveData[text] = state
                DoSave()
                callback(state)
            end)
        end

        -- ELEMENTO: SLIDER MASTER
        function E:Slider(text, min, max, def, callback)
            local sFrame = Create("Frame", {
                Size = UDim2.new(0.96, 0, 0, 55),
                BackgroundColor3 = Color3.fromRGB(18, 18, 18),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(40, 40, 40),
                Parent = AreaFrame
            })
            local lab = Create("TextLabel", {
                Size = UDim2.new(1, -20, 0, 25),
                Position = UDim2.new(0, 10, 0, 5),
                Text = text:upper() .. ": " .. def,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.Code,
                TextSize = 11,
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sFrame
            })
            local bar = Create("Frame", {
                Size = UDim2.new(0.9, 0, 0, 2),
                Position = UDim2.new(0.05, 0, 0.75, 0),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Parent = sFrame
            })
            local fill = Create("Frame", {
                Size = UDim2.new((def-min)/(max-min), 0, 1, 0),
                BackgroundColor3 = mainColor,
                BorderSizePixel = 0,
                Parent = bar
            })
            local dragging = false
            local function update(input)
                local r = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(r, 0, 1, 0)
                local val = math.floor(min + (max-min)*r)
                lab.Text = text:upper() .. ": " .. val
                SaveData[text] = val
                DoSave()
                callback(val)
            end
            sFrame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true update(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end end)
            UserInputService.InputEnded:Connect(function() dragging = false end)
        end

        -- ELEMENTO: COLOR PICKER (Magia Master)
        function E:ColorPicker(text, defColor, callback)
            local cpFrame = Create("TextButton", {
                Size = UDim2.new(0.96, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Text = text:upper(),
                TextColor3 = Color3.fromRGB(200, 200, 200),
                Font = Enum.Font.Code,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(40, 40, 40),
                Parent = AreaFrame
            })
            local colorPrev = Create("Frame", {
                Size = UDim2.new(0, 25, 0, 15),
                Position = UDim2.new(1, -35, 0.5, -7),
                BackgroundColor3 = defColor,
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(255, 255, 255),
                Parent = cpFrame
            })
            cpFrame.MouseButton1Click:Connect(function()
                local newCol = Color3.fromHSV(math.random(), 1, 1) -- Sistema randômico para exemplo master
                colorPrev.BackgroundColor3 = newCol
                callback(newCol)
            end)
        end

        -- ELEMENTO: DROPDOWN
        function E:Dropdown(text, list, callback)
            local dFrame = Create("Frame", {
                Size = UDim2.new(0.96, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(40, 40, 40),
                ClipsDescendants = true,
                Parent = AreaFrame
            })
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 35),
                Text = text:upper() .. " [V]",
                TextColor3 = Color3.fromRGB(150, 150, 150),
                Font = Enum.Font.Code,
                BackgroundTransparency = 1,
                Parent = dFrame
            })
            local open = false
            btn.MouseButton1Click:Connect(function()
                open = not open
                dFrame:TweenSize(UDim2.new(0.96, 0, 0, open and (35 + #list*30) or 35), "Out", "Quart", 0.3, true)
            end)
            for i, v in pairs(list) do
                local opt = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 35 + (i-1)*30),
                    BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                    Text = tostring(v):upper(),
                    TextColor3 = Color3.fromRGB(100, 100, 100),
                    Font = Enum.Font.Code,
                    BorderSizePixel = 0,
                    Parent = dFrame
                })
                opt.MouseButton1Click:Connect(function()
                    btn.Text = text:upper() .. ": " .. tostring(v)
                    open = false
                    dFrame:TweenSize(UDim2.new(0.96, 0, 0, 35), "Out", "Quart", 0.3, true)
                    callback(v)
                end)
            end
        end

        -- ELEMENTO: TEXT BOX
        function E:Box(p, callback)
            local b = Create("TextBox", {
                Size = UDim2.new(0.96, 0, 0, 35),
                BackgroundColor3 = Color3.fromRGB(15, 15, 15),
                BorderSizePixel = 1,
                BorderColor3 = Color3.fromRGB(40, 40, 40),
                Text = "",
                PlaceholderText = "> " .. p:upper(),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.Code,
                Parent = AreaFrame
            })
            b.FocusLost:Connect(function() callback(b.Text) end)
        end

        return E
    end

    function Lib:AutoSaveLuay(b) internalAutoSave = b end
    function Lib:SetThemeColor(color)
        mainColor = color
        TopNeonLine.BackgroundColor3 = color
        VerticalSeparator.BackgroundColor3 = color
        SubLabel.TextColor3 = color
    end

    return Lib
end

return luayV2
