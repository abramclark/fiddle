import Data.Word
import Data.Char
import System.IO
import System.Environment
import Foreign.Marshal.Array
import Mandelbrot

type Rat = Float

main = do
  args <- getArgs
  let size = read $ args !! 0
  let picture = mandelbrotSet (-0.25) 0 2 size
  withFile "out.pgm" WriteMode $ \h -> do
    hPutStrLn h "P5"
    hPrint h size
    hPrint h size
    hPrint h 50
    hPutStr h $ map (chr . fromIntegral) picture
