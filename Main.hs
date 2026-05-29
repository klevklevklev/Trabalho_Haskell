import Control.Monad.State
import Numeric.LinearAlgebra -- Da biblioteca hmatrix [3]
import System.Random         -- Para a política epsilon-greedy [4]

-- | Posição no campo (x, y)
type Pos = (Double, Double)

-- | O "Campo": Estado físico do jogo
data Campo = Campo 
    { bolaPos    :: Pos
    , bolaVel    :: Pos
    , barraX     :: Double -- Posição horizontal da nossa barrinha
    , placar     :: Int
    } deriving (Show)

-- | O "Craque": Pesos aprendidos pelo Reinforcement Learning
data CraqueState = CraqueState
    { pesos    :: Vector Double -- Vetor theta (θ) da aproximação linear [5]
    , epsilon  :: Double        -- Taxa de exploração [6]
    } deriving (Show)

-- | O "Mundo": Estado completo para a Mônada
data Mundo = Mundo 
    { estadoJogo :: Campo
    , cérebro    :: CraqueState
    } deriving (Show)

-- | Nossa Mônada de Estado personalizada [7, 8]
type Jogo = StateT Mundo IO

-- | Ações disponíveis para a barrinha
data Jogada = CorrerEsquerda | FicarParado | CorrerDireita 
    deriving (Enum, Bounded, Eq, Show)

-- | Converte o estado atual em características táticas (Features φ) [5, 9]
extrairFeatures :: Campo -> Jogada -> Vector Double
extrairFeatures campo acao = 
    let (bx, by) = bolaPos campo
        distancia = bx - barraX campo
    in fromList [1.0, bx, by, distancia, fromIntegral (fromEnum acao)]

-- | Calcula o Valor Q aproximado: Q(s,a) = φ(s,a)^T * θ [5, 10]
estimarValorQ :: Campo -> Jogada -> Vector Double -> Double
estimarValorQ campo acao theta = 
    let phi = extrairFeatures campo acao
    in phi <.> theta -- Produto escalar usando hmatrix

-- | Estado inicial do campeonato
mundoInicial :: Mundo
mundoInicial = Mundo
    { estadoJogo = Campo (5, 5) (0.1, 0.2) 5 0
    , cérebro    = CraqueState (konst 0.1 5) 0.1 -- 5 features iniciais
    }

main :: IO ()
main = do
    putStrLn "--- Início da Barrinha Cup 2026 ---"
    -- Executa o jogo começando do vestiário [11, 12]
    final <- execStateT loopDeJogo mundoInicial
    print final

-- | O loop principal que será o coração do seu projeto [13]
loopDeJogo :: Jogo ()
loopDeJogo = do
    mundo <- get
    liftIO $ putStrLn "Bola em jogo..."
    -- Aqui entrará a lógica de:
    -- 1. Craque escolhe jogada (epsilon-greedy)
    -- 2. Juiz calcula física e recompensa
    -- 3. Treinador atualiza pesos (weights)
    -- 4. Repete ou termina se sofrer gol
    return ()
