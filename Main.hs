module Main where

import Control.Monad.State
import Types
import Physics
import Brain
import System.Random

main :: IO ()
main = do
    putStrLn "--- Q-Bar Challenge: Início do Treino ---"
    g <- newStdGen
    let craqueInicial = CraqueState (konst 0.0 5) 0.1 0.01 0.95 g
    let mundoInicial  = Mundo (Campo (5,5) (0.1, -0.2) 5 0) craqueInicial
    
    final <- execStateT (replicateM_ 1000 loopDeJogo) mundoInicial
    print (pesos $ craque final)

loopDeJogo :: Jogo ()
loopDeJogo = do
    m <- get
    let s = campo m
    a <- escolherAcao
    let (s', r) = proximoEstado s a
    
    treinar s a r s' -- O Treinador atualiza o craque
    modify (\mundo -> mundo { campo = s' })
    
    liftIO $ putStrLn $ "Bola em: " ++ show (bolaPos s') ++ " | Reward: " ++ show r