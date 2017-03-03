import System.IO
import Data.Char
import System.Random

main = do
  let static = map fromIntegral $ take 250000 $ (randomRs (0,1) (mkStdGen 1) :: [Int])
  h <- openFile "random_junk" WriteMode
  mapM_ (hPutChar h) $ map (chr . (+97)) static
  hClose h
