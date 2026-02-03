--[[
    luayV2 UI LIBRARY - ULTIMATE EDITION
    Foco: Design Original Quadrado, Mobile & PC Friendly
]]

local luayV2 = {}

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local plr = players.LocalPlayer

-- [[ DRAG SYSTEM MOBILE/PC ]] --
local function MakeDraggable(topbarobject, object)
    local dragging, dragInput, dragStart, startPos
    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function luayV2:Window(config)
    local Lib = {Color = config.Color or Color3.fromRGB(0, 170, 255)}
    local currentArea = nil
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Root"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = (gethui and gethui()) or CoreGui

    -- MainFrame Original (Quadrado)
    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)

    -- TopBar Original
    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    MakeDraggable(TopBar, MainFrame)

    local Title = Instance.new("TextLabel", TopBar)
    Title.Size = UDim2.new(1, -90, 1, 0); Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Text = config.Name or "LUAY V2"; Title.TextColor3 = Lib.Color
    Title.Font = Enum.Font.Code; Title.TextSize = 16; Title.TextXAlignment = 0; Title.BackgroundTransparency = 1

    -- Botões de Controle
    local CloseBtn = Instance.new("TextButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 45, 1, 0); CloseBtn.Position = UDim2.new(1, -45, 0, 0)
    CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50); CloseBtn.BorderSizePixel = 0
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MiniBtn = Instance.new("TextButton", TopBar)
    MiniBtn.Size = UDim2.new(0, 45, 1, 0); MiniBtn.Position = UDim2.new(1, -90, 0, 0)
    MiniBtn.Text = "-"; MiniBtn.TextColor3 = Color3.new(1,1,1); MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); MiniBtn.BorderSizePixel = 0
    
    local isMini = false
    MiniBtn.MouseButton1Click:Connect(function()
        isMini = not isMini
        MainFrame:TweenSize(isMini and UDim2.new(0, 350, 0, 45) or UDim2.new(0, 350, 0, 450), "Out", "Quart", 0.3, true)
    end)

    -- Sidebar & Container
    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size = UDim2.new(0, 60, 1, -80); Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0
    Instance.new("UIListLayout", Sidebar).HorizontalAlignment = 1

    local Container = Instance.new("Frame", MainFrame)
    Container.Size = UDim2.new(1, -60, 1, -80); Container.Position = UDim2.new(0, 60, 0, 45)
    Container.BackgroundTransparency = 1

    -- Footer
    local Footer = Instance.new("Frame", MainFrame)
    Footer.Size = UDim2.new(1, 0, 0, 35); Footer.Position = UDim2.new(0, 0, 1, -35)
    Footer.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Footer.BorderSizePixel = 0
    local FText = Instance.new("TextLabel", Footer)
    FText.Size = UDim2.new(1,-15,1,0); FText.Position = UDim2.new(0,15,0,0); FText.Text = "luayV2 - Premium Edition"; FText.TextColor3 = Color3.fromRGB(120,120,120); FText.Font = 3; FText.BackgroundTransparency = 1; FText.TextXAlignment = 0

    function Lib:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame", Container)
        AreaFrame.Size = UDim2.new(1, -10, 1, -10); AreaFrame.Position = UDim2.new(0, 5, 0, 5)
        AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.ScrollBarThickness = 2
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("ImageButton", Sidebar)
        TabBtn.Size = UDim2.new(0, 60, 0, 50); TabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25); TabBtn.BorderSizePixel = 0
        TabBtn.Image = "rbxassetid://" .. (icon or "4483345998")

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaFrame.Visible = true
        end)
        if not currentArea then AreaFrame.Visible = true; currentArea = true end

        local E = {}

        -- SECTION
        function E:Section(title)
            local sec = Instance.new("Frame", AreaFrame)
            sec.Size = UDim2.new(1, 0, 0, 35); sec.BackgroundColor3 = Color3.fromRGB(30, 30, 30); sec.BorderSizePixel = 0; sec.ClipsDescendants = true
            local h = Instance.new("TextButton", sec)
            h.Size = UDim2.new(1, 0, 0, 35); h.BackgroundTransparency = 1; h.Text = "  " .. title:upper() .. "  >"; h.TextColor3 = Lib.Color; h.Font = 3; h.TextXAlignment = 0
            local cF = Instance.new("Frame", sec)
            cF.Size = UDim2.new(1, 0, 0, 0); cF.Position = UDim2.new(0, 0, 0, 35); cF.BackgroundTransparency = 1
            local lay = Instance.new("UIListLayout", cF); lay.Padding = UDim.new(0, 5)

            h.MouseButton1Click:Connect(function()
                local open = sec.Size.Y.Offset < 40
                sec.Size = open and UDim2.new(1, 0, 0, lay.AbsoluteContentSize.Y + 40) or UDim2.new(1, 0, 0, 35)
                h.Text = "  " .. title:upper() .. (open and "  ^" or "  >")
            end)

            local sub = {}
            function sub:Button(t, c)
                local b = Instance.new("TextButton", cF)
                b.Size = UDim2.new(1, 0, 0, 32); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40); b.BorderSizePixel = 0
                b.Text = "  " .. t; b.TextColor3 = Color3.new(1,1,1); b.Font = 3; b.TextXAlignment = 0; b.MouseButton1Click:Connect(c); return b
            end
            return sub
        end

        -- BUTTON
        function E:Button(t, c)
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.BorderSizePixel = 0
            b.Text = "  " .. t; b.TextColor3 = Color3.new(1,1,1); b.Font = 3; b.TextXAlignment = 0; b.MouseButton1Click:Connect(c)
        end

        -- TOGGLE
        function E:Toggle(t, c)
            local s = false
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25); b.BorderSizePixel = 0
            b.Text = "  " .. t .. " [OFF]"; b.TextColor3 = Color3.new(1,1,1); b.Font = 3; b.TextXAlignment = 0
            b.MouseButton1Click:Connect(function()
                s = not s; b.Text = "  " .. t .. (s and " [ON]" or " [OFF]"); b.TextColor3 = s and Lib.Color or Color3.new(1,1,1); c(s)
            end)
        end

        -- SLIDER MOBILE FRIENDLY
        function E:Slider(t, min, max, def, c)
            local f = Instance.new("Frame", AreaFrame)
            f.Size = UDim2.new(1,0,0,50); f.BackgroundColor3 = Color3.fromRGB(25,25,25); f.BorderSizePixel = 0
            local l = Instance.new("TextLabel", f)
            l.Size = UDim2.new(1,0,0,25); l.Text = "  "..t.." ["..def.."]"; l.TextColor3 = Color3.new(1,1,1); l.BackgroundTransparency = 1; l.TextXAlignment = 0; l.Font = 3
            local bar = Instance.new("TextButton", f)
            bar.Size = UDim2.new(0.9,0,0,6); bar.Position = UDim2.new(0.05,0,0.7,0); bar.Text = ""; bar.BackgroundColor3 = Color3.fromRGB(45,45,45); bar.BorderSizePixel = 0
            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Lib.Color; fill.BorderSizePixel = 0
            
            local function update(input)
                local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(pos,0,1,0)
                local val = math.floor(min + (max-min)*pos)
                l.Text = "  "..t.." ["..val.."]"; c(val)
            end

            local dragging = false
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true update(i) end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        end

        return E
    end
    
    function Lib:Notify(t, dur) print("LUAY: "..t) end -- Notificação simples interna
    return Lib
end

return luayV2
