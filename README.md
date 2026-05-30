Como Rodar
Pré-requisitos (Windows)

Antes de rodar pela primeira vez, é necessário instalar três coisas:

1. GHCup — instala o compilador Haskell (GHC), o gerenciador de pacotes (Cabal) e o MSYS2. Acesse https://www.haskell.org/ghcup/ e siga as instruções para Windows.

2. OpenBLAS — biblioteca de álgebra linear usada pelo hmatrix. Após instalar o GHCup, abra um terminal e execute:

C:\ghcup\msys64\usr\bin\pacman.exe -Sy --noconfirm mingw-w64-x86_64-openblas

3. freeglut — biblioteca de janelas usada pelo gloss para abrir a interface gráfica. Execute:

C:\ghcup\msys64\usr\bin\pacman.exe -S --noconfirm mingw-w64-x86_64-freeglut

Após instalar o freeglut, é necessário criar uma cópia do arquivo com o nome que o Gloss espera. Execute no PowerShell:

Copy-Item "C:\ghcup\msys64\mingw64\bin\libfreeglut.dll" "C:\ghcup\msys64\mingw64\bin\freeglut.dll"

Feito isso, feche e reabra o terminal para garantir que o PATH foi atualizado.
Executando o projeto

Abra um terminal na pasta do projeto e escolha um dos dois modos:

Modo Visual — abre uma janela gráfica com animação em tempo real:

cabal run qbarchallenge -- visual

Modo Terminal — roda 1000 iterações e imprime cada passo na tela:

cabal run qbarchallenge -- terminal


