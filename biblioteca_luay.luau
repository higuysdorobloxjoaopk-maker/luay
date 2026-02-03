local luayV2 = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- [[ FUNÇÃO DE ARRASTAR UNIVERSAL (MOBILE & PC) ]] --
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
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "luayV2_Original"
    ScreenGui.Parent = (gethui and gethui()) or CoreGui or players.LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    -- Janela Principal (Quadrada / Sem Bordas Arredondadas)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
    MainFrame.Parent = ScreenGui

    -- TopBar (Menu de Título)
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    MakeDraggable(TopBar, MainFrame)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -80, 1, 0); Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Text = config.Name or "LUAY V2"; Title.TextColor3 = Lib.Color
    Title.Font = Enum.Font.Code; Title.TextXAlignment = 0; Title.BackgroundTransparency = 1; Title.Parent = TopBar

    -- Botões de Controle (Fechar e Minimizar)
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 1, 0); CloseBtn.Position = UDim2.new(1, -35, 0, 0)
    CloseBtn.Text = "X"; CloseBtn.TextColor3 = Color3.new(1,1,1); CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.BorderSizePixel = 0; CloseBtn.Parent = TopBar
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MiniBtn = Instance.new("TextButton")
    MiniBtn.Size = UDim2.new(0, 35, 1, 0); MiniBtn.Position = UDim2.new(1, -70, 0, 0)
    MiniBtn.Text = "-"; MiniBtn.TextColor3 = Color3.new(1,1,1); MiniBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MiniBtn.BorderSizePixel = 0; MiniBtn.Parent = TopBar
    
    local minimized = false
    MiniBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MainFrame:TweenSize(minimized and UDim2.new(0, 350, 0, 35) or UDim2.new(0, 350, 0, 450), "Out", "Quart", 0.3, true)
    end)

    -- Sidebar Lateral
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 60, 1, -70); Sidebar.Position = UDim2.new(0, 0, 0, 35)
    Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Sidebar.BorderSizePixel = 0; Sidebar.Parent = MainFrame
    local SideLayout = Instance.new("UIListLayout", Sidebar); SideLayout.Padding = UDim.new(0, 5)

    -- Container de Conteúdo
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -60, 1, -70); Container.Position = UDim2.new(0, 60, 0, 35)
    Container.BackgroundTransparency = 1; Container.Parent = MainFrame

    -- Footer (Barra de Baixo)
    local Footer = Instance.new("Frame")
    Footer.Size = UDim2.new(1, 0, 0, 35); Footer.Position = UDim2.new(0, 0, 1, -35)
    Footer.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Footer.BorderSizePixel = 0; Footer.Parent = MainFrame

    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(1, -10, 1, 0); FooterText.Position = UDim2.new(0, 10, 0, 0)
    FooterText.Text = "luayV2 | PC & Mobile Ready"; FooterText.TextColor3 = Color3.fromRGB(150, 150, 150)
    FooterText.Font = Enum.Font.Code; FooterText.TextSize = 12; FooterText.BackgroundTransparency = 1; FooterText.TextXAlignment = 0; FooterText.Parent = Footer

    -- [[ ÁREAS E ELEMENTOS ]] --
    function Lib:Area(name, icon)
        local AreaFrame = Instance.new("ScrollingFrame")
        AreaFrame.Size = UDim2.new(1, -10, 1, -10); AreaFrame.Position = UDim2.new(0, 5, 0, 5)
        AreaFrame.BackgroundTransparency = 1; AreaFrame.Visible = false; AreaFrame.AutomaticCanvasSize = 2
        AreaFrame.ScrollBarThickness = 2; AreaFrame.Parent = Container
        Instance.new("UIListLayout", AreaFrame).Padding = UDim.new(0, 5)

        local TabBtn = Instance.new("ImageButton")
        TabBtn.Size = UDim2.new(0, 45, 0, 45); TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.Image = "rbxassetid://" .. (icon or "4483345998"); TabBtn.BorderSizePixel = 0; TabBtn.Parent = Sidebar

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            AreaFrame.Visible = true
        end)
        if #Sidebar:GetChildren() <= 2 then AreaFrame.Visible = true end

        local E = {}

        function E:Section(title)
            local sec = Instance.new("Frame", AreaFrame)
            sec.Size = UDim2.new(1, 0, 0, 30); sec.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            sec.BorderSizePixel = 0; sec.ClipsDescendants = true
            
            local h = Instance.new("TextButton", sec)
            h.Size = UDim2.new(1, 0, 0, 30); h.BackgroundTransparency = 1; h.Text = "  " .. title:upper() .. "  >"
            h.TextColor3 = Lib.Color; h.Font = Enum.Font.Code; h.TextXAlignment = 0

            local cF = Instance.new("Frame", sec)
            cF.Size = UDim2.new(1, 0, 0, 0); cF.Position = UDim2.new(0, 0, 0, 30); cF.BackgroundTransparency = 1
            local lay = Instance.new("UIListLayout", cF); lay.Padding = UDim.new(0, 5)

            h.MouseButton1Click:Connect(function()
                local open = sec.Size.Y.Offset < 40
                sec.Size = open and UDim2.new(1, 0, 0, lay.AbsoluteContentSize.Y + 35) or UDim2.new(1, 0, 0, 30)
                h.Text = "  " .. title:upper() .. (open and "  ^" or "  >")
            end)

            local sub = {}
            function sub:Button(t, c)
                local b = Instance.new("TextButton", cF)
                b.Size = UDim2.new(1, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                b.Text = "  " .. t; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.TextXAlignment = 0
                b.MouseButton1Click:Connect(c); return b
            end
            function sub:Toggle(t, c)
                local s = false
                local b = sub:Button(t .. " [OFF]", function() end)
                b.MouseButton1Click:Connect(function()
                    s = not s; b.Text = "  " .. t .. (s and " [ON]" or " [OFF]")
                    b.TextColor3 = s and Lib.Color or Color3.new(1,1,1); c(s)
                end)
            end
            return sub
        end

        function E:Button(t, c)
            local b = Instance.new("TextButton", AreaFrame)
            b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.Text = "  " .. t; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.TextXAlignment = 0
            b.MouseButton1Click:Connect(c); return b
        end

        function E:Toggle(t, c)
            local s = false
            local b = E:Button(t .. " [OFF]", function() end)
            b.MouseButton1Click:Connect(function()
                s = not s; b.Text = "  " .. t .. (s and " [ON]" or " [OFF]")
                b.TextColor3 = s and Lib.Color or Color3.new(1,1,1); c(s)
            end)
        end
        
        function E:Slider(t, min, max, def, c)
            local f = Instance.new("Frame", AreaFrame)
            f.Size = UDim2.new(1,0,0,45); f.BackgroundColor3 = Color3.fromRGB(25,25,25); f.BorderSizePixel = 0
            local l = Instance.new("TextLabel", f)
            l.Size = UDim2.new(1,0,0,20); l.Text = "  "..t.." ["..def.."]"; l.TextColor3 = Color3.new(1,1,1)
            l.Font = Enum.Font.Code; l.BackgroundTransparency = 1; l.TextXAlignment = 0
            local bar = Instance.new("TextButton", f)
            bar.Size = UDim2.new(0.9,0,0,5); bar.Position = UDim2.new(0.05,0,0.7,0); bar.Text = ""; bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((def-min)/(max-min),0,1,0); fill.BackgroundColor3 = Lib.Color; fill.BorderSizePixel = 0
            bar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    local move = UserInputService.InputChanged:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                            fill.Size = UDim2.new(p,0,1,0); local v = math.floor(min + (max-min)*p)
                            l.Text = "  "..t.." ["..v.."]"; c(v)
                        end
                    end)
                    input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then move:Disconnect() end end)
                end
            end)
        end

        function E:Box(p, c)
            local b = Instance.new("TextBox", AreaFrame)
            b.Size = UDim2.new(1, 0, 0, 30); b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            b.PlaceholderText = p; b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.Code; b.BorderSizePixel = 0
            b.FocusLost:Connect(function() c(b.Text) end)
        end

        function E:Logs(h)
            local lF = Instance.new("ScrollingFrame", AreaFrame)
            lF.Size = UDim2.new(1,0,0,h or 100); lF.BackgroundColor3 = Color3.new(0,0,0); lF.BorderSizePixel = 0
            Instance.new("UIListLayout", lF)
            return {Log = function(_, t, col)
                local l = Instance.new("TextLabel", lF)
                l.Size = UDim2.new(1,0,0,20); l.Text = "> "..t; l.TextColor3 = col or Color3.new(1,1,1)
                l.BackgroundTransparency = 1; l.TextXAlignment = 0; l.Font = Enum.Font.Code; l.Parent = lF
            end, Clear = function() lF:ClearAllChildren(); Instance.new("UIListLayout", lF) end}
        end
        
        function E:PlayerSelector(t, c) E:Button(t, function() c(players:GetPlayers()[1]) end) end
        function E:Keybind(t, d, c) E:Button(t.." ["..d.Name.."]", c) end

        return E
    end

    function Lib:Notify(t) print("LUAY_NOTIF: "..t) end
    function Lib:SetColor(c) Lib.Color = c; Title.TextColor3 = c end
    function Lib:AutoSaveLuay() end
    function Lib:GetThemes() return {"Standard"}, {Standard = Color3.fromRGB(0, 170, 255)} end

    return Lib
end

return luayV2
