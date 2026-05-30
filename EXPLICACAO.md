# Q-Bar Challenge — Explicação Completa do Projeto

## O que é este projeto?

Este projeto implementa um **agente autônomo de Inteligência Artificial** que aprende a jogar um jogo simples: mover uma barrinha para defender uma bola que cai. O agente não é programado com regras fixas — ele **aprende sozinho** por tentativa e erro, recebendo recompensas quando acerta e punições quando erra.

A técnica utilizada se chama **Linear Q-Learning**, um algoritmo clássico de Aprendizado por Reforço (Reinforcement Learning). O projeto é escrito em **Haskell**, uma linguagem de programação puramente funcional.

---

## O Jogo

Imagine um campo de `10 x 10`. Uma bola cai do alto e uma barrinha no fundo precisa se mover para defendê-la.

```
y=10  +----------+   ← parede superior (bola rebate aqui)
      |          |
      |   🔵     |   ← bola caindo
      |          |
      |          |
y=0   |   ═══    |   ← barrinha (controlada pelo agente)
      +----------+
      x=0      x=10
```

A cada passo, o agente escolhe uma de três ações:
- **Esquerda** — move a barrinha 0.5 para a esquerda
- **Parado** — não se move
- **Direita** — move a barrinha 0.5 para a direita

---

## Estrutura dos Arquivos

```
qbarchallenge/
├── Types.hs      → Define os tipos de dados do jogo
├── Physics.hs    → Simula a física (movimento, colisões, recompensas)
├── Brain.hs      → Inteligência do agente (Q-Learning)
├── Game.hs       → Executa um passo completo (ação + física + treino)
├── Visual.hs     → Interface gráfica com a biblioteca Gloss
├── Terminal.hs   → Saída em texto no terminal (modo clássico)
└── Main.hs       → Ponto de entrada: escolhe o modo de execução
```

---

## Arquivo por Arquivo

---

### 1. Types.hs — Os Tipos de Dados

Este arquivo define as "peças" do jogo. É a fundação de tudo.

```
Campo → estado físico do jogo
  ├── bolaPos  → posição da bola: (x, y)
  ├── bolaVel  → velocidade da bola: (vx, vy)
  ├── barraX   → posição horizontal da barrinha
  └── gols     → quantos gols foram sofridos

CraqueState → o "cérebro" do agente
  ├── pesos    → vetor θ com 5 números (o que o agente aprendeu)
  ├── epsilon  → chance de explorar aleatoriamente (ex: 0.1 = 10%)
  ├── alpha    → velocidade de aprendizado (ex: 0.01)
  ├── gamma    → quanto valoriza recompensas futuras (ex: 0.95)
  └── gen      → gerador de números aleatórios

Mundo → junta Campo + CraqueState em um estado global

Jogada → as 3 ações possíveis: Esquerda | Parado | Direita
```

A mônada `StateT Mundo IO` (apelidada de `Jogo`) é a estrutura que permite ao agente ler e modificar o estado do mundo a cada passo, sem usar variáveis globais — característica fundamental do Haskell.

---

### 2. Physics.hs — O Motor Físico

Este arquivo é o "juiz" do jogo: move a bola, verifica colisões e decide as recompensas.

**`proximoEstado`** — avança o jogo um passo:

```
1. Move a bola: nova posição = posição atual + velocidade
2. Move a barrinha conforme a ação escolhida
3. Verifica colisão com paredes laterais (x=0 e x=10) → inverte vx
4. Verifica colisão com parede superior (y=10) → inverte vy
5. Verifica interação com a barrinha (y≤0):
   ├── Barrinha próxima → DEFESA: rebate bola pra cima, recompensa +10
   └── Barrinha longe  → GOL: reseta bola ao centro, recompensa -100
6. Passo normal (bola no ar) → recompensa -1
```

**Sistema de recompensas:**

