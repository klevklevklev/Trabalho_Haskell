module Terminal where

import Numeric (showFFloat)
import Numeric.LinearAlgebra (toList)
import Types
import Game

iteracoes :: Int
iteracoes = 1000

fmt2 :: Double -> String
fmt2 x = showFFloat (Just 2) x ""

rodarTerminal :: Mundo -> IO ()
rodarTerminal mundoInicial = do
    putStrLn "=== Q-Bar Challenge -- Modo Terminal ==="
    putStrLn $ "Rodando " ++ show iteracoes ++ " iterações...\n"
    mundoFinal <- loop iteracoes mundoInicial
    putStrLn "\n=== Pesos aprendidos (θ) ==="
    mapM_ (\(i, w) -> putStrLn $ "  θ" ++ show i ++ " = " ++ fmt2 w)
          (zip [0..] (toList $ pesos $ craque mundoFinal))
    putStrLn $ "\nGols sofridos: " ++ show (gols $ campo mundoFinal)
  where
    loop 0 m = return m
    loop n m = do
        let (r, m') = passoDeJogo m
        let c = campo m'
        let (bx, by) = bolaPos c
        putStrLn $ "Bola em: (" ++ fmt2 bx ++ ", " ++ fmt2 by ++ ")"
               ++ " | Reward: " ++ fmt2 r
               ++ " | Gols: "   ++ show (gols c)
        loop (n - 1) m'
