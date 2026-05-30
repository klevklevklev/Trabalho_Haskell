module Game where

import Types
import Physics
import Brain
import Control.Monad.State

-- | Executa um passo completo: escolhe ação, avança física, treina
passoDeJogo :: Mundo -> (Double, Mundo)
passoDeJogo mundo = runState passo mundo
  where
    passo = do
        m <- get
        let s = campo m
        a <- escolherAcao
        let (s', r) = proximoEstado s a
        treinar s a r s'
        modify (\w -> w { campo = s' })
        return r
