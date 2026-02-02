# 🌌 luayV2
A luayV2 é uma biblioteca de interface (UI) para Roblox, focada em um estilo minimalista, técnico e de fácil implementação.

# 🚀 Como carregar:

`Lua
local luayV2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/higuysdorobloxjoaopk-maker/luay/refs/heads/main/biblioteca_luay.luau"))()`
# 🛠 Funções principais
`Window({Name, Color, Footer}): Cria a janela principal.`

`Button(text, callback): Botão simples estilo [ Nome • ].`

`Toggle(text, callback): Interruptor estilo [ Nome [✓] ].`

`Box(placeholder, callback): Caixa de entrada de texto.`

`Slider(text, min, max, default, callback): Barra de progresso com porcentagem dinâmica.`

`Dropdown(text, list, callback): Lista expansível com animação`

# 📜Exemplo:
```luau
local luayV2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/higuysdorobloxjoaopk-maker/luay/refs/heads/main/biblioteca_luay.luau"))()

-- Criando a Janela
local win = luayV2:Window({
    Name = "Luay Hub V2",
    Color = Color3.fromRGB(0, 255, 150), -- Neon Esmeralda
    Footer = "t.me/luaycommunity | v2.0"
})

-- Botão Normal
win:Button("Kill All Players", function()
    print("Comando de Kill executado.")
end)

-- Toggle (Marcar/Desmarcar)
win:Toggle("God Mode", function(state)
    print("God Mode está:", state)
end)

-- Caixa de Texto
win:Box("Set Speed", function(text)
    local speed = tonumber(text)
    if speed then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
        print("Velocidade alterada para:", speed)
    end
end)

-- Slider (Ajuste de Valor)
win:Slider("Jump Power", 50, 500, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

-- Dropdown (Lista)
win:Dropdown("Teleport Map", {"Lobby", "Arena 1", "Arena 2", "Vip Zone"}, function(selected)
    print("Teleportando para:", selected)
end)

-- Outro botão para fechar UI manualmente se quiser
win:Button("Unload Script", function()
    print("Script descarregado.")
end)
```
