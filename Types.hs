module Types where

import Control.Monad.State
import Numeric.LinearAlgebra -- hmatrix
import System.Random

-- | Estado físico: Bola e Barrinha
data Campo = Campo 
    { bolaPos :: (Double, Double)
    , bolaVel :: (Double, Double)
    , barraX  :: Double 
    , gols    :: Int
    } deriving (Show)

-- | O Craque: Pesos (θ) e Parâmetros de Treino
data CraqueState = CraqueState
    { pesos   :: Vector Double -- Vetor θ para aproximação linear
    , epsilon :: Double        -- Taxa de exploração
    , alpha   :: Double        -- Taxa de aprendizado (Step Size)
    , gamma   :: Double        -- Fator de desconto
    , gen     :: StdGen        -- Gerador de números aleatórios
    } deriving (Show)

data Mundo = Mundo { campo :: Campo, craque :: CraqueState } deriving (Show)

-- | Ações: Correr Esquerda, Parar, Correr Direita
data Jogada = Esquerda | Parado | Direita 
    deriving (Enum, Bounded, Eq, Show)

type Jogo a = State Mundo a