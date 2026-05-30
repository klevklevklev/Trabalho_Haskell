module Physics where

import Types

proximoEstado :: Campo -> Jogada -> (Campo, Double)
proximoEstado c acao =
    let (bx, by) = bolaPos c
        (vx, vy) = bolaVel c
        novaBarraX = aplicarMovimento (barraX c) acao

        -- Move a bola
        bx1 = bx + vx
        by1 = by + vy

        -- Rebate nas paredes laterais (x: 0 a 10)
        (bx2, vx2)
            | bx1 < 0  = (-bx1,     -vx)
            | bx1 > 10 = (20 - bx1, -vx)
            | otherwise = (bx1, vx)

        -- Rebate na parede superior (y = 10)
        (by2, vy2)
            | by1 > 10 = (20 - by1, -vy)
            | otherwise = (by1, vy)

        -- Interação com a barrinha (y <= 0)
        defended = by2 <= 0 && abs (bx2 - novaBarraX) < 1.0
        gol      = by2 <= 0 && not defended

        recompensa
            | defended  =  10.0
            | gol       = -100.0
            | otherwise =  -1.0

        -- Defesa: rebate a bola pra cima; Gol: reseta ao centro
        (bolaPosFinal, bolaVelFinal, golsNovos)
            | defended  = ((bx2, 0), (vx2, abs vy2), gols c)
            | gol       = ((5,   5), (0.1, abs vy),  gols c + 1)
            | otherwise = ((bx2, by2), (vx2, vy2),   gols c)

    in ( c { bolaPos = bolaPosFinal
           , bolaVel = bolaVelFinal
           , barraX  = novaBarraX
           , gols    = golsNovos
           }
       , recompensa
       )

aplicarMovimento :: Double -> Jogada -> Double
aplicarMovimento x Esquerda = max 0  (x - 0.5)
aplicarMovimento x Direita  = min 10 (x + 0.5)
aplicarMovimento x _        = x
