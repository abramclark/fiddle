import Mandelbrot
import Prelude hiding (foldr,foldl,length,take,iterate,takeWhile,map,sum,(++))
import Data.List.Stream;
import Data.Complex; import Control.Monad;
import Data.Time.Clock

main = do
  start <- getCurrentTime
  putStrLn $ show $ sum $ mandelbrotSet (-0.25) 0 2 512
  end <- getCurrentTime
  putStrLn $ "Time to render and sum was " ++ show (end `diffUTCTime` start)
