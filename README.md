# 📦 Luay V2 — Biblioteca de Interface (UI) para Roblox

> Luay V2 – The Leviathan Core
Biblioteca completa de UI em Lua/Luau para Roblox, focada em scripts avançados, mobile, exploit-friendly e facilidade extrema de uso.




---

### 📌 Índice

1. Introdução geral


2. Filosofia da biblioteca


3. Como carregar a biblioteca


4. Criando uma Janela


5. Sistema de Áreas (Tabs)


6. Elementos da Biblioteca

Label

Button

Toggle

Input

Slider

Logs



7. Sistema de Notificações


8. Free Button (Botão Flutuante)


9. Sistema de Valores (GetValue)


10. Salvamento automático (Config JSON)


11. Boas práticas


12. Exemplo grande completo




---

### 1️⃣ Introdução geral

A Luay V2 foi criada para resolver um problema muito comum em scripts Roblox: UI feia, confusa, pesada e difícil de manter.

Ela entrega:

Interface limpa e moderna

Uso simples mesmo para iniciantes

Código organizado

Compatibilidade total com mobile

Recursos avançados sem complicação


A biblioteca abstrai toda a parte chata da UI (instâncias, tamanhos, animações, drag, eventos) e deixa você focar apenas na lógica do seu script.


---

### 2️⃣ Filosofia da biblioteca

A Luay V2 segue alguns princípios claros:

1. Tudo deve ser simples de usar


2. Nenhuma função deve exigir conhecimento avançado de UI


3. Mobile vem em primeiro lugar


4. O script não deve quebrar se algo fechar


5. Tudo que puder ser automático, será automático



Por isso ela já vem com:

Salvamento automático

Destruição segura

Valores globais

Botões flutuantes vinculados à janela



---

### 3️⃣ Como carregar a biblioteca

Este é SEMPRE o primeiro passo. Sem isso nada funciona.
```luau
local luayV2 = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/higuysdorobloxjoaopk-maker/luay/refs/heads/main/Biblioteca_v2.luay.luau"
))()
```

- 📌 Após isso, a variável luayV2 contém todas as funções da biblioteca.


---

### 4️⃣ Criando uma Janela

A janela é o núcleo de tudo. Sem janela não existe UI.
```luau
local Window = luayV2:Window({
    Name = "Meu Script",
    Color = Color3.fromRGB(0,255,150)
})
```
O que essa função faz:

Cria um ScreenGui

Cria TopBar

Cria Sidebar

Cria Container de áreas

Ativa drag automático

Configura tema

Prepara salvamento JSON


Parâmetros:

Name → Nome exibido no topo da UI

Color → Cor principal usada em toda a interface


Cada janela é independente.


---

### 5️⃣ Sistema de Áreas (Tabs)

As Áreas são as abas laterais.
```luau
local Main = Window:Area("Principal", "house")
```
O que uma Área faz:

Cria uma aba lateral

Cria um container próprio

Organiza elementos automaticamente

Controla visibilidade


Ícones disponíveis:

house

settings

user

combat

folder

eye

shield

mouse

key


Cada Área funciona de forma independente.


---

### 6️⃣ Elementos da Biblioteca

- 🏷️ Label

Labels servem para mostrar informação, status ou mensagens dinâmicas.
```luau
local lbl = Main:Label("Status: aguardando")
```
Funções disponíveis:
```luau
lbl:Update("Status: ativo")
lbl:SetColor(Color3.fromRGB(0,255,150))
```
- 📌 Labels são leves e não possuem interação.


---

### 🔘 Button

Botões executam uma ação quando clicados.
```luau
Main:Button("Executar", function()
    print("Botão clicado")
end)
```
O que acontece internamente:

Cria botão estilizado

Aplica ripple effect

Conecta MouseButton1Click


Ideal para:

Funções únicas

Execuções manuais

Debug



---

### 🔄 Toggle