| Evento | Recompensa | Por quê |
|--------|-----------|---------|
| Passo normal | -1 | Penalidade por tempo — incentiva agir rápido |
| Defesa bem-sucedida | +10 | Recompensa por defender a bola |
| Gol sofrido | -100 | Punição severa por deixar a bola passar |

---

### 3. Brain.hs — A Inteligência do Agente

Este é o coração do projeto. Implementa o algoritmo de Q-Learning Linear.

#### O que é Q-Learning?

Q-Learning é uma técnica onde o agente aprende a estimar o "valor" de cada ação em cada situação. Esse valor é chamado de **Q(estado, ação)** e representa: *"se eu estou nesta situação e faço esta ação, quanta recompensa vou acumular no futuro?"*

#### Como funciona aqui?

Em vez de uma tabela (impossível para posições contínuas como x=5.37), usamos uma **combinação linear**:

```
Q(s, a) = φ(s,a) · θ
```

Onde:
- **φ(s,a)** é o vetor de features — um resumo numérico do estado e da ação
- **θ** é o vetor de pesos — o que o agente aprendeu

**`extrairFeatures`** — transforma o estado em números:
```
φ = [1.0, posX_bola, posY_bola, distância_bola_barra, índice_ação]
     ↑         ↑          ↑              ↑                   ↑
   bias    onde está   altura da    quão longe está       0=esq
                        bola        a barrinha            1=parado
                                                          2=dir
```

**`escolherAcao`** — política Epsilon-Greedy:
```
Gera número aleatório entre 0 e 1
├── Se < ε (ex: 0.10) → EXPLORAÇÃO: escolhe ação aleatória
└── Se ≥ ε (ex: 0.90) → EXPLOTAÇÃO: escolhe a melhor ação conhecida
```
Isso garante que o agente explore novas estratégias enquanto ainda aproveita o que já aprendeu.

**`treinar`** — atualiza os pesos após cada passo:
```
1. Calcula o erro TD (Temporal Difference):
   erro = (recompensa + γ × melhor_Q_próximo_estado) - Q_atual

2. Atualiza os pesos:
   θ ← θ + α × erro × φ(s,a)
```
Se o agente errou (recebeu menos do que esperava), os pesos são ajustados para evitar aquela decisão no futuro. Se acertou, os pesos reforçam aquela decisão.

---

### 4. Main.hs — O Ponto de Entrada

Orquestra tudo e define os parâmetros iniciais do treino.

**Estado inicial:**
```
Bola:     posição (5, 5), velocidade (0.1, -0.2)  ← caindo levemente à direita
Barrinha: posição x=5                              ← no centro
Pesos θ:  [0, 0, 0, 0, 0]                         ← agente não sabe nada ainda
ε:        0.1   → 10% de chance de explorar
α:        0.01  → aprende devagar (estável)
γ:        0.95  → valoriza muito as recompensas futuras
```

**Loop principal (repetido 1000 vezes):**
```
1. Observa o estado atual do campo
2. Escolhe uma ação (epsilon-greedy)
3. Aplica a ação → obtém novo estado e recompensa
4. Treina: atualiza os pesos θ com o que aprendeu
5. Imprime: "Bola em: (x, y) | Reward: r"
```

---

## O que aparece no Terminal

Ao rodar `cabal run`, a seguinte sequência acontece:

**Início:**
```
--- Q-Bar Challenge: Início do Treino ---
```
O mundo foi criado e o treino começa.

---

**Bola descendo:**
```
Bola em: (5.10, 4.80) | Reward: -1.00
Bola em: (5.20, 4.60) | Reward: -1.00
Bola em: (5.30, 4.40) | Reward: -1.00
```
A bola cai (`y` diminui). O agente recebe -1 a cada passo — ainda sem evento especial.

---

**Gol sofrido:**
```
Bola em: (7.40, 0.20) | Reward: -1.00   ← bola quase na barrinha
Bola em: (5.00, 5.00) | Reward: -100.00 ← GOL! bola voltou ao centro
```
A barrinha estava longe quando a bola chegou em `y=0`. Punição de -100 e reinício do episódio.

