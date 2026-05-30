module Physics where

import Types

-- | Calcula a física da bola e colisão com a barrinha
proximoEstado :: Campo -> Jogada -> (Campo, Double)
proximoEstado c acao = 
    let (bx, by) = bolaPos c
        (vx, vy) = bolaVel c
        novaBarraX = aplicarMovimento (barraX c) acao
        -- Integração física simples (Euler)
        novaBolaPos = (bx + vx, by + vy)
        recompensa = calcularRecompensa c novaBolaPos novaBarraX
    in (c { bolaPos = novaBolaPos, barraX = novaBarraX }, recompensa)

aplicarMovimento :: Double -> Jogada -> Double
aplicarMovimento x Esquerda = max 0 (x - 0.5)
aplicarMovimento x Direita  = min 10 (x + 0.5)
aplicarMovimento x _        = x

calcularRecompensa :: Campo -> (Double, Double) -> Double -> Double
calcularRecompensa _ (_, by) bX 
    | by <= 0 && abs (fst (bolaPos _) - bX) < 1.0 = 10.0  -- Defesa: +10 pontos
    | by < -0.5 = -100.0                                 -- Gol Sofrido: -100 pontos
    | otherwise = -1.0                                   -- Penalidade 