Toggle é um botão liga/desliga com salvamento automático.
```luau
Main:Toggle("GodMode", false, function(state)
    if state then
        print("Ativado")
    else
        print("Desativado")
    end
end)
```
Características importantes:

Estado salvo automaticamente

Callback executado ao mudar

Desliga tudo ao fechar a janela


Excelente para:

ESP

Fly

Speed

Hacks contínuos



---

### ⌨️ Input
```luau
Input permite entrada de texto do usuário.

Main:Input("Nome", "Digite aqui", function(text)
    print("Texto digitado:", text)
end)
```
Comportamento:

Callback só dispara ao pressionar Enter

Ideal para nomes, valores e comandos



---

### 🎚️ Slider

Slider controla valores numéricos.
```luau
Main:Slider({
    Name = "Velocidade",
    Min = 0,
    Max = 500,
    Placeholder = 100,
    Callback = function(value)
        print(value)
    end
})
```
Detalhes importantes:

Mobile friendly

Hitbox grande

Valor salvo em tempo real

Integra com GetValue



---

### 📜 Logs

Logs criam um console interno.
```luau
local Logs = Main:Logs(120)
```
```luau
Logs:Log("Script iniciado")
```
```luau
Logs:Log("Sucesso", Color3.fromRGB(0,255,150))
```
```luau
Logs:Clear()
```
Ideal para:

Debug

Status

Feedback visual



---

### 7️⃣🔔 Sistema de Notificações

Notificações aparecem no canto da tela.
```luau
luayV2:Notify({
    Title = "Aviso",
    Text = "Algo aconteceu",
    Color = Color3.fromRGB(0,255,150),
    Duration = 4
})
```
Elas:

Empilham automaticamente

Desaparecem sozinhas

Não interferem na UI



---

### 8️⃣ 🟢 Free Button (Botão Flutuante)

O FreeButton é um botão independente da UI, ideal para mobile.

- ⚠️ Ele pertence à Janela, não à biblioteca direta.
```luau
local FreeBtn = Window:CreateFreeButton({
    Name = "Skill",
    Text = "⚡",
    Draggable = true,
    Callback = function(pressed)
        print(pressed)
    end,
    OnHold = function()
        print("Segurando")
    end
})

Funções extras:

FreeBtn:SetLocked(true)
FreeBtn:Visible(false)
FreeBtn:Destroy()
```

---

### 9️⃣ 🔍 Sistema de Valores (GetValue)

Permite acessar valores de Sliders.
```luau
local v = luayV2:GetValue("Velocidade")
print(v)
```
Muito usado em loops:
```luau
task.spawn(function()
    while task.wait(1) do
        print(luayV2:GetValue("Velocidade"))
    end
end)
```

---

### 🔟 Salvamento Automático

A biblioteca salva automaticamente:

Toggles

Estados


Arquivo gerado:

NomeDaJanela_Config.json

Nenhuma configuração extra é necessária.


---

### 1️⃣1️⃣ Boas Práticas

Use nomes únicos

Não recrie janelas

Use Toggle para loops

Sempre finalize scripts corretamente



---

### 1️⃣2️⃣ Exemplo Grande Completo
```luau

local luayV2 = loadstring(game:HttpGet("URL"))()
local Window = luayV2:Window({Name="Demo",Color=Color3.fromRGB(0,255,150)})

local Main = Window:Area("Main","house")
Main:Toggle("Ativar",false,function(v) print(v) end)
Main:Slider({Name="Speed",Min=0,Max=100,Placeholder=50})

Window:CreateFreeButton({
    Text="⚡",
    Callback=function(p) print(p) end
})
```

---

### 🧠 Conclusão

A Luay V2 é uma **biblioteca** feita para quem quer resultado rápido, UI bonita e zero dor de cabeça.

Se você sabe Lua básico, você domina a Luay V2.


---

Developed by JOAOPK
