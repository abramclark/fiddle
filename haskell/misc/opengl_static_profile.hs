import System.Random.Mersenne
import Control.Monad.State
import System.Environment
import Data.Word

funkyRand :: Double -> (Word8, Double)
funkyRand !x = -- (x, mod (x + 1) 251)
    let !n = x * x
        (_, s) = properFraction n
      in (floor $ s * 255, if x > 50000 then s + 13478 else s + x)

main = do
    [method, count] <- getArgs
    let c = read count :: Int
    case method of
        "f" -> do
           let (static, seed) = runState (replicateM c (State funkyRand)) 92357.1234123
           mapM_ print static
           putStrLn $ "seed: " ++ (show seed)
        "m" -> do
           mtgen <- newMTGen Nothing
           static <- randoms mtgen :: IO [Word8]
           mapM_ print (take c static)