---

**Rebote no teto:**
```
Bola em: (7.40, 9.80) | Reward: -1.00
Bola em: (7.50, 10.00) | Reward: -1.00  ← tocou o teto
Bola em: (7.60, 9.80)  | Reward: -1.00  ← rebateu, agora desce
```
A bola chegou em `y=10` e voltou — a velocidade vertical (`vy`) foi invertida.

---

**Defesa bem-sucedida (após muitas iterações):**
```
Bola em: (5.10, 0.20) | Reward: -1.00
Bola em: (5.10, 0.00) | Reward: 10.00  ← DEFESA! barrinha estava próxima
Bola em: (5.10, 0.20) | Reward: -1.00  ← bola rebateu pra cima
```
O agente moveu a barrinha para perto da bola — recompensa de +10.

---

**Pesos finais:**
```
[-1.97, -6.39, 4.53, 4.27, 0.48]
```
Ao final das 1000 iterações, os pesos `θ` aprendidos são impressos. Cada número representa o quanto aquela feature influenciou as decisões do agente ao longo do treino.

---

## Como Rodar

### Pré-requisitos (Windows)

Antes de rodar pela primeira vez, é necessário instalar três coisas:

**1. GHCup** — instala o compilador Haskell (GHC), o gerenciador de pacotes (Cabal) e o MSYS2.
Acesse `https://www.haskell.org/ghcup/` e siga as instruções para Windows.

**2. OpenBLAS** — biblioteca de álgebra linear usada pelo `hmatrix`. Após instalar o GHCup, abra um terminal e execute:

```
C:\ghcup\msys64\usr\bin\pacman.exe -Sy --noconfirm mingw-w64-x86_64-openblas
```

**3. freeglut** — biblioteca de janelas usada pelo `gloss` para abrir a interface gráfica. Execute:

```
C:\ghcup\msys64\usr\bin\pacman.exe -S --noconfirm mingw-w64-x86_64-freeglut
```

Após instalar o freeglut, é necessário criar uma cópia do arquivo com o nome que o Gloss espera. Execute no PowerShell:

```
Copy-Item "C:\ghcup\msys64\mingw64\bin\libfreeglut.dll" "C:\ghcup\msys64\mingw64\bin\freeglut.dll"
```

Feito isso, feche e reabra o terminal para garantir que o PATH foi atualizado.

---

### Executando o projeto

Abra um terminal na pasta do projeto e escolha um dos dois modos:

**Modo Visual** — abre uma janela gráfica com animação em tempo real:
```
cabal run qbarchallenge -- visual
```

**Modo Terminal** — roda 1000 iterações e imprime cada passo na tela:
```
cabal run qbarchallenge -- terminal
```

Se nenhum argumento for passado, o programa exibe as opções disponíveis:
```
cabal run qbarchallenge
```

---

### Ajustando a velocidade de aprendizado (Modo Visual)

No arquivo `Visual.hs`, a variável `passosPorFrame` controla quantas iterações de Q-learning ocorrem por quadro:

```haskell
passosPorFrame :: Int
passosPorFrame = 10  -- aumente para aprender mais rápido
```

| Valor | Efeito |
|-------|--------|
| `1`   | Animação fluida, aprendizado lento |
| `10`  | Equilíbrio entre fluidez e velocidade (padrão) |
| `50`  | Aprendizado rápido, animação um pouco travada |
| `100` | Aprendizado muito rápido, bola "pula" posições |

---

## Resumo do Fluxo Completo

```
main
 └── execStateT (replicateM_ 1000 loopDeJogo) mundoInicial
      └── loopDeJogo  (repete 1000 vezes)
           ├── escolherAcao  [Brain.hs] → decide Esquerda/Parado/Direita
           ├── proximoEstado [Physics.hs] → move bola, calcula recompensa
           ├── treinar       [Brain.hs] → atualiza pesos θ
           └── printf        [Main.hs] → imprime posição e recompensa
```
