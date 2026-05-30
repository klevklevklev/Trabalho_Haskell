module Brain where

import Types
import Numeric.LinearAlgebra
import System.Random
import Control.Monad.State

-- | Etapa 2: Extração de Features (φ)
extrairFeatures :: Campo -> Jogada -> Vector Double
extrairFeatures c acao = 
    let (bx, by) = bolaPos c
        dist = bx - barraX c
    in fromList [1.0, bx, by, dist, fromIntegral (fromEnum acao)]

-- | Aproximação Linear: Q(s,a) = φ(s,a) · θ
estimarQ :: Campo -> Jogada -> Vector Double -> Double
estimarQ c a theta = extrairFeatures c a <.> theta

-- | Etapa 3: Política Epsilon-Greedy
escolherAcao :: Jogo Jogada
escolherAcao = do
    m <- get
    let cState = craque m
    let (prob, novoGen) = randomR (0.0, 1.0) (gen cState)
    put m { craque = cState { gen = novoGen } }
    
    if prob < epsilon cState
        then return $ toEnum (fst $ randomR (0, 2) novoGen) -- Exploração
        else return $ acaoGulosa (campo m) (pesos cState) -- Explotação

acaoGulosa :: Campo -> Vector Double -> Jogada
acaoGulosa c theta = 
    let acoes = [minBound .. maxBound]
        valoresQ = [ (a, estimarQ c a theta) | a <- acoes ]
    in fst $ maximumBy (\(_, q1) (_, q2) -> compare q1 q2) valoresQ

-- | Etapa 5: Atualização de Pesos (SGD para Linear Q-Learning)
treinar :: Campo -> Jogada -> Double -> Campo -> Jogo ()
treinar s a r s' = do
    m <- get
    let cState = craque m
    let th = pesos cState
    let phi = extrairFeatures s a
    
    -- Alvo TD: r + γ * max_a' Q(s', a', θ)
    let maxQNext = maximum [ estimarQ s' a' th | a' <- [minBound .. maxBound] ]
    let alvo = r + (gamma cState * maxQNext)
    let tdError = alvo - estimarQ s a th
    
    -- Regra de atualização: θ ← θ + α * TD_Error * φ(s,a)
    let novosPesos = th + scalar (alpha cState * tdError) * phi
    put m { craque = cState { pesos = novosPesos } }