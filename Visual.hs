module Visual where

import Graphics.Gloss
import Graphics.Gloss.Data.ViewPort (ViewPort)
import Types
import Game

escala :: Float
escala = 58.0

toTela :: Double -> Float
toTela v = (realToFrac v - 5.0) * escala

type Model = (Mundo, Double)

desenhar :: Model -> Picture
desenhar (mundo, ultimoR) = pictures
    [ translate 0 (-25) jogo
    , painel
    ]
  where
    c        = campo mundo
    (bx, by) = bolaPos c

    fundo    = color campoVerde $ rectangleSolid (10 * escala) (10 * escala)
    bordas   = color (greyN 0.6) $ rectangleWire (10 * escala) (10 * escala)
    bola     = translate (toTela bx) (toTela by) $ color corBola $ circleSolid 9
    barrinha = translate (toTela (barraX c)) (toTela 0 + 7)
             $ color azul $ rectangleSolid 120 14

    jogo = pictures [fundo, bordas, bola, barrinha]

    -- Cores
    campoVerde = makeColorI 25 100 25 255
    azul       = makeColorI 60 140 255 255

    corBola
        | ultimoR >= 10  = makeColorI 50 255 80 255   -- verde: defesa
        | ultimoR <= -50 = makeColorI 255 70 70 255   -- vermelho: gol
        | otherwise      = white

    -- Painel de informações acima do campo
    painel = translate (-285) 295 $ pictures
        [ scale 0.14 0.14 $ color white
            $ text ("Gols sofridos: " ++ show (gols c))
        , translate 370 0 $ scale 0.14 0.14 $ color corReward
            $ text ("Reward: " ++ mostrarR ultimoR)
        ]

    corReward
        | ultimoR >= 10  = makeColorI 50 255 80 255
        | ultimoR <= -50 = makeColorI 255 70 70 255
        | otherwise      = greyN 0.7

    mostrarR r
        | r > 0     = "+" ++ show (round r :: Int)
        | otherwise = show (round r :: Int)

passosPorFrame :: Int
passosPorFrame = 50 -- Aumentar para acelerar o jogo, diminuir para desacelerar

avancar :: ViewPort -> Float -> Model -> Model
avancar _ _ (mundo, _) = foldl (\(m, _) _ -> let (r, m') = passoDeJogo m in (m', r))
                                (mundo, -1.0)
                                [1..passosPorFrame]

rodarVisual :: Mundo -> IO ()
rodarVisual mundoInicial = simulate
    (InWindow "Q-Bar Challenge" (630, 680) (150, 50))
    (makeColorI 15 15 15 255)
    60
    (mundoInicial, -1.0)
    desenhar
    avancar
