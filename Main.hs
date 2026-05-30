module Main where

import Numeric.LinearAlgebra (konst)
import System.Random
import System.Environment (getArgs)
import Types
import Visual
import Terminal

mundoInicial :: StdGen -> Mundo
mundoInicial g = Mundo
    (Campo (5, 5) (0.1, -0.2) 5 0)
    (CraqueState (konst 0.0 5) 0.1 0.01 0.95 g)

main :: IO ()
main = do
    args <- getArgs
    g    <- newStdGen
    case args of
        ["visual"  ] -> rodarVisual   (mundoInicial g)
        ["terminal"] -> rodarTerminal (mundoInicial g)
        _            -> do
            putStrLn "Uso: cabal run qbarchallenge -- <modo>"
            putStrLn "  visual    → abre janela gráfica com Gloss"
            putStrLn "  terminal  → roda no terminal com saída de texto"
