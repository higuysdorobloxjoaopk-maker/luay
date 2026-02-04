# 📘 LuayV2 - Manual do Desenvolvedor
A LuayV2 é uma biblioteca de interface gráfica (UI) de alto desempenho, focada em design minimalista ("Dark Mode"), interatividade mobile-friendly e ferramentas de automação.
### 🏗️ 1. Preparação e Carregamento
Para utilizar a biblioteca, você deve realizar a chamada via loadstring. Ela retorna uma tabela de funções que chamaremos de luayV2.
```luau
local luayV2 = loadstring(game:HttpGet("https://raw.githubusercontent.com/higuysdorobloxjoaopk-maker/luay/refs/heads/main/Biblioteca_v2.luay.luau"))()
```

### 🖼️ 2. A Janela Principal (Window)
A Janela é o "contêiner" pai. Sem ela, você não pode criar abas ou elementos.
Como criar:
```luau
local Window = luayV2:Window({
    Name = "Nome do Seu Script",
    Color = Color3.fromRGB(0, 255, 150) -- Cor do tema (Neon)
})
```
 * Name: O título que aparece no topo.
 * Color: Define a cor das bordas (L-Invertido), sliders e toggles ativos.
 * O que faz: Cria a estrutura com botões de fechar, minimizar e a barra lateral de ícones.
### 📂 3. Organização por Áreas (Area)
As áreas são as "Abas" laterais. Elas organizam as funções por categorias.
Como criar:
```luau
local MinhaAba = Window:Area("Combate", "combat")
```
 * Nome: O texto que aparecerá ao passar o mouse ou clicar.
 * Icon: Use o ID da imagem ou uma palavra-chave do mapa interno:
   * house, settings, user, combat, folder, eye, shield, mouse, key.
### 🕹️ 4. Elementos de Interface (Widgets)
Dentro de cada Area, você pode adicionar os seguintes componentes:
4.1 Botão (Button)
Executa uma função ao ser clicado. Possui efeito de ondulação (Ripple).
```luau
MinhaAba:Button("Executar Print", function()
    print("Botão clicado!")
end)
```
4.2 Alternador (Toggle)
Um interruptor estilo iOS para ligar/desligar funções.
```luau
MinhaAba:Toggle("Auto Farm", false, function(estado)
    print("Status do Farm:", estado)
end)
```
4.3 Controle Deslizante (Slider)
Ideal para valores numéricos como Velocidade, FOV ou Distância.
```luau
MinhaAba:Slider({
    Name = "Velocidade",
    Min = 16,
    Max = 100,
    Placeholder = 16, -- Valor inicial
    Callback = function(valor)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = valor
    end
})
```
4.4 Entrada de Texto (Input)
Captura o que o usuário digita.
```luau
MinhaAba:Input("Nome do Jogador", "Digite aqui...", function(texto)
    print("O usuário digitou: " .. texto)
end)
```
4.5 Rótulo Atualizável (Label)
Exibe informações de texto que podem mudar em tempo real.
```luau
local StatusLabel = MinhaAba:Label("Iniciando...")
StatusLabel:Update("Sistema Pronto!") -- Altera o texto
StatusLabel:SetColor(Color3.new(1,0,0)) -- Altera a cor
```
### 🚀 5. Recursos Exclusivos e Independentes
5.1 Botões Livres (CreateFreeButton)
Cria botões circulares fora da janela principal. Perfeito para controles de jogo.
```luau
local MeuBotao = luayV2:CreateFreeButton({
    Name = "BtnSubir",
    Text = "▲",
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Draggable = true, -- Permite arrastar pela tela
    OnHold = function() 
        -- Executa repetidamente enquanto estiver pressionado
    end,
    Callback = function(pressionado)
        -- Executa uma vez ao clicar (true) ou soltar (false)
    end
})
```
 * Fixação: Você pode travar o botão para que ele não seja mais arrastado usando MeuBotao:SetLocked(true).
5.2 Notificações (Notify)
Exibe um aviso elegante no canto da tela.
```luau
luayV2:Notify({
    Title = "Aviso!",
    Text = "O script foi carregado com sucesso.",
    Color = Color3.fromRGB(0, 255, 150),
    Duration = 5
})
```
### 🛠️ 6. Ordem de Criação (Best Practices)
Para evitar erros de carregamento, siga sempre esta sequência:
 * Carregar a Biblioteca: loadstring...
 * Configurar Variáveis Locais: (Serviços do Roblox).
 * Criar a Janela: luayV2:Window.
 * Criar as Áreas (Abas): Organize-as primeiro.
 * Adicionar Elementos: Coloque os botões e toggles dentro das abas.
 * Adicionar Lógica de Loop: Use RunService para checar funções ativas.
### 💡 7. Dicas Técnicas
 * Persistência: A LuayV2 salva automaticamente o estado dos seus Toggles em um arquivo JSON na pasta do executor (ex: NomeDoScript_Config.json).
 * Mobile: Os Sliders e Botões Livres possuem hitboxes otimizadas para dedos maiores, garantindo que o usuário não erre o clique.
 * Transparência: Os Botões Livres possuem BackgroundTransparency = 0.65, permitindo ver o jogo através deles enquanto mantém o estilo.
